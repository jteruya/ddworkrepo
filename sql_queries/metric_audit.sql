-- Drop Initial Tables (if they already exist)

drop table if exists metric_audit.metrics_etl_audit
;

drop table if exists metric_audit.metrics_agg_batch_audit
;

drop table if exists metric_audit.metrics_agg_batch_audit_stg
;

drop table if exists metric_audit.metrics_agg_batch_audit_update
;

drop table if exists metric_audit.metrics_agg_batch_audit_insert
;


-- Create Initial Tables
create table metric_audit.metrics_etl_audit (
    date_processed date
  , metric_src varchar
  , min_metric_batch_id int
  , max_metric_batch_id int
  , created timestamp
  , updated timestamp
)
;

create table metric_audit.metrics_agg_batch_audit (   
     metric_src varchar   
   , metric_batch_id int
   , device_id varchar
   , device_type varchar
   , binary_version varchar
   , bundle_id varchar
   , application_id varchar
   , global_user_id varchar     
   , metric_identifier varchar
   , metric_date date
   , metric_count bigint
   , created timestamp
   , updated timestamp
)
;

create table metric_audit.metrics_agg_batch_audit_stg (   
     metric_src varchar
   , metric_batch_id int
   , device_id varchar
   , device_type varchar
   , binary_version varchar
   , bundle_id varchar
   , application_id varchar
   , global_user_id varchar
   , metric_identifier varchar
   , metric_date date
   , metric_count bigint
   , created timestamp
)
;

create table metric_audit.metrics_agg_batch_audit_update (   
     metric_src varchar
   , metric_batch_id int
   , device_id varchar
   , device_type varchar
   , binary_version varchar
   , bundle_id varchar
   , application_id varchar
   , global_user_id varchar    
   , metric_identifier varchar
   , metric_date date
   , metric_count bigint
   , created timestamp
)
;

create table metric_audit.metrics_agg_batch_audit_insert (   
     metric_src varchar
   , metric_batch_id int
   , device_id varchar
   , device_type varchar
   , binary_version varchar
   , bundle_id varchar
   , application_id varchar
   , global_user_id varchar    
   , metric_identifier varchar
   , metric_date date
   , metric_count bigint
   , created timestamp
)
;


-- Insert Initial Values into metric_audit.client_metrics_etl_audit
-- Initial Batch Values are miniumum batch values for 1/1/2016 for each metric source
insert into metric_audit.metrics_etl_audit (date_processed, metric_src, min_metric_batch_id, max_metric_batch_id, created) values
(current_date - interval '1' day,'fact_views_live',18912,18912,current_timestamp),
(current_date - interval '1' day,'fact_actions_live',18919,18919,current_timestamp),
(current_date - interval '1' day,'fact_impressions_live',18918,18918,current_timestamp),
(current_date - interval '1' day,'fact_sessions_live',18913,18913,current_timestamp),
(current_date - interval '1' day,'fact_errors_live',18899,18899,current_timestamp),
(current_date - interval '1' day,'fact_checkpoints_live',18916,18916,current_timestamp),
(current_date - interval '1' day,'fact_states_live',18917,18917,current_timestamp),
(current_date - interval '1' day,'fact_notifications_live',18914,18914,current_timestamp)
;


/*
select max(batch_id)
from fact_views_live
where tinserted > '2016-02-29'
;

-- Views: 18912
-- Actions: 18919
-- Impressions: 18918
-- Sessions: 18913
-- Errors: 18899
-- Checkpoints: 18916
-- States: 18917
-- Notifications: 18914
*/





-------- Process

-- Insert View Metrics

-- Get the Delta (Dump to Temporary Table)
create temporary table client_metrics_event_views_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_views_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_views_live')
group by 1,2,3,4,5,6,7,8,9
;

-- 250,938


create temporary table client_metrics_event_actions_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_actions_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_actions_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_impressions_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_impressions_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_impressions_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_sessions_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_sessions_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_sessions_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_errors_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_errors_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_errors_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_checkpoints_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_checkpoints_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_checkpoints_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_states_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id     
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_states_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_states_live')
group by 1,2,3,4,5,6,7,8,9
;


create temporary table client_metrics_event_notifications_audit as
select created::date as metric_date
     , batch_id as metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , identifier as metric_identifier
     , count(*) as metric_count
from public.fact_notifications_live
where batch_id >= (select max(max_metric_batch_id) from metric_audit.metrics_etl_audit
                  where metric_src = 'fact_notifications_live')
group by 1,2,3,4,5,6,7,8,9
;

-- Set to STG

truncate table metric_audit.metrics_agg_batch_audit_stg
;

insert into metric_audit.metrics_agg_batch_audit_stg
select 'fact_views_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_views_audit
union all
select 'fact_actions_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_actions_audit
union all
select 'fact_impressions_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_impressions_audit
union all
select 'fact_sessions_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_sessions_audit
union all
select 'fact_errors_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_errors_audit
union all
select 'fact_checkpoints_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_checkpoints_audit
union all
select 'fact_states_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_states_audit
union all
select 'fact_notifications_live' as metric_src
     , metric_batch_id
     , device_id
     , device_type
     , binary_version
     , bundle_id
     , application_id
     , global_user_id
     , metric_identifier
     , metric_date
     , metric_count
     , current_timestamp as created
from client_metrics_event_notifications_audit
;

-- Identify Updates

truncate table metric_audit.metrics_agg_batch_audit_update
;

insert into metric_audit.metrics_agg_batch_audit_update
select stg.*
from metric_audit.metrics_agg_batch_audit_stg stg
join metric_audit.metrics_agg_batch_audit final
on stg.metric_src = final.metric_src 
and stg.metric_batch_id = final.metric_batch_id 
and stg.metric_date = final.metric_date 
and stg.metric_identifier = final.metric_identifier
and stg.device_id = final.device_id
and stg.device_type = final.device_type
and stg.binary_version = final.binary_version
and stg.bundle_id = final.bundle_id
and stg.application_id = final.application_id
and stg.global_user_id = final.global_user_id
;

-- Identify Inserts

truncate table metric_audit.metrics_agg_batch_audit_insert
;

insert into metric_audit.metrics_agg_batch_audit_insert
select stg.*
from metric_audit.metrics_agg_batch_audit_stg stg
left join metric_audit.metrics_agg_batch_audit final
on stg.metric_src = final.metric_src 
and stg.metric_batch_id = final.metric_batch_id 
and stg.metric_date = final.metric_date 
and stg.metric_identifier = final.metric_identifier
and stg.device_id = final.device_id
and stg.device_type = final.device_type
and stg.binary_version = final.binary_version
and stg.bundle_id = final.bundle_id
and stg.application_id = final.application_id
and stg.global_user_id = final.global_user_id
where final.metric_src is null
;


-- Identify Inserts


-- Update Final Table

update metric_audit.metrics_agg_batch_audit final
set metric_count = update_stg.metric_count
  , updated = current_timestamp
from metric_audit.metrics_agg_batch_audit_update update_stg
where update_stg.metric_src = final.metric_src 
and update_stg.metric_batch_id = final.metric_batch_id 
and update_stg.metric_date = final.metric_date 
and update_stg.metric_identifier = final.metric_identifier
and update_stg.device_id = final.device_id
and update_stg.device_type = final.device_type
and update_stg.binary_version = final.binary_version
and update_stg.bundle_id = final.bundle_id
and update_stg.application_id = final.application_id
and update_stg.global_user_id = final.global_user_id
;

-- Insert Final Table

insert into metric_audit.metrics_agg_batch_audit
select *
from metric_audit.metrics_agg_batch_audit_insert
;


-- Add ETL Processing Record

insert into metric_audit.metrics_etl_audit 
select current_date as date_processed
     , metric_src
     , min(metric_batch_id) as min_metric_batch_id
     , max(metric_batch_id) as max_metric_batch_id
     , current_timestamp as created
     , null as created
from metric_audit.metrics_agg_batch_audit_stg
group by 1,2
;


-- Agg Processing
drop table if exists metric_audit.metrics_agg_daily_audit
;

drop table if exists metric_audit.metrics_agg_monthly_audit
;

-- Daily
create table metric_audit.metrics_agg_daily_audit as
select metric_src
     , metric_date
     , device_type
     , binary_version
     , count(distinct global_user_id) as user_count
     , count(distinct device_id) as device_count
     , count(distinct bundle_id) as bundle_count
     , count(distinct application_id) as event_count
     , sum(metric_count) as metric_count
from metric_audit.metrics_agg_batch_audit
group by 1,2,3,4
order by 1,2,3,4
;

-- Monthly
create table metric_audit.metrics_agg_monthly_audit as
select metric_src
     , cast(extract(year from metric_date) * 100 + extract(month from metric_date) as int) as metric_yearmonth
     , device_type
     , binary_version
     , count(distinct global_user_id) as user_count
     , count(distinct device_id) as device_count
     , count(distinct bundle_id) as bundle_count
     , count(distinct application_id) as event_count
     , sum(metric_count) as metric_count
from metric_audit.metrics_agg_batch_audit
group by 1,2,3,4
order by 1,2,3,4
;




