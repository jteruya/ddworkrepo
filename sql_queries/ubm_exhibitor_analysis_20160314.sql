-- OLD QUERY (QUERY #1)
-- This is the original sql query which was in the attachment "ubm_exhibitor_analysis_20160203.sql".  To refresh, this query doesn't give you
-- the Android number because for the version of the app used by "CPhi Worldwide 2015", the metric "menuitem" did not fire for Android.
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

-- OLD QUERY (QUERY #1) RESULTS:
-- The results from this query give you the following result which is the same answer provided in my last email.
-- "Application ID": 616449eb-8d8b-43c8-a886-57567b3efe83, "Device Type": ios, "Exhibitor App Section Visit Count": 10178, "Unique User Count": 1527

-- NEW QUERY (QUERY #2)
-- After you asked, I thought about ways that one might infer the Exhibitor app section visits for Android.  Luckily, there is a way to infer this.
-- We have a view metric (identifier = 'list') that fires each time a user is on the Exhibitor list view which can generally only be accessed via a click from the global
-- navigation menu which is the count we are looking for.  If we count the number of these list metrics (specifically for the Exhibitor list), we can
-- get the count you are looking for indirectly.  Below is the query for this:

select application_id as "Application ID"
     , case
         when app_type_id in (1,2) then 'ios'
         when app_type_id in (3) then 'android'
         else 'html5'
       end as "Device Type"
     , count(*) as "Exhibitor App Section Visit Count"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_views_new views
join jt.ubm_events_users users
on views.application_id = lower(users.applicationid)
and views.global_user_id = lower(users.globaluserid)
where views.created >= users.anastartdate
and views.created < users.anaenddate
and views.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
-- This is the new view identifier
and views.identifier = 'list'
-- This is for Android only
and app_type_id = 3
-- We are only looking at list views where they pertain to Exhibitor Lists
and (views.metadata->>'type' = 'exhibitor' or views.metadata->>'type' = 'exhibitors')
group by 1,2
order by 1,2;

-- NEW QUERY (QUERY #2) RESULTS:
-- The results from this query give you the following result for Android.
-- "Application ID": 616449eb-8d8b-43c8-a886-57567b3efe83, "Device Type": android, "Exhibitor App Section Visit Count": 10738, "Unique User Count": 670






