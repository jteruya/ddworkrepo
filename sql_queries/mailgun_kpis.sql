create schema mailgun;

create table mailgun.mailguncube as (select * from public.mailguncube);

select count(*)
from mailgun.mailguncube;

--7773025
--7784426

select count(*)
from public.mailguncube_20151104;

--7773025

drop index ndx_mailguncube_application_id;

truncate table public.mailguncube_20151023;
drop table public.mailguncube_20151023;

alter table public.mailguncube rename to mailguncube_20151104;

create index ndx_mailguncube_application_id on mailgun.mailguncube (applicationid);


select *
from mailgun.agg_mailgunstatus_per_applicationid;

select *
from mailgun.agg_mailgunstatus_per_recipientemaildomain;

-- create aggregates at domain level

drop table if exists agg_mailgun_status_per_recipientemaildomain;
create table agg_mailgunstatus_per_recipientemaildomain as
select mailguncube.recipientemaildomain
     , count(case when accepted_flag = true then 1 else null end) as accepted
     , count(case when rejected_flag = true then 1 else null end) as rejected
     , count(case when delivered_flag = true then 1 else null end) as delivered
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed               
     , count(case when opened_flag = true then 1 else null end) as opened
     , count(case when clicked_flag = true then 1 else null end) as clicked
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed
     , count(case when complained_flag = true then 1 else null end) as complained
     , count(case when stored_flag = true then 1 else null end) as stored
from mailgun.mailguncube mailguncube
group by mailguncube.recipientemaildomain;


-- create aggregates at event level

drop table if exists agg_mailgun_status_per_applicationid;
create table agg_mailgunstatus_per_applicationid as
select mailguncube.applicationid
     , case
          when events.eventtype = '' or events.eventtype is null then 'No Event Type'
          else events.eventtype
       end as eventtype
     , events.startdate
     , events.enddate
     , count(case when accepted_flag = true then 1 else null end) as accepted
     , count(case when rejected_flag = true then 1 else null end) as rejected
     , count(case when delivered_flag = true then 1 else null end) as delivered
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed               
     , count(case when opened_flag = true then 1 else null end) as opened
     , count(case when clicked_flag = true then 1 else null end) as clicked
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed
     , count(case when complained_flag = true then 1 else null end) as complained
     , count(case when stored_flag = true then 1 else null end) as stored
from mailgun.mailguncube mailguncube
join authdb_applications events
on mailguncube.applicationid = events.applicationid::uuid
group by mailguncube.applicationid, events.eventtype, events.startdate, events.enddate;


-- create aggregates at domain/subject (or type) level



-- create aggregates at event/subject (or type) level




/* Across Event Type for 1 month */

select label.eventtype
     , coalesce(stats.accepted,0) as accepted
     , coalesce(stats.rejected,0) as rejected
     , coalesce(stats.delivered,0) as delivered
     , coalesce(stats.failed,0) as failed
     , coalesce(stats.opened,0) as opened
     , coalesce(stats.clicked,0) as clicked
     , coalesce(stats.unsubscribed,0) as unsubscribed
     , coalesce(stats.complained,0) as complained
     , coalesce(stats.stored,0) as stored
from (select distinct case
                when eventtype is null or eventtype = '' then 'No Event Type'
                else eventtype
             end as eventtype
      from authdb_applications 
      order by eventtype) label
left join (select mailguncube.applicationid
                , events.eventtype
                , count(case when accepted_flag = true then 1 else null end) as accepted
                , count(case when rejected_flag = true then 1 else null end) as rejected
                , count(case when delivered_flag = true then 1 else null end) as delivered
                , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed               
                , count(case when opened_flag = true then 1 else null end) as opened
                , count(case when clicked_flag = true then 1 else null end) as clicked
                , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed
                , count(case when complained_flag = true then 1 else null end) as complained
                , count(case when stored_flag = true then 1 else null end) as stored
           from (select applicationid
                      , startdate
                      , enddate 
                      , case
                           when eventtype is null or eventtype = '' then 'No Event Type'
                           else eventtype
                        end as eventtype
                 from authdb_applications) events
           join mailgun.mailguncube mailguncube
           on mailguncube.applicationid = events.applicationid::uuid
           left join eventcube.testevents testevents
           on events.applicationid = testevents.applicationid
           where testevents.applicationid is null
           and events.startdate >= current_date - interval '1' month
           and events.startdate < current_date
           and events.startdate is not null
           group by mailguncube.applicationid, events.eventtype) stats
on label.eventtype = stats.eventtype;           


/* Across Event Type */
select monthyeareventtype.eventtype
     , monthyeareventtype.yyyy_mm
     , coalesce(stats.accepted_count,0) as accepted_count
     , coalesce(stats.rejected_count,0) as rejected_count
     , coalesce(stats.delivered_count,0) as delivered_count
     , coalesce(stats.failed_count,0) as failed_count
     , coalesce(stats.opened_count,0) as opened_count
     , coalesce(stats.clicked_count,0) as clicked_count
     , coalesce(stats.unsubscribed_count,0) as unsubscribed_count
     , coalesce(stats.complained_count,0) as complained_count
     , coalesce(stats.stored_count,0) as stored_count
from (select monthyear.yyyy_mm
           , eventtype.eventtype
      from (select cast(extract(year from current_date - interval '5' month) as int) || '-' || case when cast(extract(month from current_date - interval '5' month) as int) < 10 then '0' else '' end || cast(extract(month from current_date - interval '5' month) as int) as yyyy_mm
            union 
            select cast(extract(year from current_date - interval '4' month) as int) || '-' || case when cast(extract(month from current_date - interval '4' month) as int) < 10 then '0' else '' end || cast(extract(month from current_date - interval '4' month) as int) as yyyy_mm
            union 
            select cast(extract(year from current_date - interval '3' month) as int) || '-' || case when cast(extract(month from current_date - interval '3' month) as int) < 10 then '0' else '' end || cast(extract(month from current_date - interval '3' month) as int) as yyyy_mm
            union 
            select cast(extract(year from current_date - interval '2' month) as int) || '-' || case when cast(extract(month from current_date - interval '2' month) as int) < 10 then '0' else '' end || cast(extract(month from current_date - interval '2' month) as int) as yyyy_mm
            union
            select cast(extract(year from current_date - interval '1' month) as int) || '-' || case when cast(extract(month from current_date - interval '1' month) as int) < 10 then '0' else '' end || cast(extract(month from current_date - interval '1' month) as int) as yyyy_mm
            union  
            select cast(extract(year from current_date) as int) || '-' || cast(extract(month from current_date) as int) as yyyy_mm) monthyear
      join (select distinct case
                               when eventtype is null or eventtype = '' then 'No Event Type'
                               else eventtype
                            end as eventtype
            from authdb_applications) eventtype
      on 1 = 1) monthyeareventtype
left join (select cast(extract(year from events.startdate) as int) || '-' || case when cast(extract(month from events.startdate) as int) < 10 then '0' else '' end || cast(extract(month from events.startdate) as int) as yyyy_mm
                , events.eventtype
                , count(case when accepted_flag = true then 1 else null end) as accepted_count
                , count(case when rejected_flag = true then 1 else null end) as rejected_count
                , count(case when delivered_flag = true then 1 else null end) as delivered_count
                , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed_count                
                , count(case when opened_flag = true then 1 else null end) as opened_count
                , count(case when clicked_flag = true then 1 else null end) as clicked_count 
                , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed_count
                , count(case when complained_flag = true then 1 else null end) as complained_count
                , count(case when stored_flag = true then 1 else null end) as stored_count    
           from (select applicationid
                      , startdate
                      , enddate 
                      , case
                           when eventtype is null or eventtype = '' then 'No Event Type'
                           else eventtype
                        end as eventtype
                 from authdb_applications) events
           join mailguncube mailguncube
           on mailguncube.applicationid = events.applicationid::uuid
           left join eventcube.testevents testevents
           on events.applicationid = testevents.applicationid
           where testevents.applicationid is null
           and events.startdate >= current_date - interval '6' month
           and events.startdate < current_date
           and events.startdate is not null
           group by yyyy_mm, events.eventtype) stats
on monthyeareventtype.yyyy_mm = stats.yyyy_mm and monthyeareventtype.eventtype = stats.eventtype
order by monthyeareventtype.yyyy_mm, monthyeareventtype.eventtype;


/* Across Registration Type */
select cast(extract(year from events.startdate) as int) || '-' || case when cast(extract(month from events.startdate) as int) < 10 then '0' else '' end || cast(extract(month from events.startdate) as int) as yyyy_mm
     , case
         when events.canregister = 'true' then 'Open Event'
         else 'Closed Event'
       end as registration_type
     , count(case when accepted_flag = true then 1 else null end) as accepted_count
     , count(case when rejected_flag = true then 1 else null end) as rejected_count
     , count(case when delivered_flag = true then 1 else null end) as delivered_count
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed_count                
     , count(case when opened_flag = true then 1 else null end) as opened_count
     , count(case when clicked_flag = true then 1 else null end) as clicked_count 
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed_count
     , count(case when complained_flag = true then 1 else null end) as complained_count
     , count(case when stored_flag = true then 1 else null end) as stored_count    
from (select applicationid
           , startdate
           , enddate 
           , canregister
      from authdb_applications) events
join mailguncube mailguncube
on mailguncube.applicationid = events.applicationid::uuid
left join eventcube.testevents testevents
on events.applicationid = testevents.applicationid
where testevents.applicationid is null
and events.startdate >= current_date - interval '6' month
and events.startdate < current_date
and events.startdate is not null
group by yyyy_mm, events.canregister
order by yyyy_mm, events.canregister;





select count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when rejected_flag = true then 1 else null end) as rejectedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as unsubscribedcnt
     , count(case when complained_flag = true then 1 else null end) as complainedcnt
     , count(case when stored_flag = true then 1 else null end) as storedcnt
from mailguncube;

-- 7548453 (total messages)
-- 7484312 (accepted count)
-- 64141 (diff)

select count(*)
from mailguncube
where accepted_flag = false;
--64,141 <- same as diff

-- Investigate all records where accepted_flag = false
-- Universe: 64,141 messages

select count(*)
     , count(case when recipientemail is null then 1 else null end) as nullrecipientemailcnt
     , count(case when applicationid is null then 1 else null end) as nullapplicationidcnt
     , count(case when senderemail is null then 1 else null end) as nullsenderemailcnt
     , count(case when subject is null then 1 else null end) as nullsubjectcnt
from mailguncube
where accepted_flag = false;

-- Null Recipient Email: 31,316
-- Null Sender Email: 31,316
-- Null Subject: 31,316
-- Null ApplicationId: 112

select count(*)
     , count(case when recipientemail is null then 1 else null end) as nullrecipientemailcnt
     , count(case when applicationid is null then 1 else null end) as nullapplicationidcnt
     , count(case when senderemail is null then 1 else null end) as nullsenderemailcnt
     , count(case when subject is null then 1 else null end) as nullsubjectcnt
from mailguncube
where accepted_flag = false;

-- Prove that 31,316 records have no subject, recipientemail and senderemail
select count(*)
from mailguncube
where accepted_flag = false
and recipientemail is null
and senderemail is null
and subject is null;

-- 31,316


select count(*) as totalcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , max(first_delivered_timestamp) as last_delivered_timestamp
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , max(first_failed_timestamp) as last_failed_timestamp     
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , max(first_opened_timestamp) as last_opened_timestamp
     , count(case when clicked_flag = true then 1 else null end) as unsubscribedcnt
     , max(first_clicked_timestamp) as last_clicked_timestamp
     , count(case when complained_flag = true then 1 else null end) as complainedcnt
     , max(first_complained_timestamp) as last_complained_timestamp
     , count(case when stored_flag = true then 1 else null end) as storedcnt
     , max(first_stored_timestamp) as last_stored_timestamp
from mailguncube
where accepted_flag = false;
-- all in october

select *
from mailguncube
where accepted_flag = false
and extract(month from first_delivered_timestamp) = 10;



