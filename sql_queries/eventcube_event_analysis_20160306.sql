drop table if exists jt.events;
create table jt.events as
select w.week_starting
     , e.*
from eventcube.eventcubesummary e
join (select wk.*
      from dashboard.calendar_wk wk
      join (select min(week_starting) as firstweek
                 , max(week_starting) as lastweek
            from dashboard.calendar_wk
            /*where date <= :END and date >= :START*/) weeklimit
      on wk.week_starting >= weeklimit.firstweek and wk.week_starting <= weeklimit.lastweek) w
on e.startdate = w.date
and e.enddate <= current_date - 1
left join eventcube.testevents t
on e.applicationid = t.applicationid
where t.applicationid is null
;



select week_starting
     , count(*) as eventcnt
from jt.events
where startdate >= '2015-02-09'
group by 1
order by 1;

select extract(year from startdate)::int * 100 + extract(month from startdate)::int as yearmonth
     , count(*) as eventcnt
from jt.events
where startdate >= '2015-02-09'
group by 1
order by 1;



select applicationid
from authdb_applications
except
select applicationid
from eventcube.eventcubesummary;

-- 903 (applicationid)
-- 669 (eventcube)

-- 243


select applicationid
from eventcube.eventcubesummary
except
select applicationid
from authdb_applications;
-- 0 (all events in eventcubesummary are in applications)


select *
from eventcube.eventcubesummary
where applicationid = 'A1595770-FF78-4518-8286-16C950260E6E';


select count(*)
     -- 5809
     , count(case when startdate is null then 1 else null end)
     -- 3027
from authdb_applications
where applicationid in (
select distinct applicationid
from authdb_applications
except
select distinct applicationid
from eventcube.eventcubesummary);


select count(*)
     -- 2782
     , count(case when startdate < current_date - interval '13' month then 1 else null end)
     -- 2294
from authdb_applications
where applicationid in (
select distinct applicationid
from authdb_applications
except
select distinct applicationid
from eventcube.eventcubesummary)
and startdate is not null;


select *
from authdb_applications
where applicationid in (
select distinct applicationid
from authdb_applications
except
select distinct applicationid
from eventcube.eventcubesummary)
and startdate is not null
and startdate >= current_date - interval '13' month;
-- 488


-- 384 (test events)
select *
from eventcube.testevents
where applicationid in (select applicationid
from authdb_applications
where applicationid in (
select distinct applicationid
from authdb_applications
except
select distinct applicationid
from eventcube.eventcubesummary)
and startdate is not null
and startdate >= current_date - interval '13' month);


select count(*)
     , count(distinct applicationid)
     , count(case when eventcube then 1 else null end)

from (select a.*
           , case
                when b.applicationid is not null then true
                else false
             end as eventcube
           , case
                when c.applicationid is not null then true
                else false
             end as eventcubetestevent 
      from authdb_applications a
      left join eventcube.eventcubesummary b
      on a.applicationid = b.applicationid
      left join eventcube.testevents c
      on a.applicationid = c.applicationid) a
order by startdate, enddate, applicationid;