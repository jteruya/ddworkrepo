

drop table jt.mailgun_subject_categories;

/* Table: jt.mailgun_subject_categories
   Description: This table contains the distinct applicationid, senderemail, subject an categorization
   of the email based on the contents of the subject line. */

select distinct applicationid
     , senderemail
     , subject
     , case
         -- Welcome Emails
         when lower(subject) like '%welcome%' then 'welcome email'
         when lower(subject) like '%bienvenido%' then 'spanish welcome email'
         
         -- Password Reset Emails
         when lower(subject) like '%password%reset%' then 'password reset email'
         when lower(subject) like '%restablecer%' then 'spanish password reset email'
         
         -- Social Alert Emails
         when lower(subject) like '%sent you a message%' then 'message alert email'
         when lower(subject) like '%has requested a meeting%' then 'meeting request email'
         
         -- Core Functionality Emails
         when lower(subject) like 'your session notes' then 'session notes email'
         
         -- Daily Digest Emails
         when lower(subject) like 'today at%' then 'daily digest email'

         -- Exhibitor Alerts
         when lower(subject) like '%exhibitor report%' then 'exhibitor report'
         when lower(subject) like '%exhibitor opportunity%' then 'exhibitor opportunity'

         -- Leads Alerts
         when lower(subject) like '%leads report%' then 'leads report email'
         
         -- Activity Flagged Alert
         when lower(subject) like 'activity flagged %' then 'activity flagged email'
         
         -- Beacon Message Alert
         when lower(subject) like '%beacon%' then 'beacon message info email'        
         
         -- Engagement Report
         when lower(subject) like '%engagement report%' then 'engagement report'

         -- Call to Action Emails
         when lower(subject) like '%set up%' then 'Setup Call to Action Email'

         -- NULL Subject Lines
         when subject is null then 'null subject'
         
         -- ELSE case
         else 'no category'
         
       end as category_desc
into jt.mailgun_subject_categories
from mailgun.events;

/* This query uses the jt.mailgun_subject_categories and kevin.tm_eventcubesummary
   tables with the mailgun.events table to return the counts based on the event type,
   email category and email status. */


select eventtype
     , category_desc
     , eventstatus
     , count(*) as cnt
from (select a.applicationid
           , a.subject
           , a.eventstatus
           , b.category_desc
           , c.eventtype
      from mailgun.events a
      join jt.mailgun_subject_categories b
      on a.applicationid = b.applicationid
      and a.subject = b.subject
      join kevin.tm_eventcubesummary c
      on a.applicationid = c.applicationid) a
group by eventtype, category_desc, eventstatus
order by cnt desc;



         




   