-- Percentage All Time
-- Run on 5/22/2015
-- Total: 2,738
-- Welcome Emails Sent: 2,113
-- Welcome Email Sent Percent: 0.7717

select count(*) as total_events	
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 0 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.startdate
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate < '2015-05-21') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created < '2015-05-21'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a;	


-- 2013 Welcome Email Percentages
-- Results from Run on 5/22/2015
-- Total: 55
-- Welcome Emails Sent: 55
-- Welcome Email Sent Percentage: 1.0000

select count(*) as total_events	
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 0 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.startdate
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate < '2013-01-01') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created < '2013-01-01'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a;	


-- 2013 Welcome Email Percentages
-- Results from Run on 5/22
-- Total Events: 357
-- Welcome Emails Sent: 357
-- Welcome Email Sent Percentage: 1.0000
select count(*) as total_events	
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 0 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.startdate
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate >= '2013-01-01' and startdate <= '2013-12-31') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created >= '2013-01-01'
                 and created <= '2013-12-31'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a;


-- 2014 Welcome Email Percentages
-- Results from Run on 5/22
-- Total Events: 1368
-- Welcome Emails Sent: 1341
-- Welcome Email Sent Percentage: 0.9803
select count(*) as total_events	
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 0 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.startdate
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate >= '2014-01-01' and startdate <= '2014-12-31') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created >= '2014-01-01'
                 and created <= '2014-12-31'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a;


-- 2015 Welcome Email Percentages
-- Results from Run on 5/22
-- Total Events: 959
-- Welcome Emails Sent: 435
-- Welcome Email Sent Percentage: .4536

select count(*) as total_events	
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 0 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.startdate
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate >= '2015-01-01' and startdate <= '2015-05-21') b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created >= '2015-01-01'
                 and created <= '2015-05-21'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a;      


/* ALL SQL ABOVE IS WRONG BECAUSE OF SENTFLAG.
   THIS IS CORRECTED WITH THE SQL BELOW. */
      
      
-- New SQL that buckets all categories at once.
-- Takes into account email events across years.
-- Also, sentflag correction which was inverted (i should have been looking for sentflag = 1).
-- Results from Run on 5/22
-- 2012 and Before: 55, 0, 0.0000
-- 2013 Events: 357, 1, 0.0028
-- 2014 Events: 1368, 95, 0.0694
-- 2015 Events (thru 5/21): 959, 530, 0.5527
select datebucketdesc
     , count(*) as total_events	
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
           , case
               when b.startdate <= '2012-12-31' then '2012 and Before'
               when b.startdate >= '2013-01-01' and b.startdate <= '2013-12-31' then '2013 Events'
               when b.startdate >= '2014-01-01' and b.startdate <= '2014-12-31' then '2014 Events'
               when b.startdate >= '2015-01-01' and b.startdate <= '2015-05-21' then '2015 Events (thru 5/21)'
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate <= '2015-05-21' and openevent = 0) b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created <= '2015-05-21'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a
group by datebucketdesc;
     


-- average Adoption Rates for Closed Reg Events for everything before 5/21.
-- sent flag is set correctly.
-- Results from Run on 5/22
select distinct datebucketdesc
     , count(*) over (partition by datebucketdesc) as total_events	
     
     , count(case when sentflag = 1 then 1 else null end) over (partition by datebucketdesc) as welcome_email_sent
     , avg(case when sentflag = 1 then adoption else null end) over (partition by datebucketdesc) as average_adoption_when_welcome_sent
     
     , count(case when sentflag = 0 then 1 else null end) over (partition by datebucketdesc) as welcome_email_not_sent
     , avg(case when sentflag = 0 then adoption else null end) over (partition by datebucketdesc) as average_adoption_when_welcome_not_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) over (partition by datebucketdesc) as decimal(10,4))/cast(count(*) over (partition by datebucketdesc) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct
from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.adoption
           , case
               when b.startdate <= '2012-12-31' then '2012 and Before (Closed Reg Events)'
               when b.startdate >= '2013-01-01' and b.startdate <= '2013-12-31' then '2013 Events (Closed Reg Events)'
               when b.startdate >= '2014-01-01' and b.startdate <= '2014-12-31' then '2014 Events (Closed Reg Events)'
               when b.startdate >= '2015-01-01' and b.startdate <= '2015-05-21' then '2015 Events (Closed Reg Events thru 5/21)'
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
      join (select * from reportingdb.dbo.eventcubesummary where startdate <= '2015-05-21' and openevent = 0) b	
      on a.applicationid = b.applicationid	
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'	
                 and created <= '2015-05-21'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a
order by datebucketdesc;


-- New SQL that buckets only those events in the mailgun time window.
-- Takes into account email events across years.
-- Also, sentflag correction which was inverted (i should have been looking for sentflag = 1).
-- Results from Run on 5/22
-- datebucketdesc: Mailgun 4/16 - 5/21
-- total_events: 337
-- welcome_email_sent: 192
-- average adoption when welcome sent: 0.559856620417
-- welcome email not sent: 145
-- average adoption when welcome not sent: 0.386465001478
-- welcome email sent percent 0.5697

select datebucketdesc
     , count(*) as total_events	
     
     , count(case when sentflag = 1 then 1 else null end) as welcome_email_sent
--     , avg(case when sentflag = 1 then adoption else null end) as average_adoption_when_welcome_sent
     
     , count(case when sentflag = 0 then 1 else null end) as welcome_email_not_sent
--     , avg(case when sentflag = 0 then adoption else null end) as average_adoption_when_welcome_not_sent
     , cast(cast(count(case when sentflag = 1 then 1 else null end) as decimal(10,4))/cast(count(*) as decimal(10,4)) as decimal(10,4)) as welcome_email_sent_pct

from (select a.applicationid	
	   , b.name
	   , b.eventtype
	   , b.adoption
           , 'Mailgun 4/16 - 5/21' as datebucketdesc
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
      	
      join (select * from reportingdb.dbo.eventcubesummary 
            where startdate <= '2015-05-21' 
            and startdate >= '2015-04-16' 
            and openevent = 0)  b	
      on a.applicationid = b.applicationid	
      
      left join (select distinct applicationid	
	                       , updated 
                 from ratings.dbo.mailtemplates 	
                 where name = 'Welcome') created	
      on a.applicationid = created.applicationid	
      
      left join (select applicationid 	
	              , max(recipientscount) as max_recipients 
                 from ratings.dbo.emailevents 	
                 where emailtype = 'Welcome'
                 --and created >= '2015-04-16'	
                 and created <= '2015-05-21'	
                 group by applicationid) sent	
      on a.applicationid = sent.applicationid	
      ) a
group by datebucketdesc
order by datebucketdesc;










