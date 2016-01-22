drop table if exists jt.q3_bookmarks_prior_event_start;
create table jt.q3_bookmarks_prior_event_start  as
select distinct f.application_id
     , a.name
     , a.startdate
     , a.enddate
     , f.global_user_id
from fact_actions f
join authdb_applications a
on lower(a.applicationid) = f.application_id 
where f.identifier = 'bookmarkbutton'
and a.startdate >= '2015-07-01'
and a.enddate < current_date
and f.created < a.startdate;

drop table if exists jt.q3_session_during_event_start;
create table jt.q3_session_during_event_start as
select distinct s.application_id
     , a.name
     , a.startdate
     , a.enddate
     , s.user_id
from fact_sessions s
join authdb_applications a
on lower(a.applicationid) = s.application_id 
where s.metrics_type_id = 1
and a.startdate >= '2015-07-01'
and a.enddate < current_date
and s.start_date between a.startdate and a.enddate;

drop table if exists jt.q3_bookmark_to_session;

create table jt.q3_bookmark_to_session as
select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.global_user_id
     , b.userid as user_id
     , c.user_id as session_user_id
from jt.q3_bookmarks_prior_event_start a
join (select * from authdb_is_users where isdisabled = 0) b
on a.global_user_id = lower(b.globaluserid) and a.application_id = lower(b.applicationid)
left join jt.q3_session_during_event_start c
on b.userid = c.user_id and a.application_id = c.application_id;


drop table if exists jt.q3_event_bookmark_to_session;
create table jt.q3_event_bookmark_to_session as
select application_id
     , name
     , startdate
     , enddate
     , count(*) bookmark_prior_users_cnt
     , count(case when session_user_id is not null then 1 else null end) as sessions_during_event_users_cnt
     , count(case when session_user_id is not null then 1 else null end)::decimal(12,2)/count(*)::decimal(12,2) as sessions_during_event_users_pct
from jt.q3_bookmark_to_session
group by 1,2,3,4;


select *
from jt.q3_event_bookmark_to_session;

select avg(sessions_during_event_users_pct) as average_sessions_during_event_users_pct
     , percentile_cont(0.5) within group (order by sessions_during_event_users_pct) as median_sessions_during_event_users_pct
from jt.q3_event_bookmark_to_session;




