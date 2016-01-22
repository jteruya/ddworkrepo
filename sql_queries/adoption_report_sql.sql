--============================================================================================================
-- Table: jt.calendar
-- Description: One time lookup table that creates a date lookup table with day, week, month, quarter, year info.
--============================================================================================================
select i::date as date
     , extract(year from i::date)::int as year
     , extract(quarter from i::date)::int as quarter_of_year
     , extract(week from i::date)::int as week_of_year
     , extract(month from i::date)::int as month_of_year
     , to_char(i::date, 'day') as day_name     
     , extract(day from i::date)::int as day_of_month
     , rank() over (partition by extract(year from i::date)::int order by i::date) as day_of_year
into jt.calendar
from generate_series('2015-01-01', '2017-12-31', '1 day'::interval) i;

-------------------------------------------------------------------------------------------------------------

drop table if exists jt.agg_session_per_appuser;

--============================================================================================================
-- Table: jt.agg_session_per_appuser
-- Description: Event information and adoption

-- 1. Application Id
-- 2. User Id

-- Event Filters (Conditions for event sessions to be included):
-- 1. Event start date has to occur on or within the start/end dates of the current quarter.
-- 2. Event end date has to occur before the current date (Event has to be finished currently).
-- 3. User Id is not null.
--============================================================================================================

create table jt.agg_session_per_appuser as 
select s.application_id as applicationid
     , s.user_id as userid
from public.fact_sessions s
join (select * from public.authdb_applications where canregister = false) a
on lower(a.applicationid::varchar) = s.application_id
join (select min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.calendar where date = current_date) a
      join jt.calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year) c
on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date and a.enddate < current_date
where s.user_id is not null
group by s.application_id, s.user_id;


drop table if exists jt.testevents;

--============================================================================================================
-- Table: jt.testevents
-- Description: Identify the Test Events through two methods:

-- 1a. Identify if the naming of the Event has anything to do with a DoubleDutch test/internal/QA Event
-- 1b. Identify if the specific Bundle Unique ID is tied to a test event (as specified by internal users)
-- 2.  Check if the Event has 20 or fewer Users across all Event sessions (or no Event sessions at all)
--============================================================================================================

create table jt.testevents as
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
      left join jt.agg_session_per_appuser s 
      on lower(a.applicationid) = s.applicationid
      group by 1,2
      having count(*) <= 20) s;


drop table if exists jt.event_adoption;

--============================================================================================================
-- Table: jt.event_adoption
-- Description: Event information and adoption

-- 1. Application Id
-- 2. Event Name
-- 3. Event Start Date
-- 4. Event End Date
-- 5. Event Adoption

-- Event Filters (Conditions for event to be included):
-- 1. Event start date has to occur on or within the start/end dates of the current quarter.
-- 2. Event end date has to occur before the current date (Event has to be finished currently).
-- 3. Event should not be part of the table jt.testevents.
-- 4. Event should not allow registering (canregister = false).
-- 5. For each event, the users must be enabled (isdisabled = 0).
--============================================================================================================

create table jt.event_adoption as
select u.applicationid
     , a.name as event_name
     , a.startdate
     , a.enddate
     , 1.0*sum(case when s.applicationid is not null and s.userid is not null then 1 else 0 end)/count(*) as adoption
from (select * from public.authdb_is_users where isdisabled = 0) u
join (select * from public.authdb_applications where canregister = false) a
on u.applicationid = a.applicationid
join (select min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.calendar where date = current_date) a
      join jt.calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year) c
on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date and a.enddate < current_date
left join (select applicationid, userid from jt.agg_session_per_appuser) s 
on lower(u.applicationid::varchar) = s.applicationid and u.userid = s.userid
left join jt.testevents t
on a.applicationid = t.applicationid
where t.applicationid is null
group by u.applicationid, a.name, a.startdate, a.enddate;


--============================================================================================================
-- Table: jt.quarter_summary_adoption
-- Description: Quarterly summary statisitics:
-- 1. Date Report Run
-- 2. Current Quarter
-- 3. Start of Quarter
-- 4. End of Quarter 
-- 5. Quarter Event Count
-- 6. Average Adoption
-- 7. Median Adoption
--============================================================================================================
create table jt.quarter_summary_adoption (
     date_generated timestamp
   , quarter int
   , start_of_quarter date
   , end_of_quarter date
   , event_count int
   , adoption_average decimal(12,4)
   , adoption_median decimal(12,4));

delete from jt.quarter_summary_adoption where date_generated::date = current_date;

insert into jt.quarter_summary_adoption (
select current_timestamp as date_generated
     , c.year * 10 + c.quarter_of_year as quarter
     , c.start_quarter_date as start_of_quarter
     , c.end_quarter_date as end_of_quarter
     , count(*) as event_count
     , avg(adoption) as adoption_average
     , percentile_cont(0.5) within group (order by adoption) as adoption_median 
from jt.event_adoption a
join (select a.year
           , a.quarter_of_year
           , min(b.date) as start_quarter_date
           , max(b.date) as end_quarter_date
      from (select * from jt.calendar where date = current_date) a
      join jt.calendar b
      on a.quarter_of_year = b.quarter_of_year and a.year = b.year
      group by a.year, a.quarter_of_year) c
on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date
group by date_generated, quarter, start_of_quarter, end_of_quarter);

select *
from jt.quarter_summary_adoption;

\copy to (select current_date as date_generated, c.year * 10 + c.quarter_of_year as quarter, c.start_quarter_date as start_of_quarter, c.end_quarter_date as end_of_quarter, count(*) as event_count, avg(adoption) as adoption_average, percentile_cont(0.5) within group (order by adoption) as adoption_median from jt.event_adoption a join (select a.year, a.quarter_of_year, min(b.date) as start_quarter_date, max(b.date) as end_quarter_date from (select * from jt.calendar where date = current_date) a join jt.calendar b on a.quarter_of_year = b.quarter_of_year and a.year = b.year group by a.year, a.quarter_of_year) c on a.startdate >= c.start_quarter_date and a.startdate <= c.end_quarter_date group by date_generated, quarter, start_of_quarter, end_of_quarter) to '/home/jteruya/adoption_report/csv/quarter_summary.csv' with csv;

--============================================================================================================
-- Event Level Summary
--============================================================================================================
select *
from jt.event_adoption
order by startdate, enddate;

\copy to (select * from jt.event_adoption order by startdate, enddate) to '/home/jteruya/adoption_report/csv/quarter_event_summary.csv' with csv;