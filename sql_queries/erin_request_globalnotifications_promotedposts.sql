drop table if exists jt.erin_request_agg_session_per_appuser;

create table jt.erin_request_agg_session_per_appuser as 
select distinct s.application_id as applicationid
     , s.user_id as userid
from public.fact_sessions s
join (select * from public.authdb_applications) a
on lower(a.applicationid::varchar) = lower(s.application_id)
where s.user_id is not null;

select *
from public.fact_sessions limit 10


drop table if exists jt.erin_request_testevents;

create table jt.erin_request_testevents as
select s.*
from (select distinct applicationid
           , trim(a.name) as name
      from public.authdb_applications a
      join public.authdb_bundles b on a.bundleid = b.bundleid
      
      -- 1a --
      where a.name like '%doubledutch%'
      or b.name like '%doubledutch%'
      or b.name in ('pride','ddqa')

      -- 1b --
      or a.bundleid in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
   
      union

      -- 2 --
      select a.applicationid
           , trim(a.name) as name
      from public.authdb_applications a
      left join jt.erin_request_agg_session_per_appuser s 
      on lower(a.applicationid) = lower(s.applicationid)
      group by 1,2
      having count(*) <= 20) s;
      
select s.applicationid
     , s.name
     , s.startdate
     , s.enddate
     , coalesce(p.promotedposts,0) as promotedposts
     , coalesce(g.globalpushnotifications,0) as globalpushnotifications
from public.authdb_applications s
--left join jt.erin_request_testevents b
left join jt.adoption_report_testevents b
on s.applicationid = b.applicationid
LEFT OUTER JOIN
( 
        SELECT 
                ApplicationId, 
                COUNT(*) PromotedPosts
        FROM PUBLIC.Ratings_PromotedPosts
        GROUP BY ApplicationId
) P ON S.ApplicationId = P.ApplicationId
LEFT OUTER JOIN
( 
        SELECT 
                ApplicationId, 
                COUNT(*) GlobalPushNotifications
        FROM PUBLIC.Ratings_GlobalMessages
        GROUP BY ApplicationId
) G ON S.ApplicationId = G.ApplicationId
join (select min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.adoption_report_calendar where date = current_date) a
      join jt.adoption_report_calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year) c
on s.startdate >= c.start_quarter_date and s.startdate <= c.end_quarter_date --and a.enddate < current_date
where b.applicationid is null
and s.startdate >= '2015-07-01'
and s.startdate <= '2015-09-30'
order by 3,4;


select b.bundleid
     , a.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , case
         when b.name like '%doubledutch%' or b.name like '%doubledutch%' or b.name in ('pride','ddqa') then 1
         when b.bundleid in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
         then 2
         else 3
       end as reason
from jt.erin_request_testevents a
join authdb_applications b
on a.applicationid = b.applicationid
where b.startdate >= '2015-07-01'
order by 4,5

select *
from fact_sessions
where metrics_type_id = 1 
and upper(application_id) = '65859721-FE52-4A66-89F3-E0C88545A193' limit 100


select *
from jt.erin_request_agg_session_per_appuser
where upper(applicationid) = '65859721-FE52-4A66-89F3-E0C88545A193';

select *
from public.authdb_applications
where applicationid = '65859721-FE52-4A66-89F3-E0C88545A193';
