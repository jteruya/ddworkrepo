-- All Events (through 5/27)
select datebucketdesc
     , count(*) as total_events	
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
     , count(case when openevent = 0 then 1 else null end) as closed_events
     , count(case when sentflag = 1 and openevent = 0 then 1 else null end) as closed_event_welcome_email_sent
     , cast(cast(count(case when sentflag = 1 and openevent = 0 then 1 else null end) as decimal(10,4))/cast(count(case when openevent = 0 then 1 else null end) as decimal(10,4)) as decimal(10,4)) as closed_event_welcome_email_sent_pct
from (select a.applicationid
           , a.name
           , a.eventtype
           , a.openevent
           , case
               when a.startdate <= '2012-12-31' then '2012 and Before'
               when a.startdate >= '2013-01-01' and a.startdate <= '2013-12-31' then '2013 Events'
               when a.startdate >= '2014-01-01' and a.startdate <= '2014-12-31' then '2014 Events'
               when a.startdate >= '2015-01-01' and a.startdate <= '2015-05-25' then '2015 Events (thru 5/25)'
             end as datebucketdesc
           , a.enddate
           , case
               when b.applicationid is not null then 1	
               else 0	
             end as sentflag
      from (select * from kevin.tm_eventcubesummary where startdate <= '2015-05-25') a
      left join (select distinct applicationid 
                 from mailgun.events 
                 where (subject like 'Welcome to %' or subject like 'Bienvenido %') 
                 and (eventstatus = 'delivered' or eventstatus = 'accepted')) b
      on a.applicationid = b.applicationid) a
group by datebucketdesc
order by datebucketdesc;

-- All Events (Variable Start Date - 5/21)
select datebucketdesc
     , count(*) as total_events	
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
     , count(case when openevent = 0 then 1 else null end) as closed_events
     , count(case when sentflag = 1 and openevent = 0 then 1 else null end) as closed_event_welcome_email_sent
     , cast(cast(count(case when sentflag = 1 and openevent = 0 then 1 else null end) as decimal(10,4))/cast(count(case when openevent = 0 then 1 else null end) as decimal(10,4)) as decimal(10,4)) as closed_event_welcome_email_sent_pct
from (select a.applicationid
           , a.name
           , a.eventtype
           , a.openevent
           , case
               when a.startdate <= '2012-12-31' then '2012 and Before'
               when a.startdate >= '2013-01-01' and a.startdate <= '2013-12-31' then '2013 Events'
               when a.startdate >= '2014-01-01' and a.startdate <= '2014-12-31' then '2014 Events'
               when a.startdate >= '2015-01-01' and a.startdate <= '2015-05-25' then '2015 Events (5/18 thru 5/25)'
             end as datebucketdesc
           , a.enddate
           , case
               when b.applicationid is not null then 1	
               else 0	
             end as sentflag
      from (select * from kevin.tm_eventcubesummary where startdate >= '2015-05-18' and startdate <= '2015-05-25') a
      left join (select distinct applicationid 
                 from mailgun.events 
                 where (subject like 'Welcome to %' or subject like 'Bienvenido %') 
                 and (eventstatus = 'delivered' or eventstatus = 'accepted')) b
      on a.applicationid = b.applicationid) a
group by datebucketdesc
order by datebucketdesc;


