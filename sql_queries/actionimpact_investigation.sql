select count(*)
     , count(distinct applicationid) as uniqueeventcnt
     , count(distinct recipientemail) as uniquerecipientemailcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true or clicked_flag = true or unsubscribed_flag = true or complained_flag = true or stored_flag = true then 1 else null end) as respondedcnt    
from mailguncube
where recipientemaildomain = 'razorfish.com';
--where recipientemaildomain = 'actionimpact.com';

select distinct recipientemail
from mailguncube
where recipientemaildomain = 'actionimpact.com'; 

select count(*)
     , count(case when accepted_flag = true then 1 else null end) as accepted
     , count(case when delivered_flag = true then 1 else null end) as delivered
     , count(case when opened_flag = true or clicked_flag = true or unsubscribed_flag = true or complained_flag = true or stored_flag = true then 1 else null end)     
from mailguncube
where recipientemail = 'tjackson@actionimpact.com';


select *
from mailguncube
where recipientemaildomain = 'actionimpact.com'
order by first_accepted_timestamp; 


-- 132 

select messageid
     , senderemail
     , recipientemail
     , applicationid
     , subject
     , cast(extract(month from first_accepted_timestamp) as int) as month
     , cast(extract(day from first_accepted_timestamp) as int) as day
     , cast(extract(hour from first_accepted_timestamp) as int) + 4 as hour
     , cast(extract(minute from first_accepted_timestamp) as int) as minute
     , accepted_flag
     , delivered_flag
     , opened_flag
     , clicked_flag
     , case
         when opened_flag = true or clicked_flag = true or complained_flag = true or unsubscribed_flag = true or stored_flag = true then true
         else false
       end as responded_flag
from mailguncube
where recipientemaildomain = 'actionimpact.com'
or recipientemail = 'appactionimpact@gmail.com'
--and cast(extract(month from first_accepted_timestamp) as int) = 10
order by month, day, hour, minute;

select *
from authdb_applications
where lower(applicationid) = '2a6ecd9e-6518-43a0-8ca8-23e75c93a873';





select *
from mailguncube
where recipientemail = 'appactionimpact@gmail.com';