-- What % of active users send a message?


-- Social Release (Direct Messages, 6.0+)

-- Events with app version v6.x and above
-- Flagging if "Direct Messaging is Enabled"
drop table if exists jt.dm_events;
create table jt.dm_events as
select events.*
     , case
          when configset.applicationid is not null then 1
          else 0
       end as directmessagingcmsenabled
     , case
          when configgrid.applicationid is not null then 1
          else 0
       end as directmessagemicroapp
from eventcube.eventcubesummary events
left join (select *
           from public.ratings_applicationconfigsettings
           where name = 'EnableDirectMessaging'
           and settingvalue = 'True') configset
on events.applicationid = configset.applicationid
left join (select *
           from public.ratings_applicationconfiggriditems
           where typeid = 205
           and selected = true) configgrid
on events.applicationid = configgrid.applicationid
where events.binaryversion like '6.%'
and events.enddate < current_date
and (configset.applicationid is not null or configgrid.applicationid is not null);

-- Get all app sessions associated with the DM events.
drop table if exists jt.dm_sessions;
create table jt.dm_sessions as
select *
from fact_sessions_live
where application_id in (select lower(applicationid)
                         from jt.dm_events)
and identifier = 'start'
and binary_version like '6.%';

drop table if exists jt.dm_actions;
create table jt.dm_actions as
select *
from fact_actions_live
where application_id in (select lower(applicationid)
                         from jt.dm_events)
and binary_version like '6.%';

drop table if exists jt.dm_views;
create table jt.dm_views as
select *
from fact_views_live
where application_id in (select lower(applicationid)
                         from jt.dm_events)
and binary_version like '6.%';


-- Get all non-disabled users associated with the DM events.
drop table if exists jt.dm_users;
create table jt.dm_users as
select users.applicationid 
     , users.globaluserid
     , users.userid
     , count(case when sessions.session_id is not null then 1 else null end) as sessioncnt
from (select distinct users.applicationid
           , users.globaluserid
           , users.userid
      from authdb_is_users users
      join jt.dm_events events
      on users.applicationid = events.applicationid
      where isdisabled = 0) users
left join jt.dm_sessions sessions
on sessions.global_user_id = lower(users.globaluserid)
group by 1,2,3;


-- Get the Users that Send/Recieve Messages Based on Actions
-- Users (senders and recievers) need to be non-disabled users
drop table if exists jt.dm_events_msgsend;
create table jt.dm_events_msgsend as
select upper(actions.application_id) as applicationid
     , upper(actions.global_user_id) as globaluserid
     , users.userid
     , actions.device_type
     , case
          when channels.type is null then 'ERROR'
          else channels.type
       end as roomtype
     , channels.userid as recipientuserid
     , cast(actions.metadata->>'ChannelId' as bigint) as roomid
     , min(actions.created) as firstmsgsent
     , count(*) as msgsendcnt
from jt.dm_actions actions
join jt.dm_events events
on actions.application_id = lower(events.applicationid)
join (select distinct userid
           , globaluserid
      from public.authdb_is_users 
      where isdisabled = 0) users
on actions.global_user_id = lower(users.globaluserid)
left join (select distinct rooms.id
           , rooms.type
           , case
               when rooms.type = 'GROUP' then members.userid
               else null
             end as userid
           from channels.rooms rooms
           join channels.members members
           on rooms.id = members.channelid
           join (select distinct userid
                      , globaluserid
                 from public.authdb_is_users 
                 where isdisabled = 0) users
           on members.userid = users.userid) channels
on ((cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'GROUP' and users.userid <> channels.userid) 
or (cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'TOPIC'))
where actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit'
group by 1,2,3,4,5,6,7;




select events.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , users.usercnt
     , users.activeusercnt
     , count(distinct send.userid) as sendercnt
     , count(distinct send.recipientuserid) as recipientcnt
     , case
          when users.activeusercnt > 0 then count(distinct send.userid)::decimal(12,4)/users.activeusercnt::decimal(12,4) 
          else null 
       end as senderpct
     , case
          when users.usercnt > 0 then count(distinct send.recipientuserid)::decimal(12,4)/users.usercnt::decimal(12,4) 
          else null 
       end as recipientpct
from jt.dm_events events
join (select applicationid
           , count(*) as usercnt
           , count(case when sessioncnt > 0 then 1 else null end) as activeusercnt
      from jt.dm_users
      group by 1) as users
on events.applicationid = users.applicationid
left join (select *
           from jt.dm_events_msgsend
           where roomtype = 'GROUP') send
on events.applicationid = send.applicationid
group by 1,2,3,4,5,6,7
order by 3,4,1;

-- What % of messages are read (viewed)?

-- Chat View Records
drop table if exists jt.dm_chat_views;
create table jt.dm_chat_views as
select distinct views.*
     , cast(views.metadata->>'ChannelId' as bigint) as channelid
     , channels.type
     , channels.userid as otheruserid
from jt.dm_views views
join jt.dm_events events
on views.application_id = lower(events.applicationid)
join (select distinct userid
           , globaluserid
      from public.authdb_is_users 
      where isdisabled = 0) users
on views.global_user_id = lower(users.globaluserid)
left join (select distinct rooms.id
           , rooms.type
           , case
               when rooms.type = 'GROUP' then members.userid
               else null
             end as userid
           from channels.rooms rooms
           join channels.members members
           on rooms.id = members.channelid
           join (select distinct userid
                      , globaluserid
                 from public.authdb_is_users 
                 where isdisabled = 0) users
           on members.userid = users.userid) channels
on ((cast(views.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'GROUP' and users.userid <> channels.userid) 
or (cast(views.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'TOPIC'))
where views.identifier = 'chat';

-- Submit Chat Action Records
drop table if exists jt.dm_submitchat_action;
create table jt.dm_submitchat_action as
select distinct actions.*
     , cast(actions.metadata->>'ChannelId' as bigint) as channelid
     , channels.type
     , channels.userid as otheruserid
from jt.dm_actions actions
join jt.dm_events events
on actions.application_id = lower(events.applicationid)
join (select distinct userid
           , globaluserid
      from public.authdb_is_users 
      where isdisabled = 0) users
on actions.global_user_id = lower(users.globaluserid)
left join (select distinct rooms.id
           , rooms.type
           , case
               when rooms.type = 'GROUP' then members.userid
               else null
             end as userid
           from channels.rooms rooms
           join channels.members members
           on rooms.id = members.channelid
           join (select distinct userid
                      , globaluserid
                 from public.authdb_is_users 
                 where isdisabled = 0) users
           on members.userid = users.userid) channels
on ((cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'GROUP' and users.userid <> channels.userid) 
or (cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'TOPIC'))
where actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit';


drop table if exists jt.dm_mute_action;
create table jt.dm_mute_action as
select distinct actions.*
     , cast(actions.metadata->>'ChannelId' as bigint) as channelid
     , channels.type
     , channels.userid as otheruserid
from jt.dm_actions actions
join jt.dm_events events
on actions.application_id = lower(events.applicationid)
join (select distinct userid
           , globaluserid
      from public.authdb_is_users 
      where isdisabled = 0) users
on actions.global_user_id = lower(users.globaluserid)
left join (select distinct rooms.id
           , rooms.type
           , case
               when rooms.type = 'GROUP' then members.userid
               else null
             end as userid
           from channels.rooms rooms
           join channels.members members
           on rooms.id = members.channelid
           join (select distinct userid
                      , globaluserid
                 from public.authdb_is_users 
                 where isdisabled = 0) users
           on members.userid = users.userid) channels
on ((cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'GROUP' and users.userid <> channels.userid) 
or (cast(actions.metadata->>'ChannelId' as bigint) = channels.id and channels.type = 'TOPIC'))
where actions.identifier = 'chatProfileButton'
and actions.metadata->>'Type' = 'mute';


-- Submit Chat Action Records with a view and response.
drop table if exists jt.dm_submitchat_action_viewed;
create table jt.dm_submitchat_action_viewed as
select distinct chatactions.*
     , case
         when chatviews.global_user_id is null then 0
         else 1
       end as viewflag
from jt.dm_submitchat_action chatactions
join jt.dm_users users
on chatactions.otheruserid = users.userid
left join jt.dm_chat_views chatviews
on lower(users.globaluserid) = chatviews.global_user_id
and chatactions.channelid = chatviews.channelid
and chatactions.application_id = chatviews.application_id
and chatactions.created < chatviews.created
where chatactions.otheruserid is not null;

select application_id
     , count(*)
from jt.dm_submitchat_action
group by 1
order by 1;

select application_id
     , count(*) as messagecnt
     , count(case when viewflag = 1 then 1 else null end) as viewedcnt
     , count(case when viewflag = 0 then 1 else null end) as notviewedcnt
     , count(case when viewflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as viewedpct
     , count(case when viewflag = 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as notviewedpct
from jt.dm_submitchat_action_viewed
group by 1
order by 1;

-- What % of messages are responded to? 
select application_id
     , count(*) as convcnt
     , count(case when msgsentcnt > 1 then 1 else null end) as respondcnt
     , count(case when msgsentcnt > 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as respondpct
from (select application_id
           , channelid
           , count(*) as msgsentcnt
      from jt.dm_submitchat_action
      where type = 'GROUP'
      group by 1,2) channel
group by 1
order by 1;

select count(*)
from channels.rooms 
where applicationid = '086de2c6-d69f-4c97-81f6-1db36873d297'
and type = 'GROUP';

select *
from channels.rooms
where applicationid = '086de2c6-d69f-4c97-81f6-1db36873d297';

-- What % of conversations get blockd?
select application_id
     , count(*) 
from (select application_id
           , channelid
           , count(*) as msgsentcnt
      from jt.dm_mute_action
      where type = 'GROUP'
      group by 1,2) channel
group by 1
order by 1;

-- Are attendees who use Direct Messages (either send or receive messages) more engaged in the app overall?
drop table if exists jt.dm_users_sendrecieve;
create table jt.dm_users_sendrecieve as
select users.*
     , case
         when sendmsg.global_user_id is null then 0
         else 1
       end as submitmsgflag
     , case
         when recievemsg.otheruserid is null then 0
         else 1
       end as recievemsgflag
     , case
         when sendmsg.global_user_id is null and recievemsg.otheruserid is null then 0
         else 1
       end as groupid
from jt.dm_users users
left join (select distinct global_user_id
           from jt.dm_submitchat_action
           where type = 'GROUP') sendmsg
on lower(users.globaluserid) = sendmsg.global_user_id
left join (select distinct otheruserid
           from jt.dm_submitchat_action
           where type = 'GROUP') recievemsg
on users.userid = recievemsg.otheruserid;


select applicationid
     , count(distinct globaluserid) as groupcnt
     , percentile_cont(0.5) within group (order by sessioncnt) as mediansessioncnt
from jt.dm_users_sendrecieve
where groupid = 0
and sessioncnt > 0
group by 1;

select applicationid
     , count(distinct globaluserid) as groupcnt
     , percentile_cont(0.5) within group (order by sessioncnt) as mediansessioncnt
from jt.dm_users_sendrecieve
where groupid = 1
and sessioncnt > 0
group by 1;


select count(distinct globaluserid) as groupcnt
     , percentile_cont(0.5) within group (order by sessioncnt) as mediansessioncnt
from jt.dm_users_sendrecieve
where groupid = 0;

select count(distinct globaluserid) as groupcnt
     , percentile_cont(0.5) within group (order by sessioncnt) as mediansessioncnt
from jt.dm_users_sendrecieve
where groupid = 1;


select *
from jt.dm_users_sendrecieve limit 10;
