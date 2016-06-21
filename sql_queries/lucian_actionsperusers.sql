-- Get Event Population
drop table if exists jt.lucian_actions_events
;

create table jt.lucian_actions_events as
select applicationid as lower_application_id, * from eventcube.eventcubesummary limit 0
;

insert into jt.lucian_actions_events
select lower(ecs.applicationid) as lower_application_id
     , ecs.*
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where ecs.startdate <= '2016-05-05'
and te.applicationid is null
;

-- Get the Users Population

drop table if exists jt.lucian_actions_users
;

drop index if exists ndx_lucian_actions_users
;

create table jt.lucian_actions_users as
select lower(applicationid) as lower_application_id, lower(globaluserid) as lower_global_user_id, applicationid, globaluserid, userid from public.authdb_is_users limit 0
;

create index ndx_lucian_actions_users on jt.lucian_actions_users (lower_application_id)
;

insert into jt.lucian_actions_users
select distinct events.lower_application_id as lower_application_id
     , lower(users.globaluserid) as lower_global_user_id
     , users.applicationid
     , users.globaluserid
     , users.userid
from authdb_is_users users
join jt.lucian_actions_events events
on users.applicationid = events.applicationid
where users.isdisabled = 0
;


-- Get the Actions Population (1 month)
drop table if exists jt.lucian_actions_live_1month
;

create table jt.lucian_actions_live_1month as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_1month
select actions.*
from fact_actions_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;


-- Get the Actions Population (3 month)
drop table if exists jt.lucian_actions_live_3month_test
;

create table jt.lucian_actions_live_3month_test as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_3month_test
select actions.*
from fact_actions_live actions
where actions.application_id in (select lower_application_id from jt.lucian_actions_events)
;


-- 2 months prior
drop table if exists jt.lucian_actions_live_3month_test_1p
;

create table jt.lucian_actions_live_3month_test_1p as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_3month_test_1p
select actions.*
from jt.lucian_actions_live_3month_test actions
where actions.created <= '2016-04-05'
and actions.created >= '2016-03-05'
;

-- 3 months prior
drop table if exists jt.lucian_actions_live_3month_test_2p
;

create table jt.lucian_actions_live_3month_test_2p as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_3month_test_2p
select actions.*
from jt.lucian_actions_live_3month_test actions
where actions.created <= '2016-03-05'
and actions.created >= '2016-02-05'
;

-- 2 months prior (users)
drop table if exists jt.lucian_actions_live_3month_test_1p_users
;

create table jt.lucian_actions_live_3month_test_1p_users as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_3month_test_1p_users
select actions.*
from jt.lucian_actions_live_3month_test_1p actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
;


-- 3 months prior (users)
drop table if exists jt.lucian_actions_live_3month_test_2p_users
;

create table jt.lucian_actions_live_3month_test_2p_users as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_3month_test_2p_users
select actions.*
from jt.lucian_actions_live_3month_test_2p actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
;


create table jt.lucian_actions_live_3month_test_2p_users_agg as
select application_id
     , global_user_id
     , count(*) as actioncnt
from jt.lucian_actions_live_3month_test_2p_users
group by 1,2
;


create table jt.lucian_actions_live_3month_test_1p_users_agg as
select application_id
     , global_user_id
     , count(*) as actioncnt
from jt.lucian_actions_live_3month_test_1p_users
group by 1,2
;

create table jt.lucian_actions_live_1month_user_agg as
select application_id
     , global_user_id
     , count(*) as actioncnt
from jt.lucian_actions_live_1month
group by 1,2
;




-- Get the Old Actions Population (1 month)
drop table if exists jt.lucian_old_actions_live_1month
;

create table jt.lucian_old_actions_live_1month as
select * from fact_actions_new limit 0
;

insert into jt.lucian_old_actions_live_1month
select actions.*
from fact_actions_new actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

select application_id
     , count(distinct global_user_id) as usercnt
     , count(*) as actioncnt
from jt.lucian_old_actions_live_1month
group by 1
;


-- Get the Old Actions Population (3 month)
drop table if exists jt.lucian_old_actions_live_3month
;

create table jt.lucian_old_actions_live_3month as
select * from fact_actions_new limit 0
;

insert into jt.lucian_old_actions_live_3month
select actions.*
from fact_actions_new actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-04-05'
and actions.created >= '2016-02-05'
;

select application_id
     , count(distinct global_user_id) as usercnt
     , count(*) as actioncnt
from jt.lucian_old_actions_live_3month
group by 1
;


create table jt.lucian_old_actions_live_3month_agg as
select application_id
     , global_user_id
     , count(*) as actioncnt
from jt.lucian_old_actions_live_3month
group by 1,2
;

create table jt.lucian_old_actions_live_1month_agg as
select application_id
     , global_user_id
     , count(*) as actioncnt
from jt.lucian_old_actions_live_1month
group by 1,2
;

-- New Metrics Results (Month 1)
select count(distinct application_id)
     , count(distinct global_user_id)
     , sum(actioncnt)
     , avg(actioncnt)
     , percentile_cont(0.5) within group (order by actioncnt)
from jt.lucian_actions_live_1month_user_agg
;

-- Old Metrics Results (Month 1)
select count(distinct application_id)
     , count(distinct global_user_id)
     , sum(actioncnt)
     , avg(actioncnt)
     , percentile_cont(0.5) within group (order by actioncnt)
from jt.lucian_old_actions_live_1month_agg
;

-- New Metrics Results (All 3 Months)
select count(distinct application_id) as totalevents
     , count(distinct global_user_id) as totalusers
     , sum(totalactioncnt) as totalactions
     , avg(totalactioncnt)
     , percentile_cont(0.5) within group (order by totalactioncnt)
from (
select application_id
     , global_user_id
     , sum(actioncnt) as totalactioncnt
from (
select *
from jt.lucian_actions_live_1month_user_agg
union all
select *
from jt.lucian_actions_live_3month_test_1p_users_agg
union all
select *
from jt.lucian_actions_live_3month_test_2p_users_agg
)a
group by 1,2
) a
;

-- Old Metrics Results (All 3 Months)
select count(distinct application_id) as totalevents
     , count(distinct global_user_id) as totalusers
     , sum(totalactioncnt) as totalactions
     , avg(totalactioncnt)
     , percentile_cont(0.5) within group (order by totalactioncnt)
from (
select application_id
     , global_user_id
     , sum(actioncnt) as totalactioncnt
from (
select *
from jt.lucian_old_actions_live_3month_agg
union all
select *
from jt.lucian_old_actions_live_1month_agg
)a
group by 1,2
) a
;





