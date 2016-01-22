drop table if exists jt.seamless_login_first_session_info;
--drop table if exists jt.seamless_login_first_session_info2;
drop table if exists jt.seamless_login_first_session_info_users;
drop table if exists jt.seamless_login_event_users;


select distinct a.application_id
     , a.user_id
     , a.first_session_date
     , b.device_id
     , b.app_type_id
into jt.seamless_login_first_session_info
from (select application_id
           , user_id
           , min(start_date) as first_session_date
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755')
      group by 1,2) a
join (select application_id
           , user_id
           , device_id
           , app_type_id
           , start_date
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755')) b
on a.application_id = b.application_id and a.user_id = b.user_id and a.first_session_date = b.start_date;

/*
select s.application_id
     , e.name
     , e.startdate
     , e.enddate
     , s.app_type_id
     , s.user_id
     , s.device_id
     , s.start_date as sessionstartdate
     , i.first_session_date as firstsessionstartdate
into jt.seamless_login_first_session_info2
from jt.seamless_login_first_session_info i
join (select * from fact_sessions where metrics_type_id = 1) s
on i.application_id = s.application_id and i.user_id = s.user_id
join (select distinct deviceid from jt.seamless_login) l
on lower(s.device_id) = lower(l.deviceid::varchar)
join jt.tm_eventcubesummary e
on lower(s.application_id) = lower(e.applicationid::varchar)
where lower(s.application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or lower(s.application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or lower(s.application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or lower(s.application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
or lower(s.application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or lower(s.application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or lower(s.application_id) = '85874647-b187-49ef-8a45-e3b5720e1755';
*/

select s.application_id
     , s.user_id
     , e.name
     , e.startdate
     , e.enddate
     , u.globaluserid
     , s.app_type_id
     , s.device_id
     , a.bundleid
     , g.emailaddress
     , g.firstname
     , g.username
     , g.phone
into jt.seamless_login_first_session_info_users
from (select distinct application_id
           , user_id
           , app_type_id
           , device_id
      from jt.seamless_login_first_session_info) s
join jt.tm_is_users u
on s.user_id = u.userid
join jt.tm_applications a
on s.application_id = a.applicationid::varchar
join jt.tm_globaluserdetails g
on g.globaluserid = u.globaluserid and g.bundleid = a.bundleid
join jt.tm_eventcubesummary e
on s.application_id = e.applicationid::varchar;


select distinct u.application_id
           , e.name
           , e.startdate
           , e.enddate
           , u.user_id
           , u.globaluserid
           , u.emailaddress
           , f.recipientemail
           , f.clicked_bnc_flag
           , u.app_type_id
           , case
               when f.clicked_bnc_flag = true and u.app_type_id = 3 and f.clicked_bnc_clientos = 'Android' then true
               when f.clicked_bnc_flag = true and u.app_type_id = 1 and f.clicked_bnc_devicetype = 'mobile' and f.clicked_bnc_clientos = 'iOS' then true
               when f.clicked_bnc_flag = true and u.app_type_id = 2 and f.clicked_bnc_devicetype = 'tablet' and f.clicked_bnc_clientos = 'iOS' then true
               else null
             end as clicked_bnc_device_match_flag
      into jt.seamless_login_event_users
      from jt.seamless_login_first_session_info_users u
      left join (select distinct applicationid 
                      , recipientemail
                      , clicked_bnc_flag
                      , clicked_bnc_clientos
                      , clicked_bnc_devicetype
                 from jt.seamless_fact_analysis 
                 where clicked_bnc_flag = true
                 and clicked_bnc_devicetype = 'mobile') f
      on u.emailaddress = f.recipientemail and u.application_id = f.applicationid::varchar
      /*left join (select distinct applicationid  
                      , recipientemail
                      , clicked_flag
                 from jt.seamless_fact_analysis 
                 where clicked_bnc_flag = false) g
      on u.emailaddress = g.recipientemail and u.application_id = g.applicationid::varchar*/
      join jt.tm_eventcubesummary e
      on u.application_id = e.applicationid::varchar;


/* Connect Email Funnel with 1st Session Device Type */

select application_id
     , name
     , startdate
     , enddate
     , count(*) as total_app_users
     --, count(case when clicked_flag is null then 1 else null end) as seamless_users_not_in_funnel
     --, count(case when clicked_flag = true then 1 else null end) as total_users_logged_in_with_seamless_users_in_funnel
     --, count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as seamless_users_no_click_in_funnel
     --, count(case when clicked_flag is null and emailaddress is null then 1 else null end) as seamless_users_no_email_address
     , count(case when clicked_bnc_flag = true then 1 else null end) as app_user_clicked_bnc
     , count(case when clicked_bnc_device_match_flag = true then 1 else null end) as seamless_user
     , count(case when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 1 else null end) as seamless_ios_user
     , count(case when clicked_bnc_device_match_flag = true and app_type_id in (3) then 1 else null end) as seamless_android_user
from jt.seamless_login_event_users
group by 1,2,3,4
order by 3,4;




drop table if exists jt.seamless_sessions_tracker;

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_id
     , a.globaluserid
     , a.emailaddress
     , case
         when clicked_bnc_device_match_flag is null and app_type_id in (1,2) then 'regular_ios_user'
         when clicked_bnc_device_match_flag is null and app_type_id in (3) then 'regular_android_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 'seamless_ios_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (3) then 'seamless_android_user'
       end as user_type
     , b.session_cnt
into jt.seamless_sessions_tracker
from jt.seamless_login_event_users a
join (select application_id
           , user_id
           , count(*) as session_cnt
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755') 
      group by 1,2) b
on a.application_id = b.application_id and a.user_id = b.user_id;




        

/* Session Counts */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_type_cnt
     , a.average_session_cnt
     , b.median_session_cnt
     , a.regular_user_cnt
     , a.average_regular_session_cnt
     , c.median_session_cnt as median_regular_session_cnt
     , a.seamless_user_cnt
     , a.average_seamless_session_cnt
     , d.median_session_cnt as median_seamless_session_cnt
     , a.regular_ios_user_cnt
     , a.average_ios_regular_session_cnt
     , e.median_session_cnt as median_ios_regular_session_cnt
     , a.regular_android_user_cnt
     , a.average_android_regular_session_cnt
     , f.median_session_cnt as median_android_regular_session_cnt
     , a.seamless_ios_user_cnt
     , a.average_ios_seamless_session_cnt
     , g.median_session_cnt as median_ios_seamless_session_cnt
     , a.seamless_android_user_cnt
     , a.average_android_seamless_session_cnt
     , h.median_session_cnt as median_android_seamless_session_cnt
from (select application_id
           , name
           , startdate
           , enddate
           , count(*) as user_type_cnt
           , avg(session_cnt) as average_session_cnt
           , count(case when user_type like 'regular%' then 1 else null end) as regular_user_cnt
           , avg(case when user_type like 'regular%' then session_cnt else null end) as average_regular_session_cnt
           , count(case when user_type like 'seamless%' then 1 else null end) as seamless_user_cnt
           , avg(case when user_type like 'seamless%' then session_cnt else null end) as average_seamless_session_cnt
           , count(case when user_type like 'regular_ios_user' then 1 else null end) as regular_ios_user_cnt
           , avg(case when user_type like 'regular_ios_user' then session_cnt else null end) as average_ios_regular_session_cnt
           , count(case when user_type like 'regular_android_user' then 1 else null end) as regular_android_user_cnt
           , avg(case when user_type like 'regular_android_user' then session_cnt else null end) as average_android_regular_session_cnt
           , count(case when user_type like 'seamless_ios_user' then 1 else null end) as seamless_ios_user_cnt
           , avg(case when user_type like 'seamless_ios_user' then session_cnt else null end) as average_ios_seamless_session_cnt
           , count(case when user_type like 'seamless_android_user' then 1 else null end) as seamless_android_user_cnt
           , avg(case when user_type like 'seamless_android_user' then session_cnt else null end) as average_android_seamless_session_cnt
      from jt.seamless_sessions_tracker
      group by 1,2,3,4) a
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      group by 1) b
on a.application_id = b.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular%'
      group by 1) c
on a.application_id = c.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless%'
      group by 1) d
on a.application_id = d.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular_ios_user'
      group by 1) e
on a.application_id = e.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular_android_user'
      group by 1) f
on a.application_id = f.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless_ios_user'
      group by 1) g
on a.application_id = g.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless_android_user'
      group by 1) h
on a.application_id = h.application_id;








drop table if exists jt.seamless_sessions_length_tracker;

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_id
     , a.globaluserid
     , a.emailaddress
     , case
         when clicked_bnc_device_match_flag is null and app_type_id in (1,2) then 'regular_ios_user'
         when clicked_bnc_device_match_flag is null and app_type_id in (3) then 'regular_android_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 'seamless_ios_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (3) then 'seamless_android_user'
       end as user_type
     , b.duration
into jt.seamless_sessions_length_tracker
from jt.seamless_login_event_users a
join (select applicationid
                , userid
                , enddate - startdate as duration
           from jt.tm_sessions
           where (applicationid = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
           or applicationid = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
           or applicationid = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
           or applicationid = '904434f2-c7c7-4c84-a972-bee9ef324900'
           or applicationid = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
           or applicationid = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
           or applicationid = '85874647-b187-49ef-8a45-e3b5720e1755')
           and apptypeid < 4
           and enddate is not null
           and enddate >= startdate) b
on a.application_id = b.applicationid::varchar and a.user_id = b.userid;





/* Session Lengths */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.average_session_duration
     , b.median_session_duration
     , a.average_regular_session_duration
     , c.median_session_duration as median_regular_session_duration
     , a.average_seamless_session_duration
     , d.median_session_duration as median_seamless_session_duration
     , a.average_ios_regular_session_duration
     , e.median_session_duration as median_ios_regular_session_duration
     , a.average_android_regular_session_duration
     , f.median_session_duration as median_android_regular_session_duration
     , a.average_ios_seamless_session_duration
     , g.median_session_duration as median_ios_seamless_session_duration
     , a.average_android_seamless_session_duration
     , h.median_session_duration as median_android_seamless_session_duration
from (select application_id
           , name
           , startdate
           , enddate
           , avg(duration) as average_session_duration
           , avg(case when user_type like 'regular%' then duration else null end) as average_regular_session_duration
           , avg(case when user_type like 'seamless%' then duration else null end) as average_seamless_session_duration
           , avg(case when user_type like 'regular_ios_user' then duration else null end) as average_ios_regular_session_duration
           , avg(case when user_type like 'regular_android_user' then duration else null end) as average_android_regular_session_duration
           , avg(case when user_type like 'seamless_ios_user' then duration else null end) as average_ios_seamless_session_duration
           , avg(case when user_type like 'seamless_android_user' then duration else null end) as average_android_seamless_session_duration
      from jt.seamless_sessions_length_tracker
      group by 1,2,3,4) a
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      group by 1) b
on a.application_id = b.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular%'
      group by 1) c
on a.application_id = c.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless%'
      group by 1) d
on a.application_id = d.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular_ios_user'
      group by 1) e
on a.application_id = e.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular_android_user'
      group by 1) f
on a.application_id = f.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless_ios_user'
      group by 1) g
on a.application_id = g.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless_android_user'
      group by 1) h
on a.application_id = h.application_id;







------------Everything Below is Old -----------

/*

drop table if exists jt.seamless_login_sessions;
drop table if exists jt.seamless_login_users;


-- Seamless Login Sessions
select s.application_id
     , e.name
     , e.startdate
     , e.enddate
     , s.app_type_id
     , s.user_id
     , s.device_id
     , s.start_date as sessionstartdate
into jt.seamless_login_sessions
from (select * from fact_sessions where metrics_type_id = 1) s
join (select distinct deviceid from jt.seamless_login) l
on lower(s.device_id) = lower(l.deviceid::varchar)
join jt.tm_eventcubesummary e
on lower(s.application_id) = lower(e.applicationid::varchar)
where lower(s.application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or lower(s.application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or lower(s.application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or lower(s.application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
or lower(s.application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or lower(s.application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or lower(s.application_id) = '85874647-b187-49ef-8a45-e3b5720e1755';






-- Seamless Login Users
select s.application_id
     , s.user_id
     , s.name
     , s.startdate
     , s.enddate
     , u.globaluserid
     , a.bundleid
     , g.emailaddress
     , g.firstname
     , g.username
     , g.phone
into jt.seamless_login_users
from (select distinct application_id
           , user_id
           , name
           , startdate
           , enddate
      from jt.seamless_login_sessions) s
join jt.tm_is_users u
on s.user_id = u.userid
join jt.tm_applications a
on s.application_id = a.applicationid::varchar
join jt.tm_globaluserdetails g
on g.globaluserid = u.globaluserid and g.bundleid = a.bundleid;

-- Connecting mailgun and seamless metrics
select application_id
     , name
     , startdate
     , enddate
     , count(*) as seamless_total_users
     , count(case when clicked_flag is null then 1 else null end) as seamless_users_not_in_funnel
     , count(case when clicked_flag = true then 1 else null end) as total_users_logged_in_with_seamless_users_in_funnel
     , count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as seamless_users_no_click_in_funnel
     , count(case when clicked_flag is null and emailaddress is null then 1 else null end) as seamless_users_no_email_address
from (select distinct u.application_id
           , e.name
           , e.startdate
           , e.enddate
           , u.user_id
           , u.globaluserid
           --, s.device_id
           , u.emailaddress
           , f.recipientemail
           , case
               when f.clicked_flag = true then true
               when g.clicked_flag = false then false
               else null
             end as clicked_flag
      from jt.seamless_login_users u
      left join (select distinct recipientemail
                      , clicked_flag
                 from jt.seamless_fact_analysis 
                 where clicked_flag = true) f
      on u.emailaddress = f.recipientemail
      left join (select distinct recipientemail
                      , clicked_flag
                 from jt.seamless_fact_analysis 
                 where clicked_flag = false) g
      on u.emailaddress = g.recipientemail
      join jt.tm_eventcubesummary e
      on u.application_id = e.applicationid::varchar
      ) a
group by 1,2,3,4
order by 3,4;


*/












