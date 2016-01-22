
drop table if exists jt.repeat_users_application_users;

--============================================================================================================
-- Table: jt.repeat_users_application_users
-- Description: Get all of login views metrics relevant to the login funnel since 5/1/2015.
--              (1) enteremail
--              (2) enterpassword
--              (3) eventpicker
--              (4) profilefiller
--              (5) accountpicker
--============================================================================================================
create table jt.repeat_users_application_users as
select a.applicationid
     , a.bundleid
     , a.name as eventname
     , a.startdate
     , a.eventtype
     , u.userid
     , u.globaluserid
     , g.emailaddress
     , g.username
     , g.firstname
     , g.lastname
     , g.phone
from authdb_applications a
join jt.tm_eventcubesummary e
on a.applicationid = upper(e.applicationid::varchar)
join (select * from authdb_is_users where isdisabled = 0) u
on a.applicationid = u.applicationid
join (select * from ratings_globaluserdetails where isdisabled = 0) g
on u.globaluserid = g.globaluserid and a.bundleid = g.bundleid;

-- Count/Pct of Users in Bundles
drop table if exists jt.application_users_bucket;

select u.bundleid
     , count(*) as total_bundle_users
     , count(case when m.usercnt is null then 1 else null end) as total_unique_users
     , cast(cast(count(case when m.usercnt is null then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_unique_users
     , count(case when m.usercnt is not null then 1 else null end) as total_repeat_users
     , cast(cast(count(case when m.usercnt is not null then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_repeat_users
into jt.application_users_bucket
from (select distinct bundleid
           , globaluserid
      from jt.application_users) u
left join (select bundleid
                , globaluserid
                , count(*) as usercnt
           from jt.application_users
           group by 1,2
           having count(*) > 1) m
on u.bundleid = m.bundleid and u.globaluserid = m.globaluserid
group by 1;

-- Bundle Users
select avg(total_bundle_users) as average_total_bundle_users
     , percentile_cont(0.5) within group (order by total_bundle_users) as median_total_bundle_users
     , avg(total_repeat_users) as average_total_repeat_users
     , percentile_cont(0.5) within group (order by total_repeat_users) as median_total_repeat_users
     , avg(pct_repeat_users) as average_pct_repeat_users
     , percentile_cont(0.5) within group (order by pct_repeat_users) as median_pct_repeat_users
from jt.application_users_bucket;


select avg(total_bundle_users) as average_total_bundle_users
     , percentile_cont(0.5) within group (order by total_bundle_users) as median_total_bundle_users
     , avg(total_repeat_users) as average_total_repeat_users
     , percentile_cont(0.5) within group (order by total_repeat_users) as median_total_repeat_users
     , avg(pct_repeat_users) as average_pct_repeat_users
     , percentile_cont(0.5) within group (order by pct_repeat_users) as median_pct_repeat_users
from jt.application_users_bucket
where total_repeat_users > 0;


------------------------------------- New --------------------
select max(created)
     , max(updated)
from ratings_globaluserdetails;

-- Alfred Created: 2015-08-08 04:47:01
-- Alfred Updated: 2015-08-08 04:47:58


-- Repeat Users Event Population
-- 1.) Event started on or after 5/1/2015
-- 2.) Event ended by 08/08/2015
-- 3.) Event has at least 20 Registered Users
-- 4.) Bundle has 2 or more events during the time period 5/1/2015 - 8/8/2015

select count(*)
from jt.repeat_users_events;
--260 events 

select distinct bundle_id
from jt.repeat_users_events;
--66 bundles


drop table if exists jt.repeat_users_events;

--============================================================================================================
-- Table: jt.repeat_users_events
-- Description: Get event data and corresponding metadata based on the following criteria:
--              (1) Start Date >= '2015-05-01'
--              (2) End Date < current_date
--              (3) Number of Registered (Non-Disabled) Users for the Event is at least 20
--              (4) Number of Events within the Bundle >= 2
--============================================================================================================

create table jt.repeat_users_events as
select *
from (select distinct bundle_id
           , count(case when distinct_bundle_user_flag = 1 then 1 else null end) over (partition by bundle_id) as bundle_user_cnt
           , count(case when distinct_bundle_event_flag = 1 then 1 else null end) over (partition by bundle_id) as bundle_event_cnt
           , application_id
           , name
           , event_user_cnt
           , eventtype
           , startdate
           , enddate
           , canregister
      from (select bundle_id
                 , row_number() over (partition by bundle_id, global_user_id) as distinct_bundle_user_flag
                 , global_user_id
                 , user_id
                 , row_number() over (partition by bundle_id, application_id) as distinct_bundle_event_flag
                 , application_id
                 , name
                 , event_user_cnt
                 , eventtype
                 , startdate
                 , enddate
                 , canregister
            from (select lower(a.bundleid) as bundle_id 
                       , lower(a.applicationid) as application_id
                       , lower(b.globaluserid) as global_user_id
                       , userid as user_id    
                       , a.name
                       , a.eventtype
                       , a.startdate
                       , a.enddate
                       , a.canregister
                       , count(*) over (partition by a.applicationid) event_user_cnt
                  from authdb_applications a
                  join authdb_is_users b
                  on a.applicationid = b.applicationid
                  -- (3)
                  and b.isdisabled = 0
                  -- (1)
                  where a.startdate >= '2015-05-01'
                  -- (2)
                  and a.enddate < current_date) a      
            -- (3)
            where event_user_cnt >= 20 
                 ) a
           ) a
-- (4)
where bundle_event_cnt > 1;


drop table if exists jt.repeat_users_detail;

--============================================================================================================
-- Table: jt.repeat_users_detail
-- Description: Get the user level details for each event in jt.repeat_users_events
--              (1) UserId
--              (2) GlobalUserId
--              (3) Session Flag (Did the user have at least one session.... 1 is 'Yes' and 0 is 'No')
--============================================================================================================

create table jt.repeat_users_detail as
select distinct a.bundle_id
     , a.application_id
     , b.userid as user_id
     , lower(b.globaluserid) as global_user_id
     , case
         when c.user_id is not null then 1
         else 0
       end as session_flag
from jt.repeat_users_events a
join authdb_is_users b
on a.application_id = lower(b.applicationid)
left join (select distinct user_id from fact_sessions 
           where application_id in (select distinct application_id from jt.repeat_users_events)
           and metrics_type_id = 1) c
on b.userid = c.user_id 
where b.isdisabled = 0;


drop table if exists jt.repeat_users_event_summary;

--============================================================================================================
-- Table: jt.repeat_users_event_summary
-- Description: At the event level this aggregates the number of repeat users across a bundle.  The following
--              fields are the output per event:
--              (1) event_user_cnt: The number of registered users across the event.
--              (2) bundle_user_cnt: The number of registered users across the bundle.
--              (3) bundle_event_cnt: The number of events contained within the bundle.
--              (4) repeat_register_cnt: The number of registered users who previously registered at another
--                                       event.
--              (5) repeat_register_pct: The percent of registered users who previously registered at another
--                                       event.
--              (6) repeat_session_cnt: The number of registered users who previously had at least one session
--                                       in another event's app.
--              (7) repeat_session_pct: The percent of registered users who previously had at least one session
--                                       in another event's app.
--============================================================================================================

create table jt.repeat_users_event_summary as
select application_id
     , name
     , eventtype
     , startdate
     , enddate
     , event_user_cnt
     , bundle_user_cnt
     , bundle_event_cnt
     , count(case when event_register_order >= 2 then 1 else null end) as repeat_register_cnt
     , count(case when event_register_order >= 2 then 1 else null end)::decimal(12,4)/event_user_cnt::decimal(12,4) as repeat_register_pct
     , count(case when event_session_order >= 2 then 1 else null end) as repeat_session_cnt
     , count(case when event_session_order >= 2 then 1 else null end)::decimal(12,4)/event_user_cnt::decimal(12,4) as repeat_session_pct
from (select distinct a.bundle_id
           , a.global_user_id
           , a.application_id
           , b.name
           , b.eventtype
           , b.startdate
           , b.enddate
           , b.event_user_cnt
           , b.bundle_user_cnt
           , b.bundle_event_cnt
           , a.session_flag
           , row_number() over (partition by a.bundle_id, a.global_user_id order by b.startdate, b.enddate, b.application_id) as event_register_order
           , row_number() over (partition by a.bundle_id, a.global_user_id, session_flag order by b.startdate, b.enddate, b.application_id) as event_session_order  
      from jt.repeat_users_detail a
      join jt.repeat_users_events b
      on a.application_id = b.application_id) a
group by 1,2,3,4,5,6,7,8;

delete from jt.repeat_users_all_events where date_generated::date = current_date;

--============================================================================================================
-- Table: jt.repeat_users_all_events
-- Description: Get a summary of all events 
--              (1) event_cnt: The number of events
--              (2) avg_repeat_register_user_pct: The average % of users registered for more than one event 
--                  in a bundle.
--              (3) median_repeat_register_user_pct: The median % of users registered for more than one event
--                  in a bundle.
--              (4) avg_repeat_session_user_pct: The average % of users with an app session for more than 
--                  one event in a bundle.
--              (5) median_repeat_session_user_pct: The median % of users with an app session for more than 
--                  one event in a bundle.
--============================================================================================================

insert into jt.repeat_users_all_events (
select current_date as date_generated
     , count(*) as event_cnt
     , avg(repeat_register_pct) as avg_repeat_register_user_pct
     , percentile_cont(0.5) within group (order by repeat_register_pct) as median_repeat_register_user_pct
     , avg(repeat_session_pct) as avg_repeat_session_user_pct
     , percentile_cont(0.5) within group (order by repeat_session_pct) as median_repeat_session_user_pct  
from jt.repeat_users_event_summary);



delete from jt.repeat_users_repeat_events where date_generated::date = current_date;

--============================================================================================================
-- Table: jt.repeat_users_repeat_events
-- Description: Get a summary of all events 
--              (1) event_cnt: The number of events
--              (2) avg_repeat_register_user_pct: The average % of users registered for more than one event 
--                  in a bundle.
--              (3) median_repeat_register_user_pct: The median % of users registered for more than one event
--                  in a bundle.
--              (4) avg_repeat_session_user_pct: The average % of users with an app session for more than 
--                  one event in a bundle.
--              (5) median_repeat_session_user_pct: The median % of users with an app session for more than 
--                  one event in a bundle.
--============================================================================================================

insert into jt.repeat_users_repeat_events (
select current_date as date_generated
     , count(*) as event_cnt
     , avg(repeat_register_pct) as avg_repeat_register_user_pct
     , percentile_cont(0.5) within group (order by repeat_register_pct) as median_repeat_register_user_pct
     , avg(repeat_session_pct) as avg_repeat_session_user_pct
     , percentile_cont(0.5) within group (order by repeat_session_pct) as median_repeat_session_user_pct  
from jt.repeat_users_event_summary
where repeat_register_cnt > 0);

select *
from jt.repeat_users_repeat_events;

select *
from jt.repeat_users_all_events;


create table jt.repeat_users_all_events (
        date_generated date
      , event_cnt int
      , avg_repeat_register_user_pct decimal
      , median_repeat_register_user_pct decimal
      , avg_repeat_session_user_pct decimal
      , median_repeat_session_user_pct decimal);
      
create table jt.repeat_users_repeat_events (
        date_generated date
      , event_cnt int
      , avg_repeat_register_user_pct decimal
      , median_repeat_register_user_pct decimal
      , avg_repeat_session_user_pct decimal
      , median_repeat_session_user_pct decimal);      

select count(*) as event_cnt
     , avg(repeat_register_pct) as avg_repeat_register_user_pct
     , percentile_cont(0.5) within group (order by repeat_register_pct) as median_repeat_register_user_pct
     , avg(repeat_session_pct) as avg_repeat_session_user_pct
     , percentile_cont(0.5) within group (order by repeat_session_pct) as median_repeat_session_user_pct  
from jt.repeat_users_event_summary;

select count(*) as event_cnt
     , avg(repeat_register_pct) as avg_repeat_register_user_pct
     , percentile_cont(0.5) within group (order by repeat_register_pct) as median_repeat_register_user_pct
     , avg(repeat_session_pct) as avg_repeat_session_user_pct
     , percentile_cont(0.5) within group (order by repeat_session_pct) as median_repeat_session_user_pct  
from jt.repeat_users_event_summary;


select count(*)
from jt.repeat_users_event_summary
where repeat_register_cnt > 0

-- All Events:
-- Average Percent of User Per Event Registered for more than 1 Event: 14.92%
-- Median Percent of User Per Event Registered for more than 1 Event: 5.12%
-- Average Percent of User Per Event Session for more than 1 Event: 12.60%
-- Median Percent of User Per Event Session for more than 1 Event: 4.15%

-- All Events with at least One Repeat User:
-- Average Percent of User Per Event Registered for more than 1 Event: 21.07%
-- Median Percent of User Per Event Registered for more than 1 Event: 11.49%
-- Average Percent of User Per Event Session for more than 1 Event: 17.81%
-- Median Percent of User Per Event Session for more than 1 Event: 9.23%


select extract(month from startdate)::int
     , count(*) as event_cnt
     , count(case when repeat_register_cnt > 0 then 1 else null end) as event_repeat_cnt
     , count(case when repeat_register_cnt > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_repeat_pct
     , count(case when repeat_session_cnt > 0 then 1 else null end) as event_session_cnt
     , count(case when repeat_session_cnt > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_session_pct     
from jt.repeat_users_event_summary
group by 1
order by 1;


select case
         when eventtype is null then 'No Event Type'
         else eventtype
       end as eventtype
     , count(*) as event_cnt
     , count(case when repeat_register_cnt > 0 then 1 else null end) as event_repeat_cnt
     , count(case when repeat_register_cnt > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_repeat_pct
     , count(case when repeat_session_cnt > 0 then 1 else null end) as event_session_cnt
     , count(case when repeat_session_cnt > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_session_pct   
from jt.repeat_users_event_summary
group by 1
order by 3 desc;


