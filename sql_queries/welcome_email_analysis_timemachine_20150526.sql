-- All Events (through 5/21)
select datebucketdesc
     , count(*) as total_events	
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
     , count(case when openevent = 0 then 1 else null end) as closed_events
     , count(case when sentflag = 1 and openevent = 0 then 1 else null end) as closed_event_welcome_email_sent
     , cast(cast(count(case when sentflag = 1 and openevent = 0 then 1 else null end) as decimal(10,4))/cast(count(case when openevent = 0 then 1 else null end) as decimal(10,4)) as decimal(10,4)) as closed_event_welcome_email_sent_pct
from (select a.applicationid	
             --b.applicationid
	   , b.name
	   , b.eventtype
	   , b.openevent
           , case
               when b.startdate <= '2012-12-31' then '2012 and Before'
               when b.startdate >= '2013-01-01' and b.startdate <= '2013-12-31' then '2013 Events'
               when b.startdate >= '2014-01-01' and b.startdate <= '2014-12-31' then '2014 Events'
               when b.startdate >= '2015-01-01' and b.startdate <= '2015-05-25' then '2015 Events (thru 5/25)'
             end as datebucketdesc
	   , b.enddate
	   , case
               when created.applicationid is not null then 1	
               else 0	
             end as createdflag	
	   , case
               when sent.applicationid is not null then 1	
               else 0	
             end as sentflag	
      from authdb.dbo.applications a	
      join (select * from reportingdb.dbo.eventcubesummary where startdate <= '2015-05-25') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome'
                 and enabled = 'true') created	
      on a.applicationid = created.applicationid	
      --on b.applicationid = created.applicationid
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'		
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      --on b.applicationid = sent.applicationid
      ) a
group by datebucketdesc;


-- All Events (Variable Start Date - 5/21)
select datebucketdesc
     , count(*) as total_events	
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
     , count(case when openevent = 0 then 1 else null end) as closed_events
     , count(case when sentflag = 1 and openevent = 0 then 1 else null end) as closed_event_welcome_email_sent
     , cast(cast(count(case when sentflag = 1 and openevent = 0 then 1 else null end) as decimal(10,4))/cast(count(case when openevent = 0 then 1 else null end) as decimal(10,4)) as decimal(10,4)) as closed_event_welcome_email_sent_pct
from (select a.applicationid
             --b.applicationid	
	   , b.name
	   , b.eventtype
	   , b.openevent
           , case
               when b.startdate <= '2012-12-31' then '2012 and Before'
               when b.startdate >= '2013-01-01' and b.startdate <= '2013-12-31' then '2013 Events'
               when b.startdate >= '2014-01-01' and b.startdate <= '2014-12-31' then '2014 Events'
               when b.startdate >= '2015-01-01' and b.startdate <= '2015-05-25' then '2015 Events (5/18 thru 5/25)'
             end as datebucketdesc
	   , b.enddate
	   , case
               when created.applicationid is not null then 1	
               else 0	
             end as createdflag	
	   , case
               when sent.applicationid is not null then 1	
               else 0	
             end as sentflag	
      from authdb.dbo.applications a	
      join (select * from reportingdb.dbo.eventcubesummary where startdate >= '2015-05-18' and startdate <= '2015-05-25') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome'
                 and enabled = 'true') created	
      on a.applicationid = created.applicationid	
      --on b.applicationid = created.applicationid
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'		
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid
      --on b.applicationid = sent.applicationid	
      ) a
group by datebucketdesc;

