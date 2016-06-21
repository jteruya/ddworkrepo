-- Check to see this event is on the US Server
select *
from authdb_applications
where name like 'SAP Forum Basel 2016';
-- Answer: YES
-- ApplicationID: A19077B6-86D7-447F-895F-9413F3A80449
-- BundleID: 69F883C3-1F3C-4984-BCD0-5823E7857798

-- Get unhashed user information
-- Clear out old globaluserdetails in JT schema.
truncate table jt.ratings_globaluserdetails;

-- Get the data in Robin using the following command
-- java -jar DBSync-1.1.1.jar json/adhoc/jt_ratings_globaluserdetails.json

-- Build Granular Level Table
drop table if exists jt.pa512_actions;
create table jt.pa512_actions as
select upper(actions.global_user_id) as senderid
     , actions.created
     , channels.id as channelid
     , members.globaluserid as recipientid
from fact_actions_live actions
left join (select *
      from channels.rooms
      where applicationid = 'a19077b6-86d7-447f-895f-9413f3a80449'
      and type = 'GROUP') channels
on actions.application_id = channels.applicationid
and cast(actions.metadata->>'ChannelId' as bigint) = channels.id
left join (select *
      from channels.members members
      join (select distinct userid
                 , globaluserid
            from authdb_is_users
            where applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449') users
      on members.userid = users.userid) members
on channels.id = members.channelid
and actions.global_user_id <> lower(members.globaluserid)
where actions.application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit';

-- Check Data Quality

-- Check for nulls in either the channel join or the members join
select count(*) as "Total Sends"
     , count(case when channelid is null then 1 else null end) as "Sends w/o Channel"
     , count(case when recipientid is null then 1 else null end) as "Sends w/o Recipients"
from jt.pa512_actions;
-- Total Sends: 1316
-- Sends w/o Channel: 21
-- Sends w/o Recipients: 21 (same as Sends w/o Channel records).

-- Check to see that "Total Sends" in the above query matches the "Total Sends" in the below one.
select count(*) as "Total Sends"
from fact_actions_live
where application_id = 'a19077b6-86d7-447f-895f-9413f3a80449'
and identifier = 'chatTextButton'
and metadata->>'Type' = 'submit';
-- Total Sends: 1316

-- Combine granular table with unhashed data and remove the 21 problem records.
select users.firstname as "First Name"
     , users.lastname as "Last Name"
     , users.title as "Title"
     , users.company as "Company"
     , lower(users.emailaddress) as "Email"
     , case
         when actions.created < events.startdate then 1
         when actions.created >= events.startdate and actions.created <= events.enddate then 2
         else 3
       end as "Action Timeframe Order"
     , case
         when actions.created < events.startdate then 'Before Event'
         when actions.created >= events.startdate and actions.created <= events.enddate then 'During Event'
         else 'After Event'
       end as "Action Timeframe"
     , count(*) as "Total Number of Messages Sent by User"
     , count(distinct recipientid) as "Total Number of Unique Recipients"
from jt.pa512_actions actions
join jt.ratings_globaluserdetails users
on actions.senderid = users.globaluserid
join public.authdb_applications events
on 1 = 1
where actions.channelid is not null
and events.applicationid = 'A19077B6-86D7-447F-895F-9413F3A80449'
group by 1,2,3,4,5,6,7
order by 1,2,6;

-- The output of the last query is pasted into the attachment pa512_request.xlsx
