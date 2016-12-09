-- Get the Events
drop table if exists jt.dp529_events;
create table jt.dp529_events as
select ecs.applicationid
     , ecs.name
     , ecs.startdate
     , ecs.enddate
     , ecs.eventtype
     , ecs.openevent
     , ecs.directmessaging
     , ecs.topicchannel
     , ecs.topicchannelcnt
     , ecs.sessionchannel
from eventcube.eventcubesummary ecs
left join eventcube.testevents test
on ecs.applicationid = test.applicationid
where test.applicationid is null
and ecs.enddate < current_date
;

-- Get the (Non-Disabled) Event Users
drop table if exists jt.dp529_users;
create table jt.dp529_users as
select distinct users.applicationid
     , users.userid
     , users.globaluserid
     , max(users.isdisabled) as isdisabled
     , coalesce(ucs.sessions,0) as sessions
from authdb_is_users users
join (select * from jt.dp529_events where directmessaging = 1 or topicchannel = 1 or sessionchannel = 1) events
on users.applicationid = events.applicationid
left join eventcube.usercubesummary ucs
on users.userid = ucs.userid
group by 1,2,3,5
;

-- Get All Sessions (for Session Channel Enabled Events Only)
DROP TABLE IF EXISTS JT.DP529_Sessions;
CREATE TABLE JT.DP529_Sessions AS
SELECT ITEMS.ItemId
     , ITEMS.Name AS ItemName
     , TOPICS.TopicId
     , TOPICS.Name AS TopicName
     , ITEMS.ApplicationId
     , ITEMS.IsDisabled AS ItemIsDisabled
     , TOPICS.IsDisabled AS TopicsIsDisabled
     , TOPICS.IsHidden AS TopicIsHidden
FROM PUBLIC.Ratings_Item ITEMS
JOIN JT.DP529_Events EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
WHERE EVENTS.SessionChannel = 1
AND TOPICS.ListTypeId = 2
;


-- Get the View Metrics (as of running the analysis)
drop table if exists jt.dp529_views;
create table jt.dp529_views as
select views.*
from fact_views_live views
join jt.dp529_events events
on views.application_id = lower(events.applicationid)
where views.identifier in ('chat','channelList','profile','item')
and (events.directmessaging = 1 or events.topicchannel = 1 or events.sessionchannel = 1)
;

-- Get the View Metrics for just the users
drop table if exists jt.dp529_views_users;
create table jt.dp529_views_users as
select views.*
from jt.dp529_views views
join jt.dp529_users users
on views.global_user_id = lower(users.globaluserid)
and views.application_id = lower(users.applicationid)
;

-- Get the Action Metrics (as of running the analysis)
drop table if exists jt.dp529_actions;
create table jt.dp529_actions as
select actions.*
from fact_actions_live actions
join jt.dp529_events events
on actions.application_id = lower(events.applicationid)
where actions.identifier in ('chatButton','chatTextButton','chatProfileButton','addChatButton','followButton','profilePictureButton','menuItem','startSendMessage')
and (events.directmessaging = 1 or events.topicchannel = 1 or events.sessionchannel = 1)
;

-- Get the Action Metrics for just the users
drop table if exists jt.dp529_actions_users;
create table jt.dp529_actions_users as
select actions.*
from jt.dp529_actions actions
join jt.dp529_users users
on actions.global_user_id = lower(users.globaluserid)
and actions.application_id = lower(users.applicationid)
;

-- DM User Funnel
DROP TABLE JT.DP529_DMFunnel_Users;
CREATE TABLE JT.DP529_DMFunnel_Users AS
SELECT EVENTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , EVENTS.OpenEvent
     , USERS.GlobalUserId
     , USERS.UsersId
     , MICROAPP.MicroAppCnt
     , 
FROM JT.DP529_Events EVENTS
JOIN JT.DP529_Users USERS
ON EVENTS.ApplicationId = USERS.ApplicationId
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , UPPER(Global_User_Id) AS GlobalUserId
                , COUNT(CASE WHEN Identifier = 'menuItem' AND Metadata->>'Url' LIKE '%messages%' THEN 1 ELSE NULL END) AS MicroAppCnt
           FROM JT.DP529_Actions_Users
           GROUP BY 1,2
          ) MICROAPP
;

SELECT *
FROM JT.DP529_Actions_Users
WHERE Identifier = 'menuItem' AND Metadata->>'Url' LIKE '%messages%'
UNION ALL
SELECT ACTIONS.*
FROM JT.DP529_Actions_Users ACTIONS
JOIN Channels.Rooms ROOMS
ON CAST(ACTIONS.Metadata->>'ChannelId' AS BIGINT) = ROOMS.Id
WHERE ROOMS.Type = 'GROUP'
AND (ACTIONS.Identifier = 'chatTextButton' AND ACTIONS.Metadata->>'Type' = 'submit') 

;




-- DM Funnel
drop table if exists jt.dp529_dmfunnel;
create table jt.dp529_dmfunnel as
select events.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , users.registeredusers
     , users.activeusers
     , coalesce(dmmicroapp.usercnt,0) as dmmicroappusercnt
     , coalesce(dmsentmsg.usercnt,0) as dmsentmsgusercnt
     , case when users.activeusers > 0 then coalesce(dmmicroapp.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as dmmicroappuserpct
     , case when users.activeusers > 0  then coalesce(dmsentmsg.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as dmsentmsguserpct
     , coalesce(dmmicroapp.actioncnt,0) as dmmicroappactioncnt
     , coalesce(dmsentmsg.actioncnt,0) as dmsentmsgactioncnt
-- Event Population
from jt.dp529_events events
-- Event User Counts
join (select applicationid
           , count(*) as registeredusers
           , count(case when sessions > 0 then 1 else null end) as activeusers
      from jt.dp529_users
      group by 1) users
on events.applicationid = users.applicationid
-- Users that clicked on the DM Microapp
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users
           where identifier = 'menuItem'
           and metadata->>'Url' like '%messages%'
           group by 1
           ) dmmicroapp
on users.applicationid = dmmicroapp.applicationid
-- Users that sent a message
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           and rooms.type = 'GROUP'
           group by 1
           ) dmsentmsg
on users.applicationid = dmsentmsg.applicationid
where events.directmessaging = 1
;




-- TC Funnel
drop table if exists jt.dp529_tcfunnel;
create table jt.dp529_tcfunnel as
select events.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , users.registeredusers
     , users.activeusers
     , coalesce(tcmicroapp.usercnt,0) as tcmicroappusercnt
     , coalesce(tcchannelview.usercnt,0) as tcchannelviewusercnt
     , coalesce(tcchanneljoin.usercnt,0) as tcchanneljoinusercnt
     , coalesce(tcchannelsent.usercnt,0) as tcchannelsentusercnt
     , coalesce(tcmicroapp.actioncnt,0) as tcmicroappactioncnt
     , case when users.activeusers > 0 then coalesce(tcmicroapp.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as tcmicroappuserpct
     , case when users.activeusers > 0 then coalesce(tcchannelview.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as tcchannelviewuserpct
     , case when users.activeusers > 0 then coalesce(tcchanneljoin.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as tcchanneljoinuserpct
     , case when users.activeusers > 0 then coalesce(tcchannelsent.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as tcchannelsentuserpct
     , coalesce(tcchannelview.actioncnt,0) as tcchannelviewactioncnt
     , coalesce(tcchannelsent.actioncnt,0) as tcchannelsentactioncnt
-- Event Population
from jt.dp529_events events
-- Event User Counts
join (select applicationid
           , count(*) as registeredusers
           , count(case when sessions > 0 then 1 else null end) as activeusers
      from jt.dp529_users
      group by 1) users
on events.applicationid = users.applicationid
-- Users that clicked on the TC Microapp
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           where actions.identifier = 'menuItem'
           and metadata->>'Url' like '%channel%'
           group by 1
           ) tcmicroapp
on users.applicationid = tcmicroapp.applicationid
-- Users that viewed a channel
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatButton'
           and actions.metadata->>'Type' = 'channel'
           and rooms.type = 'TOPIC'
           group by 1
           ) tcchannelview
on users.applicationid = tcchannelview.applicationid           
-- Users that joined a channel
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatButton'
           and actions.metadata->>'Type' in ('join', 'firstjoin', 'infojoin')
           and rooms.type = 'TOPIC'
           group by 1
           ) tcchanneljoin
on users.applicationid = tcchanneljoin.applicationid 
-- Users that submitted a message
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           and rooms.type = 'TOPIC'
           group by 1
           ) tcchannelsent
on users.applicationid = tcchannelsent.applicationid  
where events.topicchannel = 1       
;

-- Session Channel Funnel
drop table if exists jt.dp529_scfunnel;
create table jt.dp529_scfunnel as
select events.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , users.registeredusers
     , users.activeusers
     , coalesce(scdetailview.usercnt,0) as scmicroappusercnt
     , coalesce(scchannelview.usercnt,0) as scchannelviewusercnt
     , coalesce(scchanneljoin.usercnt,0) as scchanneljoinusercnt
     , coalesce(scchannelsent.usercnt,0) as scchannelsentusercnt
     , coalesce(scdetailview.viewcnt,0) as scmicroappactioncnt
     , case when users.activeusers > 0 then coalesce(scdetailview.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as scmicroappuserpct
     , case when users.activeusers > 0 then coalesce(scchannelview.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as scchannelviewuserpct
     , case when users.activeusers > 0 then coalesce(scchanneljoin.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as scchanneljoinuserpct
     , case when users.activeusers > 0 then coalesce(scchannelsent.usercnt,0)::decimal(12,4)/users.activeusers::decimal(12,4) else null end as scchannelsentuserpct
     , coalesce(scchannelview.viewcnt,0) as scchannelviewcnt
     , coalesce(scchannelsent.actioncnt,0) as scchannelsentactioncnt
-- Event Population
from jt.dp529_events events
-- Event User Counts
join (select applicationid
           , count(*) as registeredusers
           , count(case when sessions > 0 then 1 else null end) as activeusers
      from jt.dp529_users
      group by 1) users
on events.applicationid = users.applicationid
-- Users that view the Session Detail View
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as viewcnt
           from jt.dp529_views_users views
           join JT.DP529_Sessions SESSIONS
           on CAST(Metadata->>'ItemId' AS BIGINT) =  SESSIONS.ItemId
           WHERE views.identifier = 'item'
           AND views.Metadata->>'ItemId' ~ '^[0-9]*$'
           group by 1
          ) scdetailview
on users.applicationid = scdetailview.applicationid
-- Users that viewed a session channel chat view
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as viewcnt
           from jt.dp529_views_users views
           join channels.rooms rooms
           on cast(views.metadata->>'ChannelId' as bigint) = rooms.id
           where views.identifier = 'chat'
           and (metadata->'ItemId') IS NOT NULL
           and rooms.type = 'SESSION'
           group by 1
           ) scchannelview
on users.applicationid = scchannelview.applicationid           
-- Users that joined a channel
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatButton'
           and actions.metadata->>'Type' in ('join', 'firstjoin', 'infojoin')
           and (metadata->'ItemId') IS NOT NULL
           and rooms.type = 'SESSION'
           group by 1
           ) scchanneljoin
on users.applicationid = scchanneljoin.applicationid 
-- Users that submitted a message
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_actions_users actions
           join channels.rooms rooms
           on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
           where actions.identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           and (metadata->'ItemId') IS NOT NULL   
           and rooms.type = 'SESSION'
           group by 1
           ) scchannelsent
on users.applicationid = scchannelsent.applicationid  
where events.sessionchannel = 1       
;

--- New Results
-- Direct Messaging
SELECT CAST(EXTRACT(YEAR FROM EndDate) * 100 + EXTRACT(MONTH FROM EndDate) AS INT) AS YYYYMM
     , COUNT(*) AS EventCnt
     , AVG(dmmicroappuserpct) * 100 AS DMMAClickPct
     , AVG(DMsentmsguserpct) * 100 AS DMSentPct
FROM JT.DP529_DMFunnel
GROUP BY 1
ORDER BY 1
;


-- Topic Channel
SELECT CAST(EXTRACT(YEAR FROM EndDate) * 100 + EXTRACT(MONTH FROM EndDate) AS INT) AS YYYYMM
     , COUNT(*) AS EventCnt
     , AVG(TcMicroAppUserPct) * 100 AS TopicChannelMAClickPct
     , AVG(Tcchannelviewuserpct) * 100 AS TopicChannelViewPct
     , AVG(Tcchanneljoinuserpct) * 100 AS TopicChannelJoinPct
     , AVG(Tcchannelsentuserpct) * 100 AS TopicChannelSentPct
FROM JT.DP529_TCFunnel
GROUP BY 1
ORDER BY 1
;

-- Session Channel
SELECT CAST(EXTRACT(YEAR FROM EndDate) * 100 + EXTRACT(MONTH FROM EndDate) AS INT) AS YYYYMM
     , COUNT(*) AS EventCnt
     , AVG(ScMicroAppUserPct) * 100 AS SessionDetailViewPct
     , AVG(scchannelviewuserpct) * 100 AS SessionChannelViewPct
     , AVG(scchanneljoinuserpct) * 100 AS SessionChannelJoinPct
     , AVG(scchannelsentuserpct) * 100 AS SessionChannelSentPct
FROM JT.DP529_SCFunnel
GROUP BY 1
ORDER BY 1
;






-- Results

-- Event Counts
select count(case when directmessaging = 1 then 1 else null end) as "How many events have used DM?"
     , count(case when topicchannel = 1 then 1 else null end) as "How many events have used Channels?"
     , count(case when sessionchannel = 1 then 1 else null end) as "How many events have used Session Channel?" 
from jt.dp529_events
;

-- Event Level Topic Channels Funnel
select tc.applicationid as "Application ID"
     , tc.name as "Event Name"
     , tc.startdate as "Event Start Date"
     , tc.enddate as "Event End Date"
     , case when tc.openevent = 1 then 'Open' else 'Closed' end as "Registration Type"
     , tc.tc as "How many channels were set up in the event?"
     , tc.activeusers as "Total Active Users"
     , tcmicroappusercnt as "Total Active Users View Channel List"
     , tcchannelviewusercnt as "Total Active Users Viewed at Least 1 Channel"
     , tcchanneljoinusercnt as "Total Active Users Joined at Least 1 Channel"
     , tcchannelsentusercnt as "Total Active Users Sent at Least 1 Channel Message"
     , tcmicroappuserpct as "What % of active users viewed the Channels list?"
     , tcchannelviewuserpct as "What % tapped through from the Channels list to view an individual Channel?"
     , tcchanneljoinuserpct as "What % of active users joined at least 1 channel?"
     , tcchannelsentuserpct as "What % of active users sent a message in a channel?"
     , tcchannelviewactioncnt as "How many times (total) was the Channels list viewed by all attendees"
     , dmmicroappactioncnt as "How many times (total) was the DM list viewed by all attendees"
     , agendaactioncnt as "How many times (total) was the Activity Feed viewed by all attendees"
     , tcchannelsentactioncnt as "How many total Channels messages were sent"
     , dmsentmsgactioncnt as "How many total DMs were sent"
     , statusesactioncnt as "How many total Status Updates were posted"
from jt.dp529_tcfunnel tc
left join jt.dp529_dmfunnel dm
on tc.applicationid = dm.applicationid
order by 3,4,1
;


-- Event Level DM Funnel
select applicationid as "Application ID"
     , name as "Event Name"
     , startdate as "Event Start Date"
     , enddate as "Event End Date"
     , case when openevent = 1 then 'Open' else 'Closed' end as "Registration Type"
     , activeusers as "Total Active Users"
     , dmmicroappusercnt as "Total active users viewed the DM list"
     , dmsentmsgusercnt as "Total active users sent at least one DM"
     , dmmicroappuserpct as "What % of active users viewed the DM list?"
     , dmsentmsguserpct as "What % of active users sent at least one DM?"
from jt.dp529_dmfunnel
order by 3,4,1
;


