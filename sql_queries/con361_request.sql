select device_type
     , binary_version
     , count(*) as totalcnt
     , count(case when cast(metadata->>'View' as varchar) is null then 1 else null end)
     , count(case when cast(metadata->>'View' as varchar) = '' then 1 else null end)
from fact_actions_live
where identifier = 'upcomingSessionsNotificationButton'
and created >= '2016-01-01'
and device_type = 'ios'
group by 1,2
order by 1,2
;


select device_type
     , binary_version
     , count(*) as totalcnt
     , count(case when cast(metadata->>'View' as varchar) is null then 1 else null end)
     , count(case when cast(metadata->>'View' as varchar) = '' then 1 else null end)
from fact_actions_live
where identifier = 'upcomingSessionsNotificationButton'
and created >= '2016-01-01'
and device_type = 'ios'
and mmm_info like '%iPad%'
group by 1,2
order by 1,2
;


select device_type
     , binary_version
     , count(*) as totalcnt
     , count(case when cast(metadata->>'View' as varchar) is null then 1 else null end)
     , count(case when cast(metadata->>'View' as varchar) = '' then 1 else null end)
from fact_actions_live
where identifier = 'upcomingSessionsNotificationButton'
and created >= '2016-01-01'
and device_type = 'ios'
and mmm_info like '%iPhone%'
group by 1,2
order by 1,2
;

select *
from fact_actions_live
where application_id = '619e0c9d-da90-44a4-93b8-654d2573a1be'
and global_user_id = '6ce5b5ca-3b96-48cb-ad9c-105ed6793d3c'
and session_id = '0847b9f7-1db8-41da-ba86-1b635bb1ab0e'
union
select *
from fact_views_live
where application_id = '619e0c9d-da90-44a4-93b8-654d2573a1be'
and global_user_id = '6ce5b5ca-3b96-48cb-ad9c-105ed6793d3c'
and session_id = '0847b9f7-1db8-41da-ba86-1b635bb1ab0e'
;


select *
from ratings_item
where itemid = 10768392
;

select *
from ratings_topic
where topicid = 10302036
;