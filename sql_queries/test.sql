-- Testing Adoption Numbers for Closed Reg Events

select eventtype
     , count(*) as eventcnt
     , avg(adoption) as avgadoptiob
     , percentile_cont(0.5) within group (order by adoption) as medianadoption
from jt.tm_eventcubesummary
where (applicationid='09a40898-0d05-434d-9e7f-1f2c569ded4b'
or applicationid='5c7cf891-6288-46e3-a353-09dedafbeb7c'
or applicationid='61035230-5fcc-44f0-add8-594393c96895'
or applicationid='267e5070-4188-4c11-b027-f2431240161d'
or applicationid='bb36ee30-c3ed-49ef-a99b-3b1d6e0700ef'
or applicationid='295bb4e3-53c1-45a7-bce3-011b93a3efe5'
or applicationid='60eaca1b-fd27-4892-8b33-3d2cd54f6d1e'
or applicationid='5507aac3-c433-4759-9fcf-d8aa5fd1ccbd'
or applicationid='c9a38227-beee-4156-b427-38eb46acb9b0'
or applicationid='bd874883-0e1c-4ec2-883f-09f3685d04af'
or applicationid='ed6770d8-c409-4e56-a745-2ac02de1cef2'
or applicationid='22171396-af8b-4d75-b969-47cc9abe6069'
or applicationid='49cd9291-a4de-40b1-b578-a0c019a5150d'
or applicationid='92a9d6ac-1011-4d78-add0-efea6458a484'
or applicationid='5bd23fa4-d45b-4a4a-afbb-3013fc6a54a8'
or applicationid='9866a4b3-fdfa-4f96-81a6-4dbf3181a25e'
or applicationid='10bb5dcb-d514-47f4-b2e1-9f3a67269529'
or applicationid='0668893e-7234-451b-af10-e9b4e198721f'
or applicationid='4f0826ef-d346-4277-a85b-327b008e6132'
or applicationid='b18b18f6-cb0c-4289-9dc5-7f4a12261dc0'
or applicationid='3e943526-afe6-417f-bb1a-6e992b37a7ba'
or applicationid='7f9d075a-0a50-4a21-98c6-790af25ea083'
or applicationid='2c94cc37-abaa-419b-aaef-4fc922f820e8'
or applicationid='98056656-c959-4295-95ad-cad151f5d2a8'
or applicationid='21cb044c-c9d5-402d-82a2-f21d097f65c1'
or applicationid='03e5b58a-1a9e-43af-83d7-b8ee58bd0bf4'
or applicationid='628ae2db-eb57-48c8-952e-255af4c3e22a'
or applicationid='f713dc57-029e-43c2-b819-65a1ea525595'
or applicationid='1b6cb721-6f58-493f-a7bc-724aa276bb0e'
or applicationid='bf461c07-1f2a-409b-a81f-0688213cf6ff'
or applicationid='2ca10389-ede6-469c-ba7c-822a7dd52e67'
or applicationid='98b3331b-aebc-47ab-8bb8-10f8d8c51602'
or applicationid='c4291322-b9d5-4584-8a07-1dccdfa28df5'
or applicationid='72103917-ff18-4468-bd84-71c290442d71'
or applicationid='cd8252e7-59f2-4333-9fd9-a1784f857a79'
or applicationid='14a71e48-3864-4b1f-8553-a9a0214322b9'
or applicationid='2b071d94-2e5f-4fa0-b9e7-b8c2b3d29ca0'
or applicationid='ee9f1afa-315c-49c2-a944-84339c1fc4ba'
or applicationid='e34e75db-5845-4655-bd33-b1d7b931cfd4'
or applicationid='6b6bb985-1d7c-4572-898e-80955d05e12c'
or applicationid='158dfba5-2ffe-42f7-85c9-4ebb3896db6a'
or applicationid='f5a78b81-ca56-42a6-b297-3ae3e5188181'
or applicationid='7325e7c8-134f-407c-92f4-a646cacd2c99'
or applicationid='f359ab49-d080-4077-940f-d7af76ff100b'
or applicationid='0bbf438d-195b-4e70-afd5-fda0845793a3'
or applicationid='e5727682-4ca3-4f8c-b834-4757532efb71'
or applicationid='32652123-ab63-4952-8582-b3ba45a8de30'
or applicationid='3c89569c-a85c-492a-b9a6-f14d9fc35438'
or applicationid='ef061cad-5058-4e80-8668-283b47c91334'
or applicationid='cf1d7257-ad44-4e91-9b4c-f5bbb60a5665'
or applicationid='ae11769e-e76e-4723-be12-90dfc5b33f2d'
or applicationid='55ff0fa7-ec70-46ff-be3a-1f85db13e0f9'
or applicationid='50f47b9c-be0a-4ef0-84a4-3681e640c9f8'
or applicationid='dc8c8137-d49c-4132-85b9-4e9ee0b6fba6'
or applicationid='5d376e05-a8c2-4f14-9ce2-70a2dfece85e'
or applicationid='e539125e-a725-4ddf-899e-f5b6abab41ab'
or applicationid='9f07cb63-2016-44e1-86e9-f138aeaa2cf5'
or applicationid='27e55832-b293-4078-81a8-457085b8cac8'
or applicationid='fbaa081e-596e-47e4-9f46-4089a836cf71'
or applicationid='4471573b-4f5e-472b-ac5c-5609e1613b86'
or applicationid='2a6f46a7-e223-4088-be7a-3b04aa249dec'
or applicationid='c74aa76a-f1c3-4be1-9848-c962841a0fc8'
or applicationid='208fdd6e-94fb-42cc-b46d-2739c79397b4'
or applicationid='b4ecac21-91d4-4666-8a8a-89eafef321d1'
or applicationid='cf33f5ed-ed4d-430e-8fbc-53c2160a3f2b'
or applicationid='a1cbece2-d30c-47cd-ae5a-02e38e39021d'
or applicationid='c0561536-a8f6-41a2-8e61-b18006ea94b5'
or applicationid='5c41b176-9b34-4c9a-85a1-dcdff2309473'
or applicationid='548984b0-3f02-4d6f-b593-d39f093265b2'
or applicationid='ad948081-37d1-4860-9325-c03e7641eed0'
or applicationid='21b69912-bf05-4455-b04d-86e65e368b8f'
or applicationid='8ce79357-4829-428c-a57c-246b286503b7'
or applicationid='03488131-6a0b-4d1e-9e1c-8d271c43ad46'
or applicationid='fe70fd32-5225-451f-b404-614c49879771'
or applicationid='502d27d6-ae1b-461f-82c3-e55b4f44c796'
or applicationid='15e85cf6-b7ec-4031-adbe-84eddffcf6a4')
and eventtype = 'Conference (>2:1 session:exhibitor ratio)'
group by 1;



select eventtype
     , count(*) as eventcnt
     , avg(adoption) as avgadoptiob
     , percentile_cont(0.5) within group (order by adoption) as medianadoption
from jt.tm_eventcubesummary
where (applicationid='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or applicationid='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or applicationid='904434f2-c7c7-4c84-a972-bee9ef324900'
or applicationid='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or applicationid='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or applicationid='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or applicationid='85874647-b187-49ef-8a45-e3b5720e1755')
and adoption is not null
group by 1;





-------- Login Funnel ------------

------- Login View Metrics --------

drop table if exists jt.seamless_login_events_login_funnel_views;

select *
into jt.seamless_login_events_login_funnel_views
from fact_views
where (application_id='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or application_id='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or application_id='904434f2-c7c7-4c84-a972-bee9ef324900'
or application_id='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or application_id='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or application_id='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or application_id='85874647-b187-49ef-8a45-e3b5720e1755')
and (identifier = 'enteremail' or identifier = 'eventpicker' or identifier = 'enterpassword')
union
select v.*
from fact_views v
join jt.tm_applications a
on v.bundle_id = a.bundleid::varchar
where (a.applicationid='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or a.applicationid='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or a.applicationid='904434f2-c7c7-4c84-a972-bee9ef324900'
or a.applicationid='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or a.applicationid='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or a.applicationid='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or a.applicationid='85874647-b187-49ef-8a45-e3b5720e1755')
and (v.identifier = 'enteremail' or v.identifier = 'eventpicker' or v.identifier = 'enterpassword');


------- Login Action Metrics --------

drop table if exists jt.seamless_login_events_login_funnel_actions;

select *
     , case
         when identifier = 'eventselectbutton' then metadata->>'applicationid'
         else null
       end as event_select_application_id
into jt.seamless_login_events_login_funnel_actions
from fact_actions
where (application_id='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or application_id='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or application_id='904434f2-c7c7-4c84-a972-bee9ef324900'
or application_id='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or application_id='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or application_id='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or application_id='85874647-b187-49ef-8a45-e3b5720e1755')
and (identifier = 'enteremailtextfield' or identifier = 'submitemailbutton' or identifier = 'enterpasswordtextfield' or identifier = 'submitpasswordbutton' or identifier = 'eventselectbutton')
union
select v.*
     , case
         when v.identifier = 'eventselectbutton' then v.metadata->>'applicationid'
         else null
       end as event_select_application_id
from fact_actions v
join jt.tm_applications a
on v.bundle_id = a.bundleid::varchar
where (a.applicationid='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or a.applicationid='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or a.applicationid='904434f2-c7c7-4c84-a972-bee9ef324900'
or a.applicationid='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or a.applicationid='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or a.applicationid='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or a.applicationid='85874647-b187-49ef-8a45-e3b5720e1755')
and (v.identifier = 'enteremailtextfield' or v.identifier = 'submitemailbutton' or v.identifier = 'enterpasswordtextfield' or v.identifier = 'submitpasswordbutton' or identifier = 'eventselectbutton');



-- Login Views/Action Funnel at Bundle Level

drop table if exists jt.seamless_event_app_login_funnel;

select e.bundle_id
     , e.device_id
     , e.global_user_id
     , e.app_type_id
     , e.device_os_version
     , e.mmm_info
     , e.first_email_view_date
     , etf.first_email_enter_date
     , ets.first_email_submit_date
     , ap.first_password_view_date 
     , ptf.first_password_enter_date
     , psf.first_password_submit_date
     , p.first_event_picker_view_date
     , esb.first_event_select_date 
into jt.seamless_event_app_login_funnel
from (select bundle_id
           , device_id
           , global_user_id
           , app_type_id
           , mmm_info
           , max(device_os_version) as device_os_version
           , min(created) as first_email_view_date 
      from jt.seamless_login_events_login_funnel_views 
      where identifier = 'enteremail'
      and created >= '2015-06-01'
      group by 1,2,3,4,5) e
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_email_enter_date
           from jt.seamless_login_events_login_funnel_actions
           where identifier = 'enteremailtextfield'
           group by 1,2,3) etf
on e.bundle_id = etf.bundle_id and e.device_id = etf.device_id and e.global_user_id = etf.global_user_id
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_email_submit_date
           from jt.seamless_login_events_login_funnel_actions
           where identifier = 'submitemailbutton'
           group by 1,2,3) ets
on e.bundle_id = ets.bundle_id and e.device_id = ets.device_id and e.global_user_id = ets.global_user_id      
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_password_view_date 
           from jt.seamless_login_events_login_funnel_views 
           where identifier = 'enterpassword'
           group by 1,2,3) ap
on e.bundle_id = ap.bundle_id and e.device_id = ap.device_id and e.global_user_id = ap.global_user_id
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_password_enter_date 
           from jt.seamless_login_events_login_funnel_actions 
           where identifier = 'enterpasswordtextfield'
           group by 1,2,3) ptf
on e.bundle_id = ptf.bundle_id and e.device_id = ptf.device_id and e.global_user_id = ptf.global_user_id
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_password_submit_date 
           from jt.seamless_login_events_login_funnel_actions 
           where identifier = 'submitpasswordbutton'
           group by 1,2,3) psf
on e.bundle_id = psf.bundle_id and e.device_id = psf.device_id and e.global_user_id = psf.global_user_id
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_event_picker_view_date
           from jt.seamless_login_events_login_funnel_views 
           where identifier = 'eventpicker'
           group by 1,2,3) p
on e.bundle_id = p.bundle_id and e.device_id = p.device_id and e.global_user_id = p.global_user_id
left join (select bundle_id
                , device_id
                , global_user_id
                , min(created) as first_event_select_date 
           from jt.seamless_login_events_login_funnel_actions 
           where identifier = 'eventselectbutton'
           group by 1,2,3) esb
on e.bundle_id = esb.bundle_id and e.device_id = esb.device_id and e.global_user_id = esb.global_user_id;


select b.*
into jt.seamless_event_app_login_funnel_alter
from jt.seamless_event_app_login_funnel b
left join (select *
           from jt.seamless_event_app_login_funnel
           where first_event_picker_view_date is not null
           and first_password_submit_date is null) a
on b.bundle_id = a.bundle_id and a.global_user_id = b.global_user_id and a.device_id = b.device_id
where a.bundle_id is null;




-- Clean Funnel (Don't Use - SKIP!)
/*
drop table if exists jt.seamless_event_app_login_funnel_clean;

select bundle_id
     , device_id
     , global_user_id
     , app_type_id
     , device_os_version
     , mmm_info
     , first_email_view_date
     , case
         when first_email_enter_date is null and (first_email_submit_date is not null or first_password_view_date is not null or first_password_enter_date is not null or first_password_submit_date is not null or first_event_picker_view_date is not null or first_event_select_date is not null) then '9999-12-31'
         else first_email_enter_date
       end as first_email_enter_date
     , case
         when first_email_submit_date is null and (first_password_view_date is not null or first_password_enter_date is not null or first_password_submit_date is not null or first_event_picker_view_date is not null or first_event_select_date is not null) then '9999-12-31'
         else first_email_submit_date
       end as first_email_submit_date
     , case
         when first_password_view_date is null and (first_password_enter_date is not null or first_password_submit_date is not null or first_event_picker_view_date is not null or first_event_select_date is not null) then '9999-12-31'
         else first_password_view_date
       end as first_password_view_date
     , case
         when first_password_enter_date is null and (first_password_submit_date is not null or first_event_picker_view_date is not null or first_event_select_date is not null) then '9999-12-31'
         else first_password_enter_date
       end as first_password_enter_date
     , case
         when first_password_submit_date is null and (first_event_picker_view_date is not null or first_event_select_date is not null) then '9999-12-31'
         else first_password_submit_date
       end as first_password_submit_date
     , case
         when first_event_picker_view_date is null and (first_event_select_date is not null) then '9999-12-31'
         else first_event_picker_view_date
       end as first_event_picker_view_date
     , first_event_select_date
into jt.seamless_event_app_login_funnel_clean
from jt.seamless_event_app_login_funnel;

*/

-- Bundle Funnel Stats
drop table if exists jt.seamless_event_app_login_funnel_stats;

select bundle_id
     , count(*) as email_view_cnt
     , count(case when first_email_enter_date is not null then 1 else null end) as email_enter_cnt
     , count(case when first_email_enter_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as email_enter_pct
     , count(case when first_email_submit_date is not null then 1 else null end) as email_submit_cnt
     , count(case when first_email_submit_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as email_submit_pct
     , count(case when first_password_view_date is not null then 1 else null end) as password_view_cnt
     , count(case when first_password_view_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as password_view_pct     
     , count(case when first_password_enter_date is not null then 1 else null end) as password_enter_cnt
     , count(case when first_password_enter_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as password_enter_pct
     , count(case when first_password_submit_date is not null then 1 else null end) as password_submit_cnt
     , count(case when first_password_submit_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as password_submit_pct
     , count(case when first_event_picker_view_date is not null then 1 else null end) as event_view_cnt
     , count(case when first_event_picker_view_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_view_pct
     , count(case when first_event_select_date is not null then 1 else null end) as event_select_cnt
     , count(case when first_event_select_date is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as event_select_pct 
into jt.seamless_event_app_login_funnel_stats 
from jt.seamless_event_app_login_funnel_alter
group by 1;



select *
from jt.seamless_event_app_login_funnel_stats ;



-- Event App Stats
select a.bundle_id
     --, a.global_user_id
     --, a.device_id
     , e.application_id
     , o.name
     , o.startdate
     , o.enddate
     , count(*)
from (select bundle_id
           , device_id
           , global_user_id
           , min(created) as first_event_picker_view_date
      from jt.seamless_login_events_login_funnel_views 
      where identifier = 'eventpicker'
      group by 1,2,3) a
left join (select distinct bundle_id
           , device_id
           , global_user_id
           , event_select_application_id as application_id
      from jt.seamless_login_events_login_funnel_actions 
      where identifier = 'eventselectbutton'
      and event_select_application_id is not null
      and event_select_application_id in ('8297e8ab-eee4-43dc-a37e-5d1a07e527c0','23bde4bf-ccb3-4c21-9c04-0f515d826c88','904434f2-c7c7-4c84-a972-bee9ef324900','f0d34ef9-ba6e-4611-a57b-4c528d8e32a8','ff757ecb-56a1-41b1-ac02-5f609c3db3da','3e92f6b3-59a3-4078-9be0-42dd25c8ccc2','85874647-b187-49ef-8a45-e3b5720e1755')) e
on a.bundle_id = e.bundle_id and a.device_id = e.device_id and a.global_user_id = e.global_user_id
/*left join (select event_select_application_id as application_id
                , global_user_id
                , device_id
                , min(created) as first_eventpicker_date
           from jt.seamless_login_events_login_funnel_actions 
           where identifier = 'eventselectbutton'
           and event_select_application_id is not null
           and event_select_application_id in ('8297e8ab-eee4-43dc-a37e-5d1a07e527c0','23bde4bf-ccb3-4c21-9c04-0f515d826c88','904434f2-c7c7-4c84-a972-bee9ef324900','f0d34ef9-ba6e-4611-a57b-4c528d8e32a8','ff757ecb-56a1-41b1-ac02-5f609c3db3da','3e92f6b3-59a3-4078-9be0-42dd25c8ccc2','85874647-b187-49ef-8a45-e3b5720e1755')
           group by 1,2,3) i
on e.application_id = i.application_id and a.global_user_id = i.global_user_id and a.device_id = i.device_id*/
join jt.tm_eventcubesummary o
on e.application_id = o.applicationid::varchar
group by 1,2,3,4,5
order by 4,5;



select bundle_id
     , application_id
     , name
     , startdate
     , enddate
     , event_view_cnt
     , event_view_pct
     , event_select_cnt
     , event_select_pct
     , count(*)
from (
      
select a.bundle_id
     , a.event_view_cnt
     , a.event_view_pct
     , a.event_select_cnt
     , a.event_select_pct
     , e.device_id
     , e.application_id
     , z.name
     , z.startdate
     , z.enddate
     , o.globaluserid
from (select distinct bundle_id
           , device_id
           , global_user_id
           , event_select_application_id as application_id
      from jt.seamless_login_events_login_funnel_actions 
      where identifier = 'eventselectbutton'
      and event_select_application_id is not null
      and event_select_application_id in ('8297e8ab-eee4-43dc-a37e-5d1a07e527c0','23bde4bf-ccb3-4c21-9c04-0f515d826c88','904434f2-c7c7-4c84-a972-bee9ef324900','f0d34ef9-ba6e-4611-a57b-4c528d8e32a8','ff757ecb-56a1-41b1-ac02-5f609c3db3da','3e92f6b3-59a3-4078-9be0-42dd25c8ccc2','85874647-b187-49ef-8a45-e3b5720e1755')
      ) e
left join (select bundle_id
           , event_view_cnt
           , event_view_pct
           , event_select_cnt
           , event_select_pct
      from jt.seamless_event_app_login_funnel_stats
      where bundle_id in ('59e248a6-338c-4b4c-abb6-1f80ca1efe53','4ab76240-7004-4f50-a6a7-2518e79feec2','3329c501-bc33-4141-a103-30962be10411','8d2db0ff-0deb-4d46-89db-a169aca12d26','e4936a43-785c-4f3c-8622-b708854bef09','fc87c500-e8ce-49da-88e2-85629b7d0289')
      ) a
on a.bundle_id = e.bundle_id
join jt.seamless_login_first_session_info_users o
on lower(e.application_id) = lower(o.application_id) and lower(e.device_id) = lower(o.device_id)
join jt.tm_eventcubesummary z
on e.application_id = z.applicationid::varchar

) a
group by 1,2,3,4,5,6,7,8,9
order by 4,5
;

select application_id
     , count(*)
from (
select application_id
     , globaluserid
     , device_id
from jt.seamless_login_first_session_info_users
group by 1,2,3) a
group by 1


select *
from jt.seamless_login_first_session_info_users limit 10


select *
from jt.seamless_login_events_login_funnel_actions limit 10

deviceid
726A22B1-B5C5-4F4A-838F-7E043D3EACA6

globaluser
726a22b1-b5c5-4f4a-838f-7e043d3eaca6

application
ff757ecb-56a1-41b1-ac02-5f609c3db3da

select *
from jt.seamless_login_first_session_info_users
where application_id = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
and device_id = '726A22B1-B5C5-4F4A-838F-7E043D3EACA6'


select *
from jt.tm_eventcubesummary
where applicationid='8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
or applicationid='23bde4bf-ccb3-4c21-9c04-0f515d826c88'
or applicationid='904434f2-c7c7-4c84-a972-bee9ef324900'
or applicationid='f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
or applicationid='ff757ecb-56a1-41b1-ac02-5f609c3db3da'
or applicationid='3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
or applicationid='85874647-b187-49ef-8a45-e3b5720e1755';