select count(*) as totalcnt
     , count(case when b.applicationid is not null then 1 else null end) as testeventcnt
     , count(case when b.applicationid is null and enddate < '2016-04-04' then 1 else null end) as endedevents
     , count(case when b.applicationid is null and enddate >= '2016-04-04' then 1 else null end) as eventsstillgoing
     , count(case when b.applicationid is null and enddate < '2016-04-04' and a.openevent = 0 then 1 else null end) as endeventsclosed
     , count(case when b.applicationid is null and enddate < '2016-04-04' and a.openevent = 1 then 1 else null end) as endeventsopen
     , count(case when b.applicationid is null and enddate >= '2016-04-04' and a.openevent = 0 then 1 else null end) as eventsstillgoingclosed
     , count(case when b.applicationid is null and enddate >= '2016-04-04' and a.openevent = 1 then 1 else null end) as eventsstillgoingopen     
from eventcube.eventcubesummary a
left join eventcube.testevents b
on a.applicationid = b.applicationid
where startdate >= '2016-03-28'
and startdate < '2016-04-04';


select count(*) as totalcnt
     , count(case when b.applicationid is not null then 1 else null end) as testeventcnt
     , count(case when b.applicationid is null and enddate < '2016-04-04' then 1 else null end) as endedevents
     , count(case when b.applicationid is null and enddate >= '2016-04-04' then 1 else null end) as eventsstillgoing
     , count(case when b.applicationid is null and enddate < '2016-04-04' and a.canregister = false then 1 else null end) as endeventsclosed
     , count(case when b.applicationid is null and enddate < '2016-04-04' and a.canregister = true then 1 else null end) as endeventsopen
     , count(case when b.applicationid is null and enddate >= '2016-04-04' and a.canregister = false then 1 else null end) as eventsstillgoingclosed
     , count(case when b.applicationid is null and enddate >= '2016-04-04' and a.canregister = true then 1 else null end) as eventsstillgoingopen     
from authdb_applications a
left join eventcube.testevents b
on a.applicationid = b.applicationid
where startdate >= '2016-03-28'
and startdate < '2016-04-04'
and startdate is not null
and enddate is not null;




select a.*
from authdb_applications a
join eventcube.testevents b
on a.applicationid = b.applicationid
where a.applicationid not in (select a.applicationid 
                                 from eventcube.eventcubesummary a
                                 join eventcube.testevents b
                                 on a.applicationid = b.applicationid
                                 where startdate >= '2016-03-28'
                                 and startdate < '2016-04-04')
and startdate >= '2016-03-28'
and startdate < '2016-04-04';

