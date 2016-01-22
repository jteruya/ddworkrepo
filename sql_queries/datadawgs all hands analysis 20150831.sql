select *
from jt.adoption_report_quarter_summary;

-- Q3 Adoption by Event Type
select case
         when eventtype is null then 'No Event Type'
         else eventtype
       end as eventtype
     , count(adoption) as event_cnt
     , avg(adoption) as adoption_avg
from jt.adoption_report_quarter_event_summary a
join authdb_applications b
on a.applicationid = b.applicationid
group by 1
order by 2 desc;

-- Q3 Agenda Items

select avg(agenda_item_cnt)
     , percentile_cont(0.5) within group (order by agenda_item_cnt)
from (select application_id
           , global_user_id
           , count(*) as agenda_item_cnt
      from fact_views a
      join authdb_applications b
      on a.application_id = lower(b.applicationid)
      left join jt.adoption_report_testevents c
      on lower(b.applicationid) = lower(c.applicationid)
      where a.identifier = 'bookmarks' 
      and a.metadata->>'type' = 'agenda'
      and b.startdate >= '2015-07-01'
      and b.enddate <= '2015-09-30'
      and c.applicationid is null
      group by 1,2) a;


-- Survey to Complete

select 
from fact_impressions
where identifier = 'surveystocomplete'
limit 10;


-- Tapped on 

select avg(user_tapped_pct)
     , percentile_cont(0.5) within group (order by user_tapped_pct)
from (
select application_id
     , count(*) as users_cnt
     , count(case when user_tapped = 1 then 1 else null end) as user_tapped_cnt
     , count(case when user_tapped = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as user_tapped_pct
from (select distinct application_id
           , global_user_id
           , case
               when a.application_id is not null then 1
               else 0
             end as user_tapped
      from authdb_applications b
      join authdb_is_users d
      on b.applicationid = d.applicationid
      left join fact_actions a
      on a.application_id = lower(b.applicationid)
      left join jt.adoption_report_testevents c
      on lower(b.applicationid) = lower(c.applicationid)
      where a.identifier = 'surveystocompletebutton'
      and b.startdate >= '2015-07-01'
      and b.enddate <= '2015-09-30'
      and c.applicationid is null
      and d.isdisabled = 0) a
group by 1) a;


drop table if exists jt.allhands_events;
create table jt.allhands_events as
select a.*
from authdb_applications a
left join jt.adoption_report_testevents b
on lower(a.applicationid) = lower(b.applicationid)
where a.startdate >= '2015-07-01'
and a.enddate <= '2015-09-30'
and b.applicationid is null;

drop table if exists jt.allhands_events_user_cnt;
create table jt.allhands_events_user_cnt as
select a.applicationid
     , count(*) as user_cnt
from jt.allhands_events a
join authdb_is_users b
on a.applicationid = b.applicationid
where b.isdisabled = 0
group by 1;


drop table if exists jt.allhands_events_user_survey_to_complete;
create table jt.allhands_events_user_survey_to_complete as
select a.application_id
     , count(*) as user_tapped_cnt
from (select distinct a.application_id
           , a.global_user_id
      from fact_actions a
      join jt.allhands_events b
      on a.application_id = lower(b.applicationid)
      join authdb_is_users c
      on a.application_id = lower(c.applicationid) and a.global_user_id = lower(c.globaluserid)
      where c.isdisabled = 0
      and a.identifier = 'surveystocompletebutton') a
group by 1;

drop table if exists jt.allhands_events_user_my_agenda;
create table jt.allhands_events_user_my_agenda as
select a.application_id
     , count(*) as user_tapped_cnt
from (select distinct a.application_id
           , a.global_user_id
      from fact_views a
      join jt.allhands_events b
      on a.application_id = lower(b.applicationid)
      join authdb_is_users c
      on a.application_id = lower(c.applicationid) and a.global_user_id = lower(c.globaluserid)
      where c.isdisabled = 0
      and a.identifier = 'bookmarks' 
      and a.metadata->>'type' = 'agenda') a
group by 1;


select avg(pct)
     , percentile_cont(0.5) within group (order by pct)
from (
select a.application_id
     , a.user_tapped_cnt
     , b.user_cnt
     , a.user_tapped_cnt::decimal(12,4)/b.user_cnt::decimal(12,4) as pct
from jt.allhands_events_user_survey_to_complete a
join jt.allhands_events_user_cnt b
on a.application_id = lower(b.applicationid)) a;




select avg(pct)
     , percentile_cont(0.5) within group (order by pct)
from (
select a.application_id
     , a.user_tapped_cnt
     , b.user_cnt
     , a.user_tapped_cnt::decimal(12,4)/b.user_cnt::decimal(12,4) as pct
from jt.allhands_events_user_my_agenda a
join jt.allhands_events_user_cnt b
on a.application_id = lower(b.applicationid)) a;


/* Customer with most events */
select a.bundleid
     , b.name
     , count(*)
from authdb_applications a
join authdb_bundles b
on a.bundleid = b.bundleid
where lower(a.name) not like '%doubledutch%' and lower(b.name) not like '%doubledutch%' and lower(b.name) not in ('pride','ddqa')
and lower(a.bundleid) not in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
and a.startdate is not null
and a.enddate is not null
group by 1,2
order by 3 desc;



select c.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.eventtype
     , count(*) as actions
from fact_actions c
join authdb_applications a
on c.application_id = lower(a.applicationid)
join authdb_bundles b
on a.bundleid = b.bundleid
where lower(a.name) not like '%doubledutch%' and lower(b.name) not like '%doubledutch%' and lower(b.name) not in ('pride','ddqa')
and lower(a.bundleid) not in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
and a.startdate is not null
and a.enddate is not null
group by 1,2,3,4,5
order by 6 desc;
