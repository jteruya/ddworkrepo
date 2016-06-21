-- Check to see this event is on the US Server
select *
from authdb_applications
where name like 'SAP Forum Lausanne 2016';
-- Answer: YES
-- ApplicationID: 56D7BFF7-5990-467D-B481-565AB0C97612
-- BundleID: 69F883C3-1F3C-4984-BCD0-5823E7857798

-- Get unhashed user information
-- Clear out old globaluserdetails in JT schema.
truncate table jt.ratings_globaluserdetails;

-- Get the data in Robin using the following command
-- java -jar DBSync-1.1.1.jar json/adhoc/jt_ratings_globaluserdetails.json

-- Build Granular Level Table
drop table if exists jt.pa605_actions;
create table jt.pa605_actions as
select upper(actions.global_user_id) as senderid
     , actions.created
     , channels.id as channelid
     , members.globaluserid as recipientid
from fact_actions_live actions
left join (select *
      from channels.rooms
      where applicationid = '56d7bff7-5990-467d-b481-565ab0c97612'
      and type = 'GROUP') channels
on actions.application_id = channels.applicationid
and cast(actions.metadata->>'ChannelId' as bigint) = channels.id
left join (select *
      from channels.members members
      join (select distinct userid
                 , globaluserid
            from authdb_is_users
            where applicationid = '56D7BFF7-5990-467D-B481-565AB0C97612') users
      on members.userid = users.userid) members
on channels.id = members.channelid
and actions.global_user_id <> lower(members.globaluserid)
where actions.application_id = '56d7bff7-5990-467d-b481-565ab0c97612'
and actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit'
-- Date Range April 1 - June 15
and actions.created >= '2016-04-01'
and actions.created <= '2016-06-15';

-- Check Data Quality

-- Check for nulls in either the channel join or the members join
select count(*) as "Total Sends"
     , count(case when channelid is null then 1 else null end) as "Sends w/o Channel"
     , count(case when recipientid is null then 1 else null end) as "Sends w/o Recipients"
from jt.pa605_actions;
-- Total Sends: 335
-- Sends w/o Channel: 0
-- Sends w/o Recipients: 0 (same as Sends w/o Channel records).

-- Check to see that "Total Sends" in the above query matches the "Total Sends" in the below one.
select count(*) as "Total Sends"
from fact_actions_live
where application_id = '56d7bff7-5990-467d-b481-565ab0c97612'
and identifier = 'chatTextButton'
and metadata->>'Type' = 'submit'
-- Date Range April 1 - June 15
and created >= '2016-04-01'
and created <= '2016-06-15';
-- Total Sends: 335

-- Combine granular table with unhashed data and remove the 21 problem records.
select users.firstname as "First Name"
     , users.lastname as "Last Name"
     , users.title as "Title"
     , users.company as "Company"
     , case
         when actions.created::date < events.startdate then 1
         when actions.created::date > events.enddate then 3
         else 2
       end as timeframeorder
     , case
         when actions.created::date < events.startdate then 'Before Event (4/1/2016 - 6/12/2016)'
         when actions.created::date > events.enddate then 'After Event (6/14/2016 - 6/15/2016)'
         else 'During Event (6/13/2016)'
       end as "Time Frame"
     , lower(users.emailaddress) as "Email"
     , count(*) as "Total Number of Messages Sent by User"
     , count(distinct recipientid) as "Total Number of Unique Recipients"
from jt.pa605_actions actions
join jt.ratings_globaluserdetails users
on actions.senderid = users.globaluserid
join public.authdb_applications events
on 1 = 1
where actions.channelid is not null
and events.applicationid = '56D7BFF7-5990-467D-B481-565AB0C97612'
group by 1,2,3,4,5,6,7
order by 1,2,5
;

-- The output of the last query is pasted into the attachment pa605_request.xlsx


