-- Get the events that have the CMS option "Session Notes Enabled" on.
drop table if exists jt.sessionnotes_events;
create table jt.sessionnotes_events as
select config.applicationid
     , ecs.name
     , ecs.startdate
     , ecs.enddate
     , ecs.eventtype
     , ecs.openevent
from public.ratings_applicationconfigsettings config
join eventcube.eventcubesummary ecs 
on config.applicationid = ecs.applicationid
where config.name = 'EnableSessionNotes'
and config.settingvalue = 'True';

-- Get the users and total counts of users to the events that 
-- have the CMS option "Session Notes Enabled" on.
drop table if exists jt.sessionnotes_users;
create table jt.sessionnotes_users as
select users.applicationid
     , users.userid
     , users.globaluserid
from (select distinct applicationid
           , globaluserid
           , userid
      from public.authdb_is_users
      where applicationid in (select applicationid
                              from jt.sessionnotes_events)
      and isdisabled = 0) users;




-- Get the session detail views of the events that have app sessions with 6.3.
drop table if exists jt.sessionnotes_user_sessions;
create table jt.sessionnotes_user_sessions as
select events.applicationid
     , users.globaluserid
     , count(*) as sessioncnt
from public.fact_sessions_live sessions
join jt.sessionnotes_events events
on sessions.application_id = lower(events.applicationid)
join jt.sessionnotes_events_users users
on sessions.application_id = lower(users.applicationid)
and sessions.global_user_id = lower(users.globaluserid)
where sessions.binary_version like '%6.3%'
group by 1,2;

-- Get the session detail views of the events that have session detail views with 6.3.
drop table if exists jt.sessionnotes_user_session_views;
create table jt.sessionnotes_user_session_views as
select events.applicationid
     , users.globaluserid
     , count(*) as sessionviewcnt
     , count(distinct views.metadata->>'ItemId') as uniquesessionviewcnt
from public.fact_views_live views
join jt.sessionnotes_events events
on views.application_id = lower(events.applicationid)
join jt.sessionnotes_events_users users
on views.application_id = lower(users.applicationid)
and views.global_user_id = lower(users.globaluserid)
join (select distinct item.itemid::varchar as itemid
      from ratings_item item
      join ratings_topic topic
      on item.parenttopicid = topic.topicid
      where item.isdisabled = 0
      and topic.isdisabled = 0
      and topic.listtypeid = 2
     ) sessionitems
on views.metadata->>'ItemId' = sessionitems.itemid
where  views.identifier = 'item'
and views.binary_version like '%6.3%'
group by 1,2;

-- Get the adding of session notes with 6.3
drop table if exists jt.sessionnotes_user_add_note;
create table jt.sessionnotes_user_add_note as
select events.applicationid
     , users.globaluserid
     , count(*) as sessionnoteaddcnt
     , count(distinct actions.metadata->>'ItemId') as uniquesessionnoteaddcnt
from public.fact_actions_live actions
join jt.sessionnotes_events events
on actions.application_id = lower(events.applicationid)
join jt.sessionnotes_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.identifier = 'addSessionNoteButton'
and actions.binary_version like '%6.3%'
group by 1,2;


-- Get the saving of non-blank session notes with 6.3
drop table if exists jt.sessionnotes_user_save_note;
create table jt.sessionnotes_user_save_note as
select events.applicationid
     , users.globaluserid
     , count(*) as sessionnoteaddcnt
     , count(distinct actions.metadata->>'ItemId') as uniquesessionnoteaddcnt
from public.fact_actions_live actions
join jt.sessionnotes_events events
on actions.application_id = lower(events.applicationid)
join jt.sessionnotes_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.identifier = 'saveSessionNoteButton'
and actions.metadata->>'IsBlank' = 'false'
and actions.binary_version like '%6.3%'
group by 1,2;
      


select sessions.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , users.usercnt as totalusers
     , count(*) as userwithsessions
     , count(case when sessiondetails.globaluserid is not null then 1 else null end) as userwithsessiondetailviews
     , count(case when addnote.globaluserid is not null then 1 else null end) as addnote
     , count(case when savenote.globaluserid is not null then 1 else null end) as savenote
     , case
          when count(case when sessiondetails.globaluserid is not null then 1 else null end) > 0 
          then count(case when addnote.globaluserid is not null then 1 else null end)::decimal(12,4)/count(case when sessiondetails.globaluserid is not null then 1 else null end)::decimal(12,4) 
          else null 
       end as addnotepct
     , case
          when count(case when addnote.globaluserid is not null then 1 else null end) > 0 
          then count(case when savenote.globaluserid is not null then 1 else null end)::decimal(12,4)/count(case when addnote.globaluserid is not null then 1 else null end)::decimal(12,4) 
          else null 
       end as savenotepct
from jt.sessionnotes_user_sessions sessions
join jt.sessionnotes_events events
on sessions.applicationid = events.applicationid
join (select distinct applicationid
           , usercnt
      from jt.sessionnotes_events_users) users
on events.applicationid = users.applicationid
left join jt.sessionnotes_user_session_views sessiondetails
on sessions.applicationid = sessiondetails.applicationid
and sessions.globaluserid = sessiondetails.globaluserid
left join jt.sessionnotes_user_add_note addnote
on sessions.applicationid = addnote.applicationid
and sessions.globaluserid = addnote.globaluserid
left join jt.sessionnotes_user_save_note savenote
on sessions.applicationid = savenote.applicationid
and sessions.globaluserid = savenote.globaluserid
group by 1,2,3,4,5,6
order by 3,4;


