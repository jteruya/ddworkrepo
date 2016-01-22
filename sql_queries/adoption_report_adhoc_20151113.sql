
select i::date as date
     , extract(year from i::date)::int as year
     , extract(quarter from i::date)::int as quarter_of_year
     , extract(week from i::date)::int as week_of_year
     , extract(month from i::date)::int as month_of_year
     , to_char(i::date, 'day') as day_name
     , extract(day from i::date)::int as day_of_month
     , rank() over (partition by extract(year from i::date)::int order by i::date) as day_of_year
into jt.adoption_report_calendar
from generate_series('2015-01-01', '2017-12-31', '1 day'::interval) i;

create table jt.adoption_report_agg_session_per_appuser as
select applicationid
     , userid
from eventcube.agg_session_per_appuser
union
select distinct upper(a.application_id) as applicationid
     , b.userid
from public.fact_sessions_live a
join authdb_is_users b
on a.global_user_id = b.globaluserid  
where identifier = 'start';


create table jt.adoption_report_testevents as
select s.*
from (select distinct applicationid
           , trim(a.name) as name
      from public.authdb_applications a
      join public.authdb_bundles b on a.bundleid = b.bundleid

      -- 1a --
      where lower(a.name) like '%doubledutch%'
      or lower(b.name) like '%doubledutch%'
      or lower(b.name) in ('pride','ddqa')

      -- 1b --
      or lower(a.bundleid) in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')

      union

      -- 2 --
      select a.applicationid
           , trim(a.name) as name
      from public.authdb_applications a
      left join jt.adoption_report_agg_session_per_appuser s
      on lower(a.applicationid) = lower(s.applicationid)
      group by 1,2
      having count(*) <= 20) s;

drop table jt.adoption_report_quarter_event_summary;
create table jt.adoption_report_quarter_event_summary as
select u.applicationid
     , a.name as event_name
     , a.startdate
     , a.enddate
     , sum(case when s.applicationid is not null and s.userid is not null then 1 else 0 end) as app_session_users
     , count(*) as total_registered_users
     , 1.0*sum(case when s.applicationid is not null and s.userid is not null then 1 else 0 end)/count(*) as adoption
from (select * from public.authdb_is_users where isdisabled = 0) u
join (select * from public.authdb_applications where canregister = false) a
on u.applicationid = a.applicationid
join (select min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.adoption_report_calendar where date = current_date - interval '7' day) a
      join jt.adoption_report_calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year) c
on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date and a.enddate < current_date
left join (select applicationid, userid from jt.adoption_report_agg_session_per_appuser) s
on lower(u.applicationid::varchar) = lower(s.applicationid) and u.userid = s.userid
left join jt.adoption_report_testevents t
on a.applicationid = t.applicationid
where t.applicationid is null
group by u.applicationid, a.name, a.startdate, a.enddate;


create table jt.adoption_report_quarter_summary as
select current_timestamp as date_generated
     , c.year * 10 + c.quarter_of_year as quarter
     , c.start_quarter_date as start_of_quarter
     , c.end_quarter_date as end_of_quarter
     , count(*) as event_count
     , avg(adoption) as adoption_average
     , percentile_cont(0.5) within group (order by adoption) as adoption_median
from jt.adoption_report_quarter_event_summary a
join (select a.year
           , a.quarter_of_year
           , min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.adoption_report_calendar where date = current_date - interval '7' day) a
      join jt.adoption_report_calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year
      group by a.year, a.quarter_of_year) c
on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date
group by date_generated, quarter, start_of_quarter, end_of_quarter;


select *
from jt.adoption_report_quarter_event_summary
order by startdate, enddate, applicationid;

select *
from jt.adoption_report_quarter_summary;