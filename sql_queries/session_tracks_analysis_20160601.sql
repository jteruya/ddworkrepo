-- Event Level Temporary Table
create temporary table sessiontrackevents as
select ecs.applicationid as "Application ID"
     , ecs.name as "Event Name"
     , ecs.startdate as "Event Start Date"
     , ecs.enddate as "Event End Date"
     , ecs.eventtype as "Event Type"
     , case
         when ecs.openevent = 0 then 'Closed Reg Event'
         else 'Open Reg Event'
       end as "Event Registration Type"
     , count(*) as "Session Count"
     , count(case when filters.itemid is not null then 1 else null end) as "Session w/ Track Count"
     , count(case when filters.itemid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Session w/Track %"
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
join ratings_item item
on ecs.applicationid = item.applicationid
join ratings_topic topic
on item.parenttopicid = topic.topicid
left join (select distinct mappings.itemid
           from ratings_itemfiltermappings mappings
           join ratings_filters filters
           on mappings.filterid = filters.filterid
           join ratings_filtergroups fg
           on filters.filtergroupid = fg.filtergroupid
           join ratings_topic topic
           on fg.topicid = topic.topicid
           where fg.typeid = 0
           and mappings.isdisabled = false
           and filters.isdisabled = false
           and topic.ishidden = false
           and fg.isdisabled = false
           and topic.isdisabled = 0
           and topic.listtypeid = 2) filters
on filters.itemid = item.itemid
where ecs.startdate >= '2016-01-01'
and ecs.enddate < current_date
and item.isdisabled = 0
and topic.isdisabled = 0
and topic.listtypeid = 2
and topic.ishidden = false
and te.applicationid is null
group by 1,2,3,4,5,6
order by 3,4,1
;

-- Get Event Level Stats
select *
from sessiontrackevents
;


-- Get Overall Stats
select count(*) as "Total Events Count"
     , count(case when "Session w/ Track Count" > 0 then 1 else null end) as "Events w/ Session Tracks Count"
     , count(case when "Session w/ Track Count" > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Events w/ Session Tracks %"
     , sum("Session Count") as "Total Session Count"
     , sum("Session w/ Track Count") as "Total Session w/ Session Track Count"
     , sum("Session w/ Track Count")::decimal(12,4)/sum("Session Count")::decimal(12,4) as "Total Session w/ Session Track %"
     , sum(case when "Session w/ Track Count" > 0 then "Session Count" else 0 end) as "Total Session Count (Event has Session Tracks)"
     , sum(case when "Session w/ Track Count" > 0 then "Session w/ Track Count" else 0 end) as "Total Session w/ Session Track Count (Event has Session Tracks)"
     , sum(case when "Session w/ Track Count" > 0 then "Session w/ Track Count" else 0 end)::decimal(12,4)/sum(case when "Session w/ Track Count" > 0 then "Session Count" else 0 end)::decimal(12,4) as "Total Session w/ Session Track % (Event has Session Tracks)"
from sessiontrackevents
