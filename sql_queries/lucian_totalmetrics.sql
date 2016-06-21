-- States (1 Month)
drop table if exists jt.lucian_states_live
;

create table jt.lucian_states_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_states_live
select actions.*
from fact_states_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

select count(*)
from jt.lucian_states_live
;
-- 18,676,604

-- Notifications (1 Month)
drop table if exists jt.lucian_notifications_live
;

create table jt.lucian_notifications_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_notifications_live
select actions.*
from fact_notifications_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- 561,262


-- Error (1 Month)
drop table if exists jt.lucian_errors_live
;

create table jt.lucian_errors_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_errors_live
select actions.*
from fact_errors_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- 1,132

-- Checkpoints (1 Month)
drop table if exists jt.lucian_checkpoints_live
;

create table jt.lucian_checkpoints_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_checkpoints_live
select actions.*
from fact_checkpoints_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;
-- 1,957,707

-- Sessions (1 Month)
drop table if exists jt.lucian_sessions_live
;

create table jt.lucian_sessions_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_sessions_live
select actions.*
from fact_sessions_live actions
join jt.lucian_actions_users users
on actions.application_id = users.lower_application_id
and actions.global_user_id = users.lower_global_user_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;



-- Impressions (1 Month)
drop table if exists jt.lucian_impressions_live
;

create table jt.lucian_impressions_live as
select * from fact_actions_live limit 0
;

insert into jt.lucian_impressions_live
select actions.*
from fact_impressions_live actions
join (select distinct lower_application_id
      from jt.lucian_actions_users) users
on actions.application_id = users.lower_application_id
and actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- 58,960,807
