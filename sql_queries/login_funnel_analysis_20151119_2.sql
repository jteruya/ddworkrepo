drop table if exists jt.loginflow_new_metrics_bundle_stats_20151119;
create table jt.loginflow_new_metrics_bundle_stats_20151119 as       
select a.bundleid
     , count(*) as eventcnt
     , count(case when b.applicationid is not null then 1 else null end) as testeventcnt
     , count(case when a.canregister = 'true' then 1 else null end) as openeventcnt
     , count(case when a.canregister = 'false' then 1 else null end) as closedeventcnt
from authdb_applications a
left join eventcube.testevents b
on a.applicationid = b.applicationid
group by 1;


/* Unique Bundle and Device - Actions from Initial Sessions*/
drop table if exists jt.loginflow_new_metrics_actions_20151119;
create table jt.loginflow_new_metrics_actions_20151119 as
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
and created >= '2015-10-01'
and created <= '2015-11-19';

/* Unique Bundle and Device - Views from Initial Sessions*/
drop table if exists jt.loginflow_new_metrics_views_20151119;
create table jt.loginflow_new_metrics_views_20151119 as
select *
from public.fact_views_live
where (identifier = 'accountPicker'
or identifier = 'enterEmail'
or identifier = 'enterPassword'
or identifier = 'eventPicker'
or identifier = 'eventProfileChoice'
or identifier = 'profileFiller'
or (identifier = 'activities' and metadata->>'Type' = 'global'))
and created >= '2015-10-01'
and created <= '2015-11-19';

drop table if exists jt.loginflow_new_metrics_all_seq_20151119;
create table jt.loginflow_new_metrics_all_seq_20151119 as
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
      from jt.loginflow_new_metrics_views_20151119
      union all
      select upper(bundle_id) as bundleid
           , upper(device_id) as deviceid
           , device_type
           , identifier
           , 'action' as identifier_type
           , created
      from jt.loginflow_new_metrics_actions_20151119) a;


drop table if exists jt.loginflow_new_metrics_all_seq_row_20151119;
create table jt.loginflow_new_metrics_all_seq_row_20151119 as
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
            from jt.loginflow_new_metrics_all_seq_20151119) a
      where identifierseqnum = 1) a
group by 1,2,3;


select count(*) as devicecnt
     , count(distinct bundleid) as bundlecnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailcnt
     , count(case when first_enteremailtextfield_timestamp is not null then 1 else null end) as enteremailtextfieldcnt
     , count(case when first_submitemailbutton_timestamp is not null then 1 else null end) as submitemailbutton
     
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickercnt
     , count(case when first_eventselectbutton_timestamp is not null then 1 else null end) as eventselectbutton
     
     , count(case when first_enterprofilechoice_timestamp is not null then 1 else null end) as enterprofilechoicecnt
     , count(case when first_createprofilebutton_timestamp is not null then 1 else null end) as createprofilebutton
     
     , count(case when first_profilefiller_timestamp is not null then 1 else null end) as profilefillercnt
     , count(case when first_changeprofilephotobutton_timestamp is not null then 1 else null end) as changeprofilephotobuttoncnt
     , count(case when first_enterfirstnametextfield_timestamp is not null then 1 else null end) as enterfirstnametextfieldcnt
     , count(case when first_enterlastnametextfield_timestamp is not null then 1 else null end) as enterlastnametextfieldcnt
     , count(case when first_entercompanytextfield_timestamp is not null then 1 else null end) as entercompanytextfieldcnt
     , count(case when first_entertitletextfield_timestamp is not null then 1 else null end) as entertitletextfieldcnt
     , count(case when first_submitprofilebutton_timestamp is not null then 1 else null end) as submitprofilebuttoncnt
     
     , count(case when first_globalactivities_timestamp is not null then 1 else null end) as globalactivitiescnt
     
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerpct
     , count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4) as profilefillerpct
     , count(case when first_globalactivities_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4) as globalactivitiespct
from jt.loginflow_new_metrics_all_seq_row_20151119
where bundleid in (select bundleid
                   from jt.loginflow_new_metrics_bundle_stats_20151119
                   where eventcnt = openeventcnt
                   and testeventcnt = 0)
and device_type = 'ios'
and first_enteremail_timestamp is not null
and (first_eventpicker_timestamp is null or (first_eventpicker_timestamp is not null and first_eventpicker_timestamp > first_enteremail_timestamp and ((first_globalactivities_timestamp is not null and first_eventpicker_timestamp < first_globalactivities_timestamp) or (first_globalactivities_timestamp is null and first_eventpicker_timestamp < first_enteremail_timestamp + interval '10' minute)) )) 
and (first_enterprofilechoice_timestamp is null or (first_enterprofilechoice_timestamp is not null and first_enterprofilechoice_timestamp > first_enteremail_timestamp and ((first_globalactivities_timestamp is not null and first_enterprofilechoice_timestamp < first_globalactivities_timestamp) or (first_globalactivities_timestamp is null and first_enterprofilechoice_timestamp < first_enteremail_timestamp + interval '10' minute)) )) 
and (first_profilefiller_timestamp is null or (first_profilefiller_timestamp is not null and first_profilefiller_timestamp > first_enteremail_timestamp and ((first_globalactivities_timestamp is not null and first_profilefiller_timestamp < first_globalactivities_timestamp) or (first_globalactivities_timestamp is null and first_profilefiller_timestamp < first_enteremail_timestamp + interval '10' minute)) )) 
and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_enterpassword_timestamp > first_globalactivities_timestamp));


select count(*) as devicecnt
     , count(distinct bundleid) as bundlecnt
from jt.loginflow_new_metrics_all_seq_row_20151119
where bundleid in (select bundleid
                   from jt.loginflow_new_metrics_bundle_stats_20151119
                   where eventcnt = openeventcnt
                   and testeventcnt = 0)
and device_type = 'android'
and (first_enteremail_timestamp is not null or first_accountpicker_timestamp is not null)
and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_enterpassword_timestamp > first_globalactivities_timestamp));