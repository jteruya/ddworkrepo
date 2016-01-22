drop table if exists jt.loginflow_new_metrics_bundle_stats_20151118;
create table jt.loginflow_new_metrics_bundle_stats_20151118 as       
select a.bundleid
     , count(*) as eventcnt
     , count(case when b.applicationid is not null then 1 else null end) as testeventcnt
     , count(case when a.canregister = 'true' then 1 else null end) as openeventcnt
     , count(case when a.canregister = 'false' then 1 else null end) as closedeventcnt
from authdb_applications a
left join eventcube.testevents b
on a.applicationid = b.applicationid
group by 1;


/* Unique Bundle and Device - Initial Sessions*/
drop table if exists jt.loginflow_new_metrics_sessions_20151118;
create table jt.loginflow_new_metrics_sessions_20151118 as
select *
from (select upper(bundle_id) as bundleid
           , upper(device_id) as deviceid
           , device_type
           , row_number() over (partition by bundle_id, device_id order by created) as sessionseqnum
           , session_id
      from public.fact_sessions_live
      where identifier = 'start'
      and created >= '2015-10-01'
      and created <= '2015-11-18'
      and bundle_id not in (select distinct lower(b.bundleid)
                            from eventcube.testevents a
                            join authdb_applications b
                            on a.applicationid = b.applicationid)      
      ) a
where sessionseqnum = 1;

/* Unique Bundle and Device - Actions from Initial Sessions*/
drop table if exists jt.loginflow_new_metrics_actions_20151118;
create table jt.loginflow_new_metrics_actions_20151118 as
select *
from public.fact_actions_live
where (identifier = 'accountSelectButton'
or identifier = 'anotherAccountButton'
or identifier = 'enterEmailTextField'
or identifier = 'submitEmailButton'
or identifier = 'enterPasswordTextField'
or identifier = 'submitPasswordButton'
or identifier = 'resetPasswordButton'
or identifier = 'cancelResetPasswordButton'
or identifier = 'submitResetPasswordButton'
or identifier = 'eventSelectButton'
or identifier = 'createProfileButton'
or identifier = 'changeProfilePhotoButton'
or identifier = 'enterFirstNameTextField'
or identifier = 'enterLastNameTextField'
or identifier = 'enterCompanyTextField'
or identifier = 'enterTitleTextField'
or identifier = 'submitProfileButton')
and session_id in (select distinct session_id from jt.loginflow_new_metrics_sessions_20151118);

/* Unique Bundle and Device - Views from Initial Sessions*/
drop table if exists jt.loginflow_new_metrics_views_20151118;
create table jt.loginflow_new_metrics_views_20151118 as
select *
from public.fact_views_live
where (identifier = 'accountPicker'
or identifier = 'enterEmail'
or identifier = 'enterPassword'
or identifier = 'eventPicker'
or identifier = 'eventProfileChoice'
or identifier = 'profileFiller'
or (identifier = 'activities' and metadata->>'Type' = 'global'))
and session_id in (select distinct session_id from jt.loginflow_new_metrics_sessions_20151118);


drop table if exists jt.loginflow_new_metrics_all_seq_20151118;
create table jt.loginflow_new_metrics_all_seq_20151118 as
select rank() over (partition by bundleid, deviceid, device_type, identifier order by created) as identifierseqnum
     , rank() over (partition by bundleid, deviceid, device_type, identifier_type order by created) as typeseqnum
     , rank() over (partition by bundleid, deviceid, device_type order by created) as seqnum
     , *
from (select upper(bundle_id) as bundleid
           , upper(device_id) as deviceid
           , device_type
           , identifier
           , 'view' as identifier_type
           , created
      from jt.loginflow_new_metrics_views_20151118
      union all
      select upper(bundle_id) as bundleid
           , upper(device_id) as deviceid
           , device_type
           , identifier
           , 'action' as identifier_type
           , created
      from jt.loginflow_new_metrics_actions_20151118) a;

select *
from jt.loginflow_new_metrics_all_seq_20151118;

drop table if exists jt.loginflow_new_metrics_all_seq_row_20151118;
create table jt.loginflow_new_metrics_all_seq_row_20151118 as
select bundleid
     , deviceid
     , device_type     
     
     -- Account Picker (Android Only)
     , min(case when identifier = 'accountPicker' then created else null end) as first_accountpicker_timestamp
     , min(case when identifier = 'anotherAccountButton' then created else null end) as first_anotheraccountbutton_timestamp
     
     -- Enter Email     
     , min(case when identifier = 'enterEmail' then created else null end) as first_enteremail_timestamp
     , min(case when identifier = 'enterEmailTextField' then created else null end) as first_enteremailtextfield_timestamp
     , min(case when identifier = 'submitEmailButton' then created else null end) as first_submitemailbutton_timestamp
     
     -- Enter Password      
     , min(case when identifier = 'enterPassword' then created else null end) as first_enterpassword_timestamp
     , min(case when identifier = 'enterPasswordTextField' then created else null end) as first_enterpasswordtextfield_timestamp
     , min(case when identifier = 'submitPasswordButton' then created else null end) as first_submitpasswordbutton_timestamp
     , min(case when identifier = 'resetPasswordButton' then created else null end) as first_resetpasswordbutton_timestamp
     , min(case when identifier = 'cancelResetPasswordButton' then created else null end) as first_cancelresetpasswordbutton_timestamp
     , min(case when identifier = 'submitResetPasswordButton' then created else null end) as first_submitresetpasswordbutton_timestamp
     
     -- EventPicker
     , min(previousview) as previouseventpickerview
     , min(case when identifier = 'eventPicker' then created else null end) as first_eventpicker_timestamp
     , min(case when identifier = 'eventSelectButton' then created else null end) as first_eventselectbutton_timestamp
     
     -- LinkedIn Import     
     , min(case when identifier = 'eventProfileChoice' then created else null end) as first_enterprofilechoice_timestamp
     , min(case when identifier = 'createProfileButton' then created else null end) as first_createprofilebutton_timestamp
     
     -- Profile Filler
     , min(case when identifier = 'profileFiller' then created else null end) as first_profilefiller_timestamp
     , min(case when identifier = 'changeProfilePhotoButton' then created else null end) as first_changeprofilephotobutton_timestamp
     , min(case when identifier = 'enterFirstNameTextField' then created else null end) as first_enterfirstnametextfield_timestamp
     , min(case when identifier = 'enterLastNameTextField' then created else null end) as first_enterlastnametextfield_timestamp
     , min(case when identifier = 'enterCompanyTextField' then created else null end) as first_entercompanytextfield_timestamp
     , min(case when identifier = 'enterTitleTextField' then created else null end) as first_entertitletextfield_timestamp
     , min(case when identifier = 'submitProfileButton' then created else null end) as first_submitprofilebutton_timestamp       
     
     -- Activity Feed
     , min(case when identifier = 'activities' then created else null end) as first_globalactivities_timestamp
          
from (select bundleid
           , deviceid
           , device_type
           , identifier_type
           , previousviewseqnum
           , previousview
           , identifier
           , created
           , seqnum
      from (select *
                 , case
                      when identifier = 'eventPicker' and device_type = 'android' and identifier_type = 'view'
                      then lag(seqnum,1) over (partition by bundleid, deviceid, identifier_type order by typeseqnum)
                   end as previousviewseqnum
                 , case
                      when identifier = 'eventPicker' and device_type = 'android' and identifier_type = 'view'
                      then lag(identifier,1) over (partition by bundleid, deviceid, identifier_type order by typeseqnum)
                   end as previousview
            from jt.loginflow_new_metrics_all_seq_20151118) a
      where identifierseqnum = 1) a
group by 1,2,3;


select count(*) as devicecnt
     , count(distinct bundleid) as bundlecnt
from jt.loginflow_new_metrics_all_seq_row_20151118
where bundleid in (select bundleid
                   from jt.loginflow_new_metrics_bundle_stats_20151118
                   where eventcnt = openeventcnt)
and device_type = 'ios'
and first_enteremail_timestamp is not null
and first_enterpassword_timestamp is null;




select count(*) as devicecnt
     , count(distinct bundleid) as bundlecnt
from jt.loginflow_new_metrics_all_seq_row_20151118
where bundleid in (select bundleid
                   from jt.loginflow_new_metrics_bundle_stats_20151118
                   where eventcnt = openeventcnt)
and device_type = 'android'
and (first_enteremail_timestamp is not null or first_accountpicker_timestamp is not null)
and first_enterpassword_timestamp is null;