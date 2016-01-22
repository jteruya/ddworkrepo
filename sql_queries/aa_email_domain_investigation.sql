select *
from mailgun.agg_status_per_domain 
where recipientemaildomain = 'aa.com';


select a.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , count(distinct recipientemail) as recipientcnt
from mailgun.mailguncube a
left join authdb_applications b
on a.applicationid = b.applicationid::uuid
where a.recipientemaildomain = 'aa.com'
group by a.applicationid, b.name, b.startdate, b.enddate
order by b.startdate, b.enddate;

-- Null Application ID
-- Connections 365 App (this could be an error as there are other records with applicationid)

select *
from mailgun.mailguncube
where recipientemaildomain = 'aa.com'
and applicationid is null;

select *
from mailgun_events
where messageid = '20150922221900.94125.40039@doubledutch.me';

-- EU Event

select *
from mailgun.mailguncube
where recipientemaildomain = 'aa.com'
and applicationid = '48b0c33a-9f44-4160-a248-7018e53d1cc1';


-- Unique Recipients and Events
select applicationid
     , name
     , startdate
     , enddate
     , row_number() over (partition by applicationid order by recipientname) as recipientnum
     , recipientname
     , recipientemail
from (select distinct a.applicationid
           , b.name
           , b.startdate
           , b.enddate
           , a.recipientname
           , a.recipientemail
      from mailgun.mailguncube a
      left join authdb_applications b
      on a.applicationid = b.applicationid::uuid
      where a.recipientemaildomain = 'aa.com') a
order by startdate, enddate, recipientname;


-- RallyOn, Becky Marnell
select *
from mailgun.mailguncube
where applicationid = '6b6bb985-1d7c-4572-898e-80955d05e12c'
and recipientemail = 'becky.marnell@aa.com';



select *
from integrations.implementation__c
where lower(sf_event_id_cms__c) = '48b0c33a-9f44-4160-a248-7018e53d1cc1';

select count(distinct applicationid) as eventcnt
     , count(distinct recipientemail) as recipientcnt
from mailgun.mailguncube
where applicationid is not null
and recipientemaildomain = 'aa.com';


