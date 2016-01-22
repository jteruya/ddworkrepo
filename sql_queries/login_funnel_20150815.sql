
drop table if exists jt.login_funnel_loginview;

--============================================================================================================
-- Table: jt.login_funnel_loginview
-- Description: Get all of login views metrics relevant to the login funnel since 5/1/2015.
--              (1) enteremail
--              (2) enterpassword
--              (3) eventpicker
--              (4) profilefiller
--              (5) accountpicker
--============================================================================================================

create table jt.login_funnel_loginview as
select *
from public.fact_views
where created >= '2015-05-01'
and identifier in ('enteremail','enterpassword','eventpicker','profilefiller','accountpicker');


drop index if exists ndx_login_funnel_loginview;

--============================================================================================================
-- Index: ndx_login_funnel_loginview
--============================================================================================================

create index ndx_login_funnel_loginview on jt.login_funnel_loginview (app_type_id, identifier, bundle_id, device_id, created);


drop table if exists jt.login_funnel_events;

--============================================================================================================
-- Table: jt.login_funnel_events
-- Description: This table gets all of the events that will be involved with this analysis.  
--              The conditions are:
--              (1) Events that have a start date between 7/1/2015 - 8/13/2015
--              (2) Events that don't have the following substrings in their name:
--                      (a) doubledutch
--                      (b) pride
--                      (c) ddqa
--              (3) Events that are not within a list of bundle ids. (See SQL Code)
--              (4) Events that have at least 20 registered (non-disabled) users for the event.
--============================================================================================================

create table jt.login_funnel_events as
select a.bundleid
     , a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.eventtype
     , a.canregister
     , count(*) as event_reg_users
from public.authdb_applications a
join public.authdb_is_users b
on a.applicationid = b.applicationid
-- (1)
where a.startdate >= '2015-05-01' and a.enddate < '2015-08-13'  
-- (2)
and lower(a.name) not like '%doubledutch%' and lower(a.name) not in ('pride','ddqa')
-- (3)
and a.bundleid not in ('00000000-0000-0000-0000-000000000000','025AA15B-CE74-40AA-A4CC-04028401C8B3','89FD8F03-0D59-41AB-A6A7-2237D8AC4EB2','5A46600A-156A-441E-B594-40F7DEFB54F2','F95FE4A7-E86A-4661-AC59-8B423F1F540A','34B4E501-3F31-46A0-8F2A-0FB6EA5E4357','09E25995-8D8F-4C2D-8F55-15BA22595E11','5637BE65-6E3F-4095-BEB8-115849B5584A','9F3489D7-C93C-4C8B-8603-DDA6A9061116','D0F56154-E8E7-4566-A845-D3F47B8B35CC','BC35D4CE-C571-4F91-834A-A8136CA137C4','3E3FDA3D-A606-4013-8DDF-711A1871BD12','75CE91A5-BCC0-459A-B479-B3956EA09ABC','384D052E-0ABD-44D1-A643-BC590135F5A0','B752A5B3-AA53-4BCF-9F52-D5600474D198','15740A5A-25D8-4DC6-A9ED-7F610FF94085','0CBC9D00-1E6D-4DB3-95FC-C5FBB156C6DE','F0C4B2DB-A743-4FB2-9E8F-A80463E52B55','8A995A58-C574-421B-8F82-E3425D9054B0','6DBB91C8-6544-48EF-8B8D-A01B435F3757','F21325D8-3A43-4275-A8B8-B4B6E3F62DE0','DE8D1832-B4EA-4BD2-AB4B-732321328B04','7E289A59-E573-454C-825B-CF31B74C8506')
-- (4)
and b.isdisabled = 0
group by 1,2,3,4,5,6,7
-- (4)
having count(*) >= 20;


drop table if exists jt.login_funnel_device_spine;

--============================================================================================================
-- Table: jt.login_funnel_device_spine
-- Description: Create a spine of all unique device ids within the list of login checkpoint metrics.
--              There are only two exception device ids that are removed from the population:
--              (1) deviceid = '00000000-0000-0000-0000-000000000000'
--              (2) deviceid is null
--============================================================================================================

create table jt.login_funnel_device_spine as
select distinct deviceid, apptypeid, mmminfo
from jt.login_funnel_globalloginstart
where deviceid <> '00000000-0000-0000-0000-000000000000'
and deviceid is not null
union
select distinct deviceid, apptypeid, mmminfo
from jt.login_funnel_globalloginsuccess
where deviceid <> '00000000-0000-0000-0000-000000000000'
and deviceid is not null
union
select distinct deviceid, apptypeid, mmminfo
from jt.login_funnel_logineventsuccess
where deviceid <> '00000000-0000-0000-0000-000000000000'
and deviceid is not null
union
select distinct deviceid, apptypeid, mmminfo
from jt.login_funnel_profilecomplete
where deviceid <> '00000000-0000-0000-0000-000000000000'
and deviceid is not null;


drop table if exists jt.login_funnel_user_device_spine;

--============================================================================================================
-- Table: jt.login_funnel_user_device_spine
-- Description: This left joins the spine with the login_funnel_logineventsuccess and
--              and login_funnel_profilecomplete tables to get any associated bundleids and globaluserids.
--============================================================================================================

create table jt.login_funnel_user_device_spine as
select a.deviceid
     , a.apptypeid
     , a.mmminfo
     , b.globaluserid
     , b.bundleid
from jt.login_funnel_device_spine a
left join (select distinct a.deviceid
                , a.globaluserid
                , b.bundleid
           from jt.login_funnel_logineventsuccess a
           join jt.login_funnel_events b
           on a.applicationid = b.applicationid::uuid
           union
           select distinct a.deviceid
                , a.globaluserid
                , b.bundleid
           from jt.login_funnel_profilecomplete a
           join jt.login_funnel_events b
           on a.applicationid = b.applicationid::uuid) b
on a.deviceid = b.deviceid;


drop table if exists jt.login_funnel_view_user_device_spine;

--============================================================================================================
-- Table: jt.login_funnel_view_user_device_spine
-- Description: This left joins any spine elements not left joined successfully in the previous step with 
--              the view metrics and attempts to get bundleids and globaluserids.
--============================================================================================================

create table jt.login_funnel_view_user_device_spine as
select a.deviceid
     , a.apptypeid
     , a.mmminfo
     , b.globaluserid
     , b.bundleid
from jt.login_funnel_user_device_spine a
left join (select distinct lower(a.device_id)::uuid as deviceid
                , null::uuid as globaluserid
                , b.bundleid
           from jt.login_funnel_loginview a
           join jt.login_funnel_events b
           on a.bundle_id = lower(b.bundleid::varchar)
           where a.bundle_id is not null) b
on a.deviceid = b.deviceid
where a.bundleid is null;


drop table if exists jt.login_funnel_user_device_spine_comb;

--============================================================================================================
-- Table: jt.login_funnel_user_device_spine_comb
-- Description: This table regenerates the spine with the bundleid and globaluserid fields (if there are any
--              from the views).
--============================================================================================================

create table jt.login_funnel_user_device_spine_comb as
select *
from jt.login_funnel_user_device_spine
where bundleid is not null                     
union
select *
from jt.login_funnel_view_user_device_spine;


drop table if exists jt.login_funnel_user_device_spine_final;

--============================================================================================================
-- Table: jt.login_funnel_user_device_spine_final
-- Description: This table is the spine table but pulls out any deviceid that is associated to two or more
--              bundleids and/or globaluserids (~1%).
--============================================================================================================

create table jt.login_funnel_user_device_spine_final as
select *
from jt.login_funnel_user_device_spine_comb
where deviceid not in (select deviceid
                          from jt.login_funnel_user_device_spine_comb
                          group by 1
                          having count(*) > 1);


drop table if exists jt.login_funnel_spine_audit;

--============================================================================================================
-- Table: jt.login_funnel_spine_audit
-- Description: This table uses the spine table and flags whether the device id can be associated with a 
--              any of the four login checkpoint metrics.
--============================================================================================================

create table jt.login_funnel_spine_audit as
select a.*
     , case
         when b.deviceid is not null then 1
         else 0
       end as globalloginstartflag
     , case
         when c.deviceid is not null then 1
         else 0
       end as globalloginsuccessflag
     , case
         when d.deviceid is not null then 1
         else 0
       end as logineventsuccessflag
     , case
         when e.deviceid is not null then 1
         else 0
       end as profilecompleteflag
from jt.login_funnel_user_device_spine_final a
left join (select distinct deviceid from jt.login_funnel_globalloginstart) b
on a.deviceid = b.deviceid
left join (select distinct deviceid from jt.login_funnel_globalloginsuccess) c
on a.deviceid = c.deviceid
left join (select distinct deviceid from jt.login_funnel_logineventsuccess) d
on a.deviceid = d.deviceid
left join (select distinct deviceid from jt.login_funnel_profilecomplete) e
on a.deviceid = e.deviceid;


drop table if exists jt.login_funnel_spine_strange;

--============================================================================================================
-- Table: jt.login_funnel_spine_strange
-- Description: This table flags any device ids with strange checkpoint firings:
--              (1) profilecomplete flag is true but the globalloginstart and/or globalloginsuccess did not fire.
--              (2) logineventsuccessflag is true but the globalloginstart and/or globalloginsuccess did not fire.
--============================================================================================================

create table jt.login_funnel_spine_strange as
select *
from jt.login_funnel_spine_audit
where (profilecompleteflag = 1 and (globalloginstartflag = 0 or globalloginsuccessflag = 0))
or (logineventsuccessflag = 1 and (globalloginstartflag = 0 or globalloginsuccessflag = 0));


drop table if exists jt.login_funnel_user_device_spine_final_final;

--============================================================================================================
-- Table: jt.login_funnel_user_device_spine_final_final
-- Description: This table pulls out of the spine any deviceids that have a strange path.
--============================================================================================================

create table jt.login_funnel_user_device_spine_final_final as
select a.*
from jt.login_funnel_user_device_spine_final a
left join (select deviceid from jt.login_funnel_spine_strange) b
on a.deviceid = b.deviceid
where b.deviceid is null;


drop table if exists jt.login_funnel_ios;

--============================================================================================================
-- Table: jt.login_funnel_ios
-- Description:  This is the iOS funnel.
--============================================================================================================

create table jt.login_funnel_ios as
select s.bundleid
     , s.deviceid
     , case
         when a.device_id is not null then 1
         else 0
       end as enteremailflag
     , case
         when a1.device_id is not null then 1
         else 0
       end as globalloginstartflag
     , case
         when b.device_id is not null then 1
         else 0
       end as enterpasswordflag
     , case
         when c.device_id is not null then 1 
         else 0
       end as globalloginsuccessflag
     , case
         when d.device_id is not null then 1
         else 0
       end as eventpickerflag
     , case
         when e.device_id is not null then 1
         else 0
       end as logineventsuccessflag
     , case
         when f.device_id is not null then 1
         else 0
       end as profilefillerflag
     , case
         when g.device_id is not null then 1
         else 0
       end as profilecomplete
from (select * from jt.login_funnel_user_device_spine_final_final where apptypeid in (1,2)) s
left join (select distinct lower(device_id) as device_id
      from jt.login_funnel_loginview
      where identifier = 'enteremail') a
on s.deviceid::varchar = a.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_globalloginstart) a1
on s.deviceid::varchar = a1.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'enterpassword') b
on s.deviceid::varchar = b.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_globalloginsuccess) c
on s.deviceid::varchar = c.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'eventpicker') d
on s.deviceid::varchar = d.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_logineventsuccess) e
on s.deviceid::varchar = e.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'profilefiller') f
on s.deviceid::varchar = f.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_profilecomplete) g
on s.deviceid::varchar = g.device_id;
                  

drop table if exists jt.login_funnel_android;

--============================================================================================================
-- Table: jt.login_funnel_android
-- Description:  This is the Android funnel.
--============================================================================================================

create table jt.login_funnel_android as
select s.bundleid
     , s.deviceid
     , case
         when a.device_id is not null then 1
         else 0
       end as accountpickerflag
     , case
         when a2.device_id is not null then 1
         else 0
       end as globalloginstartflag
     , case
         when a1.device_id is not null then 1
         else 0
       end as enteremailflag
     , case
         when b.device_id is not null then 1
         else 0
       end as enterpasswordflag
     , case
         when c.device_id is not null then 1 
         else 0
       end as globalloginsuccessflag
     , case
         when d.device_id is not null then 1
         else 0
       end as eventpickerflag
     , case
         when e.device_id is not null then 1
         else 0
       end as logineventsuccessflag
     , case
         when f.device_id is not null then 1
         else 0
       end as profilefillerflag
     , case
         when g.device_id is not null then 1
         else 0
       end as profilecomplete
from (select * from jt.login_funnel_user_device_spine_final_final where apptypeid in (3)) s
left join (select distinct lower(device_id) as device_id
      from jt.login_funnel_loginview
      where identifier = 'accountpicker') a
on s.deviceid::varchar = a.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_globalloginstart) a2
on s.deviceid::varchar = a2.device_id
left join (select distinct lower(device_id) as device_id
      from jt.login_funnel_loginview
      where identifier = 'enteremail') a1
on s.deviceid::varchar = a1.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'enterpassword') b
on s.deviceid::varchar = b.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_globalloginsuccess) c
on s.deviceid::varchar = c.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'eventpicker') d
on s.deviceid::varchar = d.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_logineventsuccess) e
on s.deviceid::varchar = e.device_id
left join (select distinct lower(device_id) as device_id
           from jt.login_funnel_loginview
           where identifier = 'profilefiller') f
on s.deviceid::varchar = f.device_id
left join (select distinct deviceid::varchar as device_id
           from jt.login_funnel_profilecomplete) g
on s.deviceid::varchar = g.device_id;  



select count(*) as devicecnt
     , count(case when globalloginstartflag = 1 then 1 else null end) as globalloginstartcnt
     , count(case when globalloginstartflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as globalloginstartpct
     , count(case when globalloginsuccessflag = 1 then 1 else null end) as globalloginsuccesscnt
     , count(case when globalloginsuccessflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as globalloginsuccesspct
     , count(case when logineventsuccessflag = 1 then 1 else null end) as logineventsuccesscnt
     , count(case when logineventsuccessflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as logineventsuccesspct
     , count(case when profilecomplete = 1 then 1 else null end) as profilecompletecnt
     , count(case when profilecomplete = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as profilecompletepct
from jt.login_funnel_ios;

select count(*) as accountpickerviewcnt
     , count(case when globalloginstartflag = 1 then 1 else null end) as globalloginstartcnt
     , count(case when globalloginstartflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as globalloginstartpct
     , count(case when globalloginsuccessflag = 1 then 1 else null end) as globalloginsuccesscnt
     , count(case when globalloginsuccessflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as globalloginsuccesspct
     , count(case when logineventsuccessflag = 1 then 1 else null end) as logineventsuccesscnt
     , count(case when logineventsuccessflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as logineventsuccesspct
     , count(case when profilecomplete = 1 then 1 else null end) as profilecompletecnt
     , count(case when profilecomplete = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as profilecompletepct
from jt.login_funnel_android; 







           