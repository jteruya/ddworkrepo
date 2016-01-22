select *
from mailgun.mailguncube
where applicationid = '170d682c-39b6-49a5-8c62-679b9fe4de70'
and ( recipientemail = 'ype.duhoux@albemarle.com;'
or recipientemail = 'monique.bourgondien@eyeon.nl'
or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
or recipientemail = 'geert.scheepers@newayselectronics.com'
or recipientemail = 'jlmv@lundbeck.com'
or recipientemail = 'tmolijn@bacardi.com'
or recipientemail = 'wilma.lork@covestro.com'
or recipientemail = 'anja.stienen@bayer.com');

-- No emails sent with this applicationid

select distinct recipientemail
from mailgun.mailguncube
where ( recipientemail = 'ype.duhoux@albemarle.com'
or recipientemail = 'monique.bourgondien@eyeon.nl'
or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
or recipientemail = 'geert.scheepers@newayselectronics.com'
or recipientemail = 'jlmv@lundbeck.com'
or recipientemail = 'tmolijn@bacardi.com'
or recipientemail = 'wilma.lork@covestro.com'
or recipientemail = 'anja.stienen@bayer.com')
and applicationid is not null;



select *
from mailgun.mailguncube
where recipientemail = 'ype.duhoux@albemarle.com';

select *
from authdb_applications
where --lower(applicationid) = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
 lower(applicationid) = '170d682c-39b6-49a5-8c62-679b9fe4de70';


select case
          when subject like '%sent you a message from  app%' then 'Message Sent From App'
          else subject
       end as subject
     , count(*)
from mailgun.mailguncube
where applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
group by 1
order by 2 desc;


select recipientemail
     , case
          when subject like '%sent you a message from  app%' then 'Message Sent From App'
          else subject
       end as subject
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and ( recipientemail = 'ype.duhoux@albemarle.com'
or recipientemail = 'monique.bourgondien@eyeon.nl'
or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
or recipientemail = 'geert.scheepers@newayselectronics.com'
or recipientemail = 'jlmv@lundbeck.com'
or recipientemail = 'tmolijn@bacardi.com'
or recipientemail = 'wilma.lork@covestro.com'
or recipientemail = 'anja.stienen@bayer.com')
group by 1,(case when subject like '%sent you a message from  app%' then 'Message Sent From App' else subject end)
order by 1,(case when subject like '%sent you a message from  app%' then 'Message Sent From App' else subject end);



select recipientemail
     , recipientemaildomain
     , case
          when subject like '%sent you a message from  app%' then 'Message Sent From App'
          else subject
       end as subject
     , senderemail
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and ( recipientemail = 'ype.duhoux@albemarle.com'
or recipientemail = 'monique.bourgondien@eyeon.nl'
or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
or recipientemail = 'geert.scheepers@newayselectronics.com'
or recipientemail = 'jlmv@lundbeck.com'
or recipientemail = 'tmolijn@bacardi.com'
or recipientemail = 'wilma.lork@covestro.com'
or recipientemail = 'anja.stienen@bayer.com')
group by 1,2,3,4
order by 1,2,3,4;





select recipientemaildomain
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then 'Message Sent'
          when lower(subject) like '%today at%' then 'Today At'
          when lower(subject) like '%welcome to%' or lower(subject) like '%bienvenido%' then 'Welcome'
          when lower(subject) like '%password reset%' or lower(subject) like '%restablecer%' then 'Password Reset'
          when lower(subject) like '%exhibitor opportunity%' then 'Exhibitor Opportunity'
          when lower(subject) like '%granted access%doubledutch cms%' then 'CMS Access Grant'
          else subject
       end as subject
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain in (select distinct recipientemaildomain
                               from mailgun.mailguncube
                               where ( recipientemail = 'ype.duhoux@albemarle.com'
or recipientemail = 'monique.bourgondien@eyeon.nl'
or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
or recipientemail = 'geert.scheepers@newayselectronics.com'
or recipientemail = 'jlmv@lundbeck.com'
or recipientemail = 'tmolijn@bacardi.com'
or recipientemail = 'wilma.lork@covestro.com'
or recipientemail = 'anja.stienen@bayer.com'))
group by 1,2,3
order by 1,2,3;


select extract(month from first_delivered_timestamp) as month
     , count(*)
from mailgun.mailguncube
where lower(subject) like '%password reset%'
and senderemail = 'support@doubledutch.me'
and first_delivered_timestamp is not null
group by 1
order by 1;

-- Sometime in July the last password reset email was sent with support@doubledutch.me

select extract(month from first_delivered_timestamp) as month
     , count(*)
from mailgun.mailguncube
where lower(subject) like '%password reset%'
and senderemail = 'attendeesupport@doubledutch.me'
and first_delivered_timestamp is not null
group by 1
order by 1;

-- Sometime in June the first password reset email was sent with from attendeesupport@doubledutch.me

-- Password Reset for all Domains (No Issues from First Glance)

select recipientemaildomain
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , count(distinct applicationid) as eventcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain in (select distinct recipientemaildomain
                               from mailgun.mailguncube
                               where ( recipientemail = 'ype.duhoux@albemarle.com'
                                       or recipientemail = 'monique.bourgondien@eyeon.nl'
                                       or recipientemail = 'kim.vanbroekhoven@eyeon.nl'
                                       or recipientemail = 'geert.scheepers@newayselectronics.com'
                                       or recipientemail = 'jlmv@lundbeck.com'
                                       or recipientemail = 'tmolijn@bacardi.com'
                                       or recipientemail = 'wilma.lork@covestro.com'
                                       or recipientemail = 'anja.stienen@bayer.com'))
and senderemail = 'attendeesupport@doubledutch.me'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2
order by 1,2;


-- lundbeck.com

select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'lundbeck.com'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 1,5,6,2,3;


select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'lundbeck.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;

-- eyeon.nl

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'eyeon.nl'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'eyeon.nl'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;


-- covestro.com

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'covestro.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'covestro.com'
--and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;


select *
from mailgun.mailguncube
where recipientemail = 'wilma.lork@covestro.com';


-- bayer.com

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'bayer.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'bayer.com'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'bayer.com'
and senderemail = 'attendeesupport@doubledutch.me'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 1,5,6,2,3;


-- bacardi.com

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'bacardi.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'bacardi.com'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;


select *
from mailgun.mailguncube
where recipientemail = 'lvdboomen@bacardi.com'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318';


select *
from mailgun.mailgun_events
where messageid = '20151111090826.33534.19380@doubledutch.me';


-- albemarle.com

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'albemarle.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'albemarle.com'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;

select *
from mailgun.mailguncube
where recipientemail = 'ype.duhoux@albemarle.com';

-- newayselectronics.com

select recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'newayselectronics.com'
and senderemail = 'attendeesupport@doubledutch.me'
--and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3
order by 1,4,5,2,3;


select recipientemail
     , recipientemaildomain
     , applicationid
     , case
          when lower(subject) like '%sent you a message%' or lower(subject) like '%message sent%' then null
          else senderemail
       end as senderemail
     , min(first_delivered_timestamp) as first_delivered
     , max(first_delivered_timestamp) as last_delivered
     , count(distinct recipientemail) as recipientcnt
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailgun.mailguncube
where recipientemaildomain = 'newayselectronics.com'
and senderemail = 'attendeesupport@doubledutch.me'
and applicationid = '8d97e50f-18c4-49de-a23e-c18bb3fc9318'
and (lower(subject) like '%password reset%' or lower(subject) like '%restablecer%')
group by 1,2,3,4
order by 5,6;