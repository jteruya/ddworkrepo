select recipientemaildomain
     , count(*)
from mailgun.mailguncube
where applicationid = '170d682c-39b6-49a5-8c62-679b9fe4de70'
and (recipientemaildomain like '%eye%' or recipientemaildomain like '%sim%')
group by 1
order by 2 desc;

select *
from mailgun.mailguncube
where recipientemaildomain = 'eyeontheworldenergy.com';

select *
from mailgun.agg_status_per_domain
where recipientemaildomain = 'eyeontheworldenergy.com';

select subject
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribedcnt
     , count(case when complained_flag = true then 1 else null end) as complainedcnt
     , count(case when stored_flag = true then 1 else null end) as storedcnt
     , count(case when opened_flag = true or clicked_flag = true or unsubscribed_flag = true or complained_flag = true or stored_flag = true then 1 else null end) as respondedcnt
from mailgun.mailguncube
where applicationid = '170d682c-39b6-49a5-8c62-679b9fe4de70'
and lower(subject) like '%password%'
group by 1
order by 2 desc;


select count(case when openedpct = 0 then 1 else null end) as zeropctcnt
     , count(case when openedpct > 0 and openedpct < 1 then 1 else null end) as betweenpctcnt
     , count(case when openedpct = 1 then 1 else null end) as hundredpctcnt
from (
select recipientemaildomain
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , case
          when count(case when delivered_flag = true then 1 else null end) > 0 then 
          count(case when opened_flag = true then 1 else null end)::decimal(12,4)/count(case when delivered_flag = true then 1 else null end)::decimal(12,4)
          else 0
       end as openedpct
from mailgun.mailguncube
where applicationid = '170d682c-39b6-49a5-8c62-679b9fe4de70'
and lower(subject) like '%password%'
--and recipientemaildomain = 'eyeontheworldenergy.com'
group by 1) a;
order by 6 desc;
