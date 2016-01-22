drop table if exists jt.q3_session_start;
create table jt.q3_session_start as
select s.application_id
           , a.name as event_name
           , a.startdate as event_start_date
           , a.enddate as event_end_date
           , s.user_id
           , s.start_date
           , s.batch_id
           , s.row_id
      from fact_sessions s
      join authdb_applications a
      on s.application_id = lower(a.applicationid)
      where s.metrics_type_id = 1
      and a.startdate >= '2015-07-01'
      and a.enddate < current_date;

drop table if exists jt.q3_session_end;
create table jt.q3_session_end as
select s.application_id
           , a.name as event_name
           , a.startdate as event_start_date
           , a.enddate as event_end_date
           , s.user_id
           , s.end_date
           , s.batch_id
           , s.row_id
      from fact_sessions s
      join authdb_applications a
      on s.application_id = lower(a.applicationid)
      where metrics_type_id = 2
      and a.startdate >= '2015-07-01'
      and a.enddate < current_date;


drop table if exists jt.q3_sessions;
create table jt.q3_sessions as
select s.*
     , e.end_date
from jt.q3_session_start s
join jt.q3_session_end e
on s.application_id = e.application_id 
and s.user_id = e.user_id
and s.batch_id = e.batch_id 
and s.row_id = e.row_id;



select count(*)
from jt.q3_sessions;
--9,569,993

drop table if exists jt.q3_sessions_duration;
create table jt.q3_sessions_duration as
select application_id
     , user_id
     , start_date
     , end_date
     , cast(extract(epoch from end_date) as bigint) - cast(extract(epoch from start_date) as bigint) as duration
from jt.q3_sessions
where event_end_date < current_date;


drop table if exists jt.q3_max_sessions_duration;
create table jt.q3_max_sessions_duration as
select application_id
     , user_id
     , max(duration)
from jt.q3_sessions_duration
where duration >= 0;


select count(*)
from jt.q3_sessions_duration where end_date < start_date;
--1,660,331 (17% of Total)


select count(*)
from jt.q3_sessions_duration;
--9,653,548

select cast(extract(epoch from end_date) as bigint)
from jt.q3_sessions_duration limit 1


select avg(session_cnt)
     , percentile_cont(0.5) within group (order by session_cnt)
     , avg(total_session_duration)
     , percentile_cont(0.5) within group (order by total_session_duration)
from (
select application_id
     , user_id
     , count(*) as session_cnt
     , sum(duration) as total_session_duration     
from jt.q3_sessions_duration
where duration >= 0
group by 1,2) a;

--Average Session Count: 84.5090036855144400
--Median Session Count: 41.0

-- Average Total Duration: -2 days -50:31:42.381513
-- Median Total Druation: 00:00:04.096

----------- Pull out Bad Sessions

-- Average Session Count: 70.23
-- Median Session Count: 33

-- Average Total: 554,559.133542198703
-- Median Total: 30,284


select avg(duration)
     , percentile_cont(0.5) within group (order by duration)
from jt.q3_sessions_duration;

-- Average Session Duration: -01:09:57.214096
-- Median Session Duration: 00:00:15

----------- Pull out Bad Sessions

select avg(duration)
     , percentile_cont(0.5) within group (order by duration)
from jt.q3_sessions_duration
where duration >= 0;

-- Average Session Duration: 7895 seconds
-- Median Session Duration: 25 seconds

select count(*) from (
select distinct application_id
     , user_id
from jt.q3_sessions_duration
where duration >= 0) a;

------------ Bad Session Summary:

-- Average Session Count Per User: 70.23 Sessions
-- Median Session Count Per User: 33 Session

-- Average Total Duration Per User: 554,559.133542198703 Second
-- Median Total Duration Per User: 30,284 Second

-- Average Session Duration Across Events: 7895 Seconds
-- Median Session Duration Across Events: 25 Seconds






