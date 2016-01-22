--1. What % of our events send out DD Welcome Email? 

select min(first_accepted_timestamp) as first_accepted
from mailgun.mailguncube;

-- 2015-04-16 17:00:02

select *
from mailgun.mailguncube
where recipientemaildomain <> 'doubledutch.me'
and lower(subject) not like '%welcome%'
and lower(subject) not like '%bienvenido%'

and lower(subject) not like '%password%'
and lower(subject) not like '%restablecer%'

and lower(subject) not like '%today%'
and lower(subject) not like '%what''s happening%'
and lower(subject) not like '%tonight%'
and lower(subject) not like '%digest%'
and lower(subject) not like '%recap%' 
and lower(subject) not like '%others are saying%'
and lower(subject) not like '%review%'
and lower(subject) not like '%that was the day%'
and lower(subject) not like '%trending%'
and lower(subject) not like '%wrap-up%'
and lower(subject) not like '%what up%'
and lower(subject) not like '%top content%'
and lower(subject) not like '%end of the day%'
and lower(subject) not like '%hvordan synes du det går?%'

and lower(subject) not like '%sent you a message%'
and lower(subject) not like '%requested a meeting%'
 
and lower(subject) not like '%session notes%'

and lower(subject) not like '%lead scanning%' 

and lower(subject) not like '%beacon message%'

and lower(subject) not like '%viewing your profile%'
and lower(subject) not like '%people are vieweing your profile%'

and lower(subject) not like '%exhibitor opportunity%'
and lower(subject) not like '%leads report%'

and lower(subject) not like '%engagement%'

and lower(subject) not like '%profile is complete%'

and lower(subject) not like '%=?utf-8?%'

and lower(subject) not like '%cms%'

and lower(subject) not like 'fafksdfhkas'

and lower(subject) not like '%please tell us%'

and lower(subject) not like 'https://dynatrace.influitive.com/challenges/45'

and lower(subject) not like '%collateral%'

and lower(subject) not like '%dashboard%'

and lower(subject) not like 'how is the event going so far?'

and lower(subject) not like '%tak for i dag%'
;

drop table if exists jt.dp407_events;
create table jt.dp407_events as
select a.applicationid
     , a.name
     , a.eventtype
     , a.startdate
     , a.enddate
     , a.openevent
     , a.adoption
     , case
          when b.applicationid is not null then 1
          else 0
       end as welcomeemailsent
from (select *
      from eventcube.eventcubesummary
      where startdate >= '2015-04-16'
      and enddate < current_date
      and startdate is not null) a
left join (select distinct applicationid
           from mailgun.mailguncube
           where recipientemaildomain <> 'doubledutch.me'
           and applicationid is not null
           and (lower(subject) like '%welcome%' or lower(subject) like '%bienvenido%')) b
on a.applicationid::uuid = b.applicationid
order by a.startdate, a.enddate, a.applicationid;


select count(*) as totalcnt
     , count(case when welcomeemailsent = 1 then 1 else null end) as welcomeemailcnt
     , count(case when welcomeemailsent = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as welcomeemailpct
from jt.dp407_events;

-- Since 4/16/2015, there have been 72.08% of our US events sent out a Welcome Email.  1,873 total US events, 1,350 total US events use welcome emails.

--1a. Can you guys take a look at Q1, Q2, Q3, Q4 and see if this number went up or down?

select case
          when startdate >= '2015-04-01' and startdate < '2015-07-01' then 'q2'
          when startdate >= '2015-07-01' and startdate < '2015-10-01' then 'q3'
          else 'q4'
       end as quarter
     , count(*) as totalcnt
     , count(case when welcomeemailsent = 1 then 1 else null end) as welcomeemailcnt
     , count(case when welcomeemailsent = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as welcomeemailpct
from jt.dp407_events
group by 1
order by 1;

-- q2: 447/652 -> 68.56%
-- q3: 422/586 -> 72.01%
-- q4: 481/635 -> 75.75%

--2. A list of events that did NOT send out our email (we will follow up with CSMs to see why they did not use our Welcome Email)

select *
from jt.dp407_events
where welcomeemailsent = 0
order by startdate, enddate, applicationid;

--3. Adoption rate of events that sent our email vs didn't send our email (I'm not sure how noisy this data will be)

select welcomeemailsent
     , count(*) as eventcnt
     , avg(adoption) as avgadoption
     , percentile_cont(0.5) within group (order by adoption) as medianadoption
from jt.dp407_events
where openevent = 0
group by 1;
