-- States (1 Month)
drop table if exists jt.lucian_states_live_nofilter
;

create table jt.lucian_states_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_states_live_nofilter
select actions.*
from fact_states_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 18,676,604
-- No Filter: 27,479,018

-- Notifications (1 Month)
drop table if exists jt.lucian_notifications_live_nofilter
;

create table jt.lucian_notifications_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_notifications_live_nofilter
select actions.*
from fact_notifications_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 561,262
-- No Filter: 658,814

-- Error (1 Month)
drop table if exists jt.lucian_errors_live_nofilter
;

create table jt.lucian_errors_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_errors_live_nofilter
select actions.*
from fact_errors_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 1,132
-- No Filter: 1,157

-- Checkpoints (1 Month)
drop table if exists jt.lucian_checkpoints_live_nofilter
;

create table jt.lucian_checkpoints_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_checkpoints_live_nofilter
select actions.*
from fact_checkpoints_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;
-- Filter: 1,957,707
-- No Filer: 3,449,094

-- Sessions (1 Month)
drop table if exists jt.lucian_sessions_live_nofilter
;

create table jt.lucian_sessions_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_sessions_live_nofilter
select actions.*
from fact_sessions_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 11,984,120
-- No Filter: 13,041,777


-- Impressions (1 Month)
drop table if exists jt.lucian_impressions_live_nofilter
;

create table jt.lucian_impressions_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_impressions_live_nofilter
select actions.*
from fact_impressions_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 58,960,807
-- No Filter: 61,848,311


-- Actions (1 Month)
drop table if exists jt.lucian_actions_live_nofilter
;

create table jt.lucian_actions_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_actions_live_nofilter
select actions.*
from fact_actions_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 30,731,736
-- No Filter: 44,731,918


-- Views (1 Month)
drop table if exists jt.lucian_views_live_nofilter
;

create table jt.lucian_views_live_nofilter as
select * from fact_actions_live limit 0
;

insert into jt.lucian_views_live_nofilter
select actions.*
from fact_views_live actions
where actions.created <= '2016-05-05'
and actions.created >= '2016-04-05'
;

-- Filter: 29,335,523
-- No Filter: 32,816,490