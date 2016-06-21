-- Get Event and Users
drop table if exists jt.con258_events_users
;

create table jt.con258_events_users as
select distinct lower(ecs.applicationid) as application_id
     , lower(users.globaluserid) as global_user_id
     , users.userid as user_id
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
join authdb_is_users users
on ecs.applicationid = users.applicationid
where te.applicationid is null
and users.isdisabled = 0
;

-- Create Index on Application ID
create index ndx_con258_events_users on jt.con258_events_users (application_id)
;

-- Get User and Session Counts (New Metrics)
drop table if exists jt.con258_events_users_sessions_new
;

create table jt.con258_events_users_sessions_new as
select users.application_id
     , users.global_user_id
     , count(*) as sessioncnt
from jt.con258_events_users users
join fact_sessions_live sessions
on users.application_id = sessions.application_id
and users.global_user_id = sessions.global_user_id
where (sessions.device_os_version = '4.0' or sessions.device_os_version = '4.0.3')
and sessions.device_type = 'android'
group by 1,2
;

select distinct device_os_version
from fact_sessions_live
where device_type = 'android'
and device_os_version like '4%'
;

-- Get User and Session Counts (Old Metrics) -- NOT USED
/*
drop table if exists jt.con258_events_users_sessions_old
;

create table jt.con258_events_users_sessions_old as
select users.application_id
     , users.global_user_id
     , count(sessions.application_id) as sessioncnt
from jt.con258_events_users users
left join fact_views_new sessions
on users.application_id = sessions.application_id
and users.global_user_id = sessions.global_user_id
where sessions.device_os_version = '5.0.1'
and sessions.app_type_id = 3
group by 1,2
;
*/

-- Results by Event
select users.application_id as "Application ID"
     , ecs.name as "Event Name"
     , ecs.startdate as "Event Start Date"
     , ecs.enddate as "Event End Date"
     , ecs.users as "Registered Users"
     , ecs.usersactive as "Active Users"
     , coalesce(sessions.androidcnt,0) as "Total Android Users"
     , coalesce(sessions.androidcnt,0)::decimal(12,4)/ecs.usersactive as "Total Android %"
from (select distinct application_id
      from jt.con258_events_users) users
left join (select application_id
                , count(*) as androidcnt
           from jt.con258_events_users_sessions_new
           group by 1) sessions
on users.application_id = sessions.application_id
join eventcube.eventcubesummary ecs
on users.application_id = lower(ecs.applicationid)
and ecs.usersactive > 0
and ecs.enddate < current_date
and ecs.startdate >= '2015-10-01'
order by 3,4
;

-- Results by Month
select cast(extract(year from startdate) * 100 + extract(month from startdate) as int) as "Year Month"
     , count(*) as "Event Count"
     , avg(androidpct) as "Average Android %"
     , percentile_cont(0.5) within group (order by androidpct) as "Median Android %"
     , sum(androidcnt)/sum(usersactive) as "% of Total Android"
from (
select users.application_id
     , ecs.name
     , ecs.startdate
     , ecs.enddate
     , ecs.users
     , ecs.usersactive
     , coalesce(sessions.androidcnt,0) as androidcnt
     , coalesce(sessions.androidcnt,0)::decimal(12,4)/ecs.usersactive as androidpct
from (select distinct application_id
      from jt.con258_events_users) users
left join (select application_id
                , count(*) as androidcnt
           from jt.con258_events_users_sessions_new
           group by 1) sessions
on users.application_id = sessions.application_id
join eventcube.eventcubesummary ecs
on users.application_id = lower(ecs.applicationid)
and ecs.usersactive > 0
and ecs.enddate < current_date
and ecs.startdate >= '2015-10-01'
) a
group by 1
order by 1
;


-- Overall Results
select count(*) as "Event Count"
     , avg(androidpct) as "Average Android %"
     , percentile_cont(0.5) within group (order by androidpct) as "Median Android %"
     , sum(androidcnt)/sum(usersactive) as "% of Total Android"
from (
select users.application_id
     , ecs.name
     , ecs.startdate
     , ecs.enddate
     , ecs.users
     , ecs.usersactive
     , coalesce(sessions.androidcnt,0) as androidcnt
     , coalesce(sessions.androidcnt,0)::decimal(12,4)/ecs.usersactive as androidpct
from (select distinct application_id
      from jt.con258_events_users) users
left join (select application_id
                , count(*) as androidcnt
           from jt.con258_events_users_sessions_new
           group by 1) sessions
on users.application_id = sessions.application_id
join eventcube.eventcubesummary ecs
on users.application_id = lower(ecs.applicationid)
and ecs.usersactive > 0
and ecs.enddate < current_date
and ecs.startdate >= '2015-10-01'
) a
;
