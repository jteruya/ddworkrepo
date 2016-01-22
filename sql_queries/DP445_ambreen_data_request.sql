-- Q: Event in US Robin?

select *
from authdb_applications where lower(applicationid) = 'c0d13e90-6f40-4c74-91e6-3867b5ec2188';

-- A: YES
-- SDATE: 10/26/2015
-- EDATE: 10/26/2016

-- Create Calendar Lookup

drop table if exists jt.calendar;
create table jt.calendar as
select i::date as date
     , extract(year from i::date)::int as year
     , extract(quarter from i::date)::int as quarter_of_year
     , extract(week from i::date)::int as week_of_year
     , extract(month from i::date)::int as month_of_year
     , to_char(i::date, 'day') as day_name
     , extract(day from i::date)::int as day_of_month
     , rank() over (partition by extract(year from i::date)::int order by i::date) as day_of_year
from generate_series('2015-01-01', '2017-12-31', '1 day'::interval) i;

-- Q: Visits per day.
-- Q: Active Users per day.

select count(sessiondate) as numberofdays
     , count(case when sessioncntperday > 0 then 1 else null end) as numberofdayswithsession
     , min(case when sessioncntperday > 0 then sessiondate else null end) as first_sessiondate
     , max(case when sessioncntperday > 0 then sessiondate else null end) as last_sessiondate
     , avg(uniqueusercntperday) as avguniqueusercntperday
     , avg(sessioncntperday) as avgsessioncntperday     
     , avg(case when sessioncntperday > 0 then uniqueusercntperday else null end) as avguniqueusercntperday
     , avg(case when sessioncntperday > 0 then sessioncntperday else null end) as avgsessioncntperday
from (select a.date::date as sessiondate
           , count(distinct b.user_id) as uniqueusercntperday
           , count(b.metrics_type_id) as sessioncntperday     
      from (select * from jt.calendar where date >= '2015-11-05' and date < current_date) a
      left join (select * from fact_sessions_new where application_id = 'c0d13e90-6f40-4c74-91e6-3867b5ec2188' and metrics_type_id = 1) b
      on a.date = b.start_date::date
      group by 1) a;
      
 -- 76 days Window (2015/11/05 - 2016/01/19)
 -- Number of Days: 76
 -- Number of Days with at least one App Session: 31
 -- First Date with Session: 11/05/2015
 -- Last Date with Session: 1/9/2016
 -- Average Unique App User Per Day: 1.97
 -- Average App Sessions Per Day: 8.75

-- Q: New Users

select count(*) as numberofdays
     , count(case when newusercnt > 0 then 1 else null end) as numberofdaynewusercnt
     , avg(newusercnt) as avgnewusercnt
     , avg(case when newusercnt > 0 then newusercnt else null end) as avgnewusercntonnewuserday
from (
select a.date
     , count(case when b.sessiondate is not null then 1 else null end) as newusercnt     
from (select * from jt.calendar where date >= '2015-11-05' and date < current_date) a
left join (select *
           from (select row_number() over (partition by user_id order by start_date) as sessionnum
                      , user_id
                      , start_date::date as sessiondate
                 from fact_sessions_new 
                 where application_id = 'c0d13e90-6f40-4c74-91e6-3867b5ec2188' 
                 and metrics_type_id = 1) a
            where sessionnum = 1) b
on a.date = b.sessiondate
group by 1) a;

-- 76 Day Window
-- 17 Days with a new user
-- Average New User Per Day: 0.66
-- Average New User Per Day on 17 Days: 2.94

-- Q: Likes per day

select count(likedate) as numberofdays
     , count(case when likecntperday > 0 then 1 else null end) as numberofdayswithlike
     , min(case when likecntperday > 0 then likedate else null end) as first_likedate
     , max(case when likecntperday > 0 then likedate else null end) as last_likedate
     , avg(likecntperday) as avguniqueusercntperday
     , avg(case when likecntperday > 0 then likecntperday else null end) as avguniqueusercntperdayonspecificdays
from (select a.date::date as likedate
           , count(b.identifier) as likecntperday     
      from (select * from jt.calendar where date >= '2015-11-05' and date < current_date) a
      left join (select * from fact_actions_new where application_id = 'c0d13e90-6f40-4c74-91e6-3867b5ec2188' and lower(identifier) = 'likebutton') b
      on a.date = b.created::date
      group by 1) a;
      
-- Q: Visits per day by app type

select app_type_id
     , count(case when sessioncntperday > 0 then 1 else null end) as numberofdayswithsession
     , min(case when sessioncntperday > 0 then sessiondate else null end) as first_sessiondate
     , max(case when sessioncntperday > 0 then sessiondate else null end) as last_sessiondate
     , avg(uniqueusercntperday) as avguniqueusercntperday
     , avg(sessioncntperday) as avgsessioncntperday
from (select a.date::date as sessiondate
           , b.app_type_id
           , count(distinct b.user_id) as uniqueusercntperday
           , count(b.metrics_type_id) as sessioncntperday     
      from (select * from jt.calendar where date >= '2015-11-05' and date < current_date) a
      left join (select * from fact_sessions_new where application_id = 'c0d13e90-6f40-4c74-91e6-3867b5ec2188' and metrics_type_id = 1) b
      on a.date = b.start_date::date
      where b.app_type_id is not null
      group by 1,2) a
group by 1
order by 1;





