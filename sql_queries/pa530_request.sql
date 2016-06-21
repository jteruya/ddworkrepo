-- Get Channels and States
/*
drop table if exists jt.pa530_channels;
create table jt.pa530_channels as
select distinct events.applicationid
     , events.tcflag
     , rooms.id as channelid
     , rooms.created as channelcreated
     , case
         when msgentry.metadata is not null then 1
         else 0
       end as msgentryflag     
     , case
         when msgsent.metadata is not null then 1
         else 0
       end as msgsentflag
     , case
         when profilech.channelid is not null then 1
         else 0
       end as profilechflag
     , case
         when tcch.channelid is not null then 1
         else 0
       end as tcchflag
     , case
         when profilech.channelid is not null and profilech.created <= rooms.created + interval '1' minute and profilech.created >= rooms.created - interval '1' minute then 1
         else 0
       end as profilechstartflag
     , case
         when tcch.channelid is not null and tcch.created <= rooms.created + interval '1' minute and tcch.created >= rooms.created - interval '1' minute then 1
         else 0
       end as tcchstartflag
from jt.dp529_events events
join channels.rooms rooms
on events.applicationid = upper(rooms.applicationid)
-- Enter Message
left join (select *
           from jt.dp529_actions_users
           where identifier = 'chatTextButton'
           and metadata->>'Type' = 'entry'
           ) msgentry
on cast(msgentry.metadata->>'ChannelId' as bigint) = rooms.id
-- Submitted Message Sent
left join (select *
           from jt.dp529_actions_users
           where identifier = 'chatTextButton'
           and metadata->>'Type' = 'submit'
           ) msgsent
on cast(msgsent.metadata->>'ChannelId' as bigint) = rooms.id

-- Message 
left join (select members2.channelid
                , min(actions.created) as created
           from jt.dp529_actions_users actions
           join authdb_is_users users
           on actions.global_user_id = lower(users.globaluserid)
           join channels.members members1
           on users.userid = members1.userid
           join channels.members members2
           on cast(actions.metadata->>'UserId' as bigint) = members2.userid
           and members1.channelid = members2.channelid
           where actions.identifier = 'startSendMessage'
           group by 1
           ) profilech
on profilech.channelid = rooms.id

-- Profile View Conversation Access
left join (select members2.channelid
                , min(actions.created) as created
           from jt.dp529_actions_users actions
           join authdb_is_users users
           on actions.global_user_id = lower(users.globaluserid)
           join channels.members members1
           on users.userid = members1.userid
           join channels.members members2
           on cast(actions.metadata->>'UserId' as bigint) = members2.userid
           and members1.channelid = members2.channelid
           where actions.identifier = 'startSendMessage'
           group by 1
           ) profilech
on profilech.channelid = rooms.id

-- Topic Channel Conversation Access
left join (select members2.channelid
                , min(actions.created) as created
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           join authdb_is_users users
           on actions.global_user_id = lower(users.globaluserid)
           join channels.members members1
           on users.userid = members1.userid
           join channels.members members2
           on cast(actions.metadata->>'UserId' as bigint) = members2.userid
           and members1.channelid = members2.channelid
           where actions.identifier = 'chatProfileButton'
           and actions.metadata->>'Type' = 'messageCompose'
           and rooms.type = 'TOPIC'
           group by 1
           ) tcch
on tcch.channelid = rooms.id           
where rooms.type = 'GROUP'
;


-- Get the user counts for those that accessed the channels where event has TC.
select count(distinct applicationid) as "Event Count"
     , count(*) as "DM Channel Users"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end) as "The '+' button in the DM list"
     , count(case when profilechflag = 1 then 1 else null end) as "The 'Send Message' button on Attendee Profiles"
     , count(case when tcchflag = 1 then 1 else null end) as "The 'Message' button on the Profile Card (can be accessed by tapping someone's avatar in a Channel)"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "The '+' button in the DM list %"
     , count(case when profilechflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "The 'Send Message' button on Attendee Profiles %"
     , count(case when tcchflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "The 'Message' button on the Profile Card (can be accessed by tapping someone's avatar in a Channel)"
from jt.pa530_channels
where tcflag = 1
;


-- Get the user counts for those that accessed the channels where event has TC.
select applicationid as "Application ID"
     , count(*) as "DM Channel Users"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end) as "The '+' button in the DM list"
     , count(case when profilechflag = 1 then 1 else null end) as "The 'Send Message' button on Attendee Profiles"
     , count(case when tcchflag = 1 then 1 else null end) as "the 'Message' button on the Profile Card (can be accessed by tapping someone's avatar in a Channel)"
from jt.pa530_channels
where tcflag = 1
group by 1
;


-- Get the user counts for those that accessed the channels where event does not have TC.
select count(distinct applicationid) as "Event Count"
     , count(*) as "DM Channel Users"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end) as "The '+' button in the DM list"
     , count(case when profilechflag = 1 then 1 else null end) as "The 'Send Message' button on Attendee Profiles"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "The '+' button in the DM list %"
     , count(case when profilechflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "The 'Send Message' button on Attendee Profiles %"
from jt.pa530_channels
where tcflag = 0
;


-- Get the user counts for those that accessed the dm where event does not have TC.
select applicationid as "Application ID"
     , count(*) as "DM Channel Users"
     , count(case when profilechflag = 0 and tcchflag = 0 then 1 else null end) as "The '+' button in the DM list"
     , count(case when profilechflag = 1 then 1 else null end) as "The 'Send Message' button on Attendee Profiles"
     --, count(case when tcchflag = 1 then 1 else null end) as tcchhannelflag
from jt.pa530_channels
where tcflag = 0
group by 1
;
*/

drop table if exists jt.pa530_channels;
create table jt.pa530_channels as
select distinct id
     , roomcreated
     , applicationid
     , tcflag
     , first_value(userid) over (partition by id, roomcreated, applicationid order by timediff) as userid
     , first_value(identifier) over (partition by id, roomcreated, applicationid order by timediff) as identifier
     , first_value(timediff) over (partition by id, roomcreated, applicationid order by timediff) as timediff
from (
select rooms.id
     , rooms.created as roomcreated
     , events.applicationid
     , events.tcflag
     , actions.created as actioncreated
     , users.userid
     , actions.identifier
     , abs(extract(epoch from rooms.created - actions.created)) as timediff
from channels.rooms rooms
join jt.dp529_events events
on rooms.applicationid = lower(events.applicationid)
join channels.members members
on rooms.id = members.channelid
join jt.dp529_users users
on members.userid = users.userid
join (select *
      from jt.dp529_actions_users
      where ((identifier = 'addChatButton' and metadata->>'View' in ('list','chat'))
            or (identifier = 'startSendMessage' and metadata->>'View' = 'profile')
            or (identifier = 'chatProfileButton' and metadata->>'Type' = 'messageCompose'))
      ) actions
on actions.application_id = lower(users.applicationid)
and actions.global_user_id = lower(users.globaluserid)
where rooms.type = 'GROUP'
) a
;


drop table if exists jt.pa530_channels_msg;
create table jt.pa530_channels_msg as
select rooms.*
     , case
         when msgentry.id is not null then 1
         else 0
       end as msgentryflag
     , case
         when msgsent.id is not null then 1
         else 0
       end as msgsentflag
from jt.pa530_channels rooms
-- Enter Message
left join (select distinct cast(metadata->>'ChannelId' as bigint) as id
           from jt.dp529_actions_users
           where identifier = 'chatTextButton'
           and metadata->>'Type' = 'entry'
           ) msgentry
on msgentry.id = rooms.id
-- Submitted Message Sent
left join (select distinct cast(metadata->>'ChannelId' as bigint) as id
           from jt.dp529_actions_users
           where identifier = 'chatTextButton'
           and metadata->>'Type' = 'submit'
           ) msgsent
on msgsent.id = rooms.id
;

-- Check to make sure record count is the same.
select count(*)
from jt.pa530_channels_msg
;
-- 33,154

select count(*)
from jt.pa530_channels
;
-- 33,154

-- It is!

-- Calculate records that will be pulled out of the analysis...
select count(*) as total
     , count(case when timediff <= 300 then 1 else null end) as keepcnt
     , count(case when timediff <= 300 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as keeppct
from jt.pa530_channels_msg
where tcflag = 1
;
-- Total: 6158 Channels
-- Keep: 4695 Channels
-- Keep(%): 76.24% of the Channels


-- Results: When the event doesn't have TC enabled.
select count(distinct applicationid) as "Total Events"
     , count(*) as "Total Channels"
     , count(case when identifier = 'addChatButton' then 1 else null end) as "Add Chat Button - Create DM"
     , count(case when identifier = 'startSendMessage' then 1 else null end) as "Profile View - Create DM"
     , count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end) as "Add Chat Button - Create DM and Enter Message"
     , count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end) as "Profile View - Create DM and Enter Message"
     , count(case when identifier = 'addChatButton' and msgsentflag = 1 then 1 else null end) as "Add Chat Button - Create DM and Submit Message"
     , count(case when identifier = 'startSendMessage' and msgsentflag = 1 then 1 else null end) as "Profile View - Create DM and Submit Message"
     
     , count(case when identifier = 'addChatButton' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Add Chat Button - Create DM %"
     , count(case when identifier = 'startSendMessage' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Profile View - Create DM %"
     , count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'addChatButton' then 1 else null end)::decimal(12,4) as "Add Chat Button - Create DM and Enter Message %"
     , count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'startSendMessage' then 1 else null end)::decimal(12,4) as "Profile View - Create DM and Enter Message %"
     , count(case when identifier = 'addChatButton' and msgsentflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4) as "Add Chat Button - Create DM and Submit Message %"
     , count(case when identifier = 'startSendMessage' and msgsentflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end)::decimal(12,4) as "Profile View - Create DM and Submit Message %"
from jt.pa530_channels_msg
where timediff <= 300
and tcflag = 0
;


-- Results: When the event have TC enabled.
select count(distinct applicationid) as "Total Events"
     , count(*) as "Total Channels"
     , count(case when identifier = 'addChatButton' then 1 else null end) as "Add Chat Button - Create DM"
     , count(case when identifier = 'startSendMessage' then 1 else null end) as "Profile View - Create DM"
     , count(case when identifier = 'chatProfileButton' then 1 else null end) as "Topic Channel - Create DM"
     , count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end) as "Add Chat Button - Create DM and Enter Message"
     , count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end) as "Profile View - Create DM and Enter Message"
     , count(case when identifier = 'chatProfileButton' and msgentryflag = 1 then 1 else null end) as "Topic Channel - Create DM and Enter Message"
     , count(case when identifier = 'addChatButton' and msgsentflag = 1 then 1 else null end) as "Add Chat Button - Create DM and Submit Message"
     , count(case when identifier = 'startSendMessage' and msgsentflag = 1 then 1 else null end) as "Profile View - Create DM and Submit Message"
     , count(case when identifier = 'chatProfileButton' and msgsentflag = 1 then 1 else null end) as "Topic Channel - Create DM and Submit Message"
     
     , count(case when identifier = 'addChatButton' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Add Chat Button - Create DM %"
     , count(case when identifier = 'startSendMessage' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Profile View - Create DM %"
     , count(case when identifier = 'chatProfileButton' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Topic Channel - Create DM %"
     , count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'addChatButton' then 1 else null end)::decimal(12,4) as "Add Chat Button - Create DM and Enter Message %"
     , count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'startSendMessage' then 1 else null end)::decimal(12,4) as "Profile View - Create DM and Enter Message %"
     , count(case when identifier = 'chatProfileButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'chatProfileButton' then 1 else null end)::decimal(12,4) as "Topic Channel - Create DM and Enter Message %"
     , count(case when identifier = 'addChatButton' and msgsentflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'addChatButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4) as "Add Chat Button - Create DM and Submit Message %"
     , count(case when identifier = 'startSendMessage' and msgsentflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'startSendMessage' and msgentryflag = 1 then 1 else null end)::decimal(12,4) as "Profile View - Create DM and Submit Message %"
     , count(case when identifier = 'chatProfileButton' and msgsentflag = 1 then 1 else null end)::decimal(12,4)/count(case when identifier = 'chatProfileButton' and msgentryflag = 1 then 1 else null end)::decimal(12,4) as "Topic Channel - Create DM and Submit Message %"     
from jt.pa530_channels_msg
where timediff <= 300
and tcflag = 1
;





