-- NOTE: This is for iOS only because.  No Android until fix is moved to production.

-- Create Initial Staging Table
-- This table will contain a unique record for every event, user 
-- and agenda item that was toggled on in the final state for events
-- that took place from 4/20/2015 - 6/10/2015.

select application_id
     , event_name
     , event_start_date
     , global_user_id
     , item_id
     , max(action_time) as last_action_time
into jt.bookmark_agenda_p1
from (
select a.application_id
     , b.name as event_name
     , b.startdate as event_start_date
     , a.global_user_id
     , created as action_time
     , a.metadata->>'itemid' as item_id
from (select *
      from public.fact_actions
      where created >= '2015-04-20') a
join (select * 
      from jt.tm_eventcubesummary
      where startdate >= '2015-04-20'
      and startdate <= '2015-06-10') b
on a.application_id = cast(b.applicationid as varchar)
where a.identifier = 'bookmarkbutton'
and a.metadata->>'listtype' = 'agenda'
and a.metadata->>'toggledto' = 'on') a
group by application_id, event_name, event_start_date, global_user_id, item_id;


-- Create Second Staging Table
-- This table will contain counts and percentages for each event that took place
-- after 5/1/2015.
select application_id
     , event_name
     , event_start_date
     , count(*) as total_bookmark_cnt
     , count(case when last_action_time < event_start_date then 1 else null end) as prior_bookmark_cnt
     , cast(cast(count(case when last_action_time < event_start_date then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as prior_bookmark_pct
     , count(case when last_action_time >= event_start_date then 1 else null end) as during_bookmark_cnt
     , cast(cast(count(case when last_action_time >= event_start_date then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as during_bookmark_pct
into jt.bookmark_agenda_p2
from jt.bookmark_agenda_p1
where event_start_date >= '2015-05-01'
group by application_id, event_name, event_start_date;

-- Final Output
select count(*) as total_event_cnt
     , cast(avg(total_bookmark_cnt) as decimal(8,4)) as avg_total_bookmark_cnt_per_event
     , percentile_cont(0.5) within group (order by total_bookmark_cnt) as med_total_bookmark_cnt_per_event
     , cast(avg(prior_bookmark_cnt) as decimal(8,4)) as avg_prior_bookmark_cnt_per_event
     , percentile_cont(0.5) within group (order by prior_bookmark_cnt) as med_prior_bookmark_cnt_per_event
     , cast(avg(prior_bookmark_pct) as decimal(8,4)) as avg_prior_bookmark_pct_per_event
     , percentile_cont(0.5) within group (order by prior_bookmark_pct) as med_prior_bookmark_pct_per_event
     , cast(avg(during_bookmark_cnt) as decimal(8,4)) as avg_during_bookmark_cnt_per_event
     , percentile_cont(0.5) within group (order by during_bookmark_cnt) as med_during_bookmark_cnt_per_event
     , cast(avg(during_bookmark_pct) as decimal(8,4)) as avg_during_bookmark_pct_per_event
     , percentile_cont(0.5) within group (order by during_bookmark_pct) as med_during_bookmark_pct_per_event     
from jt.bookmark_agenda_p2;