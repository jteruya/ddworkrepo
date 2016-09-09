-- Event Population
-- (1) No Test Events
-- (2) Event Starts on or after 1/1/2016
-- (3) Event Ends before the date this code is run.
drop table if exists feature_analysis_events;
create temporary table feature_analysis_events as
select ecs.*
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ecs.startdate >= '2016-01-01'
and ecs.enddate < current_date
;

-- Users Population
-- (1) All non-disabled users associated with events from event population
drop table if exists feature_analysis_events_users;
create temporary table feature_analysis_events_users as
select distinct users.applicationid
     , users.userid
     , users.globaluserid
from authdb_is_users users
join feature_analysis_events events
on users.applicationid = events.applicationid
where users.isdisabled = 0
;

select count(*)
from feature_analysis_events_users
;
-- 1079519

-- Agenda
select distinct typeid
from feature_analysis_events events
join public.ratings_applicationconfiggriditems a
on events.applicationid = a.applicationid
join ratings_topic b
on a.target = b.topicid::varchar
where b.listtypeid = 2
and a.selected = true
and b.isdisabled = 0
and b.ishidden = false
;
-- 2

-- Speakers
select distinct typeid
from feature_analysis_events events
join public.ratings_applicationconfiggriditems a
on events.applicationid = a.applicationid
join ratings_topic b
on a.target = b.topicid::varchar
where b.listtypeid = 4
and a.selected = true
and b.isdisabled = 0
and b.ishidden = false
;
-- 2

-- Exhibitors
select distinct typeid
from feature_analysis_events events
join public.ratings_applicationconfiggriditems a
on events.applicationid = a.applicationid
join ratings_topic b
on a.target = b.topicid::varchar
where b.listtypeid = 3
and a.selected = true
and b.isdisabled = 0
and b.ishidden = false
;
-- 1/2

-- Files
select distinct typeid
from feature_analysis_events events
join public.ratings_applicationconfiggriditems a
on events.applicationid = a.applicationid
join ratings_topic b
on a.target = b.topicid::varchar
where b.listtypeid = 5
and a.selected = true
and b.isdisabled = 0
and b.ishidden = false
;
-- 4



-- Menu Presses
drop table if exists feature_analysis_events_users_menu;
create temporary table feature_analysis_events_users_menu as
select case
         when metadata->>'Url' like '%agenda%' then 'Agenda Menu Button'
         when metadata->>'Url' like '%users%' then 'Users Menu Button'
         when metadata->>'Url' like '%channels%' then 'Channels Menu Button'
         when metadata->>'Url' like '%messages%' then 'Messages Menu Button'
         else 'Unknown'
       end as "Label"
     , application_id
     , global_user_id
     , count(*) as actioncnt
from fact_actions_live actions
join feature_analysis_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where identifier = 'menuItem'
and (metadata->>'Url' like '%agenda%' or metadata->>'Url' like '%users%' or metadata->>'Url' like '%channels%' or metadata->>'Url' like '%messages%')
group by 1,2,3
;


select *
from feature_analysis_events_users_menu
limit 10
;

select *
from feature_analysis_events limit 10
;


-- Summary
drop table if exists feature_analysis_events_users_feature_summary;
create temporary table feature_analysis_events_users_feature_summary as
select a.applicationid
     , a.globaluserid
     , a.userid
     , coalesce(b.sessions,0) as sessions
     , coalesce(b.eventsessions,0) as eventsessions
     , sum(case when menu."Label" is not null and menu."Label" = 'Agenda Menu Button' then actioncnt else 0 end) as agendamenucnt
     , sum(case when menu."Label" is not null and menu."Label" = 'Users Menu Button' then actioncnt else 0 end) as usersmenucnt
     , d.topicchannel
     , sum(case when menu."Label" is not null and menu."Label" = 'Channels Menu Button' then actioncnt else 0 end) as channelsmenucnt
     , d.directmessaging
     , sum(case when menu."Label" is not null and menu."Label" = 'Messages Menu Button' then actioncnt else 0 end) as messagesmenucnt
from feature_analysis_events_users a
join feature_analysis_events d
on a.applicationid = d.applicationid
left join EventCube.Agg_Session_per_AppUser b
on a.applicationid = b.applicationid
and a.userid = b.userid
left join feature_analysis_events_users_menu menu
on lower(a.globaluserid) = menu.global_user_id 
and lower(a.applicationid) = menu.application_id
group by 1,2,3,4,5,8,10
;


select count(*)
from feature_analysis_events_users_feature_summary;

-- Should be: 1,079,519
-- Is: 1,079,519

select case
         when messagesmenucnt > 0 then 'Checked Message Microapp'
         else 'Not Checked Message Microapp'
       end as label
     , count(*)
     , avg(sessions)
     , percentile_cont(0.5) within group (order by sessions)
     , avg(eventsessions)
     , percentile_cont(0.5) within group (order by eventsessions)
from feature_analysis_events_users_feature_summary
where directmessaging = 1
group by 1;