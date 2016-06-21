-- All Survey/ItemId Combinations
create temporary table allsurveys as
select distinct surveyid
     , itemid
     , applicationid
from public.ratings_surveys
where ispoll = false
and isdisabled = false
union
select distinct a.surveyid
     , b.itemid
     , a.applicationid
from public.ratings_surveys a
join public.ratings_surveymappings b
on a.surveyid = b.surveyid
where b.isdisabled = false
and a.isdisabled = false
and a.ispoll = false
;

-- Pull Event Survey Counts
create temporary table alleventsurveys as
select ecs.applicationid
     , ecs.startdate
     , ecs.enddate
     , count(distinct surveyid) as "Total Survey Count"
     , count(case when items = 0 then surveyid else null end) as "Total Global Survey Count"
     , count(case when items > 0 then surveyid else null end) as "Total Content Survey Count"
     , count(case when items = 0 then surveyid else null end)::decimal(12,4)/count(distinct surveyid)::decimal(12,4) as "% Global Survey"
     , count(case when items > 0 then surveyid else null end)::decimal(12,4)/count(distinct surveyid)::decimal(12,4) as "% Content Survey"
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
join (select surveyid
           , applicationid
           , count(case when itemid is not null then 1 else null end) as items
      from allsurveys
      --where applicationid = '539AF0AE-DCF9-4BB5-BC85-AC35E70F1798'
      group by 1,2) surveys
on ecs.applicationid = surveys.applicationid
where te.applicationid is null
and ecs.startdate >= '2016-01-01'
--and ecs.applicationid = '32CD7D04-001B-4846-8D5A-9BB7B1D62AD7'
group by 1,2,3
order by 2,3
;




select count(*) as "Event Count"
     , avg("Total Survey Count") as "Avg Total Survey Count"
     , avg("Total Global Survey Count") as "Avg Total Global Survey Count"
     , avg("Total Content Survey Count") as "Avg Total Content Survey Count"
     , percentile_cont(0.5) within group (order by "Total Survey Count")
     , percentile_cont(0.5) within group (order by "Total Global Survey Count")
     , percentile_cont(0.5) within group (order by "Total Content Survey Count")
     , avg("% Global Survey")
     , avg("% Content Survey")
     , percentile_cont(0.5) within group (order by "% Global Survey")
     , percentile_cont(0.5) within group (order by "% Content Survey")
from alleventsurveys
;




select *
from alleventsurveys
;




