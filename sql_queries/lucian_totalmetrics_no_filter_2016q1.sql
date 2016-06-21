-- States
create temporary table lucian_states_live_nofilter_other as
select actions.*
from fact_states_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_states_live_nofilter_other
group by 1
;


-- Notifications
create temporary table lucian_notifications_live_nofilter_other as
select actions.*
from fact_notifications_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_notifications_live_nofilter_other
group by 1
;


-- Error

create temporary table lucian_errors_live_nofilter_other as
select actions.*
from fact_errors_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_errors_live_nofilter_other
group by 1
;


-- Checkpoints
create temporary table lucian_checkpoints_live_nofilter_other as
select actions.*
from fact_checkpoints_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_checkpoints_live_nofilter_other
group by 1
;

-- Sessions
create temporary table lucian_sessions_live_nofilter_other as
select actions.*
from fact_sessions_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_sessions_live_nofilter_other
group by 1
;


-- Impressions
create temporary table lucian_impressions_live_nofilter_other as
select actions.*
from fact_impressions_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_impressions_live_nofilter_other
group by 1
;


-- Actions
create temporary table lucian_actions_live_nofilter_other as
select actions.*
from fact_actions_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_actions_live_nofilter_other
group by 1
;


-- Views
create temporary table lucian_views_live_nofilter_other as
select actions.*
from fact_views_live actions
where actions.created <= '2016-03-31'
and actions.created >= '2016-01-01'
;

select extract(month from created) as date
     , count(*)
from lucian_views_live_nofilter_other
group by 1
;