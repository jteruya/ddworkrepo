/* Assumptions:
   1.) 24 hours means 10AM - 9:59AM (the following day).  This is NOT a sliding 24 hour window.
   2.) The views counted are for profile views of other people and not self profile views.
   3.) These statistics are from 4/24/2015 - present because of data availability.
*/

drop table if exists jt.profile_views;
drop table if exists jt.pve_pride_views;
drop table if exists jt.pve_non_pride_views;
drop table if exists jt.pve_pride_views_sequence;
drop table if exists jt.pve_non_pride_views_sequence;


/* Create Staging Table for all Profile View Metrics */

select application_id
     , metadata->>'userid' as user_profile_viewed
     , created as user_profile_viewed_date
     , case
         when extract(hour from created) < 10 then cast((created - interval '1' day) as date)
         else cast(created as date)
       end as user_profile_viewed_date_24hour
     , count(*) as profile_viewed_count
into jt.profile_views
from fact_views
where identifier = 'profile'
and metadata->>'isfollowing' <> 'null'
group by 1,2,3,4
order by count(*) desc;

/* jt.pve_pride_views */

select application_id
     , global_user_id
     , metadata->>'userid' as vieweduserid
     , created as viewdatetime
     , case
         when extract(hour from created) < 10 then cast((created - interval '1' day) as date)
         else cast(created as date)
       end as pvedatetime
into jt.pve_pride_views
from fact_views
where identifier = 'profile'
and application_id = 'bffee970-c8b3-4a2d-89ef-a9c012000abb'
and metadata->>'isfollowing' <> 'null'
and created >= '2015-05-01 00:00:00'
and created <= now();

/* jt.pve_non_pride_views */

select application_id
     , global_user_id
     , metadata->>'userid' as vieweduserid
     , created as viewdatetime
     , case
         when extract(hour from created) < 10 then cast((created - interval '1' day) as date)
         else cast(created as date)
       end as pvedatetime
into jt.pve_non_pride_views
from fact_views
where identifier = 'profile'
and application_id <> 'bffee970-c8b3-4a2d-89ef-a9c012000abb'
and metadata->>'isfollowing' <> 'null'
and created >= '2015-05-01 00:00:00'
and created <= now();

/* Table: jt.pve_pride_views_sequence */
select row_number() over (partition by 1 order by application_id, vieweduserid, global_user_id, pvedatetime) as id
     , dense_rank() over (order by application_id, vieweduserid, global_user_id) as group_id
     , row_number() over (partition by application_id, vieweduserid, global_user_id order by pvedatetime) as vieworder
     , application_id
     , vieweduserid
     , global_user_id
     , pvedatetime
     , case
         when lag(pvedatetime,1) over (partition by application_id, vieweduserid, global_user_id rows between unbounded preceding and current row) is not null then
           pvedatetime - lag(pvedatetime,1) over (partition by application_id, vieweduserid, global_user_id rows between unbounded preceding and current row)
         else 0
       end as day_diff
     , count(*) over (partition by application_id, vieweduserid, global_user_id) as group_cnt
into jt.pve_pride_views_sequence
from (select distinct application_id
           , vieweduserid
           , pvedatetime
           , global_user_id
      from jt.pve_pride_views) a;

/* Table: jt.pve_non_pride_views_sequence */
select row_number() over (partition by 1 order by application_id, vieweduserid, global_user_id, pvedatetime) as id
     , dense_rank() over (order by application_id, vieweduserid, global_user_id) as group_id
     , row_number() over (partition by application_id, vieweduserid, global_user_id order by pvedatetime) as vieworder
     , application_id
     , vieweduserid
     , global_user_id
     , pvedatetime
     , case
         when lag(pvedatetime,1) over (partition by application_id, vieweduserid, global_user_id rows between unbounded preceding and current row) is not null then
           pvedatetime - lag(pvedatetime,1) over (partition by application_id, vieweduserid, global_user_id rows between unbounded preceding and current row)
         else 0
       end as day_diff
     , count(*) over (partition by application_id, vieweduserid, global_user_id) as group_cnt
into jt.pve_non_pride_views_sequence
from (select distinct application_id
           , vieweduserid
           , pvedatetime
           , global_user_id
      from jt.pve_non_pride_views) a;
      
/* Run PVE Investigate on BATMAN */

/* Percent Pride */
select application_id
     , total_users
     , percentile_cont(0.5) within group (order by total_number_of_users_with_view) as median_total_number_of_users_with_view_per_day
     , percentile_cont(0.5) within group (order by total_pct_of_users_with_view) as median_total_pct_of_users_with_view_per_day     
     , percentile_cont(0.5) within group (order by total_number_of_users_with_3_views) as median_total_number_of_users_with_3_views_per_day
     , percentile_cont(0.5) within group (order by total_pct_of_users_with_3_views) as median_total_pct_of_users_with_3_views_per_day    
from (select application_id
           , pvedatetime
           , total_users
           , count(*) as total_number_of_users_with_view
           , cast(cast(count(*) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_view
           , count(case when number_of_views_per_day >= 3 then 1 else null end) as total_number_of_users_with_3_views
           , cast(cast(count(case when number_of_views_per_day >= 3 then 1 else null end) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_3_views
      from (select application_id
                 , pvedatetime
                 , vieweduserid
                 , count(*) as number_of_views_per_day
                 , total_users
            from (select a.vieworder
                       , a.application_id
                       , a.vieweduserid
                       , a.global_user_id
                       , a.pvedatetime
                       , c.total_users
                  from jt.pve_pride_views_sequence a
                  left join jt.pve_pride_views_sequence_new b
                  on a.id = b.id
                  join (select count(*) as total_users
                        from authdb_is_users
                        where lower(applicationid) = 'bffee970-c8b3-4a2d-89ef-a9c012000abb'
                        and isdisabled = 0) c
                  on 1 = 1
                  where b.keep_ind is null or b.keep_ind = 1) x
            group by 1,2,3,5) y
      group by 1,2,3) z
group by 1,2;

/* Percent Everything Else */
select distinct count(*) over (partition by 1) as total_events
     , avg(total_users) over (partition by 1) as avg_number_of_users
     , avg_total_number_of_users_with_view_per_day
     , avg_total_pct_of_users_with_view_per_day
     , avg_total_number_of_users_with_3_views_per_day
     , avg_total_pct_of_users_with_3_views_per_day
from (
select distinct application_id
     , total_users
     , avg(total_number_of_users_with_view) over (partition by 1) as avg_total_number_of_users_with_view_per_day
     , avg(total_pct_of_users_with_view) over (partition by 1) as avg_total_pct_of_users_with_view_per_day
     , avg(total_number_of_users_with_3_views) over (partition by 1) as avg_total_number_of_users_with_3_views_per_day
     , avg(total_pct_of_users_with_3_views) over (partition by 1) as avg_total_pct_of_users_with_3_views_per_day
from (select application_id
           , pvedatetime
           , total_users
           , count(*) as total_number_of_users_with_view
           , cast(cast(count(*) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_view
           , count(case when number_of_views_per_day >= 3 then 1 else null end) as total_number_of_users_with_3_views
           , cast(cast(count(case when number_of_views_per_day >= 3 then 1 else null end) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_3_views
      from (select application_id
                 , pvedatetime
                 , vieweduserid
                 , count(*) as number_of_views_per_day
                 , total_users
            from (select a.vieworder
                       , a.application_id
                       , a.vieweduserid
                       , a.global_user_id
                       , a.pvedatetime
                       , c.users as total_users
                  from jt.pve_non_pride_views_sequence a
                  left join jt.pve_non_pride_views_sequence_new b
                  on a.id = b.id
                  join (select applicationid
                             , startdate
                             , enddate
                             , users
                        from jt.tm_eventcubesummary
                        where openevent = 0) c
                  on a.application_id = cast(c.applicationid as varchar)
                  where (b.keep_ind is null or b.keep_ind = 1)
                  and a.pvedatetime >= c.startdate
                  and a.pvedatetime <= c.enddate) x
            group by 1,2,3,5) y
      group by 1,2,3) z
)w;

/* Percent Everything Else by eventtype*/
select distinct 
       case 
         when eventtype is null then 'No Event Type'
         when eventtype = '_Unknown' then 'Unknown'
         else eventtype
       end as eventtype
     , count(*) over (partition by eventtype) as total_events
     , avg(total_users) over (partition by eventtype) as avg_number_of_users
     , avg_total_number_of_users_with_view_per_day
     , avg_total_pct_of_users_with_view_per_day
     , avg_total_number_of_users_with_3_views_per_day
     , avg_total_pct_of_users_with_3_views_per_day
from (
select distinct application_id
     , eventtype
     , total_users
     , avg(total_number_of_users_with_view) over (partition by eventtype) as avg_total_number_of_users_with_view_per_day
     , avg(total_pct_of_users_with_view) over (partition by eventtype) as avg_total_pct_of_users_with_view_per_day
     , avg(total_number_of_users_with_3_views) over (partition by eventtype) as avg_total_number_of_users_with_3_views_per_day
     , avg(total_pct_of_users_with_3_views) over (partition by eventtype) as avg_total_pct_of_users_with_3_views_per_day
from (select application_id
           , eventtype
           , pvedatetime
           , total_users
           , count(*) as total_number_of_users_with_view
           , cast(cast(count(*) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_view
           , count(case when number_of_views_per_day >= 3 then 1 else null end) as total_number_of_users_with_3_views
           , cast(cast(count(case when number_of_views_per_day >= 3 then 1 else null end) as decimal(10,4))/cast(total_users as decimal(10,4)) as decimal(10,4)) as total_pct_of_users_with_3_views
      from (select application_id
                 , eventtype
                 , pvedatetime
                 , vieweduserid
                 , count(*) as number_of_views_per_day
                 , total_users
            from (select a.vieworder
                       , a.application_id
                       , c.eventtype
                       , a.vieweduserid
                       , a.global_user_id
                       , a.pvedatetime
                       , c.users as total_users
                  from jt.pve_non_pride_views_sequence a
                  left join jt.pve_non_pride_views_sequence_new b
                  on a.id = b.id
                  join (select applicationid
                             , eventtype
                             , startdate
                             , enddate
                             , users
                        from jt.tm_eventcubesummary
                        where openevent = 0) c
                  on a.application_id = cast(c.applicationid as varchar)
                  where (b.keep_ind is null or b.keep_ind = 1)
                  and a.pvedatetime >= c.startdate
                  and a.pvedatetime <= c.enddate) x
            group by 1,2,3,4,6) y
      group by 1,2,3,4) z
)w;



/* Users Views Percentile Breakdown for all non-pride events */

select avg(case when percent_rnk <= 99 then profile_view_cnt else null end) as avg_profile_view_99_pct
     , avg(case when percent_rnk <= 95 then profile_view_cnt else null end) as avg_profile_view_95_pct
     , avg(case when percent_rnk <= 90 then profile_view_cnt else null end) as avg_profile_view_90_pct
     , avg(case when percent_rnk <= 75 then profile_view_cnt else null end) as avg_profile_view_75_pct
     , avg(case when percent_rnk <= 50 then profile_view_cnt else null end) as avg_profile_view_50_pct
     , avg(case when percent_rnk <= 25 then profile_view_cnt else null end) as avg_profile_view_25_pct     
     , avg(case when percent_rnk <= 10 then profile_view_cnt else null end) as avg_profile_view_10_pct 
     , avg(case when percent_rnk <= 5 then profile_view_cnt else null end) as avg_profile_view_5_pct    
     , avg(case when percent_rnk <= 1 then profile_view_cnt else null end) as avg_profile_view_1_pct            
from (select vieweduserid
           , profile_view_cnt
           , count(*) as total_users  
           , ntile(100) over (order by profile_view_cnt) as percent_rnk
      from (select vieweduserid
                 , count(*) as profile_view_cnt
            from jt.pve_non_pride_views a
            join (select applicationid
                       , startdate
                       , enddate
                       , users
                  from jt.tm_eventcubesummary) b
            on a.application_id = cast(b.applicationid as varchar)
            where a.pvedatetime >= b.startdate
            and a.pvedatetime <= b.enddate
            group by vieweduserid) a
       group by 1,2) b ;





select a.vieweduserid, case when b.eventtype = '_Unknown' then 'Unknown' when b.eventtype is null then 'No Event Type' else b.eventtype end as eventtype, count(*) as profile_view_cnt from jt.pve_non_pride_views a join (select applicationid, eventtype, startdate, enddate, users from jt.tm_eventcubesummary) b on a.application_id = cast(b.applicationid as varchar) where a.pvedatetime >= b.startdate and a.pvedatetime <= b.enddate group by 1,2;






/* Old Code Below */



/* Q1: What % of people will receive emails in Pride (bffee970-c8b3-4a2d-89ef-a9c012000abb). 
   
   Assumptions: 
   1.) Using the total number of active users today (6/18/2015) in Pride: 323
   
   Total Users: 323
   
   Average Count of Users with One Profile View: 42.23%
   Median Count of Users with One Profile View: 42
   Average Percent of Users with One Profile View: 13.07%
   Median Percent of Users with One Profile View: 13%
   
   Average Count of Users with at least Three Profile View: 8.68%
   Median Count of Users with at least Three Profile View: 7.5
   Average Percent of Users with at least Three Profile View: 2.69%
   Median Percent of Users with at least Three Profile View: 2.33%

 */

select distinct 323 as total_users
     , avg(cnt_of_users_with_profile_views) as avg_cnt_of_users_with_profile_views
     , percentile_cont(0.5) within group (order by cnt_of_users_with_profile_views) as median_cnt_of_users_with_profile_views
     , avg(pct_of_users_with_profile_views) as avg_pct_of_users_with_profile_views
     , percentile_cont(0.5) within group (order by pct_of_users_with_profile_views) as median_pct_of_users_with_profile_views
     , avg(cnt_of_users_with_over_3_profile_views) as avg_cnt_of_users_with_over_3_profile_views
     , percentile_cont(0.5) within group (order by cnt_of_users_with_over_3_profile_views) as median_cnt_of_users_with_over_3_profile_views
     , avg(pct_of_users_with_over_3_profile_views) as avg_pct_of_users_with_over_3_profile_views
     , percentile_cont(0.5) within group (order by pct_of_users_with_over_3_profile_views) as median_pct_of_users_with_over_3_profile_views
from (select user_profile_viewed_date
           , count(*) as cnt_of_users_with_profile_views
           , cast(cast(count(*) as decimal(10,4))/323.0000 as decimal(10,4)) as pct_of_users_with_profile_views
           , count(case when profile_viewed_count >= 3 then 1 else null end) as cnt_of_users_with_over_3_profile_views
           , cast(cast(count(case when profile_viewed_count >= 3 then 1 else null end) as decimal(10,4))/323.0000 as decimal(10,4)) as pct_of_users_with_over_3_profile_views
      from jt.profile_views 
      where application_id = 'bffee970-c8b3-4a2d-89ef-a9c012000abb'
      and user_profile_viewed_date >= '2015-04-24'
      group by 1) a;  

/* Q2: What % of people will receive in overall events.

   Assumptions:
   1.) Using the total number of active users today (6/18/2015)
   2.) Because of Assumptions 1.), there is the chance that the number of total users is less than the number of users that were viewed (accounts can be disabled).
       Therefore, data points where the number of active users 
   3.) Only measuring during the days of the event.
   4.) Only measuring closed events because there we can grab the total number of users.
   
   --132 to remove from population
*/      

/* Remove applicationids where there are days that percentage is higher than 100%.
   Don't trust the total user counts from eventcubesummary. */  

drop table if exists jt.profile_views_events_not_trusted;
drop table if exists jt.profile_views_event_stats;




select a.applicationid
     , cast(a.created as date) as created
     , count(*) as total_users_cnt
     , count(case when a.isdisabled = 0 then 1 else 0 end) as enabled_users_cnt
     , count(case when a.isdisabled = 1 then 1 else 0 end) as disabled_users_cnt
into jt.is_users_2015_created_counts
from authdb_is_users a
join jt.tm_eventcubesummary b
on a.applicationid = cast(b.applicationid as varchar)
where b.startdate >= '2015-01-01'
group by a.applicationid, a.created;



select *
from jt.is_users_2015_created_counts;






select distinct application_id
into jt.profile_views_events_not_trusted
from (select application_id
           , user_profile_viewed_date
           , e.users
      from jt.profile_views v
      join jt.tm_eventcubesummary e
      on v.application_id = cast(e.applicationid as varchar)
      where v.user_profile_viewed_date >= '2015-04-24'
      and e.openevent = 0
      group by 1,2,3
      having count(*) > e.users) x; 


select avg(a.cnt_of_users_with_profile_views) as avg_cnt_of_users_with_profile_views     
     , avg(a.pct_of_users_with_profile_views) as avg_pct_of_users_with_profile_views     
     , avg(a.cnt_of_users_with_over_3_profile_views) as avg_cnt_of_users_with_over_3_profile_views         
     , avg(a.pct_of_users_with_over_3_profile_views) as avg_pct_of_users_with_over_3_profile_views       
into jt.profile_views_event_stats          
from (select v.application_id
           , v.user_profile_viewed_date
           , e.users as cnt_of_total_event_app_users
           , e.openevent
           , e.eventtype
           , count(*) as cnt_of_users_with_profile_views
           , cast(cast(count(*) as decimal(10,4))/cast(e.users as decimal(10,4)) as decimal(10,4)) as pct_of_users_with_profile_views
           , count(case when v.profile_viewed_count >= 3 then 1 else null end) as cnt_of_users_with_over_3_profile_views
           , cast(cast(count(case when v.profile_viewed_count >= 3 then 1 else null end) as decimal(10,4))/cast(e.users as decimal(10,4)) as decimal(10,4)) as pct_of_users_with_over_3_profile_views
      from jt.profile_views v
      join jt.tm_eventcubesummary e
      on v.application_id = cast(e.applicationid as varchar)
      and v.user_profile_viewed_date >= e.startdate
      and v.user_profile_viewed_date <= e.enddate
      and e.openevent = 0
      where v.user_profile_viewed_date >= '2015-04-24'
      group by 1,2,3,4,5
      ) a 
left join jt.profile_views_events_not_trusted b
on a.application_id = b.application_id
where b.application_id is null
group by 1,2,3,4,5;
    
    
    
select count(case when remove_from_event_population_flag = 0 then 1 else null end) as total_event_population
     , count(case when remove_from_event_population_flag = 1 then 1 else null end) as total_excluded_event_population
     , avg(cnt_of_total_event_app_users) as avg_cnt_of_total_event_app_users_per_event_per_24hrs
     , percentile_cont(0.5) within group (order by cnt_of_total_event_app_users) as median_cnt_of_total_event_app_users_per_event_per_24hrs
     , avg(avg_cnt_of_users_with_profile_views) as avg_cnt_of_users_with_profile_views_per_event_per_24hrs
     , percentile_cont(0.5) within group (order by avg_cnt_of_users_with_profile_views) as median_cnt_of_users_with_profile_views_per_event_per_24hrs
     , avg(avg_pct_of_users_with_profile_views) as avg_pct_of_users_with_profile_views_per_event_per_24hrs
     , avg(avg_cnt_of_users_with_over_3_profile_views) as avg_cnt_of_users_with_over_3_profile_views_per_event_per_24hrs
     , percentile_cont(0.5) within group (order by avg_cnt_of_users_with_over_3_profile_views) as median_average_of_users_with_over_3_profile_views_per_event_per_24hrs
from jt.profile_views_event_stats;






