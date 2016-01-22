drop table if exists jt.nonseamless_login_sessions;
drop table if exists jt.nonseamless_login_users;

select s.application_id
     , e.name
     , e.startdate
     , e.enddate
     , s.app_type_id
     , s.user_id
     , s.device_id
     , s.start_date as sessionstartdate
into jt.nonseamless_login_sessions
from (select * from fact_sessions where metrics_type_id = 1) s
join jt.tm_eventcubesummary e
on lower(s.application_id) = lower(e.applicationid::varchar)
where (lower(s.application_id) = '5e2969e7-892a-4c2b-b0b9-ce26fbad5d05'
or lower(s.application_id) = '09a40898-0d05-434d-9e7f-1f2c569ded4b'
or lower(s.application_id) = '5c7cf891-6288-46e3-a353-09dedafbeb7c'
or lower(s.application_id) = '24041366-69b2-4e48-9a00-21d5634b08aa'
or lower(s.application_id) = 'd08b4c8c-a696-4ce0-8a1c-7ae4c590ea01'
or lower(s.application_id) = '61035230-5fcc-44f0-add8-594393c96895'
or lower(s.application_id) = 'bf21690a-b394-4ea2-ad50-4f3cdba21017'
or lower(s.application_id) = '267e5070-4188-4c11-b027-f2431240161d'
or lower(s.application_id) = '8947dcc6-fd51-47e1-a5ec-5ac2d3a54300'
or lower(s.application_id) = 'bb36ee30-c3ed-49ef-a99b-3b1d6e0700ef'
or lower(s.application_id) = '295bb4e3-53c1-45a7-bce3-011b93a3efe5'
or lower(s.application_id) = '60eaca1b-fd27-4892-8b33-3d2cd54f6d1e'
or lower(s.application_id) = '5507aac3-c433-4759-9fcf-d8aa5fd1ccbd'
or lower(s.application_id) = 'c9a38227-beee-4156-b427-38eb46acb9b0'
or lower(s.application_id) = 'bd874883-0e1c-4ec2-883f-09f3685d04af'
or lower(s.application_id) = 'ed6770d8-c409-4e56-a745-2ac02de1cef2'
or lower(s.application_id) = '22171396-af8b-4d75-b969-47cc9abe6069'
or lower(s.application_id) = '49cd9291-a4de-40b1-b578-a0c019a5150d'
or lower(s.application_id) = '92a9d6ac-1011-4d78-add0-efea6458a484'
or lower(s.application_id) = '5bd23fa4-d45b-4a4a-afbb-3013fc6a54a8'
or lower(s.application_id) = '9866a4b3-fdfa-4f96-81a6-4dbf3181a25e'
or lower(s.application_id) = '10bb5dcb-d514-47f4-b2e1-9f3a67269529'
or lower(s.application_id) = '0668893e-7234-451b-af10-e9b4e198721f'
or lower(s.application_id) = '4f0826ef-d346-4277-a85b-327b008e6132'
or lower(s.application_id) = 'b18b18f6-cb0c-4289-9dc5-7f4a12261dc0'
or lower(s.application_id) = '3e943526-afe6-417f-bb1a-6e992b37a7ba'
or lower(s.application_id) = '7f9d075a-0a50-4a21-98c6-790af25ea083'
or lower(s.application_id) = '2c94cc37-abaa-419b-aaef-4fc922f820e8'
or lower(s.application_id) = 'e26d633b-9a95-408b-871b-51f8fde9cb5a'
or lower(s.application_id) = '98056656-c959-4295-95ad-cad151f5d2a8'
or lower(s.application_id) = '21cb044c-c9d5-402d-82a2-f21d097f65c1'
or lower(s.application_id) = '03e5b58a-1a9e-43af-83d7-b8ee58bd0bf4'
or lower(s.application_id) = '628ae2db-eb57-48c8-952e-255af4c3e22a'
or lower(s.application_id) = 'f713dc57-029e-43c2-b819-65a1ea525595'
or lower(s.application_id) = '1b6cb721-6f58-493f-a7bc-724aa276bb0e'
or lower(s.application_id) = 'bf461c07-1f2a-409b-a81f-0688213cf6ff'
or lower(s.application_id) = '2ca10389-ede6-469c-ba7c-822a7dd52e67'
or lower(s.application_id) = '98b3331b-aebc-47ab-8bb8-10f8d8c51602'
or lower(s.application_id) = 'c4291322-b9d5-4584-8a07-1dccdfa28df5'
or lower(s.application_id) = '72103917-ff18-4468-bd84-71c290442d71'
or lower(s.application_id) = 'cd8252e7-59f2-4333-9fd9-a1784f857a79'
or lower(s.application_id) = '14a71e48-3864-4b1f-8553-a9a0214322b9'
or lower(s.application_id) = '376d080f-d513-4cab-937b-5a5d0a9fc909'
or lower(s.application_id) = '2b071d94-2e5f-4fa0-b9e7-b8c2b3d29ca0'
or lower(s.application_id) = 'ee9f1afa-315c-49c2-a944-84339c1fc4ba'
or lower(s.application_id) = 'e34e75db-5845-4655-bd33-b1d7b931cfd4'
or lower(s.application_id) = '6b6bb985-1d7c-4572-898e-80955d05e12c'
or lower(s.application_id) = '158dfba5-2ffe-42f7-85c9-4ebb3896db6a'
or lower(s.application_id) = '81d2e11f-1b0f-4275-a0d9-6a42b4f9e1ad'
or lower(s.application_id) = 'f5a78b81-ca56-42a6-b297-3ae3e5188181'
or lower(s.application_id) = '7325e7c8-134f-407c-92f4-a646cacd2c99'
or lower(s.application_id) = 'f359ab49-d080-4077-940f-d7af76ff100b'
or lower(s.application_id) = '0bbf438d-195b-4e70-afd5-fda0845793a3'
or lower(s.application_id) = 'badea36a-eb07-41af-b02e-8d8d7a8b4cee'
or lower(s.application_id) = 'e5727682-4ca3-4f8c-b834-4757532efb71'
or lower(s.application_id) = '32652123-ab63-4952-8582-b3ba45a8de30'
or lower(s.application_id) = '3c89569c-a85c-492a-b9a6-f14d9fc35438'
or lower(s.application_id) = '7585ed89-9d5a-43c5-aff7-c4d4207e846b'
or lower(s.application_id) = 'ef061cad-5058-4e80-8668-283b47c91334'
or lower(s.application_id) = 'cf1d7257-ad44-4e91-9b4c-f5bbb60a5665'
or lower(s.application_id) = 'ae11769e-e76e-4723-be12-90dfc5b33f2d'
or lower(s.application_id) = '55ff0fa7-ec70-46ff-be3a-1f85db13e0f9'
or lower(s.application_id) = '50f47b9c-be0a-4ef0-84a4-3681e640c9f8'
or lower(s.application_id) = 'dc8c8137-d49c-4132-85b9-4e9ee0b6fba6'
or lower(s.application_id) = '5d376e05-a8c2-4f14-9ce2-70a2dfece85e'
or lower(s.application_id) = 'e539125e-a725-4ddf-899e-f5b6abab41ab'
or lower(s.application_id) = '9f07cb63-2016-44e1-86e9-f138aeaa2cf5'
or lower(s.application_id) = '27e55832-b293-4078-81a8-457085b8cac8'
or lower(s.application_id) = 'fbaa081e-596e-47e4-9f46-4089a836cf71'
or lower(s.application_id) = '4471573b-4f5e-472b-ac5c-5609e1613b86'
or lower(s.application_id) = '2a6f46a7-e223-4088-be7a-3b04aa249dec'
or lower(s.application_id) = 'c74aa76a-f1c3-4be1-9848-c962841a0fc8'
or lower(s.application_id) = '208fdd6e-94fb-42cc-b46d-2739c79397b4'
or lower(s.application_id) = 'b4ecac21-91d4-4666-8a8a-89eafef321d1'
or lower(s.application_id) = 'cf33f5ed-ed4d-430e-8fbc-53c2160a3f2b'
or lower(s.application_id) = 'a1cbece2-d30c-47cd-ae5a-02e38e39021d'
or lower(s.application_id) = 'c0561536-a8f6-41a2-8e61-b18006ea94b5'
or lower(s.application_id) = '5c41b176-9b34-4c9a-85a1-dcdff2309473'
or lower(s.application_id) = '548984b0-3f02-4d6f-b593-d39f093265b2'
or lower(s.application_id) = 'ad948081-37d1-4860-9325-c03e7641eed0'
or lower(s.application_id) = '21b69912-bf05-4455-b04d-86e65e368b8f'
or lower(s.application_id) = '8ce79357-4829-428c-a57c-246b286503b7'
or lower(s.application_id) = '03488131-6a0b-4d1e-9e1c-8d271c43ad46'
or lower(s.application_id) = 'fe70fd32-5225-451f-b404-614c49879771'
or lower(s.application_id) = 'd25f4719-bef8-4ff7-a8fc-1bddcb4d3569'
or lower(s.application_id) = '502d27d6-ae1b-461f-82c3-e55b4f44c796'
or lower(s.application_id) = '15e85cf6-b7ec-4031-adbe-84eddffcf6a4'
or lower(s.application_id) = '91880a90-4383-4c57-bd3c-8f9e13eeb65b');


select s.application_id
     , s.user_id
     , s.name
     , s.startdate
     , s.enddate
     , u.globaluserid
     , a.bundleid
     , g.emailaddress
     , s.app_type_id
     , g.firstname
     , g.username
     , g.phone
into jt.nonseamless_login_users
from (select distinct application_id
           , user_id
           , name
           , startdate
           , enddate
           , app_type_id
      from jt.nonseamless_login_sessions) s
join jt.tm_is_users u
on s.user_id = u.userid
join jt.tm_applications a
on s.application_id = a.applicationid::varchar
join jt.tm_globaluserdetails g
on g.globaluserid = u.globaluserid and g.bundleid = a.bundleid;


-- Connecting mailgun and nonseamless metrics
select application_id
     , name
     , startdate
     , enddate
     , count(*) as total_app_users
     --, count(case when clicked_flag is null then 1 else null end) as app_users_not_in_funnel
     --, count(case when clicked_flag = true then 1 else null end) as app_users_funnel
     --, count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as app_users_in_funnel_not_clicked
     --, count(case when clicked_flag is null and emailaddress is null then 1 else null end) as app_users_no_email
     , count(case when clicked_dnload_flag = true then 1 else null end) as app_user_clicked_dnload
     , count(case when clicked_dnload_device_match_flag = true then 1 else null end) as dnload_clicked_user
     , count(case when clicked_dnload_device_match_flag = true and app_type_id in (1,2) then 1 else null end) as dnload_clicked_user_ios
     , count(case when clicked_dnload_device_match_flag = true and app_type_id in (3) then 1 else null end) as dnload_clicked_user_android
into jt.nonseamless_events_user_origin
from (select distinct u.application_id
           , e.name
           , e.startdate
           , e.enddate
           , u.user_id
           , u.globaluserid
           , u.emailaddress
           , f.recipientemail
           , f.clicked_dnload_flag
           , u.app_type_id
           , case
               when f.clicked_dnload_flag = true and u.app_type_id = 3 and f.clicked_dnload_clientos = 'Android' then true
               when f.clicked_dnload_flag = true and u.app_type_id = 1 and f.clicked_dnload_devicetype = 'mobile' and f.clicked_dnload_clientos = 'iOS' then true
               when f.clicked_dnload_flag = true and u.app_type_id = 2 and f.clicked_dnload_devicetype = 'tablet' and f.clicked_dnload_clientos = 'iOS' then true
               else null
             end as clicked_dnload_device_match_flag              
      from jt.nonseamless_login_users u
      left join (select distinct applicationid 
                      , recipientemail
                      , clicked_dnload_flag
                      , clicked_dnload_clientos
                      , clicked_dnload_devicetype
                 from jt.nonseamless_fact_analysis 
                 where clicked_dnload_flag = true) f
      on u.emailaddress = f.recipientemail and u.application_id = f.applicationid::varchar
      left join (select distinct applicationid  
                      , recipientemail
                      , clicked_flag
                 from jt.nonseamless_fact_analysis 
                 where clicked_dnload_flag = false) g
      on u.emailaddress = g.recipientemail and u.application_id = g.applicationid::varchar
      join jt.tm_eventcubesummary e
      on u.application_id = e.applicationid::varchar
      ) a
group by 1,2,3,4
order by 3,4;



select a.*
     , b.total_app_users
     , b.app_user_clicked_dnload
     , b.dnload_clicked_user
     , b.dnload_clicked_user_ios
     , b.dnload_clicked_user_android
from jt.nonseamless_login_funnel a
join jt.nonseamless_events_user_origin b
on lower(a.applicationid::varchar) = lower(b.application_id);