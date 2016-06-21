drop table if exists google.ep_app_event_nolabel_counts;
create table google.ep_app_event_nolabel_counts (
     application_id varchar
   , global_user_id varchar
   , event_category varchar
   , event_action varchar
   , date date
   , hour_of_day int
   , total_events int );

select min(date)
     , max(date)
from google.ep_app_pageview_counts;

select min(date)
     , max(date)
from google.ep_app_event_counts;

-- EP Pageview
drop table if exists jt.eppageview;
create table jt.eppageview as
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , upper(a.global_user_id) as globaluserid
     , a.date
     , a.hour_of_day
     , case
         when a.date < b.startdate then 'Before Event'
         when a.date >= b.startdate and a.date <= b.enddate then 'During Event'
         else 'After Event'
       end as timedesc
     , sum(total_pageviews) as totalpageview
from google.ep_app_pageview_counts a
join eventcube.eventcubesummary b
on a.application_id = lower(b.applicationid)
left join eventcube.testevents c
on b.applicationid = c.applicationid
where a.global_user_id in (select distinct lower(globaluserid)
                         from ratings_globaluserdetails
                         where upper(bundleid) = 'C6DEACD6-2869-4C8A-9CFC-8E7951AC7672'
                         and lower(emailaddressdomain) not like '%doubledutch%')
and a.page_path = '/analytics/newanalytics'
and c.applicationid is null
group by 1,2,3,4,5,6,7,8
order by 1,5,6,7;

-- EP Datepicker Action
drop table if exists jt.datepicker;
create table jt.datepicker as
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , upper(a.global_user_id) as globaluserid
     , a.date
     , a.hour_of_day
     , case
         when a.date < b.startdate then 'Before Event'
         when a.date >= b.startdate and a.date <= b.enddate then 'During Event'
         else 'After Event'
       end as timedesc
     , sum(total_events) as totaleventcnt
from google.ep_app_event_counts a
join eventcube.eventcubesummary b
on a.application_id = lower(b.applicationid)
left join eventcube.testevents c
on b.applicationid = c.applicationid
where a.global_user_id in (select distinct lower(globaluserid)
                         from ratings_globaluserdetails
                         where upper(bundleid) = 'C6DEACD6-2869-4C8A-9CFC-8E7951AC7672'
                         and lower(emailaddressdomain) not like '%doubledutch%')
and a.event_category = 'datepicker'
and c.applicationid is null
group by 1,2,3,4,5,6,7,8
order by 1,5,6,7;

-- EP Time Selector Action
drop table if exists jt.timeselector;
create table jt.timeselector as
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , upper(a.global_user_id) as globaluserid
     , a.date
     , a.hour_of_day
     , case
         when a.date < b.startdate then 'Before Event'
         when a.date >= b.startdate and a.date <= b.enddate then 'During Event'
         else 'After Event'
       end as timedesc
     , sum(total_events) as totaleventcnt
from google.ep_app_event_nolabel_counts a
join eventcube.eventcubesummary b
on a.application_id = lower(b.applicationid)
left join eventcube.testevents c
on b.applicationid = c.applicationid
where a.global_user_id in (select distinct lower(globaluserid)
                         from ratings_globaluserdetails
                         where upper(bundleid) = 'C6DEACD6-2869-4C8A-9CFC-8E7951AC7672'
                         and lower(emailaddressdomain) not like '%doubledutch%')
and a.event_category = 'timeframeselector'
and c.applicationid is null
group by 1,2,3,4,5,6,7,8
order by 1,5,6,7;

drop table if exists jt.timetogglegranular;
create table jt.timetogglegranular as
select a.globaluserid
     , a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.date
     , a.hour_of_day
     , a.timedesc
     , case
          when b.applicationid is null then false
          else true
       end datepicker
     , case
          when c.applicationid is null then false
          else true
       end timeframeselector
from jt.eppageview a
left join jt.datepicker b
on a.applicationid = b.applicationid
and a.globaluserid = b.globaluserid
and a.date = b.date
left join jt.timeselector c
on a.applicationid = c.applicationid
and a.globaluserid = c.globaluserid
and a.date = c.date;


-- All Time
select count(distinct globaluserid) as uniqueepvisitors
     , count(distinct case when datepicker then globaluserid else null end) as uniquedatepickerusers
     , count(distinct case when timeframeselector then globaluserid else null end) as uniquetimeframeusers
     , count(distinct case when datepicker and timeframeselector then globaluserid else null end) as uniquetimechangeusers
     , count(distinct case when datepicker or timeframeselector then globaluserid else null end) as uniquetimechangeusersor
     , count(distinct case when datepicker then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquedatepickeruserspct
     , count(distinct case when timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimeframeuserspct
     , count(distinct case when datepicker and timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimechangeuserspct
     , count(distinct case when datepicker or timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimechangeusersorpct
from jt.timetogglegranular;

-- Before, During, After Slicing
select timedesc
     , count(distinct globaluserid) as uniqueepvisitors
     , count(distinct case when datepicker then globaluserid else null end) as uniquedatepickerusers
     , count(distinct case when timeframeselector then globaluserid else null end) as uniquetimeframeusers
     , count(distinct case when datepicker and timeframeselector then globaluserid else null end) as uniquetimechangeusers
     , count(distinct case when datepicker or timeframeselector then globaluserid else null end) as uniquetimechangeusersor
     , count(distinct case when datepicker then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquedatepickeruserspct
     , count(distinct case when timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimeframeuserspct
     , count(distinct case when datepicker and timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimechangeuserspct
     , count(distinct case when datepicker or timeframeselector then globaluserid else null end)::decimal(12,4)/count(distinct globaluserid)::decimal(12,4) as uniquetimechangeusersorpct
from jt.timetogglegranular
group by 1
order by 1;



