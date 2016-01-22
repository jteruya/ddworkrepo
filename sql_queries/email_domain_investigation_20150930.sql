
-- Welcome Email Funnel
select count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailguncube
where applicationid = '4c482531-c114-4e76-bc14-d55b84f6ac3c'
and lower(subject) like 'welcome%';

-- Password Reset Funnel
select count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
from mailguncube
where applicationid = '4c482531-c114-4e76-bc14-d55b84f6ac3c'
and lower(subject) like 'password reset%';


select substring(email from (position('@' in email) + 1) for length(email) - position('@' in email)) as email_domain
     , count(*)
from (
select distinct recipientemail
     , substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1)) as email
from mailguncube
where applicationid = '4c482531-c114-4e76-bc14-d55b84f6ac3c'
and lower(subject) like 'password reset%'
and opened_flag is false
and clicked_flag is false) a
group by 1
order by 2 desc;


select substring(email from (position('@' in email) + 1) for length(email) - position('@' in email)) as email_domain
     , count(*)
from (
select distinct recipientemail
     , substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1)) as email
from mailguncube
where applicationid = '4c482531-c114-4e76-bc14-d55b84f6ac3c'
and lower(subject) like 'password reset%'
and (opened_flag is true or clicked_flag is true)) a
group by 1
order by 2 desc;


-- Across Events
-- longbeach.gov

select applicationid
     , case
         when position('<' in recipientemail) > 0 then substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1)) 
         else recipientemail
       end as recipientemail
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when rejected_flag = true then 1 else null end) as rejectedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when failed_flag = true then 1 else null end) as failedcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribedcnt
     , count(case when complained_flag = true then 1 else null end) as complainedcnt
     , count(case when stored_flag = true then 1 else null end) as storedcnt
from mailguncube
where recipientemail like '%@longbeach.gov%'
group by 1,2

-- Conclusion: No email we have sent through mailgun has ever been opened.

-- All Email Domains Analysis

select *
from mailguncube
where recipientemail like '%robert.mace@ectorcountyisd.org%';

truncate table jt.mailgundomaincube;
drop table jt.mailgundomaincube;

create table jt.mailgundomaincube as
select case
          when position('@' in recipientemail) > 0 then substring(recipientemail from (position('@' in recipientemail) + 1) for length(recipientemail) - position('@' in recipientemail)) 
          else 'Invalid Email'
       end as email_domain
     , count(distinct (case when canregister = 'false' then applicationid end)) as event_count_closed
     , count(distinct (case when canregister = 'true' then applicationid end)) as event_count_open
     , count(distinct applicationid) as event_count
     , count(distinct recipientemail) as recipient_count
     , sum(totalcnt) as total_message_count
     , sum(rejectedcnt) as total_rejected_count
     , sum(acceptedcnt) as total_accepted_count
     , sum(deliveredcnt) as total_delivered_count
     , sum(failedcnt) as total_failed_count
     , sum(openedcnt) as total_opened_count
     , sum(clickedcnt) as total_clicked_count
     , sum(unsubscribedcnt) as unsubscribed_count 
     , sum(complainedcnt) as complained_count
     , sum(storedcnt) as stored_count
     , sum(useractioncnt) as total_user_action_cnt
from (
select a.applicationid
     , c.canregister
     , case
         when position('<' in recipientemail) > 0 and position('>' in recipientemail) > 0 and position('<' in recipientemail) < position('>' in recipientemail) then lower(substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1))) 
         else lower(recipientemail)
       end as recipientemail
     , count(*) as totalcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when rejected_flag = true then 1 else null end) as rejectedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failedcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribedcnt
     , count(case when complained_flag = true then 1 else null end) as complainedcnt
     , count(case when stored_flag = true then 1 else null end) as storedcnt
     , count(case when opened_flag = true or clicked_flag = true or unsubscribed_flag = true or complained_flag = true or stored_flag = true then 1 else null end) as useractioncnt
from mailguncube a
left join eventcube.testevents b
on a.applicationid = b.applicationid::uuid
join authdb_applications c
on a.applicationid = c.applicationid::uuid
where b.applicationid is null
group by 1,2,3) a
group by 1;

select count(*) from (
select *
from mailguncube
where recipientemail like '%gmai.com%'
and delivered_flag = true
and cast(first_delivered_timestamp as date) >= '2015-09-04'
-- 3,436
union all
select *
from mailguncube
where recipientemail like '%gmai.com%'
and delivered_flag = true
and cast(first_delivered_timestamp as date) < '2015-09-04'
and lower(subject) not like '%today at%'
--262
) a;

select *
from mailguncube
where recipientemail like '%gmai.com%'
and delivered_flag = true
and cast(first_delivered_timestamp as date) >= '2015-09-04'

--a0e2d006-abb5-4f7a-83b4-241567b1c412


select *
from authdb_applications
where lower(applicationid) = 'a0e2d006-abb5-4f7a-83b4-241567b1c412';

--3,698 





-- List of Potential Domains with no user engagements (Positive or Negative) (1833 email domains)
-- Could be Corporate Filter or Going to Spam
-- To be in this population, the following needs to occur:
   -- 1.) No User Actions (Opens, Clicks, Flagged, etc.)
   -- 2.) At least 4 recipients
   -- 3.) At least 10 messages

select count(*)
     , sum(total_delivered_count)
from (
select *
from jt.mailgundomaincube
where total_delivered_count > 0
and total_user_action_cnt = 0 and (recipient_count >= 4 and total_delivered_count >= 10)
and email_domain <> 'Invalid Email'
order by total_delivered_count desc, recipient_count desc, event_count desc) a;

-- List of Potential Domains with no response but too little actions and/or recipients to determine (67296 email domains)
-- Not sure where to categoizes these:
   -- 1.) No User Actions (Opens, Clicks, Flagged, etc.)
   -- 2.) < 5 recipients or < 10 messages sent to this domain.

select count(*)
     , sum(total_delivered_count)
from (
select *
from jt.mailgundomaincube
where total_delivered_count > 0
and total_user_action_cnt = 0 and (recipient_count < 4 or total_delivered_count < 10)
and email_domain <> 'Invalid Email'
order by total_message_count desc, recipient_count desc, event_count desc) a;

select count(*)
     , sum(total_delivered_count)
from jt.mailgundomaincube
where email_domain = 'Invalid Email'

-- List of Email Domains with user engagements. (103,188 email domains)

select count(*)
     , sum(total_delivered_count)
from (
select *
from jt.mailgundomaincube
where total_delivered_count > 0
and total_user_action_cnt > 0
--and email_domain = 'gmail.com'
and email_domain <> 'Invalid Email'
order by total_user_action_cnt, total_message_count desc) a;

select count(*)
     , sum(total_message_count)
from (
select *
from jt.mailgundomaincube
where total_delivered_count > 0
and total_user_action_cnt > 0
and total_user_action_cnt::decimal(12,4)/total_delivered_count::decimal(12,4) < 0.05
and email_domain <> 'Invalid Email'
order by total_message_count desc, total_user_action_cnt) a;

-- Potential dead email domains or misspellings (No Successful Deliveries) (11,602 email domains)

select count(*)
     , sum(total_delivered_count)
from (
select *
from jt.mailgundomaincube
where total_delivered_count = 0
and email_domain <> 'Invalid Email'
order by event_count desc, recipient_count desc, total_message_count desc) a;

-- Total Email Domains: 183,919

select count(*)
     , sum(total_delivered_count)
from jt.mailgundomaincube;


--5,091,980 (test event messages pulled out of population)


select a.*
from public.mailguncube a
left join eventcube.testevents b
on a.applicationid = b.applicationid::uuid
join authdb_applications c
on a.applicationid = c.applicationid::uuid
where b.applicationid is null
and lower(recipientemail) not like '%@%'
and (opened_flag = true or clicked_flag = true or unsubscribed_flag = true or complained_flag = true or stored_flag = true);
--5,485,531

select *
from jt.mailgundomaincube
where email_domain like '%bunnings.com.au%';

--92223
--24101
--68235
--41 

select *
from jt.mailgundomaincube
where recipientemai

----- Next Steps
-- investigate "Invalid Email" (specify what that is)
-- use this to determine the "Password Reset" Funnel.

