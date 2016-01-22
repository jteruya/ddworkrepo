/* Device Ids (Run on Batman) */

select distinct ',''' || cast(deviceid as varchar) || ''''
from jt.seamless_login;


/* Create Table Based on distinct device ids in jt.seamless_login table in batman (Run in TM) */

drop table reportingdb.dbo.jt_seamless_login_users;

select a.applicationid
     , a.bundleid
     , u.userid
     , u.globaluserid
     , u.created
     , g.emailaddress
     , g.username
     , g.seamlesslogintoken
into reportingdb.dbo.jt_seamless_login_users
from authdb.dbo.applications a
join authdb.dbo.is_users u
on a.applicationid = u.applicationid
join ratings.dbo.globaluserdetails g
on a.bundleid = g.bundleid
and u.globaluserid = g.globaluserid
where (a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA')
and u.isdisabled = 0
and g.isdisabled = 0;


drop table reportingdb.dbo.jt_seamless_login_sessions;

select *
into reportingdb.dbo.jt_seamless_login_sessions
from analyticsdb.dbo.sessions
where lower(deviceid) in ('8631657a-253a-4247-8e0c-b08f52bdfd67'
,'d21cf6ff-4b60-4358-9ff3-ca9f11191623'
,'a0421ef6-5db9-4155-b378-10a42184cb95'
,'18bb433c-cb0f-4e83-89ec-f3d013232502'
,'70634b31-efe3-4abd-bf44-6ba0842f79a6'
,'b9e1f502-b6c2-4c15-9438-488f6e38c15a'
,'1c75be90-c8b3-47f2-89f1-52471c55c4ba'
,'71f5ff97-fc13-4759-a660-4c9891767ff5'
,'09d9c7d0-3e5d-44a1-b992-fd5f0512427e'
,'4627eb5e-28ea-45a2-8c17-b1ff0c3af257'
,'349b9464-f7a5-41ef-9105-074bf1eed977'
,'5c22ed0d-36d1-41ff-aeaf-11e5d78d3100'
,'fdb71610-4080-4712-a7b2-9fbe6c090c7b'
,'29a62e08-3199-44b3-b77d-399a09be714c'
,'b6e7db7f-581c-4f06-89d2-ca34096e1b62'
,'717c0697-6a75-49ea-be46-50d96860ba15'
,'aaa9acbb-58c6-4376-8577-29c9bea81fe9'
,'7ba136e0-ec02-4212-88f5-f420381a3372'
,'7b1aaafa-f3ed-48d7-bdd7-e37e421d1158'
,'d2adb892-688a-478c-9dba-120e2ee7be36'
,'e600f2ab-cfcb-4da9-a79f-a77866d77a46'
,'912d67c8-15c6-4701-8421-3b358d94fe08'
,'66ea8aac-965a-4a45-9570-cfc5e7b7f854'
,'81bbbfc5-54e6-4458-9103-13c4c98d4a89'
,'94050e90-1171-44df-b54f-2fc93586c6b5'
,'64e9dd8d-c102-4063-8e1e-0c86c0b21e93'
,'23e50eb7-5ab9-4d8f-a0eb-77a4a61a8934'
,'a6507299-c6f8-422c-bb0b-14f6401bb3d6'
,'b4a24525-bba5-485a-8655-01fed3a5c0cb'
,'8cffb459-7511-40b0-9b76-e54cbf703b99'
,'addd9a5a-a858-4acb-b098-c40a28d23f1e'
,'da7ca76a-5f32-433e-b5f1-8cfc201e3693'
,'094b44bd-6aa8-418e-8fb1-f27d49abc242'
,'78225322-a029-41b3-a4e5-16b7fed85ab5'
,'5ff932f9-c073-47d6-81b4-cf587ea08344'
,'6ee5fd99-15eb-4ec3-88a5-3b5e6e79f4f0'
,'7054153d-f04a-4f45-8f91-ae0a97fb01e9'
,'9c34880a-afd8-40a7-be7d-92c268ff6804'
,'47fc66ae-cdd6-4c57-a817-d907d4e72330'
,'2f73d2e7-2499-42dd-b757-f11a649eaaa9'
,'5acfa87e-006c-4754-83be-0eb7d3008dca'
,'8b1587fd-c5de-4317-aea2-154346060b74'
,'cb3b3e53-9fca-4339-bb2b-534311af2eab'
,'fb510523-31f2-4323-8070-5143655726a6'
,'2f8cd835-6611-40b9-bf00-b8cfe40c233f'
,'8210bc25-1785-4554-b95b-2e958fb6f19e'
,'d5f8dd3f-5ca8-42bf-9efe-6679789089f8'
,'c322df08-314f-4247-b615-409d78b1bc1a'
,'064f7f3f-a809-4d6f-8f41-bd0aa7ed2e79'
,'e13fdda8-0c2f-4955-b7ff-5a44d4f2516f'
,'3252fc74-2c6c-4236-9cc8-cdd0ce8737d0'
,'efa54aeb-eff9-4b3e-b7de-9104d5d321ef'
,'9d758476-7d4f-4585-96a2-fc29d58f4c8d'
,'ce713260-7baf-4bd4-94c8-648e67e18b48'
,'d5eff03e-c6ef-4746-abf7-213397a13f4a'
,'c26f300b-ef67-46ac-b0bf-367db713712e'
,'06def3e1-eb8d-4275-8777-4077a51ec8bc'
,'2858063c-d47b-4f73-a366-e7b213d19e9b'
,'8a386557-7e39-4c69-a636-eec1dd7b27e4'
,'63cf13cb-726e-4594-aaa7-00b2aac362ce'
,'f14ba972-fdfe-454f-abf6-4733df60484f'
,'1300a6f4-1fce-43fd-a943-a370e4addc6b'
,'8738fec1-2269-45ab-b0d6-075e0d22d3d1'
,'b3b735f5-bcb3-4d66-930e-488d5f48c9b3'
,'be37b83f-8518-41e9-a086-6d24ca4c9c52'
,'8ab9811e-5a1d-4ef0-9965-f1dfb058b5d7'
,'8cda094f-6bc6-4231-911f-594196a34b92'
,'30a832e9-57b5-4144-b93d-6070f519e0df'
,'7966208b-d447-4dc2-92b2-3733d43711cc'
,'bf334f12-3f81-40b9-9710-15aa12bc6563'
,'5e6a9de0-ec97-4902-9276-42a059b50624'
,'54ede2fe-c8d3-41d2-8d08-a0fdc369ed5c'
,'4c772f21-06dd-4bed-af96-6c89fbcf309e'
,'f03c3383-a046-4af0-acec-ba2b3b47e040'
,'3c7dd91d-5f00-44ff-a59c-5bc5c4a52e5b'
,'8f9120bd-a1de-4e64-bb1e-83ee2fc2cb54'
,'b5cfe340-7843-420a-afab-4ef4e530f3f8'
,'5f23cb6b-66e5-46fa-a16b-936834f7b155'
,'17227dce-6b6b-4028-bd3d-063af9478a0e'
,'49be7cc4-317e-4c48-92a9-b0f24af29178'
,'4495a963-bcf2-4760-8d85-82a31aef0dd2'
,'d2439905-bfc0-4631-9a84-9ef1b141332f'
,'cb6af564-3c46-4461-9f18-0013d8c49c68'
,'ec0018c7-1c2a-4223-9f95-3a9200940d01'
,'e0a05e50-da78-45eb-a2fb-f62dc7ba472c'
,'03aff35a-61e3-482d-b7c2-6c2b8d02d41d'
,'572505ee-6195-48a2-be5f-fc6a1d7ee4ad'
,'03940b70-d11e-467c-a958-8b07274860b0'
,'04cdedb6-903f-4bc9-a946-b83cb34693fc'
,'d774c033-8c8d-45aa-a15b-abaf34a15380'
,'e19b20d8-ac0d-42cc-a3ed-f864ffd0f299'
,'afa6dd1f-4fea-4b85-8e0d-e307a9ad8f97'
,'9ed2fddc-5efd-4176-9280-6a609b35abc7'
,'230f0acb-b35b-4a3e-8b50-92022acce22e'
,'ac8a56ca-b533-4d7d-b04a-81239e1536e0'
,'24359143-7891-42f9-b1db-dd2da5e26820'
,'a23f6554-5360-4aa6-8ecb-2116a0568617'
,'255a6d4f-fdfe-4a3f-bb75-c4e41c672d27'
,'26a6a579-f3a4-456c-9644-f57f7929c381'
,'71449f99-4b00-40dd-9cfd-dda2e89bedb1'
,'1c0b50a1-403c-41db-b6db-b410df6c5ca6'
,'27139e12-bb91-4b7b-8776-bde5192a44ea'
,'de4c09ea-282a-4e5e-a64d-a62cd5a57f7e'
,'0f54a809-95be-4959-9493-6b254b8bc326'
,'09e29c7a-8d95-44eb-b668-57c22db4aa13'
,'65d0d5c5-c464-4aed-af5c-cd26e1d8dd30'
,'73286489-fe4a-4d41-bc36-58abaf7aee6c'
,'d602397d-b034-4c1c-b875-d20edddca150'
,'d18edb6d-9f7a-4ec0-8c2d-2adbe21ce525'
,'8e24316c-6d37-46ec-bab0-b3e7eb31fa01'
,'13a696cf-95f3-4c76-bbc6-7ea4389e93ca'
,'8b2ae57e-b199-4ab2-a9f1-adb92553bcf8'
,'34fe550e-e06b-4e7b-af0a-381777601aa3'
,'979b7467-5677-4f34-ab3f-a01f002dabe3'
,'4f16b8ee-9f5e-44d6-9a65-f0381a661112'
,'b655286a-9806-4940-b964-620e35b68704'
,'626832c9-3c45-451e-9b4f-ff09093ee2b5'
,'3c4efd34-6580-4df9-a758-02053be79a97'
,'81e941c6-e4c2-438c-8397-4eb02e30db8b'
,'27795ff4-2d14-45bf-8780-359e7dd1d632'
,'5be30848-5597-4102-93ad-db6a12e2a844'
,'45d2c1ef-40ce-436f-b36b-421879c2114a'
,'5e4c00c0-ced2-4832-9f00-d074e94ce40f'
,'354eb677-99ee-44c2-9a3b-b61fd5c68828'
,'cb7469a0-c148-4134-b8e9-f74912d7672f'
,'cd6b93ab-a6ea-4990-95c5-b544b1e2fba4'
,'739fe5ea-fd41-4974-840c-f55329837049'
,'18edc052-779c-4bfb-b579-d67ea3da3b95'
,'52eee5ca-d394-49ba-adab-4b43d6ea7fcb'
,'cdbdfa3a-f89c-488d-9350-952c65391f91'
,'be4b9114-93e5-4d43-b694-5382f66fc540'
,'159f4938-090b-4aa1-ad9d-e75dcdecf1ce'
,'68317557-ea3b-4a24-9832-c9c332808bb7'
,'9b3344a0-cd19-4a30-8e8f-136d3c3871fa'
,'4adb0221-3755-43d4-b4e3-834d933a1555'
,'4ea1a31c-f22e-4aa4-827e-aafbd32767f1'
,'fc0193ad-ef84-4d1d-8ca0-7e4b3bcd381c'
,'b4fa4e32-8b48-4656-a16e-4cfe20e098ac'
,'edab3a8f-85b7-4cd2-9bff-1765b7ba3451'
,'58a1a7ee-1ddb-4e3c-a15b-1a399d6771c2'
,'d6d350dc-81fd-4ea5-8ddf-f1e9bf4dffe7'
,'11d87aab-8af3-49f8-9b5e-b4e7312c9551'
,'08c832c8-a9f0-4d9f-acc5-757a74efdf9e'
,'ff4d1386-284f-4681-913c-5716da8d0895'
,'24c04653-22ba-47c2-af18-1e2bf95c0e61'
,'5f72accf-94d6-4f2e-9e35-706cd21017a8'
,'25e2ed4c-2493-4fff-9898-c2ddb38ebecd'
,'af2a88c1-dfb3-4ab6-ba14-2875da00273c'
,'9f363f53-a821-4ccd-934d-b676e9e8b16b'
,'7a158d3c-563b-4e46-97d9-299ab4f1c90c'
,'2fd462d5-7ebd-4161-b302-5f5b0b197d6d'
,'aa39317b-1847-4f20-9c02-7124e7572543'
,'2ce0fd9d-f70d-44a0-939c-f74108cd362b'
,'aa8dd21f-0423-44bc-96b0-c125d93c51f7'
,'97f23aec-665f-4793-bcf8-a48dcce59892'
,'1ca3464c-05f0-4a02-bcce-fe904f940383'
,'bf9ab2ae-c260-49ec-8814-3f9c7c637aec'
,'87bec21a-0c27-47fd-9658-ebf12f434042'
,'81de1878-bc64-4f03-abf2-2a358aa47eda'
,'1fbb54e2-f3dd-4682-9198-3fdc595a8871'
,'d30b6e55-f23b-46ef-9edd-047cf17e4d8a'
,'e10f7364-ae54-4920-88d2-8a3432dec59c');


/* Get Average/Median for Seamless Login Info */
/* Fix Counts */
select distinct e.applicationid 
     , e.name as eventname
     , e.startdate
     , e.enddate
     , e.downloads
     , e.users
     , e.usersactive
     , e.usersengaged
     , coalesce(count(case when s.flag = 'seamless' then 1 else null end) over (partition by s.applicationid),0) as totaluserswithaseamlessloginsession
     , coalesce(avg(s.usersessioncnt) over (partition by s.applicationid),0) as avgseamlessloginsessioncntperuser
     , coalesce(percentile_cont(0.5) within group (order by s.usersessioncnt) over (partition by s.applicationid),0) as medianseamlessloginsessioncntperuser
     , coalesce(count(case when s2.flag = 'non-seamless' then 1 else null end) over (partition by s2.applicationid),0) as totaluserswithasession
     , coalesce(avg(s2.usersessioncnt) over (partition by s2.applicationid),0) as avgsessioncntperuser
     , coalesce(percentile_cont(0.5) within group (order by s2.usersessioncnt) over (partition by s2.applicationid),0) as mediansessioncntperuser
from (select * from reportingdb.dbo.eventcubesummary
      where applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
      or applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
      or applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
      or applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
      or applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA') e
left join (select applicationid
                , userid
                , 'seamless' as flag
                , count(*) as usersessioncnt
           from reportingdb.dbo.jt_seamless_login_sessions
           group by applicationid, userid) s
on s.applicationid = e.applicationid
left join (select a.applicationid
                , a.userid
                , 'non-seamless' as flag
                , count(*) as usersessioncnt
           from analyticsdb.dbo.sessions a
           left join reportingdb.dbo.jt_seamless_login_sessions b
           on a.sessionid = b.sessionid
           where b.sessionid is null
           group by a.applicationid, a.userid) s2
on e.applicationid = s2.applicationid
order by e.startdate, e.enddate;








/* Seamless Login Analysis 6/16/2015 (Done on Batman) */

select deviceid
     , deviceos
     , mmminfo as modelnumber
     , case
         when mmminfo = 'iPad3,4' then 'iPad 4th Gen Wifi Only'
         when mmminfo = 'iPad2,5' then 'iPad Mini Wifi Only/1st Gen'
         when mmminfo = 'iPhone3,1' then 'iPhone 4'
         when mmminfo = 'iPhone4,1' then 'iPhone 4S'
         when mmminfo = 'iPhone5,2' then 'iPhone 5'
         when mmminfo = 'iPhone5,3' then 'iPhone 5C'
         when mmminfo = 'iPhone5,4' then 'iPhone 5C'
         when mmminfo = 'iPhone6,2' then 'iPhone 5S'
         when mmminfo = 'iPhone7,1' then 'iPhone 6+'
         when mmminfo = 'iPhone7,2' then 'iPhone 6'
         else 'Unknown'
       end as modelname
     , count(*) as count
from jt.seamless_login
group by deviceid, deviceos, mmminfo
order by count(*) desc;

select distinct modelname
     , sum(count) over (partition by 1) as totalcount
     , sum(count) over (partition by modelname) as modelcount
     , cast(cast(sum(count) over (partition by modelname) as decimal(5,2))/cast(sum(count) over (partition by 1) as decimal(5,2)) as decimal(5,2)) * 100 as modelpct
from (
select deviceid
     , deviceos
     , mmminfo as modelnumber
     , case
         when mmminfo = 'iPad3,4' then 'iPad 4th Gen Wifi Only'
         when mmminfo = 'iPad2,5' then 'iPad Mini Wifi Only/1st Gen'
         when mmminfo = 'iPhone3,1' then 'iPhone 4'
         when mmminfo = 'iPhone4,1' then 'iPhone 4S'
         when mmminfo = 'iPhone5,2' then 'iPhone 5'
         when mmminfo = 'iPhone5,3' then 'iPhone 5C'
         when mmminfo = 'iPhone5,4' then 'iPhone 5C'
         when mmminfo = 'iPhone6,2' then 'iPhone 5S'
         when mmminfo = 'iPhone7,1' then 'iPhone 6+'
         when mmminfo = 'iPhone7,2' then 'iPhone 6'
         else 'Unknown'
       end as modelname
     , count(*) as count
from jt.seamless_login
group by deviceid, deviceos, mmminfo
having count(*) > 1) a
order by modelname;



select count(*) from public.ratings_globaluserdetails;

--4,362,841
--4,362,898
--4,363,314
--4,363,610
--4,364,316

--4,411,383 (TM)
--4,411,383

drop table if exists jt.seamless_login_users;
drop table if exists jt.seamless_login_sessions;

select a.applicationid
     , a.bundleid
     , u.userid
     , u.globaluserid
     , u.created
     , g.emailaddress
     , g.username
     , g.seamlesslogintoken
into jt.seamless_login_users
from public.authdb_applications a
join jt.tm_is_users u
on lower(cast(a.applicationid as varchar)) = lower(cast(u.applicationid as varchar))
join public.ratings_globaluserdetails g
on a.bundleid = g.bundleid
and lower(cast(u.globaluserid as varchar)) = lower(cast(g.globaluserid as varchar))
where (a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or a.applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');
--and u.isdisabled = 0
--and g.isdisabled = 0;


select *
into jt.seamless_login_sessions
from public.fact_sessions a
join (select distinct deviceid from jt.seamless_login ) b
on lower(a.device_id) = lower(cast(deviceid as varchar))
where upper(a.application_id) = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or upper(a.application_id) = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or upper(a.application_id) = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or upper(a.application_id) = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or upper(a.application_id) = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or upper(a.application_id) = '85874647-B187-49EF-8A45-E3B5720E1755';





select application_id
     , name
     , startdate
     , enddate
     , count(*) as total_users_logged_in_with_seamless_login
     , count(case when clicked_flag is null then 1 else null end) as total_users_logged_in_with_seamless_login_not_in_email_funnel
     , count(case when clicked_flag = true then 1 else null end) as total_users_logged_in_with_seamless_login_clicked_in_funnel
     , count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as total_users_logged_in_with_seamless_login_click_not_logged_by_mailgun
     , count(case when clicked_flag is null and emailaddress is null then 1 else null end) as total_users_logged_in_with_seamless_login_and_no_email_address
from (select distinct s.application_id
           , e.name
           , e.startdate
           , e.enddate
           , s.user_id
           , u.globaluserid
           , s.device_id
           , u.emailaddress
           , f.recipientemail
           , case
               when f.clicked_flag = true then true
               when g.clicked_flag = false then false
               else null
             end as clicked_flag
      from (select distinct user_id, device_id, application_id from jt.seamless_login_sessions where metrics_type_id = 1) s
      left join jt.seamless_login_users u
      on s.user_id = u.userid
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
      on s.application_id = lower(cast(e.applicationid as varchar))
      ) a
group by 1,2,3,4
order by 3,4;

select *
from public.mailgun_events
where recipientemail like '%erik.meems@century.nl%';


select application_id
     , count(*)
from (select distinct user_id, device_id, application_id from jt.seamless_login_sessions where metrics_type_id = 1) s
left join jt.seamless_login_users u
      on s.user_id = u.userid
group by 1;


select application_id
     , count(*)
from (select distinct user_id, device_id, application_id from jt.seamless_login_sessions where metrics_type_id = 1) s
left join jt.seamless_login_users u
      on s.user_id = u.userid
left join (select distinct recipientemail
                      , clicked_flag
                      , applicationid
                 from jt.seamless_fact_analysis 
                 where clicked_flag = true) f
      on u.emailaddress = f.recipientemail
      and lower(s.application_id) = lower(cast(f.applicationid as varchar))
group by 1;


select *
from jt.seamless_fact_analysis;

select *
from jt.seamless_login_sessions
where metrics_type_id = 1;

select e.applicationid 
     , e.name as eventname
     , e.downloads
     , e.users
     , e.usersactive
     , e.usersengaged
     , count(case when u.flag = 'seamless' then 1 else null end) as total_user_cnt_with_seamless
     , avg(case when u.flag = 'seamless' then s.sessioncnt else null end) as avg_session_cnt_with_seamless_per_user
     , count(case when u.flag is null then 1 else null end) as total_user_cnt_without_seamless
     , avg(case when u.flag is null then s.sessioncnt else null end) as avg_session_cnt_without_seamless_per_user
from (select * from jt.tm_eventcubesummary
      where applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
      or applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
      or applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
      or applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
      or applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
      or applicationid = '85874647-B187-49EF-8A45-E3B5720E1755') e
join (select application_id
           , user_id
           , count(*) as sessioncnt
      from public.fact_sessions 
      where metrics_type_id = 1
      and (upper(application_id) = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
      or upper(application_id) = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
      or upper(application_id) = '904434F2-C7C7-4C84-A972-BEE9EF324900'
      or upper(application_id) = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
      or upper(application_id) = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
      or upper(application_id) = '85874647-B187-49EF-8A45-E3B5720E1755') 
      group by 1,2) s
on lower(cast(e.applicationid as varchar)) = s.application_id
left join (select distinct application_id
                , user_id
                , 'seamless' as flag
           from jt.seamless_login_sessions) u
on s.application_id = u.application_id and s.user_id = u.user_id
group by 1,2,3,4,5,6;


select * 
from public.ratings_globaluserdetails
where globaluserid in (
select distinct globaluserid      
from jt.tm_is_users
where userid in (select distinct user_id
                                         from public.fact_sessions
                                         where lower(device_id) in (select distinct lower(cast(deviceid as varchar))
                                                                    from jt.seamless_login)
                                         and application_id = '85874647-b187-49ef-8a45-e3b5720e1755'));
                                         
                                         
select count(*)
from public.authdb_is_users;

select count(*)
from public.ratings_globaluserdetails;
