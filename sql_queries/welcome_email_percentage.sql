-- SQL for Paul Request:
-- Q: How many events send out Welcome Emails?
-- Follow up with Andrew/Kevin to see if we can go back further than 4/16.
-- Explore the number of downloads vs the number of registrants.

select case 
         when a.eventtype is null then 'No Event Type'
         when a.eventtype = '_Unknown' then 'Unknown'
         else a.eventtype 
       end as eventtype
     , count(*) as total_events
     , count(case when b.applicationid is not null then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when b.applicationid is not null then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select applicationid
           , eventtype
      from kevin.tm_eventcubesummary
      where startdate >= '2015-04-16') a
left join (select distinct applicationid
           from mailgun.events
           where subject like 'Welcome to %' or subject like 'Bienvenido %') b
on a.applicationid = b.applicationid
group by eventtype
order by eventtype;


select count(*) as total_events
     , count(case when b.applicationid is not null then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when b.applicationid is not null then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select applicationid
           , eventtype
      from kevin.tm_eventcubesummary
      where startdate >= '2015-04-16'
      and startdate <= '2015-05-21') a
left join (select distinct applicationid
           from mailgun.events
           where subject like 'Welcome to %' or subject like 'Bienvenido %') b
on a.applicationid = b.applicationid;

           

