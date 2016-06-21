select *
from authdb_applications
where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449';

select applicationid
     , name
     , startdate
     , enddate
     , registrants
     , users
     , usersactive
     , adoption
from eventcube.eventcubesummary
where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449';

-- Registrants: 1759
-- Users: 1187
-- Active Users: 1187
-- Adoption: 67.48%

-- EP (3/16) @ 3:19PM PST
-- Registrants: 1759
-- Active Users: 1241

-- EP (3/16) @ 3:30PM PST NEW USERS REPORT
-- Registrants: 1759
-- Active Users: 1204

select count(distinct sessions.global_user_id) as usercnt
     , count(distinct case when users.global_user_id is not null then users.global_user_id else null end) as nondisabledcnt
from public.fact_sessions_live sessions
left join (select distinct lower(globaluserid) as global_user_id
           from public.authdb_is_users
           where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449'
           and isdisabled = 0) users
on sessions.global_user_id = users.global_user_id
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and identifier = 'start'
;

-- Start
-- Total: 1245
-- Non-Disabled: 1193

-- Start or End
-- Total: 1245
-- Non-Disabled: 1193

-- So identifier doesn't matter.

select count(distinct sessions.global_user_id) as usercnt
     , count(distinct case when users.global_user_id is not null then users.global_user_id else null end) as nondisabledcnt
from public.fact_sessions_live sessions
left join (select distinct lower(globaluserid) as global_user_id
           from public.authdb_is_users
           where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449'
           /*and isdisabled = 0*/) users
on sessions.global_user_id = users.global_user_id
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and identifier = 'start'
;

-- Total: 1245
-- Authdb: 1245

-- So all users that have a session are in IS Users

select sessions.global_user_id
     , users.user_id
     , users.isdisabled
     , count(*) as session_cnt
from public.fact_sessions_live sessions
left join (select distinct lower(globaluserid) as global_user_id
                , userid as user_id
                , isdisabled
           from public.authdb_is_users
           where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449') users
on sessions.global_user_id = users.global_user_id
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and identifier = 'start'
group by 1,2,3
;
 

-- New Metrics

select *
from fact_sessions_live
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 0

select *
from fact_actions_live
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 0

select *
from fact_views_live
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 0

-- Old Metrics

select count(distinct user_id)
from fact_sessions_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and user_id in (select distinct userid as user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 1

select count(distinct global_user_id)
from fact_actions_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 11

select count(distinct global_user_id)
from fact_views_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;

-- 11


select *
from fact_views_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and global_user_id in (select distinct lower(globaluserid) as global_user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
order by global_user_id, created
;


select *
from fact_sessions_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and user_id in (select distinct userid as user_id from public.authdb_is_users
                       where userid in (46529036,46500597,46449953,46426012,46393113,46392845,46392801,46392310,46392237,46392208,46392142))
;





select *
from fact_sessions_new
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and user_id = 46529036;


select start_date::date
     , count(*)
from fact_sessions_new
where start_date >= '2016-02-01' 
and start_date < current_date
and metrics_type_id = 1
group by 1
order by 1;

select end_date::date
     , count(*)
from fact_sessions_new
where end_date >= '2016-02-01' 
and end_date < current_date
and metrics_type_id = 2
group by 1
order by 1;

select created::date
     , count(*)
from fact_views_new
where created >= '2016-02-01' 
and created < current_date
group by 1
order by 1;

select created::date
     , count(*)
from fact_views_live
where created >= '2016-02-01' 
and created < current_date
group by 1
order by 1;


select created::date
     , count(*)
from fact_sessions_live
where identifier = 'end'
and created >= '2016-02-01' 
and created < current_date
group by 1
order by 1;