select distinct ecs.applicationid as "Application ID"
     , ecs.name as "Event Name"
     , ecs.startdate as "Event Start Date"
     , ecs.enddate as "Event End Date"
     , case
         when openevent = 1 then true
         else false
       end as "Open Reg Event?"
     , acgi.title as "Channel MicroApp Name"
from ratings_applicationconfiggriditems acgi
join (select a.*
      from eventcube.eventcubesummary a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null) ecs
on acgi.applicationid = ecs.applicationid
where typeid = 206
and selected = true
order by 3,4;