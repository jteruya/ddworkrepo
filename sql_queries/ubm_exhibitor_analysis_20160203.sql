
-- OVERALL BACKGROUND: This file details the steps taken to get the results presented in the attachment "UBM_Exhibitor_Analysis_20160203.xlsx".
--                     Each step includes background and/or the purpose for each SQL query to justify the reasons for pulling the data in the form that
--                     it is in.  With regard to the metrics themselves there was a large refresh that occurred this Fall betweeen CPhI Worldwide and
--                     CPhI India/Fi Europe.  Because of this, attempting to get the counts for these two groups requires pulling from different
--                     tables where a prefix in the action/view table name of "_new" is for old metrics and "_live" is for new metrics.

-- STEP 1:
-- CREATE STAGING TABLE: jt.ubm_events
-- PURPOSE: This contains metadata about the events that are being analyzed as well as storing the analysis timeframe
--          which is 2 weeks before the start date and 2 weeks after the enddate.
drop table if exists jt.ubm_events;
create table jt.ubm_events as
select applicationid
     , bundleid
     , name
     , timezoneid
     , startdate
     , enddate
     , canregister
     -- Calculate Analysis Start Date
     , (startdate - interval '2 week') as anastartdate
     -- Calculate Analyais End Date
     , (enddate + interval '2 week' + interval '1day') as anaenddate
from public.authdb_applications
where applicationid = '616449EB-8D8B-43C8-A886-57567B3EFE83'
or applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
or applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31';

-- STEP 2:
-- PURPOSE: Query the events metadata from STEP 1 to the excel attachment.
-- SQL RESULT: Results pasted in the excel file under the "EVENTS" section.
select applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Start Date"
     , enddate as "End Date"
     , anastartdate as "Analysis Start Date"
     , anaenddate as "Analysis End Date"
from jt.ubm_events
order by startdate, applicationid;

-- STEP 3:
-- BACKGROUND: A topicid in our data is an identifier that associates 
--             lists of items (e.g. speakers, sessions, exhibitors, etc.).
--             In this query, I'm trying to get those lists that are
--                (1) exhibitors (listtypeid = 3) and 
--                (2) not hidden in the app (ishidden = false)
-- PURPOSE: Get the exhibitor topic ids for each of the events which are the ids of the exhibitor lists.
-- SQL RESULT:
-- The following are the associated topic ids (sometimes referenced as "listid") which will be used in subsequent queries.
--      applicationId: 7C56BC3C-B8BD-42A9-B11B-6B221B661C31, topicId: 10277802
--      applicationId: E7DBE508-1E84-4EF9-BF3D-577C789C4DE5, topicId: 10277813
--      applicationId: 616449EB-8D8B-43C8-A886-57567B3EFE83, topicId: 10276204
select topics.*
from ratings_topic topics
join jt.ubm_events events
on topics.applicationid = events.applicationid
-- Condition (1)
where listtypeid = 3
-- Condition (2)
and ishidden = false;

-- STEP 4:
-- CREATE STAGING TABLE: jt.ubm_events_users
-- BACKGROUND: We are trying to get the list of users for each event.  The list will consist of the following conditions:
--             (1) only distinct users (no duplicates)
--             (2) only users that have NOT been deleted in the CMS (isdisabled = 0)  
--             (3) the total count of all users in the event
-- PURPOSE: Get all the unique app users (attendees) associated with the three events that are nondisabled users in the CMS.
drop table if exists jt.ubm_events_users;
create table jt.ubm_events_users as
       -- Condition (1)
select distinct events.applicationid
     , name
     , timezoneid
     , startdate
     , enddate
     , anastartdate
     , anaenddate
      -- Condition (3)
     , count(*) over (partition by events.applicationid) as usercnt
     , users.userid
     , users.globaluserid
from public.authdb_is_users users
join jt.ubm_events events
on users.applicationid = events.applicationid
-- Condition (2)
where isdisabled = 0;

-- STEP 5: Get the total number of clicks and the unique app users on the "Exhibitor" microapp in the global navigation menu.
-- BACKGROUND: The app section visits metric ("menuitem") fires each time a user clicks on an option in the global navigation menu of 
--             the app.  We can simply aggregate these clicks for the "Exhibitor" option across events using the topic pulled in STEP 3
--             to identifier the exhibitor menu option.  This number should align with the number in "App Section Visits" card in the CMS with only 
--             a small amount of varianace.  As mentioned, the data we have access to as analysts is upstream of the CMS but our numbers are
--             very close to the CMS' numbers for this stat.
-- SUBSTEPS: 5A, 5B and 5C

-- SUBSTEP 5A:
-- PURPOSE: Get the total number of visits and unique users to the "Exhibitor" microapp in the old actions table for CPhI Worldwide.
-- NOTE: The android version of this metric doesn't fire for Android in the old metrics.  This is a confirmed
--       metrics bug for Android in the app version.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "APP SESSION VISITS BY EVENT, DEVICE TYPE" table.
--             Because of the android metrics issue (it doesn't fire), the android row for this event has been blacked out.
select application_id as "Application ID"
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor App Section Visit Count"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'menuitem'
and actions.metadata->>'listid' = '10276204'
group by 1,2
order by 1,2;

-- SUBSTEP 5B:
-- PURPOSE: Get the total number of visits and unique users to the "Exhibitor" microapp in the new actions table for CPhI India and Fi Europe.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "APP SESSION VISITS BY EVENT, DEVICE TYPE" table.
select application_id as "Application ID"
     , device_type as "Device Type"
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
group by 1,2
order by 1,2;

-- SUBSTEP 5C:
-- PURPOSE: Aggregate by events.  Done in Excel.
-- RESULT: Results under the "APP SESSION VISITS BY EVENT" section.

-- STEP 6: Get the total number of highlights of the exhibitor search box and the unique app users that do these actons.
-- BACKGROUND: The action metric that tracks highlighting of the search box ("enterlistsearchtextfield") in the Exhibitor microapp fires each time a user 
--             clicks on the search box to begin a search.  We will simply aggregate this metric if it fires when a user is in the Exhibitor microapp using
--             the topicids pulled in STEP 3.
-- SUBSTEPS: 6A, 6B and 6C

-- SUBSTEP 6A:
-- PURPOSE: Get the total number of Exhibitor List Search Highlighting and unique users that do this action in the old actions table for CPhI Worldwide.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR SEARCH (HIGHLIGHT SEARCH BOX) BY EVENT, DEVICE TYPE" table.
select application_id as "Application ID"
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Search Box Highlight"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_actions_new actions
join jt.ubm_events_users users
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where actions.created >= users.anastartdate
and actions.created < users.anaenddate
and actions.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and actions.identifier = 'enterlistsearchtextfield'
and actions.metadata->>'listid' in ('10276204')
group by 1,2
order by 1,2;

-- SUBSTEP 6B:
-- PURPOSE: Get the total number of Exhibitor List Search Highlighting and unique users that do this action in the new actions table for CPhI India and Fi Europe.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR SEARCH (HIGHLIGHT SEARCH BOX) BY EVENT, DEVICE TYPE" table.
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

-- SUBSTEP 6C:
-- PURPOSE: Aggregate across events.  Done in Excel.
-- RESULT: Results under the "EXHIBITOR SEARCH (HIGHLIGHT SEARCH BOX) BY EVENT" section.

-- STEP 7:
-- PURPOSE: Total number of exhibitor searches in the exhibitor microapp.
-- BACKGROUND: The exhibitor search metric ("submitlistsearch") fires once for each character typed into the exhibitor search text box.
--             For example, if I wanted to look for the Exhibitor "UBM", I would type "u" then "b" then "m".  As I type these characters
--             a metrics will fire each time I type a character and each of the metrics that fire will capture the string in the text box.
--             To cut down on this number, we've decided to only count unique searches where a unique search is defined as for every user:
--                     (1) The beginning character (in the example above this would be "u") is the same.
--                     (2) The minute of the day is the same.
--             This logic will approximate the "true" number of searches that a user attempts in the search box.
-- SUBSTEPS: 7A, 7B and 7C

-- SUBSTEP 7A:
-- PURPOSE: Use old metrics to get exhibitor searches for CPhI Worldwide.
-- NOTE: This metric was not yet released for this app's version.  No metrics captured.
-- SQL RESULT: Because of the metrics issue, results for CPhI Worldwide in the "EXHIBITOR SEARCH (TYPE IN SEARCH BOX) BY EVENT, DEVICE TYPE" table
--             has been blacked out.

-- SUBSTEP 7B:
-- PURPOSE: Use new metrics to get exhibitor searches for CPhI India and Fi Europe.
-- NOTE: This metric for iOS doesn't seem to fire all of the time and underrepresenting the number of searches.  I've confirmed this on test devices which explains the low counts.
-- SQL RESULT: Because of the metrics unreliability for iOS, results for CPhI India and Fi Europe in the "EXHIBITOR SEARCH (TYPE IN SEARCH BOX) BY EVENT, DEVICE TYPE" table
--             has been bolded and highlighted.  This is not blacked out because the metrics are firing some of the time.
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) as "Exhibitor Search Count"
     , count(distinct global_user_id) as "Unique User Count"
     , count(case when resultcnt = '0' then 1 else null end) as "Exhibitor Search (No Results) Count"
     , count(distinct case when resultcnt = '0' then global_user_id else null end) as "Unique User Count"
from (select distinct application_id 
           , global_user_id
           , device_type
           , device_id
           , finalcreated
           , lastsearchterm
           , resultcnt
      from (select a.application_id
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
            group by 1,2,3,4,5,6
            ) A
       ) a
group by 1,2
order by 1,2;

-- SUBSTEP 7C:
-- PURPOSE: Aggregate across events.  Done in Excel.
-- RESULT: Results under the "EXHIBITOR SEARCH (TYPE IN SEARCH BOX) BY EVENT" section.

-- STEP 8: Total number of exhibitor profile views in the exhibitor microapp.
-- BACKGROUND: The exhibitor profile view metric ("item") fires each time an exhibitor profile
--             is viewed by a user (attendee).  This will measure the number of profile views that are exhibitors
--             based on the topicids pulled in STEP 3.
-- SUBSTEPS: 8A, 8B and 8C

-- SUBSTEP 8A:
-- PURPOSE: Use old metrics to get exhibitor profile views for CPhI Worldwide.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR PROFILE VIEW BY EVENT, DEVICE TYPE" table.
select application_id as "Application ID"
     , case
          when app_type_id in (1,2) then 'ios'
          when app_type_id in (3) then 'android'
          else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor Profile View Count"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_views_new views
join jt.ubm_events_users users
on views.application_id = lower(users.applicationid)
and views.global_user_id = lower(users.globaluserid)
where views.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and views.created >= users.anastartdate
and views.created < users.anaenddate 
and views.identifier = 'item'
and views.metadata->>'type' = 'exhibitor'
group by 1,2
order by 1,2;

-- SUBSTEP 8B: 
-- PURPOSE: Use newq metrics to get exhibitor profile views for CPhI India and Fi Europe.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR PROFILE VIEW BY EVENT, DEVICE TYPE" table.
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

-- SUBSTEP 8C:
-- PURPOSE: Aggregate across events.  Done in Excel.
-- RESULT: Results under the "EXHIBITOR PROFILE VIEW BY EVENT" section.

-- STEP 9: Total number of exhibitor bookmarks.
-- BACKGROUND: The bookmark action metric ("bookmarkbutton") fires each time a user bookmarks an item (e.g. session, exhibitor, etc.) in the app.
--             The bookmars action metrics should be associated with exhibitors only using the topicids pulled from STEP 3.
--             The exhibitor bookmark should be counted based on the following conditions:
--             (1) a unique app user
--             (2) a unique exhibitor
--             (3) bookmark button is turned 'on' ('off' is not counted)
--             (4) the exhibitor (item) has not been deleted from the CMS
-- SUBSTEPS: 9A, 9B and 9C


-- SUBSTEP 9A:
-- PURPOSE: Use old metrics to get exhibitor bookmark actions for CPhI Worldwide.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR BOOKMARKS BY EVENT, DEVICE TYPE" table.
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) "Exhibitor Bookmark Total"
     , count(distinct global_user_id) as "Unique User Count"
from (
       -- Condition (1) and (2)
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
-- Condition (4)
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
-- Condition (3)
and actions.metadata->>'toggledto' = 'on'
group by 1,2,3,4) a
group by 1,2
order by 1,2;

-- SUBSTEP 9B:
-- PURPOSE: Use new metrics to get exhibitor bookmark actions for CPhI India and Fi Europe.
-- SQL RESULT: The results of the below SQL are pasted in the excel file under the "EXHIBITOR BOOKMARKS BY EVENT, DEVICE TYPE" table.
select application_id as "Application ID"
     , device_type as "Device Type"
     , count(*) "Exhibitor Bookmark Total"
     , count(distinct global_user_id) as "Unique User Count"
from (
       -- Condition (1) and (2)
select actions.application_id
     , actions.global_user_id
     , device_type
     , actions.metadata->>'ItemId' as exhibitor_itemid
     , min(actions.created) as bookmark_datetime
from fact_actions_live actions
join jt.ubm_events_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
-- Condition (4)
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
-- Condition (3)
and actions.metadata->>'ToggledTo' = 'on'
group by 1,2,3,4) a
group by 1,2
order by 1,2;

-- SUBSTEP 9C:
-- PURPOSE: Aggregate across events.  Done in Excel.
-- RESULT: Results under the "EXHIBITOR BOOKMARKS BY EVENT" section.

-- STEP 10: Create exhibitor funnel using the unique user counts.
-- BACKGROUND: The actions or view counts gathered from STEP 5 - STEP 9 cannot be compared directly because the relationships
--             between these counts can be many to many.  A better way to see a relationship would be to compare the unique users
--             counts that was pulled for each of these steps.  The funnel percentages in excel are calculated based on the following relationships:
--                (1) The users that click on the exhibitor search box clicked on the Exhibitor microapp in the global navigation menu.
--                (2) The users that type in the search box must be from (1)
--                (3) The users that view an exhibitor profile are from (1) because a user could either search the list or browse the list.
--                (4) The users that bookmark and exhibitor are from (1) because a user can bookmark an exhibitor in the list or in the profile.
--        
--             All metrics issues (either bolded or highlighted in earlier steps) are not calculated and bolded out.

-- RESULT: Results under the "EXHIBITOR FUNNEL" table.