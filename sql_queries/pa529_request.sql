-- Get the Events
drop table if exists jt.dp529_events;
create table jt.dp529_events as
select ecs.applicationid
     , ecs.name
     , ecs.startdate
     , ecs.enddate
     , ecs.eventtype
     , ecs.openevent
     , case when ecs.directmessaging = 1 /*and ecs.binaryversion >= '6'*/ then 1 else 0 end as dmflag
     , case when ecs.topicchannel = 1 /*and (ecs.binaryversion <> '6.1' and ecs.binaryversion <> '6.1.%' and ecs.binaryversion <> '6.0' and ecs.binaryversion <> '6.0.%')*/ then 1 else 0 end as tcflag
     , ecs.topicchannelcnt as tc
     , case when ecs.sessionchannel = 1 /*and ecs.binaryversion >= '6.8'*/ then 1 else 0 end as scflag
from eventcube.eventcubesummary ecs
left join eventcube.testevents test
on ecs.applicationid = test.applicationid
where test.applicationid is null
and ecs.enddate < current_date
/*
and ((ecs.binaryversion >= '6.8' and ecs.sessionchannel = 1)
or (ecs.binaryversion >= '6.2' and ecs.topicchannel = 1)
or (ecs.binaryversion >= '6' and ecs.directmessaging = 1))
*/
and ecs.binaryversion >= '6' and (ecs.sessionchannel = 1 or ecs.topicchannel = 1 or ecs.directmessaging = 1)
;

-- Get the (Non-Disabled) Event Users
drop table if exists jt.dp529_users;
create table jt.dp529_users as
select distinct users.applicationid
     , users.userid
     , users.globaluserid
     , coalesce(ucs.sessions,0) as sessions
from authdb_is_users users
join jt.dp529_events events
on users.applicationid = events.applicationid
left join eventcube.usercubesummary ucs
on users.userid = ucs.userid
where users.isdisabled = 0
;

-- Get the View Metrics (as of running the analysis)
drop table if exists jt.dp529_views;
create table jt.dp529_views as
select views.*
from fact_views_live views
join jt.dp529_events events
on views.application_id = lower(events.applicationid)
where views.identifier in ('chat','channelList','profile','list', 'activities')
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
where events.dmflag = 1
;




-- TC Funnel
drop table if exists jt.dp529_tcfunnel;
create table jt.dp529_tcfunnel as
select events.applicationid
     , events.name
     , events.startdate
     , events.enddate
     , events.openevent
     , events.dmflag
     , events.tc
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
     , coalesce(agenda.actioncnt,0) as agendaactioncnt
     , coalesce(activityfeed.actioncnt,0) as activityfeedactioncnt
     , coalesce(tcchannelsent.actioncnt,0) as tcchannelsentactioncnt
     , coalesce(statuses.actioncnt,0) as statusesactioncnt
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
-- Users that see the activity feed
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_views_users
           where identifier = 'activities'
           and metadata->>'Type' = 'global'
           group by 1
           ) activityfeed
on users.applicationid = activityfeed.applicationid 
-- Users that see agenda
left join (select upper(application_id) as applicationid
                , count(distinct global_user_id) as usercnt
                , count(*) as actioncnt
           from jt.dp529_views_users views
           join ratings_topic topic
           on cast(views.metadata->>'ListId' as bigint) = topic.topicid
           where views.identifier = 'list'
           AND metadata->>'ListId' NOT IN ('listID','items','dd://agenda/')
           --and cast(views.metadata->>'ListId' as varchar) <> 'items'
           and topic.listtypeid = 2
           and topic.isdisabled = 0
           group by 1
           ) agenda
on users.applicationid = agenda.applicationid
-- Status Updates
left join (select ins.applicationid
                , count(distinct userid) as usercnt
                , count(*) as actioncnt
           from ratings_usercheckins ins
           join ratings_usercheckinnotes notes
           on ins.checkinid = notes.checkinid
           join jt.dp529_events events
           on ins.applicationid = events.applicationid
           where ins.isdisabled = false
           group by 1
           ) statuses
on users.applicationid = statuses.applicationid
where events.tcflag = 1       
;

-- Results

-- Event Counts
select count(case when dmflag = 1 then 1 else null end) as "How many events have used DM?"
     , count(case when tcflag = 1 then 1 else null end) as "How many events have used Channels?"
     , count(case when scflag = 1 then 1 else null end) as "How many events have used Session Channel?" 
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
