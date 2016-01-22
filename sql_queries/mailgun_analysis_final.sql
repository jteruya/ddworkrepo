-- Leadercast Analysis (First)
drop table jt.delivered;
drop table jt.delivered_once;
drop table jt.delivered_more_than_once;
drop table jt.mailgun_events_lvl_1;
drop table jt.mailgun_events_lvl_2;
drop table jt.mailgun_events_lvl_3;
drop table jt.mailgun_events_lvl_4;
drop table jt.mailgun_events_spine;
drop table jt.mailgun_events_summary;
drop table jt.mailgun_strange_paths;

-- Lookup table delivered emails
select a.applicationid
     , b.name
     , b.eventtype
     , a.messageid
     , a.subject
     , case
         when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'Password Reset Email'
         when a.subject like '%sent you a message%' then 'Message Alert Email'
         when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'Welcome Email'
         when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'Today At Email'
         when a.subject like 'Your Session Notes' then 'Session Note Alert Email'
         when a.subject like 'Your Beacon Message Info' then 'Beacon Message Info'
         when a.subject like 'Exhibitor Opportunity %' then 'Exhibitor Opportunity Email'
         when a.subject like 'Your Leads Report %' then 'Leads Report Email'
         when a.subject like 'Set Up Lead Scanning For %' then 'Set Up Lead Scanning Call To Action Email'
         when a.subject like 'Activity Flagged %' then 'Activity Flagged Email'
         when a.subject like '% has requested a meeting' then 'Meeting Request Email'
         when a.subject is null then 'NULL Subject Email'
         else 'Unknown Email'
       end as emailsubjectcatg
     , a.recipientemail
into jt.delivered
from mailgun.events a
join kevin.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'delivered'
and a.applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

--Universe of recipients to include in our sales funnel.
select applicationid
     , name
     , eventtype
     , recipientemail
     , messageid
     , emailsubjectcatg
into jt.delivered_once
from jt.delivered
group by applicationid, name, eventtype, recipientemail, messageid, emailsubjectcatg
having count(*) = 1;

--Universe of recipients to exclude from our sales funnel because of multiple deliveries.
select applicationid
     , name
     , eventtype
     , recipientemail
     , messageid
     , emailsubjectcatg
into jt.delivered_more_than_once
from jt.delivered
group by applicationid, name, eventtype, recipientemail, messageid, emailsubjectcatg
having count(*) > 1;

-- Level 1 Steps (Accepted or Rejected)
-- Mailgun Email Approval Actions
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_1
from mailgun.events
where (eventstatus = 'accepted' or eventstatus = 'rejected')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 2 Steps (Delivered and/or Failed)
-- Delivery Status Actions
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_2
from mailgun.events
where (eventstatus = 'delivered' or eventstatus = 'failed')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 3 Steps (Opened and/or Complained)
-- Actions within the email client 
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_3
from mailgun.events
where (eventstatus = 'opened' or eventstatus = 'complained')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 4 Steps (Clicked and/or Unsubscribed and/or Stored)
-- Actions within the email
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_4
from mailgun.events
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Create the spine of unique messages
select a.*
into jt.mailgun_events_spine
from (select messageid
      from jt.mailgun_events_lvl_2
      union
      select messageid
      from jt.mailgun_events_lvl_3
      union
      select messageid
      from jt.mailgun_events_lvl_4) a
join jt.delivered_once b
on a.messageid = b.messageid;


select a.*             
     , case
         when c.messageid is not null then true
         else false
       end as delivered_flag
--     , coalesce(c.cnt,0) as delivered_cnt
     
     , case
         when d.messageid is not null then true
         else false
       end as failed_flag
     , coalesce(d.cnt,0) as failed_cnt
     
     , case
         when e.messageid is not null then true
         else false
       end as opened_flag
--     , coalesce(e.cnt,0) as opened_cnt
     
     , case
         when f.messageid is not null then true
         else false
       end as complained_flag
--     , coalesce(f.cnt,0) as complained_cnt
     
     , case
         when g.messageid is not null then true
         else false
       end as clicked_flag
--     , coalesce(g.cnt,0) as clicked_cnt
     
     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
--     , coalesce(h.cnt,0) as unsubscribed_cnt
     
     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
--     , coalesce(i.cnt,0) as stored_cnt

into jt.mailgun_events_summary
from jt.mailgun_events_spine a
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'delivered' group by messageid) c
on a.messageid = c.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'failed' group by messageid) d
on a.messageid = d.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'opened' group by messageid) e
on a.messageid = e.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'complained' group by messageid) f
on a.messageid = f.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'clicked' group by messageid) g
on a.messageid = g.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'unsubscribed' group by messageid) h
on a.messageid = h.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'stored' group by messageid) i
on a.messageid = i.messageid;


-- This gets the paths that might don't follow the hierarchy and are suspicious.
select messageid
     , delivered_flag
     , failed_flag
     , opened_flag
     , complained_flag
     , clicked_flag
     , unsubscribed_flag
     , stored_flag
into jt.mailgun_strange_paths
from jt.mailgun_events_summary
where ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
or ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false);


select a.messageid
     , a.delivered_flag
     , a.failed_flag
     , a.failed_cnt
     , a.opened_flag
     , a.complained_flag
     , a.clicked_flag
     , a.unsubscribed_flag
     , a.stored_flag
     , c.applicationid
     , c.eventtype
     , c.emailsubjectcatg
into jt.mailgun_fact_analysis
from jt.mailgun_events_summary a
left join jt.mailgun_strange_paths b
on a.messageid = b.messageid
left join jt.delivered_once c
on a.messageid = c.messageid
where b.messageid is null;

select eventtype
     , emailsubjectcatg
     , openedcnt
     , cast(cast(openedcnt as decimal(8,2))/cast(deliveredcnt as decimal(8,2)) as decimal(8,2)) as openedpct
     , deliveredcnt
from (select eventtype
           , emailsubjectcatg
           , count(*) as deliveredcnt
           , count(case when opened_flag = true then 1 else null end) as openedcnt
           , count(case when opened_flag = false then 1 else null end) as notopenedcnt     
      from jt.mailgun_fact_analysis
      group by eventtype, emailsubjectcatg) a
order by eventtype, emailsubjectcatg;



     
