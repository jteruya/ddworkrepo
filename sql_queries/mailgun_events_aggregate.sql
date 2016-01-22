-- Table: jt.mailgun_events_aggregate
-- This table will be used to create the email funnel reports.

select mailgundate
     , eventstatus
     , emailsubjectcatg
     , eventtype
     , count(*)
into jt.mailgun_events_aggregate
from (select cast(to_timestamp(a.eventtimestamp/1000) as date) as mailgundate
           , a.eventstatus
           , case 
               when b.eventtype = '' then 'No Event Type'
               when b.eventtype = '_Unknown' then 'Unknown'
               else b.eventtype 
             end as eventtype
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
      from mailgun.events a
      join kevin.tm_eventcubesummary b
      on a.applicationid = b.applicationid) a
group by mailgundate, eventstatus, emailsubjectcatg, eventtype
order by mailgundate;




