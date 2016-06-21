-- Get Bundleid
select *
from authdb_applications
where lower(applicationid) = '30f31548-1f06-42b7-8cf7-183b436b582b'
;
-- dfe0c6d3-e130-4e5d-8293-17e6e69fe990

-- Check to see how many events associated with this bundle
select *
from authdb_applications
where bundleid = 'DFE0C6D3-E130-4E5D-8293-17E6E69FE990'
;
-- 1 event

-- Check binary version/device type distribution
select device_type
     , binary_version
     , count(distinct global_user_id) as usercnt
     , count(*) as sessioncnt
from public.fact_sessions_live
where application_id = '30f31548-1f06-42b7-8cf7-183b436b582b'
and identifier = 'start'
group by 1,2
order by 1,2
;

-- Use loginFlowStart Checkpoint to check for distribution
select device_type
     , binary_version
     , count(*) as splashscreenviews
     , count(distinct device_id) as unique_devices
from public.fact_checkpoints_live
where bundle_id = 'dfe0c6d3-e130-4e5d-8293-17e6e69fe990'
and identifier = 'loginFlowStart'
group by 1,2
order by 1,2
;

-- Looks good.

select count(*) as splashscreenviews
     , count(distinct device_id) as unique_devices
from public.fact_checkpoints_live
where bundle_id = 'dfe0c6d3-e130-4e5d-8293-17e6e69fe990'
and identifier = 'loginFlowStart'
;






