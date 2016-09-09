-- Item Name Stats
select count(*)
     , count(distinct applicationid)
     , avg(len)
     , percentile_cont(0.5) within group (order by len)
     , max(len)
from (
select items.applicationid
     , char_length(items.name) as len
from ratings_item items
join ratings_topic topics
on items.parenttopicid = topics.topicid
where items.applicationid in (
select ecs.applicationid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ecs.startdate >= '2016-01-01'
and ecs.enddate < current_date
)
and items.isdisabled = 0
and topics.isdisabled = 0
and topics.ishidden = false
and topics.listtypeid = 3
)a
;

-- Check on Item with 216 Chars
select items.applicationid
     , items.itemid
     , items.name
     , items.shortname
     , items.parenttopicid
     , char_length(items.name) as len
     , char_length(items.shortname) as shortlen
from ratings_item items
join ratings_topic topics
on items.parenttopicid = topics.topicid
where items.applicationid in (
select ecs.applicationid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ecs.startdate >= '2016-01-01'
and ecs.enddate < current_date
)
and items.isdisabled = 0
and topics.isdisabled = 0
and topics.ishidden = false
and topics.listtypeid = 3
and char_length(items.name) = 216
;





-- Get boothdetails data
drop table jt.ratings_boothdetails;
create table jt.ratings_boothdetails (
        boothid bigint,
        boothnumber varchar,
        --lefty numeric,
        --top numeric,
        width numeric,
        height numeric,
        level int,
        applicationid varchar)
;

-- Get booth number stats
select count(*)
     , count(distinct applicationid)
     , avg(len)
     , percentile_cont(0.5) within group (order by len)
     , max(len)
from (
select applicationid
     , char_length(trim(boothnumber)) as len
from jt.ratings_boothdetails
where upper(applicationid) in (
select ecs.applicationid
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ecs.startdate >= '2016-01-01'
and ecs.enddate < current_date
))a
where len > 0 ;



select *
from jt.ratings_boothdetails
where boothnumber = ''
;


