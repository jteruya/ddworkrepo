select *
from authdb_applications
where lower(applicationid) = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
;

drop table if exists nondisabledusers;
create temporary table nondisabledusers as
select distinct lower(globaluserid) as global_user_id
     , userid
     , isdisabled
from authdb_is_users
where applicationid = '0DD15060-2A62-4E8C-8D02-4D16006626D2'
;


drop table if exists nondisabledusers_sessions;
create temporary table nondisabledusers_sessions as
select a.global_user_id
     , count(case when b.global_user_id is not null then 1 else null end) as sessioncnt
     , count(distinct case when b.device_id is not null then 1 else null end) as devicecnt
from nondisabledusers a
left join (select *
           from public.fact_sessions_live
           where application_id = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
           and identifier = 'start') b
on a.global_user_id = b.global_user_id
group by 1
;

drop table if exists nondisabledusers_actions;
create temporary table nondisabledusers_actions as
select a.global_user_id
     , count(case when b.global_user_id is not null then 1 else null end) as actioncnt
from nondisabledusers a
left join (select *
           from public.fact_actions_live
           where application_id = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
           ) b
on a.global_user_id = b.global_user_id
group by 1
;

drop table if exists nondisabledusers_views;
create temporary table nondisabledusers_views as
select a.global_user_id
     , count(case when b.global_user_id is not null then 1 else null end) as actioncnt
from nondisabledusers a
left join (select *
           from public.fact_views_live
           where application_id = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
           ) b
on a.global_user_id = b.global_user_id
group by 1
;


-- Check Record Counts
select count(*)
from nondisabledusers
;

select count(*)
from nondisabledusers_sessions
;

select count(*)
from nondisabledusers_actions
;


select count(global_user_id) as regusercnt
     , count(case when sessioncnt > 0 then 1 else null end) as activeusercnt
     , count(case when sessioncnt > 0 then 1 else null end)::decimal(12,4)/count(global_user_id)::decimal(12,4) as activeuserpct
     , sum(devicecnt) as devicecnt
     , sum(sessioncnt) as sessioncnt
     , sum(actioncnt) as actioncnt
     , sum(viewcnt) as viewcnt
from (
select aa.global_user_id
     , coalesce(a.sessioncnt,0) as sessioncnt
     , coalesce(a.devicecnt,0) as devicecnt
     , coalesce(b.actioncnt,0) as actioncnt
     , coalesce(c.actioncnt,0) as viewcnt
from nondisabledusers aa
left join nondisabledusers_sessions a
on aa.global_user_id = a.global_user_id
left join nondisabledusers_actions b
on aa.global_user_id = b.global_user_id
left join nondisabledusers_views c
on aa.global_user_id = c.global_user_id
where aa.isdisabled = 0
) a
;



-- 2297 Registered Users
-- 1711 Active Users
-- 1711 Unique Devices

-- Total Actions: 592,793
-- Total Actions per Active User: 346.46
-- Total Actions per Active User Avg: 346.46
-- Total Actions per Active User Median: 246




select *
from nondisabledusers a
join nondisabledusers_sessions b
on a.global_user_id = b.global_user_id
where a.isdisabled = 0
and b.sessioncnt > 0
and a.userid = 47606062
;


select *
from nondisabledusers
where userid = 47409386
;
-- be4410bb-ac61-4544-829b-fe14b5638583

select *
from nondisabledusers_sessions
where global_user_id = 'be4410bb-ac61-4544-829b-fe14b5638583'
;


select *
from fact_sessions_new
where application_id = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
and user_id = 47409386
; 