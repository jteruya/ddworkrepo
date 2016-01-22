drop table if exists jt.events_login_funnel_actions;
create table jt.events_login_funnel_actions as
select *
     , case
         when identifier = 'eventselectbutton' then metadata->>'applicationid'
         else null
       end as event_select_application_id
from fact_actions
where (identifier = 'enteremailtextfield' or identifier = 'submitemailbutton' or identifier = 'enterpasswordtextfield' or identifier = 'submitpasswordbutton' or identifier = 'eventselectbutton' or identifier = 'resetpasswordbutton' or identifier = 'submitresetpasswordbutton');

create index ndx_events_login_funnel_actions on jt.events_login_funnel_actions (bundle_id, global_user_id, identifier, created);


drop table if exists jt.events_login_funnel_views;

create table jt.events_login_funnel_views as
select *
     , case
         when identifier = 'eventselectbutton' then metadata->>'applicationid'
         else null
       end as event_select_application_id
from fact_views
where (identifier = 'enteremail' or identifier = 'enterpassword' or identifier = 'eventpicker' or identifier = 'profilefiller' or identifier = 'resetpassword' or identifier = 'remotessologin');

create index ndx_events_login_funnel_views on jt.events_login_funnel_views (bundle_id, global_user_id, identifier, created);


---------------------Bundle View Below-----------------------------

drop table if exists jt.bundle_login_view;

create table jt.bundle_login_view as
select a.bundle_id
     , case
         when b.bundle_id is not null then true
         else false
       end as enteremailflag
     , case
         when b.bundle_id is not null then b.min_created
         else null
       end as enteremailcreated       
     , case
         when c.bundle_id is not null then true
         else false
       end as enterpasswordflag
     , case
         when c.bundle_id is not null then c.min_created
         else null
       end as enterpasswordcreated  
     , case
         when d.bundle_id is not null then true
         else false
       end as eventpickerflag
     , case
         when d.bundle_id is not null then d.min_created
         else null
       end as eventpickercreated  
     , case
         when e.bundle_id is not null then true
         else false
       end as remotessologinflag
     , case
         when e.bundle_id is not null then e.min_created
         else null
       end as remotessologincreated       
     , case
         when f.bundle_id is not null then true
         else false
       end as profilefillerflag    
     , case
         when f.bundle_id is not null then f.min_created
         else null
       end as profilefillercreated       
from (select distinct lower(bundleid) as bundle_id
      from authdb_applications
      where startdate is not null
      and startdate >= '2015-05-01'
      and enddate < current_date) a
left join (select bundle_id
                , min(created) as min_created
           from jt.events_login_funnel_views
           where identifier = 'enteremail'
           group by 1) b
on a.bundle_id = b.bundle_id
left join (select bundle_id
                , min(created) as min_created
           from jt.events_login_funnel_views
           where identifier = 'enterpassword'
           group by 1) c
on a.bundle_id = c.bundle_id    
left join (select bundle_id
                , min(created) as min_created
           from jt.events_login_funnel_views
           where identifier = 'eventpicker'
           group by 1) d
on a.bundle_id = d.bundle_id   
left join (select bundle_id
                , min(created) as min_created
           from jt.events_login_funnel_views
           where identifier = 'remotessologin'
           group by 1) e
on a.bundle_id = e.bundle_id      
left join (select bundle_id
                , min(created) as min_created
           from jt.events_login_funnel_views
           where identifier = 'profilefiller'
           group by 1) f
on a.bundle_id = f.bundle_id;


drop table if exists jt.bundle_login_path;

create table jt.bundle_login_path as
select bundle_id
     , dense_rank() over (partition by 1 order by cast(case when enteremailflag is not null and enteremailflag is true then '|enteremail' else '' end || case when enterpasswordflag is not null and enterpasswordflag is true then '|enterpassword' else '' end || case when eventpickerflag is not null and eventpickerflag = true then '|eventpicker' else '' end || case when remotessologinflag is not null and remotessologinflag is true then '|remotessologin' else '' end || case when profilefillerflag is not null and profilefillerflag is true then '|profilefiller' else '' end as varchar(1000))) as login_path_id
     , cast(case when enteremailflag is not null and enteremailflag is true then '|enteremail' else '' end || case when enterpasswordflag is not null and enterpasswordflag is true then '|enterpassword' else '' end || case when eventpickerflag is not null and eventpickerflag = true then '|eventpicker' else '' end || case when remotessologinflag is not null and remotessologinflag is true then '|remotessologin' else '' end || case when profilefillerflag is not null and profilefillerflag is true then '|profilefiller' else '' end as varchar(1000)) as login_path
from jt.bundle_login_view;


--------User Level---------------------


--------User Session-----------------
---- 1.) Events Since 6/1
---- 2.) Events Finished by Yesterday
---- 3.) Events with at least 20 users

drop table if exists jt.login_app_all_registered_users;

create table jt.login_app_all_registered_users as
select lower(a.bundleid) as bundle_id
     , lower(a.applicationid) as application_id
     , a.name as event_name
     , a.startdate as event_start_date
     , a.enddate as event_end_date
     , lower(u.globaluserid) as global_user_id
     , u.userid as user_id
from authdb_applications a
join authdb_is_users u
on a.applicationid = u.applicationid
where u.isdisabled = 0
and a.startdate >= '2015-06-01'
and a.enddate < current_date
and lower(a.applicationid) in (select lower(applicationid) from authdb_is_users group by 1 having count(*) >= 20);


create index ndx_login_app_all_registered_users on jt.login_app_all_registered_users (application_id, global_user_id, user_id);


drop table if exists jt.login_app_user_app_session;

create table jt.login_app_user_app_session as
select a.*
     , b.start_date
from jt.login_app_all_registered_users a
join fact_sessions b
on a.application_id = b.application_id and a.user_id = b.user_id
where b.metrics_type_id = 1
and start_date >= '2015-05-01';



drop table if exists jt.login_app_user_login_view;

create table jt.login_app_user_login_view as
select a.bundle_id
     , a.global_user_id
     , b.enteremailtime
     , b.enterpasswordtime
     , b.eventpickertime
     , b.profilefillertime
     , c.enteremailtextfieldtime
     , c.submitemailbuttontime
     , c.enterpasswordtextfieldtime
     , c.submitpasswordbuttontime
     , c.eventselectbuttontime
from (select distinct bundle_id
           , global_user_id
      from jt.login_app_all_registered_users) a
left join (select bundle_id
                , global_user_id
                , min(case when identifier = 'enteremail' then created else null end) as enteremailtime
                , min(case when identifier = 'enterpassword' then created else null end) as enterpasswordtime
                , min(case when identifier = 'eventpicker' then created else null end) as eventpickertime
                , min(case when identifier = 'profilefiller' then created else null end) as profilefillertime
           from jt.events_login_funnel_views
           group by 1,2) b
on a.bundle_id = b.bundle_id and a.global_user_id = b.global_user_id
left join (select bundle_id
                , global_user_id
                , min(case when identifier = 'enteremailtextfield' then created else null end) as enteremailtextfieldtime
                , min(case when identifier = 'submitemailbutton' then created else null end) as submitemailbuttontime
                , min(case when identifier = 'enterpasswordtextfield' then created else null end) as enterpasswordtextfieldtime
                , min(case when identifier = 'submitpasswordbutton' then created else null end) as submitpasswordbuttontime
                , min(case when identifier = 'eventselectbutton' then created else null end) as eventselectbuttontime
           from jt.events_login_funnel_actions
           group by 1,2) c
on a.bundle_id = c.bundle_id and a.global_user_id = c.global_user_id;           









drop table if exists jt.login_app_user_login_path;

create table jt.login_app_user_login_path as
select bundle_id
     , global_user_id
     , cast(case when enteremailtime is not null then '|enteremail' else '' end || 
       case when enteremailtextfieldtime is not null then '|enteremailtextfield' else '' end || 
       case when submitemailbuttontime is not null then '|submitemailbutton' else '' end || 
       case when enterpasswordtime is not null then '|enterpassword' else '' end || 
       case when enterpasswordtextfieldtime is not null then '|enterpasswordtextfield' else '' end ||      
       case when submitpasswordbuttontime is not null then '|submitpasswordbutton' else '' end ||          
       case when eventpickertime is not null then '|eventpicker' else '' end || 
       case when eventselectbuttontime is not null then '|eventselectbutton' else '' end ||        
       case when profilefillertime is not null then '|profilefiller' else '' end as varchar(1000)) as login_path
from jt.login_app_user_login_view;











-- Pick Bundles that....
-- 1.) Only one event per bundle
-- 2.) Event is open register
-- 3.) Event occurs after 6/1
-- 4.) Event finished by yesterday
select distinct bundle_id
from jt.login_app_user_login_path a
where bundle_id not in (select distinct lower(bundleid) as bundle_id from authdb_applications where startdate < '2015-06-01' and enddate < current_date)
and bundle_id in (select lower(bundleid) as bundle_id from authdb_applications where canregister = true group by 1 having count(*) = 1);


select *
from authdb_applications
where lower(bundleid) = '6a169437-c304-4f63-bdc2-5b18d5255e89';



select bundle_id
     , login_path
     , count(*)
from jt.login_app_user_login_path
where bundle_id = '6a169437-c304-4f63-bdc2-5b18d5255e89'
group by 1,2
order by 3 desc



select *
from fact_sessions 
where upper(application_id) = '155B771E-840B-4E24-AC4F-120D4D05B480' and user_id = 44780231;

--Device ID: 104606F4-C643-4F49-8ACB-6F9357220DE5

select *
from fact_views 
where application_id = '155b771e-840b-4e24-ac4f-120d4d05b480'
and lower(device_id) = '104606f4-c643-4f49-8acb-6f9357220de5' 
and created >= '2015-08-07'

2015-08-07 17:26:45 S
2015-08-07 17:26:48 profilefiller
2015-08-07 17:27:06 activities
2015-08-07 17:28:11 E


/* Find Bundles with only 1 Event */
select lower(a.bundleid) as bundle_id
     , lower(a.applicationid) as application_id
     , a.name
     , a.startdate
     , a.enddate
     , b.user_cnt
     , a.canregister
from authdb_applications a
join (select lower(applicationid) as applicationid
           , count(*) as user_cnt
      from authdb_is_users
      where isdisabled = 0
      group by 1) b
on lower(a.applicationid) = b.applicationid
where lower(a.bundleid) in (
select distinct bundle_id
from jt.user_login_path)
and a.startdate >= '2015-06-01'
and a.enddate < current_date
group by 1,2,3,4,5,6,7
having count(*) = 1;
-- bundle_id: 766a4954-4e3f-4faa-93cb-26e564ce7a09
-- application_id: 30cc5b5e-5ebd-49bb-80fb-cb308a3a33ec
-- 843 registered users
-- canregister = false
-- 2015 GMAC Annual Conference

-- bundle_id: 7aace5a4-16b0-44fd-875e-85da9d01ac56
-- application_id: 8844f3eb-ef43-451f-bc0b-a1125a20de6e
-- 924 registered users
-- canregister = true
-- CYTO 2015


select count(*)
from jt.user_app_session
--where lower(bundleid) = '766a4954-4e3f-4faa-93cb-26e564ce7a09';
where lower(bundleid) = '7aace5a4-16b0-44fd-875e-85da9d01ac56';
--517 users with session (GMAC)
--888 users with session (CYTO)


select login_path
     , count(*) 
from jt.user_login_path
--where bundle_id = '766a4954-4e3f-4faa-93cb-26e564ce7a09'
where bundle_id = '7aace5a4-16b0-44fd-875e-85da9d01ac56'
group by 1
order by 2 desc;


select *
from jt.user_login_path
where login_path = '|appsessionflag';

select identifier
     , count(*)
from fact_views
where application_id = '8844f3eb-ef43-451f-bc0b-a1125a20de6e'
and bundle_id = '70bcb72c-5092-432b-bec2-8fd5eb7d1044' and global_user_id = '412e2b8a-ff91-4e58-b34c-8abf1882f337'
group by 1
order by 2 desc;

select identifier
     , count(*)
from fact_actions
where application_id = '8844f3eb-ef43-451f-bc0b-a1125a20de6e'
and bundle_id = '70bcb72c-5092-432b-bec2-8fd5eb7d1044' and global_user_id = '412e2b8a-ff91-4e58-b34c-8abf1882f337'
group by 1
order by 2 desc;

select *
from authdb_is_users
where lower(applicationid) = '8844f3eb-ef43-451f-bc0b-a1125a20de6e'
and lower(globaluserid) = '412e2b8a-ff91-4e58-b34c-8abf1882f337';

select *
from fact_sessions limit 1;



select *
from jt.user_app_session
where lower(bundleid) = '70bcb72c-5092-432b-bec2-8fd5eb7d1044' and global_user_id = '412e2b8a-ff91-4e58-b34c-8abf1882f337'


select *
from authdb_is_users
where lower(globaluserid) = '412e2b8a-ff91-4e58-b34c-8abf1882f337';
--EDE175B0-80CF-489F-BC79-45388223BCAB

select *
from authdb_applications
where applicationid = 'EDE175B0-80CF-489F-BC79-45388223BCAB';
--70BCB72C-5092-432B-BEC2-8FD5EB7D1044





























