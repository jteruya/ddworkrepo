
--drop table photofeed_events;

-- create temporary table to store q3 events and flag if they have photofeed microapp
create temporary table photofeed_events as
select a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.canregister
     , c.title
     , d.notdisabledcnt
     , d.totalusercnt
     , case when c.applicationid is not null then true else false end as photofeedflag
from (select * from authdb_applications where startdate >= '2015-07-01' and enddate < current_date) a
left join jt.adoption_report_testevents b
on a.applicationid = b.applicationid
left join (select * from ratings_applicationconfiggriditems where typeid = 11 and selected = 'true') c
on a.applicationid = c.applicationid
left join (select applicationid, count(case when isdisabled = 0 then 1 else null end) as notdisabledcnt, count(*) as totalusercnt from authdb_is_users group by 1) d
on a.applicationid = d.applicationid
where b.applicationid is null;

-- % of apps that have the photofeed microapp
select count(*)
     , count(case when photofeedflag = true then 1 else null end) as photofeedcnt
     , count(case when photofeedflag = true then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as photofeedpct
from photofeed_events a;

-- 389 total q3 events
-- 264 total events use photofeed (67.87%)


--drop table photofeed_events_users;

create temporary table photofeed_events_users as
select applicationid
     , count(*) as totalviewusercnt
from (select distinct b.applicationid
           , a.global_user_id
      from public.fact_views a
      join photofeed_events b
      on a.application_id = lower(b.applicationid)
      where a.identifier = 'photofeed') a
group by applicationid;


-- % of users by event
select a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.canregister
     , coalesce(b.totalviewusercnt, 0) as photofeedviewcnt
     , a.notdisabledcnt as eventuserisdisabledcnt
     , a.totalusercnt as eventusercnt
     , coalesce(b.totalviewusercnt, 0)::decimal(12,4)/a.totalusercnt::decimal(12,4) as photofeedviewpct
     , coalesce(b.totalviewusercnt, 0)::decimal(12,4)/a.notdisabledcnt::decimal(12,4) as photofeednondisabledviewpct
from (select * from photofeed_events where photofeedflag = true) a
left join photofeed_events_users b
on a.applicationid = b.applicationid
order by startdate, enddate, name;


-- avg and median % of users over all events
select avg(photofeedviewpct)
     , percentile_cont(0.5) within group (order by photofeedviewpct)
     , avg(case when photofeedviewcnt <= eventuserisdisabledcnt then photofeednondisabledviewpct else null end) as avgminus
     , avg(photofeednondisabledviewpct) as avg
     , percentile_cont(0.5) within group (order by photofeednondisabledviewpct)
from (select a.applicationid
           , a.name
           , a.startdate
           , a.enddate
           , a.canregister
           , coalesce(b.totalviewusercnt, 0) as photofeedviewcnt
           , a.notdisabledcnt as eventuserisdisabledcnt
           , a.totalusercnt as eventusercnt
           , coalesce(b.totalviewusercnt, 0)::decimal(12,4)/a.totalusercnt::decimal(12,4) as photofeedviewpct
           , coalesce(b.totalviewusercnt, 0)::decimal(12,4)/a.notdisabledcnt::decimal(12,4) as photofeednondisabledviewpct
      from (select * from photofeed_events where photofeedflag = true) a
      left join photofeed_events_users b
      on a.applicationid = b.applicationid) a;

-- Avg: 23.87% of total users
-- Median: 21.85% of total users


-- Look at Exception Event (Vast Majority of Users are Disabled)
select count(*)
     , count(case when isdisabled = 1 then 1 else null end)
     , count(case when isdisabled = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4)
from authdb_is_users
where applicationid = '079C2D53-BCF3-4C67-9DDC-1257B42B1D57';




