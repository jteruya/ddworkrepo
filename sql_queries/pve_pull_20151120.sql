select a.applicationid
     , c.name
     , c.startdate
     , c.enddate
     , c.canregister
     , count(distinct recipientemail) as recipientemailcnt
     , count(case when first_accepted_timestamp is not null then 1 else null end) as acceptedcnt
     , count(case when first_failed_timestamp is not null and first_delivered_timestamp is null then 1 else null end) as failedcnt
     , count(case when first_delivered_timestamp is not null then 1 else null end) as deliveredcnt
     , count(case when first_opened_timestamp is not null then 1 else null end) as openedcnt
     , count(case when first_clicked_timestamp is not null then 1 else null end) as clickedcnt
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%'
group by 1,2,3,4,5;

-- 86 events





select count(*) as eventcnt
     , sum(recipientemailcnt) as recipientcnt
     , sum(acceptedcnt) as acceptedcnt
     , sum(deliveredcnt) as deliveredcnt
     , sum(openedcnt) as openedcnt
     , sum(clickedcnt) as clickedcnt
from (
select a.applicationid
     , count(distinct recipientemail) as recipientemailcnt
     , count(case when first_accepted_timestamp is not null then 1 else null end) as acceptedcnt
     , count(case when first_delivered_timestamp is not null then 1 else null end) as deliveredcnt
     , count(case when first_opened_timestamp is not null then 1 else null end) as openedcnt
     , count(case when first_clicked_timestamp is not null then 1 else null end) as clickedcnt
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%'
group by 1) a;



select count(*) as eventcnt
     , sum(recipientemailcnt) as recipientcnt
     , sum(acceptedcnt) as acceptedcnt
     , sum(deliveredcnt) as deliveredcnt
     , sum(openedcnt) as openedcnt
     , sum(clickedcnt) as clickedcnt
from (
select a.applicationid
     , count(distinct recipientemail) as recipientemailcnt
     , count(case when first_accepted_timestamp is not null then 1 else null end) as acceptedcnt
     , count(case when first_delivered_timestamp is not null then 1 else null end) as deliveredcnt
     , count(case when first_opened_timestamp is not null then 1 else null end) as openedcnt
     , count(case when first_clicked_timestamp is not null then 1 else null end) as clickedcnt
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%'
group by 1) a;





select min(first_delivered_timestamp)
     , max(first_delivered_timestamp)
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%';


-- First Delivered: 2015-07-13 10:10:56
-- Last Delivered: 2015-08-27 10:00:55








select a.applicationid
     , count(distinct recipientemail) as recipientemailcnt
     , count(case when first_accepted_timestamp is not null then 1 else null end) as acceptedcnt
     , count(case when first_delivered_timestamp is not null then 1 else null end) as deliveredcnt
     , count(case when first_opened_timestamp is not null then 1 else null end) as openedcnt
     , count(case when first_clicked_timestamp is not null then 1 else null end) as clickedcnt
     , count(case when first_delivered_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_accepted_timestamp is not null then 1 else null end)::decimal(12,4) as deliveredpct
     , case
         when count(case when first_delivered_timestamp is not null then 1 else null end)::decimal(12,4) > 0
         then count(case when first_opened_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_delivered_timestamp is not null then 1 else null end)::decimal(12,4) 
         else null
       end as openedpct
     , case
         when count(case when first_opened_timestamp is not null then 1 else null end)::decimal(12,4) > 0
         then count(case when first_clicked_timestamp is not null then 1 else null end)::decimal(12,4)/count(case when first_opened_timestamp is not null then 1 else null end)::decimal(12,4) 
         else null
       end as clickedpct
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%'
group by 1;


select *
from mailgun.mailguncube a
left join eventcube.testevents b
on lower(a.applicationid::varchar) = lower(b.applicationid)

left join authdb_applications c
on lower(a.applicationid::varchar) = lower(c.applicationid)

where b.applicationid is null
and recipientemaildomain <> 'doubledutch.me'
and lower(a.subject) like '%people are viewing%'
and a.applicationid = '86bf59f6-efb4-4b1e-a50c-31600ff860a9';



select *
from mailgun.mailgun_events
where messageid = '20150721170041.46827.9982@doubledutch.me';
