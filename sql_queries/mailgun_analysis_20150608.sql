
/* Drop Table Commands - Run if needed
*/
drop table if exists jt.accepted;
drop table if exists jt.delivered;
drop table if exists jt.delivered_once;
drop table if exists jt.delivered_more_than_once;
drop table if exists jt.mailgun_events_lvl_2;
drop table if exists jt.mailgun_events_lvl_3;
drop table if exists jt.mailgun_events_lvl_4;
drop table if exists jt.mailgun_events_spine;
drop table if exists jt.mailgun_events_summary;
drop table if exists jt.mailgun_strange_paths;
drop table if exists jt.mailgun_fact_analysis;

/* Query A:
   Table Created: jt.accepted
   Lookup table of accepted emails
*/
select a.applicationid
     , b.name
     , b.eventtype
     , a.messageid
     , a.subject
     , case
         when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'passwordresetemail'
         when a.subject like '%sent you a message%' then 'messagealertemail'
         when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'welcomeemail'
         when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'dailydigestemail'
         when a.subject like 'Your Session Notes' then 'sessionnotealertemail'
         when a.subject like 'Your Beacon Message Info' then 'beaconmessageinfoemail'
         when a.subject like 'Exhibitor Opportunity %' then 'exhibitoropportunityemail'
         when a.subject like 'Your Leads Report %' then 'leadsreportemailemail'
         when a.subject like 'Set Up Lead Scanning For %' then 'setupleadscanningcalltoactionemail'
         when a.subject like 'Activity Flagged %' then 'activityflaggedemail'
         when a.subject like '% has requested a meeting' then 'meetingrequestemail'
         when a.subject is null then 'nullsubjectemail'
         else 'unknownemail'
       end as emailsubjectcatg
     , a.recipientemail
     , a.eventtimestamp
into jt.accepted
from mailgun.events a
join jt.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'accepted';
--and a.applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

/* Query B:
   Table Created: jt.delivered
   Lookup table of accepted emails
*/
select a.applicationid
     , b.name
     , b.eventtype
     , a.messageid
     , a.subject
     , case
         when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'passwordresetemail'
         when a.subject like '%sent you a message%' then 'messagealertemail'
         when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'welcomeemail'
         when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'dailydigestemail'
         when a.subject like 'Your Session Notes' then 'sessionnotealertemail'
         when a.subject like 'Your Beacon Message Info' then 'beaconmessageinfoemail'
         when a.subject like 'Exhibitor Opportunity %' then 'exhibitoropportunityemail'
         when a.subject like 'Your Leads Report %' then 'leadsreportemailemail'
         when a.subject like 'Set Up Lead Scanning For %' then 'setupleadscanningcalltoactionemail'
         when a.subject like 'Activity Flagged %' then 'activityflaggedemail'
         when a.subject like '% has requested a meeting' then 'meetingrequestemail'
         when a.subject is null then 'nullsubjectemail'
         else 'unknownemail'
       end as emailsubjectcatg
     , a.recipientemail
     , a.eventtimestamp
into jt.delivered
from mailgun.events a
join jt.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'delivered';
--and a.applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

/* Query C:
   Table Created: jt.delivered_once
   Universe of recipients to include in our delivered sales funnel.
*/
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

/* Query D:
   Table Created: jt.delivered_more_than_once
   Recipients that will be excluded from the sales funnel because of multiple deliveries to the same person.
*/
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


/* Query E:
   Table Created: jt.mailgun_events_lvl_2
   Level 2 Steps (Delivered and/or Failed).  Delivery Status Actions
*/
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
where (eventstatus = 'delivered' or eventstatus = 'failed');
--and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

/* Query F:
   Table Created: jt.mailgun_events_lvl_3
   Level 3 Steps (Opened and/or Complained).  Actions within the email client 
*/ 
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
where (eventstatus = 'opened' or eventstatus = 'complained');
--and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

/* Query G:
   Table Created: jt.mailgun_events_lvl_4
   Level 4 Steps (Clicked and/or Unsubscribed and/or Stored).  Actions within the email
*/ 
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
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored');
--and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

/* Message ID - Recipient Lookups */

drop table if exists jt.mailgun_message_recipeint_delivered_lookup;
drop table if exists jt.mailgun_message_recipeint_complained_lookup;

select a.*
into jt.mailgun_message_recipeint_delivered_lookup
from (select messageid
           , recipientemail
      from jt.mailgun_events_lvl_2) a
join jt.delivered_once b
on a.messageid = b.messageid;

select a.*
into jt.mailgun_message_recipeint_complained_lookup
from (select messageid
           , recipientemail
      from jt.mailgun_events_lvl_3
      where eventstatus = 'complained') a
join jt.delivered_once b
on a.messageid = b.messageid;

/* Query H:
   Table Created: jt.mailgun_events_spine
   Unions all level 2, 3, and 4 actions and joins them with the users that recieved the delivered email only once.
*/ 
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

/* Query I:
   Table Created: jt.mailgun_events_summary
   This creates the granular fact table that tracks to see if there an email went through a particular state (e.g. clicked).
*/ 
select a.*             
     , case
         when c.messageid is not null then true
         else false
       end as delivered_flag
     , case
         when c.messageid is not null then c.eventtimestamp
         else null
       end as delivered_time
--     , coalesce(c.cnt,0) as delivered_cnt
     
     , case
         when d.messageid is not null then true
         else false
       end as failed_flag
     , case
         when d.messageid is not null then d.eventtimestamp
         else null
       end as failed_time
--    , coalesce(d.cnt,0) as failed_cnt
     
     , case
         when e.messageid is not null then true
         else false
       end as opened_flag
     , case
         when e.messageid is not null then e.eventtimestamp
         else null
       end as opened_time
--     , coalesce(e.cnt,0) as opened_cnt
     
     , case
         when f.messageid is not null then true
         else false
       end as complained_flag
     , case
         when f.messageid is not null then f.eventtimestamp
         else null
       end as complained_time
--     , coalesce(f.cnt,0) as complained_cnt
     
     , case
         when g.messageid is not null then true
         else false
       end as clicked_flag
     , case
         when g.messageid is not null then g.eventtimestamp
         else null
       end as clicked_time
--     , coalesce(g.cnt,0) as clicked_cnt
     
     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
     , case
         when h.messageid is not null then h.eventtimestamp
         else null
       end as unsubscribed_time
--     , coalesce(h.cnt,0) as unsubscribed_cnt
     
     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
     , case
         when i.messageid is not null then i.eventtimestamp
         else null
       end as stored_time
--     , coalesce(i.cnt,0) as stored_cnt

into jt.mailgun_events_summary
from jt.mailgun_events_spine a
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'delivered' group by messageid) c
on a.messageid = c.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'failed' group by messageid) d
on a.messageid = d.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'opened' group by messageid) e
on a.messageid = e.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'complained' group by messageid) f
on a.messageid = f.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'clicked' group by messageid) g
on a.messageid = g.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'unsubscribed' group by messageid) h
on a.messageid = h.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'stored' group by messageid) i
on a.messageid = i.messageid;

/* Query J:
   Table Created: jt.mailgun_strange_paths
   This gets the paths that might don't follow the hierarchy and are suspicious.  They will be excluded from the analysis.
*/ 
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

/* Query K:
   Table Created: jt.mailgun_fact_analysis
   This is the clean population of delivered email that has:
        1.) Only one email was delivered to the recipient.
        2.) No strange paths (e.g. no delivery but there was a click action)
*/
select a.messageid
     , a.delivered_flag
     , a.delivered_time
     , a.failed_flag
     , a.failed_time
     , a.opened_flag
     , a.opened_time
     , a.complained_flag
     , a.complained_time
     , a.clicked_flag
     , a.clicked_time
     , a.unsubscribed_flag
     , a.unsubscribed_time
     , a.stored_flag
     , a.stored_time
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

/*
-- This queries aggregate counts and percentages by event type and email subject category and pulls for delivered emails:
--        1.) acceptedcnt: This is the number of unique types of emails (e.g. Welcome Emails) that needs to be sent to a recipient and is accepted by mailgun.
--        2.) deliveredcnt: This is the number of unique type of emails (e.g. Welcome Emails) that are delivered to the intended user.
--        3.) deliveredpct: This is the percentage of accepted emails that were successfully delivered.

select eventtype
     , emailsubjectcatg
     , count(*) as acceptedcnt
     , count(case when deliveredmessageid is not null then 1 else null end) as deliveredcnt
     , cast(cast(count(case when deliveredmessageid is not null then 1 else null end) as decimal(8,2))/cast(count(*) as decimal(8,2)) as decimal(8,2)) as deliveredpct
from (select a.*
           , d.messageid as deliveredmessageid
      from (select applicationid
                 , messageid
                 , emailsubjectcatg
                 , eventtype
                 , recipientemail
            from jt.accepted
            group by applicationid, messageid, emailsubjectcatg, eventtype, recipientemail) a
      left join (select applicationid
                      , messageid
                      , emailsubjectcatg
                      , eventtype
                      , recipientemail
                 from jt.delivered
                 group by applicationid, messageid, emailsubjectcatg, eventtype, recipientemail) d
      on a.applicationid = d.applicationid and a.messageid = d.messageid and a.emailsubjectcatg = d.emailsubjectcatg and a.eventtype = d.eventtype and a.recipientemail = d.recipientemail
      ) x
group by eventtype, emailsubjectcatg;

-- This queries aggregate counts and percentages by event type and email subject category and pulls for opened and clicked actions by a user.
--      1.) deliveredcnt: This is the number of unique type of emails (e.g. Welcome Emails) that are delivered to the intended user.
--      2.) openedcnt: This is the number of emails that were opened at least once from the pool of delivered emails.
--      3.) openedpct: This is the percentage of emails that were opened at least once from the pool of delivered emails.
--      4.) clickedcnt: This is the number of emails that were clicked on at least once from the pool of delivered emails.
--      5.) clickedpct: This is the percentage of emails that were clicked on at least once from the pool of delivered emails.

select eventtype
     , emailsubjectcatg
     , deliveredcnt
     , openedcnt
     , cast(cast(openedcnt as decimal(8,2))/cast(deliveredcnt as decimal(8,2)) as decimal(8,2)) as openedpct
     , clickedcnt
     , cast(cast(clickedcnt as decimal(8,2))/cast(deliveredcnt as decimal(8,2)) as decimal(8,2)) as clickedpct
from (select eventtype
           , emailsubjectcatg
           , count(*) as deliveredcnt
           , count(case when opened_flag = true then 1 else null end) as openedcnt
           , count(case when clicked_flag = true then 1 else null end) as clickedcnt
      from jt.mailgun_fact_analysis
      group by eventtype, emailsubjectcatg) a
order by eventtype, emailsubjectcatg;

-- User in Excel to Lucian
select eventtype
     , emailsubjectcatg
     , cast(cast(count(case when deliveredmessageid is not null then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as deliveredpctaccepted
     , count(*) as acceptedcnt
     , count(case when deliveredmessageid is not null then 1 else null end) as deliveredcnt
from (select a.*
           , d.messageid as deliveredmessageid
      from (select applicationid
                 , messageid
                 , emailsubjectcatg
                 , eventtype
                 , recipientemail
            from jt.accepted
            group by applicationid, messageid, emailsubjectcatg, eventtype, recipientemail) a
      left join (select applicationid
                      , messageid
                      , emailsubjectcatg
                      , eventtype
                      , recipientemail
                 from jt.delivered
                 group by applicationid, messageid, emailsubjectcatg, eventtype, recipientemail) d
      on a.applicationid = d.applicationid and a.messageid = d.messageid and a.emailsubjectcatg = d.emailsubjectcatg and a.eventtype = d.eventtype and a.recipientemail = d.recipientemail
      ) x
where emailsubjectcatg = 'Meeting Request Email'
group by eventtype, emailsubjectcatg
order by eventtype, emailsubjectcatg;

select eventtype
     , emailsubjectcatg
     , deliveredcnt
     , cast(cast(openedcnt as decimal(10,4))/cast(deliveredcnt as decimal(10,4)) as decimal(10,4)) as openedpct
     , cast(cast(complainedcnt as decimal(10,4))/cast(deliveredcnt as decimal(10,4)) as decimal(10,4)) as complainedpct
     , cast(cast(clickedcnt as decimal(10,4))/cast(deliveredcnt as decimal(10,4)) as decimal(10,4)) as clickedpctofdelivered
     , case when openedcnt > 0 then cast(cast(clickedcnt as decimal(10,4))/cast(openedcnt as decimal(10,4)) as decimal(10,4)) else 0 end as clickedpctofopened               
     , cast(cast(unsubscribedcnt as decimal(10,4))/cast(deliveredcnt as decimal(10,4)) as decimal(10,4)) as unsubscribedpctdelivered
     , case when openedcnt > 0 then cast(cast(unsubscribedcnt as decimal(10,4))/cast(openedcnt as decimal(10,4)) as decimal(10,4)) else 0 end as unsubscribedpctopened
     , cast(cast(storedcnt as decimal(10,4))/cast(deliveredcnt as decimal(10,4)) as decimal(10,4)) as storedpctdelivered
     , case when openedcnt > 0 then cast(cast(storedcnt as decimal(10,4))/cast(openedcnt as decimal(10,4)) as decimal(10,4)) else 0 end as storedpctopened
     , openedcnt
     , complainedcnt
     , clickedcnt
     , unsubscribedcnt
     , storedcnt
from (select eventtype
           , emailsubjectcatg
           , count(*) as deliveredcnt
           , count(case when opened_flag = true then 1 else null end) as openedcnt
           , count(case when complained_flag = true then 1 else null end) as complainedcnt
           , count(case when clicked_flag = true then 1 else null end) as clickedcnt
           , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribedcnt
           , count(case when stored_flag = true then 1 else null end) as storedcnt
      from jt.mailgun_fact_analysis
      group by eventtype, emailsubjectcatg) a
where emailsubjectcatg = 'Meeting Request Email'
order by eventtype, emailsubjectcatg;
*/
