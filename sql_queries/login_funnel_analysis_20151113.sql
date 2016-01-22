create table jt.loginflow_new_metrics_view_sample as
select bundle_id
     , device_id
     , device_type
     , identifier
     , created
from public.fact_views_live
where (identifier = 'accountPicker'
or identifier = 'enterEmail'
or identifier = 'enterPassword'
or identifier = 'eventPicker'
or identifier = 'eventProfileChoice'
or identifier = 'profileFiller'
or (identifier = 'activities' and metadata->>'Type' = 'global'))
and extract(year from created) = 2015
and extract(month from created) in (10,11);

create table jt.loginflow_new_metrics_actions_sample as
select bundle_id
     , device_id
     , device_type
     , identifier
     , created
from public.fact_actions_live
where (identifier = 'accountSelectButton'
or identifier = 'anotherAccountButton'
or identifier = 'enterEmailTextField'
or identifier = 'submitEmailButton'
or identifier = 'eventselectbutton'
or identifier = 'createProfileButton'
or identifier = 'changeProfilePhotoButton'
or identifier = 'enterFirstNameTextField'
or identifier = 'enterLastNameTextField'
or identifier = 'enterCompanyTextField'
or identifier = 'enterTitleTextField'
or identifier = 'submitProfileButton')
and extract(year from created) = 2015
and extract(month from created) in (10,11);





drop table jt.loginflow_new_metrics_views;
create table jt.loginflow_new_metrics_views as
select upper(bundle_id) as bundleid
     , upper(device_id) as deviceid
     , device_type
     , min(case when identifier = 'accountPicker' then created else null end) as first_accountpicker_timestamp
     , min(case when identifier = 'enterEmail' then created else null end) as first_enteremail_timestamp
     , min(case when identifier = 'enterPassword' then created else null end) as first_enterpassword_timestamp
     , min(case when identifier = 'eventPicker' then created else null end) as first_eventpicker_timestamp
     , min(case when identifier = 'eventProfileChoice' then created else null end) as first_enterprofilechoice_timestamp
     , min(case when identifier = 'profileFiller' then created else null end) as first_profilefiller_timestamp
     , min(case when identifier = 'activities' then created else null end) as first_gloablactivities_timestamp
from jt.loginflow_new_metrics_view_sample
group by upper(bundle_id), upper(device_id), device_type;


drop table jt.loginflow_new_metrics_actions;
create table jt.loginflow_new_metrics_actions as
select upper(bundle_id) as bundleid
     , upper(device_id) as deviceid
     , device_type
     , min(case when identifier = 'accountSelectButton' then created else null end) as first_accountselectbutton_timestamp
     , min(case when identifier = 'anotherAccountButton' then created else null end) as first_anotheraccountbutton_timestamp
     , min(case when identifier = 'enterEmailTextField' then created else null end) as first_enteremailtextfield_timestamp
     , min(case when identifier = 'submitEmailButton' then created else null end) as first_submitemailbutton_timestamp
     , min(case when identifier = 'eventSelectButton' then created else null end) as first_eventselectbutton_timestamp
     , min(case when identifier = 'createProfileButton' then created else null end) as first_createprofilebutton_timestamp
     , min(case when identifier = 'changeProfilePhotoButton' then created else null end) as first_changeprofilephotobutton_timestamp
     , min(case when identifier = 'enterFirstNameTextField' then created else null end) as first_enterfirstnametextfield_timestamp
     , min(case when identifier = 'enterLastNameTextField' then created else null end) as first_enterlastnametextfield_timestamp
     , min(case when identifier = 'enterCompanyTextField' then created else null end) as first_entercompanytextfield_timestamp
     , min(case when identifier = 'enterTitleTextField' then created else null end) as first_entertitletextfield_timestamp
     , min(case when identifier = 'submitProfileButton' then created else null end) as first_submitprofilebutton_timestamp
from jt.loginflow_new_metrics_actions_sample
group by upper(bundle_id), upper(device_id), device_type;


drop table jt.loginflow_new_metrics_sessions;
create table jt.loginflow_new_metrics_sessions (
     bundleid varchar
   , applicationid varchar
   , name varchar
   , startdate timestamp
   , enddate timestamp
   , canregister varchar
   , deviceid varchar
   , sessionstartdate timestamp );
   

insert into jt.loginflow_new_metrics_sessions (      
select upper(b.bundleid) as bundleid
     , upper(a.applicationid) as applicationid
     , b.name
     , b.startdate
     , b.enddate
     , b.canregister
     , upper(a.deviceid) as deviceid
     , a.startdate as sessionstartdate
from v_fact_sessions_all a
join authdb_applications b
on a.applicationid = b.applicationid
where a.metrictypeid = 1 
and a.applicationid in (select distinct b.applicationid
                          from (select distinct bundleid
                                from jt.loginflow_new_metrics_views
                                union 
                                select distinct bundleid
                                from jt.loginflow_new_metrics_actions) a
                          join authdb_applications b
                          on a.bundleid = b.bundleid
                          left join eventcube.testevents c
                          on b.applicationid = c.applicationid
                          where c.applicationid is null));
                          
drop table jt.loginflow_new_metrics_min_sessions;
create table jt.loginflow_new_metrics_min_sessions as                  
select bundleid
     , deviceid
     , min(sessionstartdate) as first_sessionstartdate
from jt.loginflow_new_metrics_sessions
group by 1,2;


drop table jt.loginflow_new_metrics_views_initial;
create table jt.loginflow_new_metrics_views_initial as
select a.bundleid
     , a.deviceid
     , a.device_type
     , a.first_accountpicker_timestamp
     , c.first_accountselectbutton_timestamp
     , c.first_anotheraccountbutton_timestamp
     , a.first_enteremail_timestamp
     , c.first_enteremailtextfield_timestamp
     , c.first_submitemailbutton_timestamp
     , a.first_enterpassword_timestamp
     , a.first_eventpicker_timestamp
     , c.first_eventselectbutton_timestamp
     , a.first_enterprofilechoice_timestamp
     , c.first_createprofilebutton_timestamp
     , a.first_profilefiller_timestamp
     , c.first_enterfirstnametextfield_timestamp
     , c.first_enterlastnametextfield_timestamp
     , c.first_entercompanytextfield_timestamp
     , c.first_submitprofilebutton_timestamp
     , a.first_gloablactivities_timestamp
     , b.first_sessionstartdate
from (select * from jt.loginflow_new_metrics_views
      where bundleid is not null and deviceid is not null) a
left join (select * from jt.loginflow_new_metrics_actions
           where bundleid is not null and deviceid is not null) c
on a.bundleid = c.bundleid and a.deviceid = c.deviceid
left join jt.loginflow_new_metrics_min_sessions b
on a.bundleid = b.bundleid and a.deviceid = b.deviceid
where (a.device_type = 'android' and first_sessionstartdate is not null and first_accountpicker_timestamp < first_sessionstartdate)
or (a.device_type = 'android' and first_sessionstartdate is null)
or (a.device_type = 'ios' and first_enteremail_timestamp < first_sessionstartdate)
or (a.device_type = 'ios' and first_sessionstartdate is null);



-- iOS

select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_profilefiller_timestamp is not null then 1 else null end) as profilefillerviewcnt
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end) as globalactivityviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerviewpct
     , count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4) as profilefillerviewpct
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4) as globalactivityviewpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
left join (select distinct bundleid
           from jt.loginflow_new_metrics_views_initial
           where first_enterprofilechoice_timestamp is not null) c
on a.bundleid = c.bundleid
where c.bundleid is null
and (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));



select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_enterprofilechoice_timestamp is not null then 1 else null end) as enterprofilechoiceviewcnt     
     , count(case when first_profilefiller_timestamp is not null then 1 else null end) as profilefillerviewcnt
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end) as globalactivityviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerviewpct
     , count(case when first_enterprofilechoice_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4) as enterprofilechoiceviewpct
     , count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enterprofilechoice_timestamp is not null then 1 else null end)::decimal(12,4) as profilefillerviewpct
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4) as globalactivityviewpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
join (select distinct bundleid
      from jt.loginflow_new_metrics_views_initial
      where first_enterprofilechoice_timestamp is not null) c
on a.bundleid = c.bundleid
where (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));


select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));




-- Android

select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_profilefiller_timestamp is not null then 1 else null end) as profilefillerviewcnt
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end) as globalactivityviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as enteremailviewpct
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerviewpct
     , count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4) as profilefillerviewpct
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4) as globalactivityviewpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
left join (select distinct bundleid
      from jt.loginflow_new_metrics_views_initial
      where first_enterprofilechoice_timestamp is not null) c
on a.bundleid = c.bundleid
where c.bundleid is null
and (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));


select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_enterprofilechoice_timestamp is not null then 1 else null end) as enterprofilechoiceviewcnt
     , count(case when first_profilefiller_timestamp is not null then 1 else null end) as profilefillerviewcnt
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end) as globalactivityviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as enteremailviewpct
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as eventpickerviewpct
     , count(case when first_enterprofilechoice_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4) as enterprofilechoiceviewpct
     , count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enterprofilechoice_timestamp is not null then 1 else null end)::decimal(12,4) as profilefillerviewpct
     , count(case when first_gloablactivities_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_profilefiller_timestamp is not null then 1 else null end)::decimal(12,4) as globalactivityviewpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
join (select distinct bundleid
      from jt.loginflow_new_metrics_views_initial
      where first_enterprofilechoice_timestamp is not null) c
on a.bundleid = c.bundleid
where (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));


select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as accountpickerviewpct
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));






-- Follow Up Questions

-- How many events: 131

select a.bundleid
     , c.name as bundlename
     , count(case when device_type = 'ios' then 1 else null end) as iosdevicecnt
     , count(case when device_type = 'ios' and first_enteremail_timestamp is not null then 1 else null end) as iosdevicefirstviewcnt
     , count(case when device_type = 'android' then 1 else null end) as androiddevicecnt
     , count(case when device_type = 'android' and first_accountpicker_timestamp is not null then 1 else null end) as iosdevicefirstviewcnt     
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
join (select distinct bundleid, name from authdb_bundles) c
on b.bundleid = c.bundleid
where (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)))
or (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)))
group by 1,2;


select distinct a.bundleid
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
join (select distinct bundleid, name from authdb_bundles) c
on b.bundleid = c.bundleid
where (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)))
or (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)));




select bundleid
     , applicationid
     , name
     , startdate
     , enddate
     , canregister
from authdb_applications
where bundleid in (
select distinct a.bundleid
from jt.loginflow_new_metrics_views_initial a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
join (select distinct bundleid, name from authdb_bundles) c
on b.bundleid = c.bundleid
where (device_type = 'ios' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate)))
or (device_type = 'android' and (first_enterpassword_timestamp is null or (first_enterpassword_timestamp is not null and first_sessionstartdate is not null and first_enterpassword_timestamp > first_sessionstartdate))))
and bundleid = '71891C8D-9788-4140-8740-75EBAC117221'
order by startdate, enddate, applicationid, canregister;


-- A relatively low number of people clicked on enter email link. Any conclusions we can draw from this? Would it be fair to say, given the choice between tapping email vs entering email users would pick tapping.


drop table if exists jt.loginflow_new_metrics_all;
create table jt.loginflow_new_metrics_all as
select upper(bundle_id) as bundleid
     , upper(device_id) as deviceid
     , 'view' as identifier_type
     , device_type
     , identifier
     , created
from jt.loginflow_new_metrics_view_sample
union all
select upper(bundle_id) as bundleid
     , upper(device_id) as deviceid
     , 'action' as identifier_type
     , device_type
     , identifier
     , created
from jt.loginflow_new_metrics_actions_sample;


drop table if exists jt.loginflow_new_metrics_all_seq;
create table jt.loginflow_new_metrics_all_seq as
select row_number() over (partition by bundleid, deviceid, device_type, identifier order by created) as identifierseqnum
     , row_number() over (partition by bundleid, deviceid, device_type, identifier_type order by created) as typeseqnum
     , row_number() over (partition by bundleid, deviceid, device_type order by created) as seqnum
     , *
from jt.loginflow_new_metrics_all;



drop table jt.loginflow_new_metrics_view_2;
create table jt.loginflow_new_metrics_view_2 as
select bundleid
     , deviceid
     , device_type
     
     /* View Sequence Number */ 
     , min(case when identifier = 'accountPicker' then seqnum else null end) as accountpickerseqnum
     , min(case when identifier = 'enterEmail' then seqnum else null end) as enteremailseqnum
     , min(case when identifier = 'enterPassword' then seqnum else null end) as enterpasswordseqnum
     , min(previousviewseqnum) as previouseventpickerviewseqnum
     , min(case when identifier = 'eventPicker' then seqnum else null end) as eventpickerseqnum
     , min(case when identifier = 'eventProfileChoice' then seqnum else null end) as eventprofilechoiceseqnum
     , min(case when identifier = 'profileFiller' then seqnum else null end) as profilefillerseqnum
     , min(case when identifier = 'activities' then seqnum else null end) as activityseqnum
     
     /* View Created Timestamps */ 
     , min(case when identifier = 'accountPicker' then created else null end) as first_accountpicker_timestamp
     , min(case when identifier = 'enterEmail' then created else null end) as first_enteremail_timestamp
     , min(case when identifier = 'enterPassword' then created else null end) as first_enterpassword_timestamp
     , min(previousview) as previouseventpickerview
     /*, min(previousaction) as previousaction*/
     , min(case when identifier = 'eventPicker' then created else null end) as first_eventpicker_timestamp
     , min(case when identifier = 'eventProfileChoice' then created else null end) as first_enterprofilechoice_timestamp
     , min(case when identifier = 'profileFiller' then created else null end) as first_profilefiller_timestamp
     , min(case when identifier = 'activities' then created else null end) as first_gloablactivities_timestamp
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
                 /*, case
                      when identifier = 'eventPicker' and device_type = 'android' and identifier_type = 'action'
                      then lag(seqnum,1) over (partition by bundleid, deviceid, identifier_type order by typeseqnum)
                   end as previousactionseqnum
                 , case
                      when identifier = 'eventPicker' and device_type = 'android' and identifier_type = 'action'
                      then lag(identifier,1) over (partition by bundleid, deviceid, identifier_type order by typeseqnum)
                   end as previousaction*/
            from jt.loginflow_new_metrics_all_seq) a
      where identifierseqnum = 1) a
group by 1,2,3;




drop table jt.loginflow_new_metrics_actions_2;
create table jt.loginflow_new_metrics_actions_2 as
select bundleid
     , deviceid
     , device_type  
      
     /* Action Sequence Number */  
     , min(case when identifier = 'accountSelectButton' then seqnum else null end) as accountselectbuttonseqnum
     , min(case when identifier = 'anotherAccountButton' then seqnum else null end) as anotheraccountbuttonseqnum
     , min(case when identifier = 'enterEmailTextField' then seqnum else null end) as enteremailtextfieldseqnum
     , min(case when identifier = 'submitEmailButton' then seqnum else null end) as submitemailbuttonseqnum
     , min(case when identifier = 'eventSelectButton' then seqnum else null end) as eventselectbuttonseqnum
     , min(case when identifier = 'createProfileButton' then seqnum else null end) as createprofilebuttonseqnum
     , min(case when identifier = 'changeProfilePhotoButton' then seqnum else null end) as changeprofilephotobuttonseqnum
     , min(case when identifier = 'enterFirstNameTextField' then seqnum else null end) as enterfirstnametextfieldseqnum
     , min(case when identifier = 'enterLastNameTextField' then seqnum else null end) as enterlastnametextfieldseqnum
     , min(case when identifier = 'enterCompanyTextField' then seqnum else null end) as entercompanytextfieldseqnum
     , min(case when identifier = 'enterTitleTextField' then seqnum else null end) as entertitletextfieldseqnum
     , min(case when identifier = 'submitProfileButton' then seqnum else null end) as submitprofilebuttonseqnum
     
     /* Action Created Timestamps */  
     , min(case when identifier = 'accountSelectButton' then created else null end) as first_accountselectbutton_timestamp
     , min(case when identifier = 'anotherAccountButton' then created else null end) as first_anotheraccountbutton_timestamp
     , min(case when identifier = 'enterEmailTextField' then created else null end) as first_enteremailtextfield_timestamp
     , min(case when identifier = 'submitEmailButton' then created else null end) as first_submitemailbutton_timestamp
     , min(case when identifier = 'eventSelectButton' then created else null end) as first_eventselectbutton_timestamp
     , min(case when identifier = 'createProfileButton' then created else null end) as first_createprofilebutton_timestamp
     , min(case when identifier = 'changeProfilePhotoButton' then created else null end) as first_changeprofilephotobutton_timestamp
     , min(case when identifier = 'enterFirstNameTextField' then created else null end) as first_enterfirstnametextfield_timestamp
     , min(case when identifier = 'enterLastNameTextField' then created else null end) as first_enterlastnametextfield_timestamp
     , min(case when identifier = 'enterCompanyTextField' then created else null end) as first_entercompanytextfield_timestamp
     , min(case when identifier = 'enterTitleTextField' then created else null end) as first_entertitletextfield_timestamp
     , min(case when identifier = 'submitProfileButton' then created else null end) as first_submitprofilebutton_timestamp
from (select bundleid
           , deviceid
           , device_type
           , identifier_type
           , identifier
           , created
           , seqnum
      from jt.loginflow_new_metrics_all_seq
      where identifierseqnum = 1) a
group by 1,2,3;


/* Device Audit */
select count(*)
     , count(case when accountpickerseqnum is not null then 1 else null end) as accountpickercnt
     , count(case when accountpickerseqnum is not null 
                       and ((first_gloablactivities_timestamp is not null and first_accountpicker_timestamp < first_gloablactivities_timestamp)
                           or (first_gloablactivities_timestamp is null and first_accountpicker_timestamp is not null)) 
                  then 1 
                  else null 
             end) as accountpickergoodcnt
     , count(case when accountpickerseqnum is null and enteremailseqnum is not null then 1 else null end) as enteremailcnt
     , count(case when accountpickerseqnum is null and enteremailseqnum is not null
                       and ((first_gloablactivities_timestamp is not null and first_enteremail_timestamp < first_gloablactivities_timestamp)
                           or (first_gloablactivities_timestamp is null and first_enteremail_timestamp is not null)) 
                  then 1 
                  else null 
             end) as enteremailgoodcnt
     , count(case when accountpickerseqnum is null and enteremailseqnum is null then 1 else null end) as badcnt
from jt.loginflow_new_metrics_view_2
where device_type = 'android';


drop table jt.loginflow_new_metrics_views_initial_2;
create table jt.loginflow_new_metrics_views_initial_2 as
select a.bundleid
     , a.deviceid
     , a.device_type  
     
     /* Sequence Number */ 
     , a.accountpickerseqnum
     , c.accountselectbuttonseqnum
     , c.anotheraccountbuttonseqnum
     , a.enteremailseqnum
     , c.enteremailtextfieldseqnum
     , c.submitemailbuttonseqnum
     , a.enterpasswordseqnum
     , a.previouseventpickerviewseqnum
     , a.eventpickerseqnum
     , c.eventselectbuttonseqnum
     , a.eventprofilechoiceseqnum
     , c.createprofilebuttonseqnum
     , a.profilefillerseqnum
     , c.enterfirstnametextfieldseqnum
     , c.enterlastnametextfieldseqnum
     , c.entercompanytextfieldseqnum
     , c.entertitletextfieldseqnum
     , c.submitprofilebuttonseqnum
     , a.activityseqnum  
     
     /* Created Timestamps */   
     , a.first_accountpicker_timestamp
     , c.first_accountselectbutton_timestamp
     , c.first_anotheraccountbutton_timestamp
     , a.first_enteremail_timestamp
     , c.first_enteremailtextfield_timestamp
     , c.first_submitemailbutton_timestamp
     , a.first_enterpassword_timestamp
     , a.previouseventpickerview
     , a.first_eventpicker_timestamp
     , c.first_eventselectbutton_timestamp
     , a.first_enterprofilechoice_timestamp
     , c.first_createprofilebutton_timestamp
     , a.first_profilefiller_timestamp
     , c.first_enterfirstnametextfield_timestamp
     , c.first_enterlastnametextfield_timestamp
     , c.first_entercompanytextfield_timestamp
     , c.first_entertitletextfield_timestamp
     , c.first_submitprofilebutton_timestamp
     , a.first_gloablactivities_timestamp
     , b.first_sessionstartdate
     , case
         when (a.device_type = 'android' and first_gloablactivities_timestamp is not null and first_accountpicker_timestamp is not null and first_accountpicker_timestamp < first_gloablactivities_timestamp)
         then 1
         when (a.device_type = 'android' and first_gloablactivities_timestamp is null and first_accountpicker_timestamp is not null)
         then 2
         when (a.device_type = 'android' and first_gloablactivities_timestamp is not null and first_enteremail_timestamp is not null and first_enteremail_timestamp < first_gloablactivities_timestamp)
         then 3
         when (a.device_type = 'android' and first_gloablactivities_timestamp is null and first_enteremail_timestamp is not null)
         then 4
         when (a.device_type = 'ios' and first_enteremail_timestamp < first_gloablactivities_timestamp)
         then 5
         when (a.device_type = 'ios' and first_gloablactivities_timestamp is null and first_enteremail_timestamp is not null)
         then 6
         else null
       end as reason
/* Add View Information */
from (select * from jt.loginflow_new_metrics_view_2
      where bundleid is not null and deviceid is not null) a
/* Add Action Information */
left join (select * from jt.loginflow_new_metrics_actions_2
           where bundleid is not null and deviceid is not null) c
on a.bundleid = c.bundleid and a.deviceid = c.deviceid
/* Add First Session Date */
left join jt.loginflow_new_metrics_min_sessions b
on a.bundleid = b.bundleid and a.deviceid = b.deviceid
/* Only Allow Bundle/Device Combinations where either:
   (1) For Android, the accountpickerview or enteremailview was viewed 1st and before the 1st view of the global activity feed.
   (2) For iOS, the enteremailview was viewed. 
*/
where (a.device_type = 'android' and first_gloablactivities_timestamp is not null and first_accountpicker_timestamp is not null and first_accountpicker_timestamp < first_gloablactivities_timestamp)
or (a.device_type = 'android' and first_gloablactivities_timestamp is null and first_accountpicker_timestamp is not null)
or (a.device_type = 'android' and first_gloablactivities_timestamp is not null and first_enteremail_timestamp is not null and first_enteremail_timestamp < first_gloablactivities_timestamp)
or (a.device_type = 'android' and first_gloablactivities_timestamp is null and first_enteremail_timestamp is not null)
or (a.device_type = 'ios' and first_enteremail_timestamp < first_gloablactivities_timestamp)
or (a.device_type = 'ios' and first_gloablactivities_timestamp is null and first_enteremail_timestamp is not null);


drop table jt.loginflow_new_metrics_views_initial_clean_android_path12_2;
create table jt.loginflow_new_metrics_views_initial_clean_android_path12_2 as
select bundleid
     , deviceid
     , device_type        
     , first_accountpicker_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_accountselectbutton_timestamp < first_gloablactivities_timestamp
            then first_accountselectbutton_timestamp
         when first_gloablactivities_timestamp is null and first_accountselectbutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_accountselectbutton_timestamp
         else null
       end as first_accountselectbutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_anotheraccountbutton_timestamp < first_gloablactivities_timestamp
            then first_anotheraccountbutton_timestamp
         when first_gloablactivities_timestamp is null and first_anotheraccountbutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_anotheraccountbutton_timestamp
         else null
       end as first_anotheraccountbutton_timestamp       
     , case
         when first_gloablactivities_timestamp is not null and first_enteremail_timestamp < first_gloablactivities_timestamp
            then first_enteremail_timestamp
         when first_gloablactivities_timestamp is null and first_enteremail_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enteremail_timestamp
         else null
       end as first_enteremail_timestamp     
     , case
         when first_gloablactivities_timestamp is not null and first_enteremailtextfield_timestamp < first_gloablactivities_timestamp
            then first_enteremailtextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enteremailtextfield_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enteremailtextfield_timestamp
         else null
       end as first_enteremailtextfield_timestamp   
     , case
         when first_gloablactivities_timestamp is not null and first_submitemailbutton_timestamp < first_gloablactivities_timestamp
            then first_submitemailbutton_timestamp
         when first_gloablactivities_timestamp is null and first_submitemailbutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_submitemailbutton_timestamp
         else null
       end as first_submitemailbutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterpassword_timestamp < first_gloablactivities_timestamp
            then first_enterpassword_timestamp
         when first_gloablactivities_timestamp is null and first_enterpassword_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enterpassword_timestamp
         else null
       end as first_enterpassword_timestamp
     , previouseventpickerview   
     , case
         when first_gloablactivities_timestamp is not null and first_eventpicker_timestamp < first_gloablactivities_timestamp
            then first_eventpicker_timestamp
         when first_gloablactivities_timestamp is null and first_eventpicker_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_eventpicker_timestamp
         else null
       end as first_eventpicker_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_eventselectbutton_timestamp < first_gloablactivities_timestamp
            then first_eventselectbutton_timestamp
         when first_gloablactivities_timestamp is null and first_eventselectbutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_eventselectbutton_timestamp
         else null
       end as first_eventselectbutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterprofilechoice_timestamp < first_gloablactivities_timestamp
            then first_enterprofilechoice_timestamp
         when first_gloablactivities_timestamp is null and first_enterprofilechoice_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enterprofilechoice_timestamp
         else null
       end as first_enterprofilechoice_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_createprofilebutton_timestamp < first_gloablactivities_timestamp
            then first_createprofilebutton_timestamp
         when first_gloablactivities_timestamp is null and first_createprofilebutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_createprofilebutton_timestamp
         else null
       end as first_createprofilebutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_profilefiller_timestamp < first_gloablactivities_timestamp
            then first_profilefiller_timestamp
         when first_gloablactivities_timestamp is null and first_profilefiller_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_profilefiller_timestamp
         else null
       end as first_profilefiller_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterfirstnametextfield_timestamp < first_gloablactivities_timestamp
            then first_enterfirstnametextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enterfirstnametextfield_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enterfirstnametextfield_timestamp
         else null
       end as first_enterfirstnametextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterlastnametextfield_timestamp < first_gloablactivities_timestamp
            then first_enterlastnametextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enterlastnametextfield_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_enterlastnametextfield_timestamp
         else null
       end as first_enterlastnametextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_entercompanytextfield_timestamp < first_gloablactivities_timestamp
            then first_entercompanytextfield_timestamp
         when first_gloablactivities_timestamp is null and first_entercompanytextfield_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_entercompanytextfield_timestamp
         else null
       end as first_entercompanytextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_entertitletextfield_timestamp < first_gloablactivities_timestamp
            then first_entertitletextfield_timestamp
         when first_gloablactivities_timestamp is null and first_entertitletextfield_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_entertitletextfield_timestamp
         else null
       end as first_entertitletextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_submitprofilebutton_timestamp < first_gloablactivities_timestamp
            then first_submitprofilebutton_timestamp
         when first_gloablactivities_timestamp is null and first_submitprofilebutton_timestamp < first_accountpicker_timestamp + interval '10' minute
            then first_submitprofilebutton_timestamp
         else null
       end as first_submitprofilebutton_timestamp
     , first_gloablactivities_timestamp
     , first_sessionstartdate
     , reason
from jt.loginflow_new_metrics_views_initial_2
where device_type = 'android'
and reason in (1,2);




drop table jt.loginflow_new_metrics_views_initial_clean_android_path34_2;
create table jt.loginflow_new_metrics_views_initial_clean_android_path34_2 as
select bundleid
     , deviceid
     , device_type        
     , first_accountpicker_timestamp
     , first_accountselectbutton_timestamp
     , first_anotheraccountbutton_timestamp       
     , first_enteremail_timestamp     
     , case
         when first_gloablactivities_timestamp is not null and first_enteremailtextfield_timestamp < first_gloablactivities_timestamp
            then first_enteremailtextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enteremailtextfield_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_enteremailtextfield_timestamp
         else null
       end as first_enteremailtextfield_timestamp   
     , case
         when first_gloablactivities_timestamp is not null and first_submitemailbutton_timestamp < first_gloablactivities_timestamp
            then first_submitemailbutton_timestamp
         when first_gloablactivities_timestamp is null and first_submitemailbutton_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_submitemailbutton_timestamp
         else null
       end as first_submitemailbutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterpassword_timestamp < first_gloablactivities_timestamp
            then first_enterpassword_timestamp
         when first_gloablactivities_timestamp is null and first_enterpassword_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_enterpassword_timestamp
         else null
       end as first_enterpassword_timestamp
     , previouseventpickerview   
     , case
         when first_gloablactivities_timestamp is not null and first_eventpicker_timestamp < first_gloablactivities_timestamp
            then first_eventpicker_timestamp
         when first_gloablactivities_timestamp is null and first_eventpicker_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_eventpicker_timestamp
         else null
       end as first_eventpicker_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_eventselectbutton_timestamp < first_gloablactivities_timestamp
            then first_eventselectbutton_timestamp
         when first_gloablactivities_timestamp is null and first_eventselectbutton_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_eventselectbutton_timestamp
         else null
       end as first_eventselectbutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterprofilechoice_timestamp < first_gloablactivities_timestamp
            then first_enterprofilechoice_timestamp
         when first_gloablactivities_timestamp is null and first_enterprofilechoice_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_enterprofilechoice_timestamp
         else null
       end as first_enterprofilechoice_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_createprofilebutton_timestamp < first_gloablactivities_timestamp
            then first_createprofilebutton_timestamp
         when first_gloablactivities_timestamp is null and first_createprofilebutton_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_createprofilebutton_timestamp
         else null
       end as first_createprofilebutton_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_profilefiller_timestamp < first_gloablactivities_timestamp
            then first_profilefiller_timestamp
         when first_gloablactivities_timestamp is null and first_profilefiller_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_profilefiller_timestamp
         else null
       end as first_profilefiller_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterfirstnametextfield_timestamp < first_gloablactivities_timestamp
            then first_enterfirstnametextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enterfirstnametextfield_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_enterfirstnametextfield_timestamp
         else null
       end as first_enterfirstnametextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_enterlastnametextfield_timestamp < first_gloablactivities_timestamp
            then first_enterlastnametextfield_timestamp
         when first_gloablactivities_timestamp is null and first_enterlastnametextfield_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_enterlastnametextfield_timestamp
         else null
       end as first_enterlastnametextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_entercompanytextfield_timestamp < first_gloablactivities_timestamp
            then first_entercompanytextfield_timestamp
         when first_gloablactivities_timestamp is null and first_entercompanytextfield_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_entercompanytextfield_timestamp
         else null
       end as first_entercompanytextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_entertitletextfield_timestamp < first_gloablactivities_timestamp
            then first_entertitletextfield_timestamp
         when first_gloablactivities_timestamp is null and first_entertitletextfield_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_entertitletextfield_timestamp
         else null
       end as first_entertitletextfield_timestamp
     , case
         when first_gloablactivities_timestamp is not null and first_submitprofilebutton_timestamp < first_gloablactivities_timestamp
            then first_submitprofilebutton_timestamp
         when first_gloablactivities_timestamp is null and first_submitprofilebutton_timestamp < first_enteremail_timestamp + interval '10' minute
            then first_submitprofilebutton_timestamp
         else null
       end as first_submitprofilebutton_timestamp
     , first_gloablactivities_timestamp
     , first_sessionstartdate
     , reason
from jt.loginflow_new_metrics_views_initial_2
where device_type = 'android'
and reason in (3,4);




-- Path 1: accountpickerview -> eventpickerview

select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as accountpickerviewpct
from jt.loginflow_new_metrics_views_initial_clean_android_path12_2 a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (first_enterpassword_timestamp is null 
or (first_enterpassword_timestamp is not null and first_gloablactivities_timestamp is not null and first_enterpassword_timestamp > first_gloablactivities_timestamp));


-- Break Out the Different Paths:

-- accountpickerview -> eventpickerview


select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accountpicker_timestamp is not null then 1 else null end)::decimal(12,4) as accountpickerviewpct
from jt.loginflow_new_metrics_views_initial_clean_android_path12_2 a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (first_enterpassword_timestamp is null 
or (first_enterpassword_timestamp is not null and first_gloablactivities_timestamp is not null and first_enterpassword_timestamp > first_gloablactivities_timestamp))
and first_enteremail_timestamp is null;

-- accountpickerview -> enteremailview -> eventpickerview

select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null and previouseventpickerview = 'accountPicker' then 1 else null end) as previousaccountpickerviewcnt     
     , count(case when first_eventpicker_timestamp is not null and previouseventpickerview = 'enterEmail' then 1 else null end) as previousenteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as accountpickerviewpct
from jt.loginflow_new_metrics_views_initial_clean_android_path12_2 a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (first_enterpassword_timestamp is null 
or (first_enterpassword_timestamp is not null and first_gloablactivities_timestamp is not null and first_enterpassword_timestamp > first_gloablactivities_timestamp))
and first_enteremail_timestamp is not null;




-- Path 2:  enteremailview -> eventpickerview


select count(*) as rowcnt
     , count(distinct a.bundleid) as bundlecnt
     , count(distinct a.deviceid) as devicecnt
     , count(case when first_accountpicker_timestamp is not null then 1 else null end) as accountpickerviewcnt
     , count(case when first_enteremail_timestamp is not null then 1 else null end) as enteremailviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end) as eventpickerviewcnt
     , count(case when first_eventpicker_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_enteremail_timestamp is not null then 1 else null end)::decimal(12,4) as accountpickerviewpct
from jt.loginflow_new_metrics_views_initial_clean_android_path34_2 a
join (select bundleid
      from authdb_applications a
      left join eventcube.testevents b
      on a.applicationid = b.applicationid
      where b.applicationid is null
      group by bundleid
      having count(case when canregister = 'false' then 1 else null end) = 0) b
on a.bundleid = b.bundleid
where (first_enterpassword_timestamp is null 
or (first_enterpassword_timestamp is not null and first_gloablactivities_timestamp is not null and first_enterpassword_timestamp > first_gloablactivities_timestamp));

