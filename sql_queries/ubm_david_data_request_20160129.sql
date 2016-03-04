-- Get the Events and Associated applicationid
drop table if exists jt.ubm_events;
create table jt.ubm_events as
select applicationid
     , bundleid
     , name
     , timezoneid
     , startdate
     , enddate
     , canregister
     , (startdate - interval '2 week') as anastartdate
     , (enddate + interval '2 week' + interval '1day') as anaenddate
from public.authdb_applications
-- CPhI Worldwide 2015 (10/13/2015 - 10/15/2015)
where applicationid = '616449EB-8D8B-43C8-A886-57567B3EFE83'
-- Fi Europe (12/1/2015 - 12/3/2015)
or applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
-- CPhI India (12/1/2015 - 12/3/2015)
or applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31';


-- Get the Exhibitor List Associated with Events
select topics.*
from ratings_topic topics
join jt.ubm_events events
on topics.applicationid = events.applicationid
where listtypeid = 3
and ishidden = false;

--applicationId: 7C56BC3C-B8BD-42A9-B11B-6B221B661C31, topicId: 10277802
--applicationId: E7DBE508-1E84-4EF9-BF3D-577C789C4DE5, topicId: 10277813
--applicationId: 616449EB-8D8B-43C8-A886-57567B3EFE83, topicId: 10276204

-- Get the Users Associated with Events
drop table if exists jt.ubm_events_users;
create table jt.ubm_events_users as
select distinct events.applicationid
     , name
     , timezoneid
     , startdate
     , enddate
     , anastartdate
     , anaenddate
     , count(*) over (partition by events.applicationid) as usercnt
     , users.userid
     , users.globaluserid
from public.authdb_is_users users
join jt.ubm_events events
on users.applicationid = events.applicationid
where isdisabled = 0;


-- Get the Sessions Associated with Events
drop table if exists jt.ubm_sessions;
create table jt.ubm_sessions as
select 'fact_sessions_live' as source
     , application_id
     , name
     , startdate
     , enddate
     , anastartdate
     , anaenddate
     , global_user_id
     , binary_version
     , device_type
     , created as start_date
from public.fact_sessions_live sessions
join jt.ubm_events_users users
on sessions.global_user_id = lower(users.globaluserid)
and sessions.application_id = lower(users.applicationid)
where sessions.identifier = 'start'
union all
select 'fact_sessions_new'
     , application_id
     , name
     , startdate
     , enddate
     , anastartdate
     , anaenddate
     , lower(users.globaluserid) as global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , start_date
from public.fact_sessions_new sessions
join jt.ubm_events_users users
on sessions.user_id = users.userid
and sessions.application_id = lower(users.applicationid)
where sessions.metrics_type_id = 1;


-- Get the Sessions in the Analysis Time Window
drop table if exists jt.ubm_sessions_filter;
create table jt.ubm_sessions_filter as
select *
from jt.ubm_sessions
where start_date >= anastartdate
and start_date < anaenddate;

-- Get the Sessions Breakdown per Event
select application_id
     , name
     , startdate
     , enddate
     , count(*) as sessioncnt
     , count(case when source = 'fact_sessions_new' then 1 else null end) as oldsessioncnt
     , count(case when source = 'fact_sessions_live' then 1 else null end) as newsessioncnt
     , count(case when source = 'fact_sessions_new' then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) as oldsessionpct
     , count(case when source = 'fact_sessions_live' then 1 else null end)::decimal(8,2)/count(*)::decimal(8,2) as newsessionpct    
from jt.ubm_sessions_filter
group by 1,2,3,4
order by 1,3,4;

-- Get the Sessions Breakdown per Event, Device Type, Binary Version
select application_id
     , name
     , device_type
     , binary_version
     , startdate
     , enddate
     , count(*) as sessioncnt
     , count(case when source = 'fact_sessions_new' then 1 else null end) as oldsessioncnt
     , count(case when source = 'fact_sessions_live' then 1 else null end) as newsessioncnt    
from jt.ubm_sessions_filter
group by 1,2,3,4,5,6
order by 1,4,5,6;

-- Get the menuItem Actions from fact_actions
drop table if exists jt.ubm_fact_actions;
create table jt.ubm_fact_actions as
select 'fact_actions' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'menuitem'
and metadata->>'listid' = '10276204'
union all
select 'fact_actions' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and identifier = 'menuitem'
and metadata->>'listid' = '10277802'
union all
select 'fact_actions' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and identifier = 'menuitem'
and metadata->>'listid' = '10277813';

-- Get the menuItem Actions from fact_actions_new
drop table if exists jt.ubm_fact_actions_new;
create table jt.ubm_fact_actions_new as
select 'fact_actions_new' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions_new
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'menuitem'
and metadata->>'listid' = '10276204'
union all
select 'fact_actions_new' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions_new
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and identifier = 'menuitem'
and metadata->>'listid' = '10277802'
union all
select 'fact_actions_new' as source
     , application_id
     , global_user_id
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as device_type
     , created
from fact_actions_new
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and identifier = 'menuitem'
and metadata->>'listid' = '10277813';

-- Get the menuItem Actions from fact_actions_live
drop table if exists jt.ubm_fact_actions_live;
create table jt.ubm_fact_actions_live as
select 'fact_actions_live' as source
     , application_id
     , global_user_id
     , binary_version
     , device_type
     , created
from fact_actions_live
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'menuItem'
and metadata->>'Url' like '%/10276204'
union all
select 'fact_actions_live' as source
     , application_id
     , global_user_id
     , binary_version
     , device_type
     , created
from fact_actions_live
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and identifier = 'menuItem'
and metadata->>'Url' like '%/10277802'
union all
select 'fact_actions_live' as source
     , application_id
     , global_user_id
     , binary_version
     , device_type
     , created
from fact_actions_live
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and identifier = 'menuItem'
and metadata->>'Url' like '%/10277813';

-- Get all the Menu Item Buttons (only iOS, Android doesn't track for this version)
select application_id as "Application ID"
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as "Device Type"
     , binary_version as "App Version"
     , count(*) as "Exhibitor App Section Visit Count"
     , count(distinct global_user_id) as "Unique User Count"
from (
select *
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'menuitem'
and actions.metadata->>'listid' = '10276204'
union all
select *
from public.fact_actions actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'menuitem'
and actions.metadata->>'listid' = '10276204') a
group by 1,2,3
order by 1,2,3;

-- List View (since Android not tracked)

select views.application_id as "Application ID"
     , case
         when views.app_type_id in (1,2) then 'ios'
         when views.app_type_id in (3) then 'android'
         else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Profile Views"
     , count(distinct views.global_user_id) as "Unique User Count"
from fact_views_new views
join jt.ubm_events_users users
on views.application_id = lower(users.applicationid)
and views.global_user_id = lower(users.globaluserid)
and views.identifier = 'list'
where views.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' 
and views.metadata->>'type' = 'exhibitor'
group by 1,2
order by 1,2;

-- Get all the Menu Item Buttons for 
select application_id as "Application ID"
     , device_type as "Device Type"
     , binary_version as "App Version"
     , count(*) as "Exhibitor App Section Visit Count"
     , count(distinct global_user_id) as "Unique User Count"
from (
select *
from public.fact_actions_live actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.identifier = 'menuItem'
and actions.application_id in ('7c56bc3c-b8bd-42a9-b11b-6b221b661c31', 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5')
and (actions.metadata->>'Url' like '%/10277802' or actions.metadata->>'Url' like '%/10277813')) a
group by 1,2,3;



-- Number of Exhibitor Search Attempts (Worldwide)
select application_id as "Application ID"
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Search Box Highlight"
     , count(distinct global_user_id) as "Unique User Count"
from (
select *
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'enterlistsearchtextfield'
and actions.metadata->>'listid' in ('10276204')
/*union all
select *
from public.fact_actions actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'enterlistsearchtextfield'
and actions.metadata->>'listid' in ('10276204')*/) a
group by 1,2
order by 1,2;


-- Number of Exhibitor Search Attempts (India and Europe)
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) as exhibitorsearchattempt
     , count(*) as "Exhibitor Search Box Highlight"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_actions_live actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.identifier = 'enterListSearchTextField'
and metadata->>'ListId' in ('10277813', '10277802')
group by 1,2
order by 1,2;


-- submitListSearch

-- Number of Exhibitor Search Attempts (India and Europe)
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) as "Exhibitor Search Count"
     , count(distinct global_user_id) as "Unique User Count"
     , count(case when metadata->>'Count' = '0' then 1 else null end) as "Exhibitor Search (No Results) Count"
     , count(distinct case when metadata->>'Count' = '0' then global_user_id else null end) as "Unique User Count"
from public.fact_actions_live actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.identifier = 'submitListSearch'
and metadata->>'ListId' in ('10277813', '10277802')
group by 1,2
order by 1,2;


-- Constrained Number of Exhibitor Search Attempts (India and Europe)
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) as "Exhibitor Search Count"
     , count(distinct global_user_id) as "Unique User Count"
     , count(case when resultcnt = '0' then 1 else null end) as "Exhibitor Search (No Results) Count"
     , count(distinct case when resultcnt = '0' then global_user_id else null end) as "Unique User Count"
from (
select distinct application_id 
     , global_user_id
     , device_type
     , device_id
     , finalcreated
     , lastsearchterm
     , resultcnt
from (
select a.application_id
     , a.global_user_id
     , a.device_type
     , a.device_id
     , a.metadata
     , a.created
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.application_id, a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.application_id, a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from public.fact_actions_live a
join jt.ubm_events_users b
on a.global_user_id = lower(b.globaluserid)
and a.application_id = lower(b.applicationid)
where a.identifier = 'submitListSearch'
and a.created >= b.anastartdate
and a.created < b.anaenddate
and a.metadata->>'ListId' in ('10277813', '10277802')
group by 1,2,3,4,5,6) A) a
group by 1,2
order by 1,2;



---- Exhibitor Profile Views (Old)

select application_id as "Application ID"
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Profile View Count"
     , count(distinct global_user_id) as "Unique User Count"
from (
select *
from public.fact_views_new views
join jt.ubm_events_users users
on views.application_id = lower(users.applicationid)
and views.global_user_id = lower(users.globaluserid)
where views.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and views.created >= users.anastartdate
and views.created < users.anaenddate 
and views.identifier = 'item'
and views.metadata->>'type' = 'exhibitor') a
group by 1,2
order by 1,2;


--- Exhibitor Profile Views (New)

select views.application_id as "Application ID"
     , views.device_type as "Device Type"
     , count(*) as "Exhibitor Profile Views"
     , count(distinct views.global_user_id) as "Unique User Count"
from public.fact_views_live views
join jt.ubm_events_users users
on views.global_user_id = lower(users.globaluserid)
and views.application_id = lower(users.applicationid)
where views.identifier = 'item'
and views.created >= users.anastartdate
and views.created < users.anaenddate
and views.metadata->>'ItemId' in (select distinct itemid::varchar
                           from ratings_item
                           where parenttopicid in (10277813, 10277802)
                           and isarchived = false
                           and isdisabled = 0)
group by 1,2
order by 1,2;


---- Exhibitor Map Views from Profile (Old)

select actions.application_id as "Application ID"
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Map View from Profile"
     , count(distinct actions.global_user_id) as "Unique User Count"
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
where actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'exhibitorprofilebutton'
and actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.metadata->>'type' = 'map'
group by 1,2
order by 1,2;

select *
from fact_actions_new
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'itembutton' limit 10;

---- Exhibitor Map Views from Profile (New)

select actions.application_id as "Application ID"
     , actions.device_type as "Device Type"
     , count(*) as "Exhibitor Map View from Profile"
     , count(distinct actions.global_user_id) as "Unique User Count"
from public.fact_actions_live actions
join jt.ubm_events_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
where actions.identifier = 'exhibitorProfileButton'
and actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.metadata->>'Type' = 'map'
group by 1,2
order by 1,2;



select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) "Exhibitor Bookmark Total"
     , count(distinct global_user_id) as "Unique User Count"
from (
select actions.application_id
     , actions.global_user_id
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as device_type
     , actions.metadata->>'itemid' as exhibitor_itemid
     , min(actions.created) as bookmark_datetime
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') items
on cast(actions.metadata->>'itemid' as int) = items.itemid
where actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'bookmarkbutton'
and actions.created >= users.anastartdate
and actions.created < users.anaenddate
group by 1,2,3,4) a
group by 1,2
order by 1,2;




select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) "Exhibitor Bookmark Total"
     , count(distinct global_user_id) as "Unique User Count"
from (
select actions.application_id
     , actions.global_user_id
     , device_type
     , actions.metadata->>'ItemId' as exhibitor_itemid
     , min(actions.created) as bookmark_datetime
from fact_actions_live actions
join jt.ubm_events_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') items
on cast(actions.metadata->>'ItemId' as int) = items.itemid
where actions.identifier = 'bookmarkButton'
and actions.application_id in ('7c56bc3c-b8bd-42a9-b11b-6b221b661c31', 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5')
and actions.metadata->>'ToggledTo' = 'on'
group by 1,2,3,4) a
group by 1,2
order by 1,2;





select distinct surveyid
from ratings_surveys 
where /*applicationid = '616449EB-8D8B-43C8-A886-57567B3EFE83'
or*/ applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
or applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31';
-- 41147, 29839, 41146

select *
from ratings_surveyquestions
where surveyid in (41147, 29839, 41146);


select users.applicationid as "Application ID"
     , users.usercnt as "Total Registered User Count"
     , count(*) as "Survey Complete User Count"
     , count(*)::decimal(8,2)/users.usercnt::decimal(8,2) as "Survey Complete User %"
from (select distinct userid
from ratings_surveyresponses
where surveyquestionid in (select surveyquestionid
from ratings_surveyquestions
where surveyid in (41147, 29839, 41146))) surveys
join jt.ubm_events_users users
on surveys.userid = users.userid
group by 1,2;

select application_id
     , metadata->>'Url' as "App Section Visit"
     , count(*) as "App Section Visit Count"
from fact_actions_live
where identifier = 'menuItem'
and application_id in ('7c56bc3c-b8bd-42a9-b11b-6b221b661c31', 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5')
and global_user_id in (
select distinct lower(users.globaluserid)
from (select distinct userid
from ratings_surveyresponses
where surveyquestionid in (select surveyquestionid
from ratings_surveyquestions
where surveyid in (41147, 41146))) surveys
join jt.ubm_events_users users
on surveys.userid = users.userid)
group by 1,2
order by 3 desc;


-------------OLD STUFF ------------------

-- Get the Binary Version for Each Event (Old Sessions)
drop table if exists jt.ubm_events_old_sessions_agg;
create temporary table jt.ubm_events_old_sessions_agg as
select users.applicationid
     , users.name
     , old_sessions.binary_version
     , case
          when old_sessions.app_type_id in (1,2) then 'ios'
          when old_sessions.app_type_id = 3 then 'android'
          else 'html5'
       end as device_type
     , users.usercnt
     , count(distinct old_sessions.user_id) as regusercnt
     , count(case when old_sessions.user_id is not null then 1 else null end) as oldsessioncnt
from jt.ubm_events_users users
join (select *
      from public.fact_sessions_new 
      where metrics_type_id = 1
      and application_id in (select distinct lower(applicationid)
                             from jt.ubm_events)) old_sessions
on lower(users.applicationid) = old_sessions.application_id 
and users.userid = old_sessions.user_id
and old_sessions.start_date >= users.
group by 1,2,3,4,5;







-- Get the Binary Version for Each Event (New Sessions)
drop table if exists jt.ubm_events_new_sessions_agg;
create temporary table jt.ubm_events_new_sessions_agg as
select users.applicationid
     , users.name
     , new_sessions.binary_version
     , new_sessions.device_type
     , users.usercnt
     , count(distinct new_sessions.global_user_id) as newsessionusercnt
     , count(case when new_sessions.global_user_id is not null then 1 else null end) as newsessioncnt
from jt.ubm_events_users users
join (select *
      from public.fact_sessions_live 
      where identifier = 'start'
      and application_id in (select distinct lower(applicationid)
                             from jt.ubm_events)) new_sessions
on lower(users.applicationid) = new_sessions.application_id 
and lower(users.globaluserid) = new_sessions.global_user_id
group by 1,2,3,4,5;



-- Get the number of Exhibitor Micro Apps clicks.

select device_type
     , metadata->>'Url' as "Menu Selection"
     , count(*) as clickcnt
from fact_actions_live actions
join ubm_events_users users
on actions.global_user_id = users.globaluserid

where actions.identifier = 'menuItem'
and a.created >= '2015-11-17 00:00:00'
and a.created < '2015-12-18 00:00:00'
group by 1,2
order by 3 desc;


select new_actions.*
     , substring(new_actions.metadata ->> 'Url' from 'item/')
from ubm_events_users users
join fact_actions_live new_actions
on lower(users.globaluserid) = new_actions.global_user_id
where new_actions.identifier = 'menuItem' 
and metadata ->> 'Url' like '%item%'  limit 10;



select application_id
     , global_user_id
     , device_id
     , created
     , device_os_version
     , binary_version
     , device_type
     , mmm_info
from fact_actions_live
where application_id in (select lower(applicationid)
                         from ubm_events)
and identifier = 'menuItem';
                         
                         
select application_id
     , global_user_id
     , device_id
     , created
     , device_os_version
     , binary_version
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id = 3 then 'android'
         else 'html5'
       end as device_type
     , mmm_info
from fact_actions
where application_id in (select lower(applicationid)
                         from ubm_events)
                ;




-- CPhI Worldwide 2015
select distinct binary_version
     , app_type_id
from fact_sessions_new a
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and 
-- Android: 5.9.2.0, iOS: 5.9.0

-- Fi Europe
select distinct binary_version
     , app_type_id
from fact_sessions_new
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5';
-- Android: 5.19.1.0; iOS: 5.19.0

-- CPhI India
select distinct binary_version
     , app_type_id
from fact_sessions_new
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31';
-- Android: 5.9.2.0, iOS: 5.9.0

-- Get the Binary Version for Each Event (New Sessions)

-- CPhI Worldwide 2015
select distinct binary_version
     , device_type
from fact_sessions_live
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83';
-- Android: 5.24.1.0; iOS: 5.24.2

-- Fi Europe
select distinct binary_version
     , device_type
from fact_sessions_live
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5';
-- Android: 5.24.1.0; iOS: 5.24.2

-- CPhI India 
select distinct binary_version
     , device_type
from fact_sessions_live
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31';
-- Android: 5.24.1.0; iOS: 5.24.2

-- % of Old Sessions

-- CPhI Worldwide 2015
select count(case when app_type_id in (1,2) then 1 else null end) as iosoldcnt
     , count(case when app_type_id = 3 then 1 else null end) as androidoldcnt
     , count(case when app_type_id = 4 then 1 else null end) as html5oldcnt
from fact_sessions_new
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83';
-- iOS: 89970
-- Android: 34928
-- HTML5: 28

select count(case when device_type = 'ios' then 1 else null end) as iosnewcnt
     , count(case when device_type = 'android' then 1 else null end) as androidnewcnt
from fact_sessions_live
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83';
-- iOS: 2952
-- Android: 3071

-- Fi Europe
select count(case when app_type_id in (1,2) then 1 else null end) as iosoldcnt
     , count(case when app_type_id = 3 then 1 else null end) as androidoldcnt
     , count(case when app_type_id = 4 then 1 else null end) as html5oldcnt
from fact_sessions_new
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5';
-- iOS: 175
-- Android: 9
-- HTML5: 30

select count(case when device_type = 'ios' then 1 else null end) as iosnewcnt
     , count(case when device_type = 'android' then 1 else null end) as androidnewcnt
from fact_sessions_live
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5';
-- iOS: 41,612
-- Android: 19,339

-- CPhI India
select count(case when app_type_id in (1,2) then 1 else null end) as iosoldcnt
     , count(case when app_type_id = 3 then 1 else null end) as androidoldcnt
     , count(case when app_type_id = 4 then 1 else null end) as html5oldcnt
from fact_sessions_new
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31';
-- iOS: 139
-- Android: 164
-- HTML5: 32

select count(case when device_type = 'ios' then 1 else null end) as iosnewcnt
     , count(case when device_type = 'android' then 1 else null end) as androidnewcnt
from fact_sessions_live
where application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31';
-- iOS: 8824
-- Android: 15416


select app_type_id
     , count(*)
from (select *
      from fact_actions
      where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
      and lower(identifier) = 'enterlistsearchtextfield'
      and metadata->>'listid' = '10276204'
      union
      select *
      from fact_actions_new
      where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
      and lower(identifier) = 'enterlistsearchtextfield'
      and metadata->>'listid' = '10276204') a
group by 1;

select max(created)
from fact_actions;
-- 2015-09-25 03:06:56

select min(created)
     , max(created)
from fact_actions_new
where extract(year from created) >= 2015;

-- Increase Number of Attendees and Exhibitors





-- Increase Engagement within Both Attendees and Exhibitors





-- Increase the User Experience for both Attendees and Exhibitors.



----

select *
from authdb_applications
where lower(applicationid) = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5';

select *
from ratings_timezones
where timezoneid = 38;



select *
from ratings_topic
where lower(applicationid) = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and listtypeid = 3
and ishidden = false;
-- topicid: 10277813

-- Count Exhibitor Menu Item Clicks (Getting Close to the CMS App Section Visits)
select device_type
     , metadata->>'Url' as "Menu Selection"
     , count(*) as clickcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as globaluserid 
      from authdb_is_users
      where isdisabled = 0) b
on a.global_user_id = b.globaluserid
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5' 
and identifier = 'menuItem'
and a.created >= '2015-11-17 00:00:00'
and a.created < '2015-12-18 00:00:00'
group by 1,2
order by 3 desc;

-- 6029
-- 5856


select *
from fact_views_live a
join (select distinct lower(globaluserid) as globaluserid 
      from authdb_is_users
      where isdisabled = 0) b
on a.global_user_id = b.globaluserid
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5' 
and identifier = 'menuItem'
and a.created >= '2015-11-17 00:00:00'
and a.created < '2015-12-18 00:00:00';      





