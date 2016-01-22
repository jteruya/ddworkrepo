select *
from jt.seamlesslogin_email_analysis_events;

-- Identify Seamless Login Events
drop table if exists jt.seamlesslogin_email_analysis_events;
create table jt.seamlesslogin_email_analysis_events as
select b.applicationid
     , b.name as eventname
     , b.startdate
     , b.enddate
     , b.eventtype
     , b.canregister
     , a.name as settingname
     , a.settingvalue
from public.ratings_applicationconfigsettings a
join authdb_applications b
on a.applicationid = b.applicationid
left join eventcube.testevents c
on b.applicationid = c.applicationid
where c.applicationid is null
and lower(a.name) like '%seamless%'
and lower(a.settingvalue) = 'true'
order by b.startdate, b.enddate, b.applicationid;



drop table if exists jt.seamlesslogin_email_analysis_events_clicks;
create table jt.seamlesslogin_email_analysis_events_clicks as
select b.applicationid
     , a.messageid
     , to_timestamp(c.eventtimestamp/1000) as eventdatetime
     , c.clickurl
     , c.clientos
     , c.devicetype
     , c.clientname
     , c.clienttype
     , c.useragent
from mailgun.mailguncube a
join (select lower(applicationid)::uuid as applicationid from jt.seamlesslogin_email_analysis_events) b
on a.applicationid = b.applicationid
join (select * from mailgun.mailgun_events where eventstatus = 'clicked') c
on a.messageid = c.messageid
where lower(a.subject) like '%welcome%'
and a.clicked_flag = true
and (c.clickurl like '%bnc.lt%' or c.clickurl like '%download%');






--- Click/Device Breakdown

drop table if exists jt.seamlesslogin_email_analysis_events_device_clicks;
create table jt.seamlesslogin_email_analysis_events_device_clicks as
select applicationid
     , messageid
     , clientos
     , count(distinct devicetype) as devicetypecnt
     , min(case when devicetype = 'desktop' then eventdatetime else null end) as first_desktop_timestamp
     , min(case when devicetype = 'mobile' then eventdatetime else null end) as first_mobile_timestamp
     , min(case when devicetype = 'tablet' then eventdatetime else null end) as first_tablet_timestamp   
     , min(case when devicetype = 'unknown' then eventdatetime else null end) as first_unknown_timestamp
     --, min(case when devicetype = 'other' then eventdatetime else null end) as first_other_timestamp          
     , min(case when devicetype is null then eventdatetime else null end) as first_null_timestamp          
from jt.seamlesslogin_email_analysis_events_clicks
where devicetype <> 'other'
group by 1,2,3;


select count(*) as totalcnt
     , count(case when devicetypecnt = 0 then 1 else null end) as zerodevicecnt
     , count(case when devicetypecnt = 1 then 1 else null end) as onedevicecnt
     , count(case when devicetypecnt > 1 then 1 else null end) as twodevicecnt
     , count(case when devicetypecnt = 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as zerodevicepct
     , count(case when devicetypecnt = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as onedevicepct
     , count(case when devicetypecnt > 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as twodevicepct
from jt.seamlesslogin_email_analysis_events_device_clicks;


-- 2656 Welcome Emails
-- 3 Zero Device (.11%)  <- Pull out of Population
-- 2618 One Device (98.57%)
-- 35 Two Device (1.32%)


-- One Device Type Clicks

select count(*) as onedevicecnt
     , count(case when first_desktop_timestamp is not null then 1 else null end) as desktopclick
     , count(case when first_mobile_timestamp is not null then 1 else null end) as mobileclick
     , count(case when first_tablet_timestamp is not null then 1 else null end) as tabletclick
     , count(case when first_unknown_timestamp is not null then 1 else null end) as unknownclick
     --, count(case when first_other_timestamp is not null then 1 else null end) as otherclick
     , count(case when first_desktop_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as desktoppct
     , count(case when first_mobile_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as mobilepct
     , count(case when first_tablet_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as tabletpct
     , count(case when first_unknown_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as unknownpct
     --, count(case when first_other_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as otherpct
from jt.seamlesslogin_email_analysis_events_device_clicks
where devicetypecnt = 1;





-- Two or More Devices Clicks (Clicked on Any Link)

select count(*) as onedevicecnt
     , count(case when first_desktop_timestamp is not null then 1 else null end) as desktopclick
     , count(case when first_mobile_timestamp is not null then 1 else null end) as mobileclick
     , count(case when first_tablet_timestamp is not null then 1 else null end) as tabletclick
     , count(case when first_unknown_timestamp is not null then 1 else null end) as unknownclick
     , count(case when first_other_timestamp is not null then 1 else null end) as otherclick
     , count(case when first_desktop_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as desktoppct
     , count(case when first_mobile_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as mobilepct
     , count(case when first_tablet_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as tabletpct
     , count(case when first_unknown_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as unknownpct
     , count(case when first_other_timestamp is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as otherpct
from jt.seamlesslogin_email_analysis_events_device_clicks
where devicetypecnt > 1;




-- Click URL Type (Only going after download link)

select count(*)
     , count(case when clickurl like '%bnc.lt%' then 1 else null end) as branchiocnt
     , count(case when clickurl like '%download%' then 1 else null end) as regulardownloandcnt
     , count(case when clickurl = 'http://doubledutch.me/' then 1 else null end) as doubledutchlinkcnt    
     , count(case when clickurl like '%reset-password%' then 1 else null end) as resetpasswordcnt
     , count(case when clickurl like '%unsubscribe%' then 1 else null end) as unsubscribecnt
     , count(case when clickurl = '""' then 1 else null end) as blankcnt
from jt.seamlesslogin_email_analysis_events_clicks;


select *
from jt.seamlesslogin_email_analysis_events_clicks;

https://bnc.lt/l/5Ss7HRU_-X