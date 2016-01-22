select *
from mailguncube where recipientemail like '%steffany@saucelabs.com%';

select *
from mailguncube 
where subject = 'Today at DevOps Enterprise Summit 2015'
and cast(first_delivered_timestamp as date) = '2015-10-21';


select *
from mailgun_events
where (messageid = '20151020011128.3279.36787@doubledutch.me'
or messageid = '20151019200730.7256.92787@doubledutch.me'
or messageid = '20151019195110.75245.14768@doubledutch.me')
and eventstatus = 'clicked';


select *
from mailguncube 
where messageid = '20151020011128.3279.36787@doubledutch.me';



select a.messageid
     , to_timestamp(a.eventtimestamp/1000)
from mailgun_events a
join mailguncube b
where eventstatus = 'clicked'
and clickurl like '%unsubscribe%';


create temp table email_investigation_unsubscribed_messages as
select a.messageid
     , a.applicationid
     , case
         when position('<' in a.recipientemail) <> 0 and position('>' in a.recipientemail) <> 0 and a.recipientemail is not null
         then lower(substring(a.recipientemail from (position('<' in a.recipientemail) + 1) for (position('>' in a.recipientemail) - position('<' in a.recipientemail) - 1)))
         else lower(a.recipientemail)
        end as recipientemail
     , a.subject
     , a.first_accepted_timestamp
     , a.first_delivered_timestamp
     , a.first_opened_timestamp
     , a.first_clicked_timestamp
     , to_timestamp(min(b.eventtimestamp)/1000) as unsubscribe_datetm
from mailguncube a
join mailgun_events b
on a.messageid = b.messageid
where b.eventstatus = 'clicked'
and b.clickurl like '%unsubscribe%'
group by 1,2,3,4,5,6,7,8;


--drop table email_investigation_mailguncubeclean;
create temp table email_investigation_mailguncubeclean as
select messageid
     , subject
     , applicationid
     , recipientemail
     , recipientname
     , cleanrecipientemail
     , case
          when position('@' in cleanrecipientemail) > 0 and cleanrecipientemail is not null
          then substring(cleanrecipientemail from (position('@' in cleanrecipientemail) + 1) for (length(cleanrecipientemail) - position('@' in cleanrecipientemail)))
          else null
       end as emaildomain
     , first_accepted_timestamp
     , first_delivered_timestamp
     , first_opened_timestamp
     , first_clicked_timestamp
from (select messageid
           , subject
           , applicationid
           , recipientemail
           , case
                when position('" <' in recipientemail) > 0 and recipientemail is not null
                then trim(lower(substring(recipientemail from (position('" <' in recipientemail) + 3) for (length(trim(recipientemail)) - position('" <' in recipientemail) - 3))))
                else lower(recipientemail)
             end as cleanrecipientemail
           , case
                when position('" <' in recipientemail) > 0 and recipientemail is not null
                then trim(lower(substring(recipientemail from 2 for position('" <' in recipientemail) - 2)))
                else null
             end as recipientname
           , first_accepted_timestamp
           , first_delivered_timestamp
           , first_opened_timestamp
           , first_clicked_timestamp
      from mailguncube) a;

drop table email_investigation_mailguncube_emailsent;
create temp table email_investigation_mailguncube_emailsent as
select b.*
     , a.messageid as unsubscribed_messageid
     , a.applicationid as unsubscribed_applicationid
     , a.subject as unsubscribed_subject
     , a.unsubscribe_datetm
     , b.first_accepted_timestamp - unsubscribe_datetm as day_diff
from email_investigation_unsubscribed_messages a
join email_investigation_mailguncubeclean b
on a.recipientemail = b.cleanrecipientemail
and a.applicationid = b.applicationid
left join eventcube.testevents c
on a.applicationid = c.applicationid::uuid
where a.unsubscribe_datetm < b.first_accepted_timestamp
and c.applicationid is null;

select *
from eventcube.testevents limit 10;


select *
from email_investigation_mailguncube_emailsent
where emaildomain <> 'doubledutch.me'
order by day_diff desc;





select *
     , to_timestamp(eventtimestamp/1000)
from mailgun_events
where messageid = '20150501100108.124202.53825@doubledutch.me'
order by eventtimestamp;

select * 
     , to_timestamp(eventtimestamp/1000)
from mailgun_events
where messageid = '20150625160157.29949.92693@doubledutch.me'
order by eventtimestamp;








select count(*)
from mailgun_events
where eventstatus = 'clicked'
and clickurl like '%unsubscribe%';
--9298

select count(*)
from mailgun_events
where eventstatus = 'clicked'
and clickurl like 'http://doubledutch.me/unsubscribe/%';
--9298





drop table mailguncube_delta;
create temporary table mailguncube_delta as
select a.messageid
     , a.applicationid
     , b.maxeventtimestamp
     , min(a.recipientemail) as origrecipientemailtxt
     , case
          when position('" <' in min(recipientemail)) > 0 and min(recipientemail) is not null
          then trim(lower(substring(min(recipientemail) from (position('" <' in min(recipientemail)) + 3) for (length(trim(min(recipientemail))) - position('" <' in min(recipientemail)) - 3))))
          else lower(min(recipientemail))
       end as recipientemail
     , case
          when position('" <' in min(recipientemail)) > 0 and position('@' in min(recipientemail)) > position('" <' in min(recipientemail)) and min(recipientemail) is not null
          then lower(substring(min(recipientemail) from (position('@' in min(recipientemail)) + 1) for (length(min(recipientemail)) - position('@' in min(recipientemail)) - 1)))
          else null
       end as recipientemaildomain
     , case
          when position('" <' in min(recipientemail)) > 0 and min(recipientemail) is not null
          then upper(lower(substring(min(recipientemail) from 2 for position('" <' in min(recipientemail)) - 2)))
          else null
       end as recipientname
     , min(a.senderemail) as origsenderemailtxt
     , case
          when position('" <' in min(senderemail)) > 0 and min(senderemail) is not null
          then trim(lower(substring(min(senderemail) from (position('" <' in min(senderemail)) + 3) for (length(trim(min(senderemail))) - position('" <' in min(senderemail)) - 3))))
          else lower(min(senderemail))
       end as senderemailemail
     , case
          when position('" <' in min(senderemail)) > 0 and position('@' in min(senderemail)) > position('" <' in min(senderemail)) and min(senderemail) is not null
          then lower(substring(min(senderemail) from (position('@' in min(senderemail)) + 1) for (length(min(senderemail)) - position('@' in min(senderemail)) - 1)))
          else null
       end as senderemaildomain
     , case
          when position('" <' in min(senderemail)) > 0 and min(senderemail) is not null
          then upper(lower(substring(min(senderemail) from 2 for position('" <' in min(senderemail)) - 2)))
          else null
       end as sendername
     , min(a.subject) as subject
     , min(case when a.eventstatus = 'accepted' then to_timestamp(a.eventtimestamp/1000) else null end) as first_accepted_timestamp
     , min(case when a.eventstatus = 'rejected' then to_timestamp(a.eventtimestamp/1000) else null end) as first_rejected_timestamp
     , min(case when a.eventstatus = 'delivered' then to_timestamp(a.eventtimestamp/1000) else null end) as first_delivered_timestamp
     , min(case when a.eventstatus = 'failed' then to_timestamp(a.eventtimestamp/1000) else null end) as first_failed_timestamp
     , min(case when a.eventstatus = 'opened' then to_timestamp(a.eventtimestamp/1000) else null end) as first_opened_timestamp
     , min(case when a.eventstatus = 'clicked' and a.clickurl not like 'http://doubledutch.me/unsubscribe/%' then to_timestamp(a.eventtimestamp/1000) else null end) as first_clicked_timestamp
     , min(case when a.eventstatus = 'unsubscribed' or (a.eventstatus = 'clicked' and a.clickurl like 'http://doubledutch.me/unsubscribe/%') then to_timestamp(a.eventtimestamp/1000) else null end) as first_unsubscribed_timestamp
     , min(case when a.eventstatus = 'complained' then to_timestamp(a.eventtimestamp/1000) else null end) as first_complained_timestamp
     , min(case when a.eventstatus = 'stored' then to_timestamp(a.eventtimestamp/1000) else null end) as first_stored_timestamp
from (select * from public.mailgun_events where eventtimestamp > (select coalesce(max(eventtimestamp_created), 0) as maxeventtimestamp from public.mailguncube)) a
join (select max(eventtimestamp) as maxeventtimestamp from public.mailgun_events) b
on 1 = 1
group by a.messageid, a.applicationid, b.maxeventtimestamp;








alter table public.mailguncube rename to mailguncube_20151023;


create table public.mailguncube (
     messageid varchar
   , applicationid uuid
   , recipientemail varchar
   , recipientemaildomain varchar
   , recipientname varchar
   , senderemail varchar
   , senderemaildomain varchar
   , sendername varchar
   , subject varchar
   , accepted_flag boolean
   , rejected_flag boolean
   , delivered_flag boolean
   , failed_flag boolean
   , opened_flag boolean
   , clicked_flag boolean
   , unsubscribed_flag boolean
   , complained_flag boolean
   , stored_flag boolean
   , first_accepted_timestamp timestamp
   , first_rejected_timestamp timestamp
   , first_delivered_timestamp timestamp
   , first_failed_timestamp timestamp
   , first_opened_timestamp timestamp
   , first_clicked_timestamp timestamp
   , first_unsubscribed_timestamp timestamp
   , first_complained_timestamp timestamp
   , first_stored_timestamp timestamp
   , eventtimestamp_created bigint
   , eventtimestamp_updated bigint);

-- create index on applicationid
create index ndx_mailguncube_application_id on mailguncube (applicationid);
