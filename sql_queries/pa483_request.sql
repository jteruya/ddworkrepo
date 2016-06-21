-- BOX: Robin US

-- Check to see if event is on Robin US
-- YES: '3e347a0b-c8be-474d-b713-95c5cab29197', '65859721-fe52-4a66-89f3-e0c88545a193', 'df3fb344-5092-4fc1-af5f-289a0684c685'
-- NO: '3de86a00-6206-4385-90a5-8bc2acae3a81'
select *
from authdb_applications
where lower(applicationid) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','3de86a00-6206-4385-90a5-8bc2acae3a81','df3fb344-5092-4fc1-af5f-289a0684c685');

select applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Start Date"
     , enddate as "End Date"
     , usersactive as "Active Users"
     , usersengaged as "Engaged Users"
     , posts as "Updates"
     , likes as "Likes"
     , comments as "Comments"
     , ratings as "Ratings"
     , totalbookmarks as "Bookmarks"
     , checkins as "Check-Ins"
from eventcube.eventcubesummary
where lower(applicationid) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','df3fb344-5092-4fc1-af5f-289a0684c685');

select application_id
     , sum(action_cnt) as action_cnt
     , count(distinct global_user_id) as user_cnt
     , count(distinct device_id) as device_cnt
     , count(distinct case when device_type = 'ios' then device_id else null end) as ios_device_cnt
     , count(distinct case when device_type = 'android' then device_id else null end) as android_device_cnt
     , count(distinct case when device_type = 'html5' then device_id else null end) as html5_device_cnt
from (select application_id
           , global_user_id
           , device_id
           , device_type
           , count(*) as action_cnt
      from fact_actions_live
      where lower(application_id) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','df3fb344-5092-4fc1-af5f-289a0684c685')
      group by 1,2,3,4
      union all
      select application_id
           , global_user_id
           , device_id
           , case
               when app_type_id in (1,2) then 'ios'
               when app_type_id in (3) then 'android'
               else 'html5'
             end as device_type
           , count(*) as action_cnt
      from fact_actions
      where lower(application_id) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','df3fb344-5092-4fc1-af5f-289a0684c685')
      group by 1,2,3,4
      union all
      select application_id
           , global_user_id
           , device_id
           , case
               when app_type_id in (1,2) then 'ios'
               when app_type_id in (3) then 'android'
               else 'html5'
             end as device_type
           , count(*) as action_cnt
      from fact_actions_new
      where lower(application_id) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','df3fb344-5092-4fc1-af5f-289a0684c685')
      group by 1,2,3,4
     ) a
join authdb_is_users b
on a.application_id = lower(b.applicationid)
and a.global_user_id = lower(b.globaluserid)
where lower(application_id) in ('3e347a0b-c8be-474d-b713-95c5cab29197','65859721-fe52-4a66-89f3-e0c88545a193','df3fb344-5092-4fc1-af5f-289a0684c685')
and b.isdisabled = 0
group by 1;

-- BOX: Robin EU

select applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Start Date"
     , enddate as "End Date"
     , usersactive as "Active Users"
     , usersengaged as "Engaged Users"
     , posts as "Updates"
     , likes as "Likes"
     , comments as "Comments"
     , ratings as "Ratings"
     , totalbookmarks as "Bookmarks"
     , checkins as "Check-Ins"
from eventcube.eventcubesummary
where lower(applicationid) in ('3de86a00-6206-4385-90a5-8bc2acae3a81');

select application_id
     , sum(action_cnt) as action_cnt
     , count(distinct global_user_id) as user_cnt
     , count(distinct device_id) as device_cnt
     , count(distinct case when device_type = 'ios' then device_id else null end) as ios_device_cnt
     , count(distinct case when device_type = 'android' then device_id else null end) as android_device_cnt
     , count(distinct case when device_type = 'html5' then device_id else null end) as html5_device_cnt
from (select application_id
           , global_user_id
           , device_id
           , device_type
           , count(*) as action_cnt
      from fact_actions_live
      where lower(application_id) in ('3de86a00-6206-4385-90a5-8bc2acae3a81')
      group by 1,2,3,4
      union all
      select application_id
           , global_user_id
           , device_id
           , case
               when app_type_id in (1,2) then 'ios'
               when app_type_id in (3) then 'android'
               else 'html5'
             end as device_type
           , count(*) as action_cnt
      from fact_actions
      where lower(application_id) in ('3de86a00-6206-4385-90a5-8bc2acae3a81')
      group by 1,2,3,4
      union all
      select application_id
           , global_user_id
           , device_id
           , case
               when app_type_id in (1,2) then 'ios'
               when app_type_id in (3) then 'android'
               else 'html5'
             end as device_type
           , count(*) as action_cnt
      from fact_actions_new
      where lower(application_id) in ('3de86a00-6206-4385-90a5-8bc2acae3a81')
      group by 1,2,3,4
     ) a
join authdb_is_users b
on a.application_id = lower(b.applicationid)
and a.global_user_id = lower(b.globaluserid)
where lower(application_id) in ('3de86a00-6206-4385-90a5-8bc2acae3a81')
and b.isdisabled = 0
group by 1;

