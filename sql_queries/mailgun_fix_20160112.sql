select cast(to_timestamp(eventtimestamp/1000) as date) as day
     , count(*) as acceptedcnt
from mailgun.mailgun_events
where eventstatus = 'accepted'
and eventtimestamp >= 1450742400000
group by 1
order by 1;


select count(*)
from mailgun.mailgun_events
where eventtimestamp >= 1450742400000;

-- 875,931

create table mailgun.mailgun_event_20151222 as 
select * from mailgun.mailgun_events where eventtimestamp >= 1450742400000;

select count(*)
from mailgun.mailgun_event_20151222;

-- 875,931

select max(eventtimestamp)
from mailgun.mailgun_events
where eventtimestamp < 1450742400000;

-- 1450741676975 (Mon, 21 Dec 2015 23:47:56 GMT)


select cast(to_timestamp(eventtimestamp_created/1000) as date) as day
     , count(*) as cnt
from mailgun.mailguncube
where eventtimestamp_created >= 1450742400000
group by 1
order by 1;

create table mailgun.mailguncube_20151222 as
select * from mailgun.mailguncube where eventtimestamp_created >= 1450742400000;

select count(*)
from mailgun.mailguncube_20151222;

-- 185,066

delete from mailgun.mailgun_events where eventtimestamp >= 1450742400000;
-- Deleted 875,931

delete from mailgun.mailguncube where eventtimestamp_created >= 1450742400000;
-- Deleted 185,066

select max(eventtimestamp)
from mailgun.mailgun_events;

-- 1450741676975 (Mon, 21 Dec 2015 23:47:56 GMT)

select max(eventtimestamp_created)
from mailgun.mailguncube;

-- 1450699975081 (Mon, 21 Dec 2015 12:12:55 GMT)

select * from mailgun.mailguncube where applicationid = 'BB1174E3-64EA-4DD6-B7BD-56F5B0EB9B7C'::uuid and unsubscribed_flag;

select cast(first_accepted_timestamp as date) as daydate
     , count(*) as cnt
from mailgun.mailguncube
where recipientemail is null
group by 1
order by 1;

-- 63619

select cast(first_delivered_timestamp as date) as daydate
     , count(*) as cnt
from mailgun.mailguncube
where recipientemail is null
group by 1
order by 1;

-- 63619

select cast(first_opened_timestamp as date) as daydate
     , count(*) as cnt
from mailgun.mailguncube
where recipientemail is null
group by 1
order by 1;



select *
from mailgun.mailgun_events
where messageid = '20160107231315.21394.3330@doubledutch.me';

1452208394000
1452208774000

20160107231315.21394.3330@doubledutch.me


select *
from mailgun.mailgun_events

----- Attempt #2

-- Create Mailgun Event Backup (from 12/22)
create table mailgun.mailgun_event_20151222_2 as 
select * from mailgun.mailgun_events where eventtimestamp >= 1450742400000;

-- Check Record Count
select count(*)
from mailgun.mailgun_event_20151222_2;
-- 958,410

-- Create Mailguncube Backup (from 12/22)
create table mailgun.mailguncube_20151222_2 as
select * from mailgun.mailguncube where eventtimestamp_created >= 1450742400000;

-- Check Record Count
select count(*)
from mailgun.mailguncube_20151222_2;
-- 211,405

-- Delete from Mailgun Event
delete from mailgun.mailgun_events where eventtimestamp >= 1450742400000;
-- Deleted 958,410

-- Delete from Mailguncube
delete from mailgun.mailguncube where eventtimestamp_created >= 1450742400000;
-- Deleted 211,405

-- Run Mailgun Load Process Again.
nohup bash mailgun_load_incremental.sh &

-- Test with the following examples:
-- messageid: 20160107231315.21394.3330@doubledutch.me
-- select recipientemail from mailgun.mailguncube where applicationid = 'BB1174E3-64EA-4DD6-B7BD-56F5B0EB9B7C'::uuid and unsubscribed_flag

select *
from mailgun.mailgun_events where messageid = '20160107231315.21394.3330@doubledutch.me';


select recipientemail from mailgun.mailguncube where applicationid = 'BB1174E3-64EA-4DD6-B7BD-56F5B0EB9B7C'::uuid and unsubscribed_flag;