-- Get ApplicationID and Check if on US Robin
select *
from authdb_applications
where name like '%RCO-US STM/SMN 2016 Offsite Meeting%';
-- ApplicationID: A813616C-3117-4BAE-8BEB-DD9559F33DB7
-- BundleID: B93CD3E6-E4B4-4FE5-BBA5-FCDE4FC58F51
-- USRobin: YES

-- Create Non-Disabled Users Table
drop table if exists jt.pa521_users;
create table jt.pa521_users as
select distinct lower(globaluserid) as global_user_id
     , userid as user_id     
from authdb_is_users
where applicationid = 'A813616C-3117-4BAE-8BEB-DD9559F33DB7'
and isdisabled = 0;

-- Create Group Rooms Table that Include Only Non-Disabled Users
drop table if exists jt.pa521_group_rooms;
create table jt.pa521_group_rooms as
select rooms.id as channel_id
     , rooms.type
     , count(*) as member_cnt
from channels.rooms rooms
join channels.members members
on rooms.id = members.channelid
join jt.pa521_users users
on members.userid = users.user_id
where rooms.type = 'GROUP'
group by 1,2
having count(*) = 2;

-- DM Funnel
select count(*) as "Registered Users"
     , count(case when sessions.global_user_id is not null then 1 else null end) as "Active Users"
     , count(case when microapp.global_user_id is not null then 1 else null end) as "Messages Microapp Visitor User Count"
     , count(case when createroom.global_user_id is not null then 1 else null end) as "Create DM Message Room User Count"
     , count(case when entry.global_user_id is not null then 1 else null end) as "Entered Text Message User Count"
     , count(case when submit.global_user_id is not null then 1 else null end) as "Submited Text Message User Count"
from (select distinct global_user_id
      from jt.pa521_users) users
left join (select distinct global_user_id
           from fact_sessions_live
           where application_id = 'a813616c-3117-4bae-8beb-dd9559f33db7') sessions
on users.global_user_id = sessions.global_user_id
left join (select distinct global_user_id
           from fact_actions_live
           where application_id = 'a813616c-3117-4bae-8beb-dd9559f33db7'
           and identifier = 'menuItem'
           and metadata->>'Url' = 'dd://messages/') microapp
on users.global_user_id = microapp.global_user_id
left join (select distinct global_user_id
           from fact_actions_live
           where application_id = 'a813616c-3117-4bae-8beb-dd9559f33db7'
           and identifier = 'addChatButton') createroom
on users.global_user_id = createroom.global_user_id             
left join (select distinct global_user_id
           from fact_actions_live actions
           join jt.pa521_group_rooms rooms
           on cast(actions.metadata->>'ChannelId' as int) = rooms.channel_id
           where actions.application_id = 'a813616c-3117-4bae-8beb-dd9559f33db7'
           and actions.identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'entry') entry
on users.global_user_id = entry.global_user_id
left join (select distinct global_user_id
           from fact_actions_live actions
           join jt.pa521_group_rooms rooms
           on cast(actions.metadata->>'ChannelId' as int) = rooms.channel_id
           where actions.application_id = 'a813616c-3117-4bae-8beb-dd9559f33db7'
           and actions.identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit') submit
on users.global_user_id = submit.global_user_id
;
