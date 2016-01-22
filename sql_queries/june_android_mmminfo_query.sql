drop table jt.android_device_mmminfo;
create table jt.android_device_mmminfo as
select distinct bundle_id
     , global_user_id 
     , mmm_info
from fact_actions
where app_type_id = 3
and created >= '2015-06-01'
and created <= '2015-06-30';

select mmm_info
     , count(*) as device_cnt
from jt.android_device_mmminfo
group by 1
order by 2 desc;