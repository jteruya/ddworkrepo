-- Pulling the Following Metrics for Saastr with the following conditions:
-- (1) All Records Relate to Saastr (Application ID: b9459b82-09b5-43f7-a730-c890dc882a8d)
-- (2) All Records are run from 1/1/2016 - present.  Originally run on 2/17/2016.

-- Get the Session for Saastr
drop table if exists jt.saastr_sessions;
create table jt.saastr_sessions as
select *
from fact_sessions_live
where application_id = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
and created >= '2016-01-01'
and identifier = 'start';

-- Get the Actions for Saastr
drop table if exists jt.saastr_actions;
create table jt.saastr_actions as
select *
from public.fact_actions_live
where application_id = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
and created >= '2016-01-01';

-- Get the Views for Saastr
drop table if exists jt.saastr_views;
create table jt.saastr_views as
select *
from public.fact_views_live
where application_id = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
and created >= '2016-01-01';

-- Pulling the distinct, non-disabled users
-- The non-disabled status is as of when this is run which was 2/17/2016

-- Get the Users for Saastr
drop table if exists jt.saastr_users;
create table jt.saastr_users as
select users.userid
     , users.globaluserid
     , count(case when sessions.global_user_id is not null then 1 else null end) as sessioncnt
from (select distinct userid
           , globaluserid
      from authdb_is_users
      where applicationid = 'B9459B82-09B5-43F7-A730-C890DC882A8D'
      and isdisabled = 0) users
left join jt.saastr_sessions sessions
on lower(users.globaluserid) = sessions.global_user_id
group by 1,2;

-- Overall Stats

-- Get the user counts

-- Total active users
select count(*) as userscnt
     , count(case when sessioncnt > 0 then 1 else null end) as activeuserscnt
from jt.saastr_users;

-- Total Registered Users: 2825
-- Active Users: 2797

-- Get the number of taps on the Agenda, Channels and DM micro app.

-- Find out what the different menu items are:
-- dd://agenda/10301874 -> Agenda
-- dd://agenda/10306657 -> Social Events
-- dd://topic/10307026 _> Companies Attending
-- dd://topic/10303013 -> Sponsors
-- dd://topic/10301875 -> Speakers
-- dd://topic/10304438 -> VC's

select metadata->>'Url'
     , count(*) as tapcnt
from jt.saastr_actions
where identifier = 'menuItem'
and (metadata->>'Url' = 'dd://agenda/10301874' or metadata->>'Url' like '%channels%' or metadata->>'Url' like '%messages%')
group by 1
order by 1;

-- DM: 3936
-- Channels: 2359
-- Agenda List: 24634

-- Get the Activity Feed View Counts

select count(*)
from jt.saastr_views
where identifier = 'activities'
and metadata->>'Type' = 'global';

-- Activity Feed (Global): 62,109

-- Get the Status Updates Posted Counts

select count(*)
from jt.saastr_actions
where identifier = 'submitStatusUpdateButton';

-- Status Updates Posted: 1354

-- DM Stats
-- Pulled from the DD dashboard on 2/17/2016

-- Channels Stats

-- Get the number of users that list on the channel list
-- Take this from the micro app taps because the view metrics "channels" doesn't appear to fire on Android

select count(distinct global_user_id) as tapcnt
from jt.saastr_actions
where identifier = 'menuItem'
and metadata->>'Url' like '%channels%';

-- 743 Channel List View

-- Get the channelid metadata from CMS
-- From the CMS
-- Elevator Pitches: 7337
-- Who's Hiring: 7336
-- Marketing and Growth: 7334
-- Sales and SDR: 7333
-- Customer Success: 7332
-- Scaling: 7331
-- Product and Engineering: 7330
-- Happy Hour: 7329


-- Old Code to tie users and channel behavior.  Not used because the "channels" and "chat" view metrics on Android not working.

/*
drop table if exists jt.saastr_users_channels;
create table jt.saastr_users_channels as
select users.*
     , coalesce(dmsent.dmsent, 0) as dmsent

     , coalesce(channellist.chlistviewcnt, 0) as channellistcnt 
     
     , coalesce(channelview.ch1viewcnt, 0) as ch1viewcnt
     , coalesce(channelview.ch2viewcnt, 0) as ch2viewcnt
     , coalesce(channelview.ch3viewcnt, 0) as ch3viewcnt
     , coalesce(channelview.ch4viewcnt, 0) as ch4viewcnt
     , coalesce(channelview.ch5viewcnt, 0) as ch5viewcnt
     , coalesce(channelview.ch6viewcnt, 0) as ch6viewcnt
     , coalesce(channelview.ch7viewcnt, 0) as ch7viewcnt
     , coalesce(channelview.ch8viewcnt, 0) as ch8viewcnt  
      
     , coalesce(channeljoin.ch1joincnt, 0) as ch1joincnt
     , coalesce(channeljoin.ch2joincnt, 0) as ch2joincnt
     , coalesce(channeljoin.ch3joincnt, 0) as ch3joincnt
     , coalesce(channeljoin.ch4joincnt, 0) as ch4joincnt
     , coalesce(channeljoin.ch5joincnt, 0) as ch5joincnt
     , coalesce(channeljoin.ch6joincnt, 0) as ch6joincnt
     , coalesce(channeljoin.ch7joincnt, 0) as ch7joincnt
     , coalesce(channeljoin.ch8joincnt, 0) as ch8joincnt 
     
     , coalesce(channelsent.ch1sentcnt, 0) as ch1sentcnt
     , coalesce(channelsent.ch2sentcnt, 0) as ch2sentcnt
     , coalesce(channelsent.ch3sentcnt, 0) as ch3sentcnt
     , coalesce(channelsent.ch4sentcnt, 0) as ch4sentcnt
     , coalesce(channelsent.ch5sentcnt, 0) as ch5sentcnt
     , coalesce(channelsent.ch6sentcnt, 0) as ch6sentcnt
     , coalesce(channelsent.ch7sentcnt, 0) as ch7sentcnt
     , coalesce(channelsent.ch8sentcnt, 0) as ch8sentcnt       
 
     , coalesce(channeloff.ch1offcnt, 0) as ch1offcnt
     , coalesce(channeloff.ch2offcnt, 0) as ch2offcnt
     , coalesce(channeloff.ch3offcnt, 0) as ch3offcnt
     , coalesce(channeloff.ch4offcnt, 0) as ch4offcnt
     , coalesce(channeloff.ch5offcnt, 0) as ch5offcnt
     , coalesce(channeloff.ch6offcnt, 0) as ch6offcnt
     , coalesce(channeloff.ch7offcnt, 0) as ch7offcnt
     , coalesce(channeloff.ch8offcnt, 0) as ch8offcnt   
            
from jt.saastr_users users
left join (select global_user_id
                , count(*) as chlistviewcnt
           from jt.saastr_actions           
           where identifier = 'menuItem' 
           and metadata->>'Url' = 'dd://channels/'
           group by 1) channellist
on lower(users.globaluserid) = channellist.global_user_id
left join (select views.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1viewcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2viewcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3viewcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4viewcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5viewcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6viewcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7viewcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8viewcnt
           from jt.saastr_views views
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(views.metadata->>'ChannelId' as int) = id
           where views.identifier = 'chat'
           group by 1) channelview          
on lower(users.globaluserid) = channelview.global_user_id
left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1joincnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2joincnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3joincnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4joincnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5joincnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6joincnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7joincnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8joincnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatButton'
           and actions.metadata->>'Type' in ('join', 'firstjoin', 'infojoin')
           group by 1) channeljoin
on lower(users.globaluserid) = channeljoin.global_user_id

left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1sentcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2sentcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3sentcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4sentcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5sentcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6sentcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7sentcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8sentcnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           group by 1) channelsent
on lower(users.globaluserid) = channelsent.global_user_id

left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1offcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2offcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3offcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4offcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5offcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6offcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7offcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8offcnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatButton'
           and actions.metadata->>'Type' = 'notifications'
           and actions.metadata->>'ToggledTo' = 'off'
           group by 1) channeloff
on lower(users.globaluserid) = channeloff.global_user_id

left join (select actions.global_user_id
                , count(*) as dmsent
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'GROUP') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           group by 1) dmsent
on lower(users.globaluserid) = dmsent.global_user_id

;
*/

-- Create table with User level Channel Stats
drop table if exists jt.saastr_users_channels_2;
create table jt.saastr_users_channels_2 as
select users.*
     , coalesce(dmsent.dmsent, 0) as dmsent

     , coalesce(channellist.chlistviewcnt, 0) as channellistcnt 
     
     , coalesce(channelview.ch1viewcnt, 0) as ch1viewcnt
     , coalesce(channelview.ch2viewcnt, 0) as ch2viewcnt
     , coalesce(channelview.ch3viewcnt, 0) as ch3viewcnt
     , coalesce(channelview.ch4viewcnt, 0) as ch4viewcnt
     , coalesce(channelview.ch5viewcnt, 0) as ch5viewcnt
     , coalesce(channelview.ch6viewcnt, 0) as ch6viewcnt
     , coalesce(channelview.ch7viewcnt, 0) as ch7viewcnt
     , coalesce(channelview.ch8viewcnt, 0) as ch8viewcnt  
      
     , coalesce(channeljoin.ch1joincnt, 0) as ch1joincnt
     , coalesce(channeljoin.ch2joincnt, 0) as ch2joincnt
     , coalesce(channeljoin.ch3joincnt, 0) as ch3joincnt
     , coalesce(channeljoin.ch4joincnt, 0) as ch4joincnt
     , coalesce(channeljoin.ch5joincnt, 0) as ch5joincnt
     , coalesce(channeljoin.ch6joincnt, 0) as ch6joincnt
     , coalesce(channeljoin.ch7joincnt, 0) as ch7joincnt
     , coalesce(channeljoin.ch8joincnt, 0) as ch8joincnt 
     
     , coalesce(channelsent.ch1sentcnt, 0) as ch1sentcnt
     , coalesce(channelsent.ch2sentcnt, 0) as ch2sentcnt
     , coalesce(channelsent.ch3sentcnt, 0) as ch3sentcnt
     , coalesce(channelsent.ch4sentcnt, 0) as ch4sentcnt
     , coalesce(channelsent.ch5sentcnt, 0) as ch5sentcnt
     , coalesce(channelsent.ch6sentcnt, 0) as ch6sentcnt
     , coalesce(channelsent.ch7sentcnt, 0) as ch7sentcnt
     , coalesce(channelsent.ch8sentcnt, 0) as ch8sentcnt       
 
     , coalesce(channeloff.ch1offcnt, 0) as ch1offcnt
     , coalesce(channeloff.ch2offcnt, 0) as ch2offcnt
     , coalesce(channeloff.ch3offcnt, 0) as ch3offcnt
     , coalesce(channeloff.ch4offcnt, 0) as ch4offcnt
     , coalesce(channeloff.ch5offcnt, 0) as ch5offcnt
     , coalesce(channeloff.ch6offcnt, 0) as ch6offcnt
     , coalesce(channeloff.ch7offcnt, 0) as ch7offcnt
     , coalesce(channeloff.ch8offcnt, 0) as ch8offcnt   
            
from jt.saastr_users users
left join (select global_user_id
                , count(*) as chlistviewcnt
           from jt.saastr_actions           
           where identifier = 'menuItem' 
           and metadata->>'Url' = 'dd://channels/'
           group by 1) channellist
on lower(users.globaluserid) = channellist.global_user_id
left join (select views.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1viewcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2viewcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3viewcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4viewcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5viewcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6viewcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7viewcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8viewcnt
           from jt.saastr_actions views
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(views.metadata->>'ChannelId' as int) = id
           where views.identifier = 'chatButton'
           and views.metadata->>'Type' = 'channel'
           group by 1) channelview          
on lower(users.globaluserid) = channelview.global_user_id
left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1joincnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2joincnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3joincnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4joincnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5joincnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6joincnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7joincnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8joincnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatButton'
           and actions.metadata->>'Type' in ('join', 'firstjoin', 'infojoin')
           group by 1) channeljoin
on lower(users.globaluserid) = channeljoin.global_user_id

left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1sentcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2sentcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3sentcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4sentcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5sentcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6sentcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7sentcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8sentcnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           group by 1) channelsent
on lower(users.globaluserid) = channelsent.global_user_id

left join (select actions.global_user_id
                , count(case when channels.id = 7337 then 1 else null end) as ch1offcnt
                , count(case when channels.id = 7336 then 1 else null end) as ch2offcnt
                , count(case when channels.id = 7334 then 1 else null end) as ch3offcnt
                , count(case when channels.id = 7333 then 1 else null end) as ch4offcnt
                , count(case when channels.id = 7332 then 1 else null end) as ch5offcnt
                , count(case when channels.id = 7331 then 1 else null end) as ch6offcnt
                , count(case when channels.id = 7330 then 1 else null end) as ch7offcnt
                , count(case when channels.id = 7329 then 1 else null end) as ch8offcnt
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'TOPIC') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatButton'
           and actions.metadata->>'Type' = 'notifications'
           and actions.metadata->>'ToggledTo' = 'off'
           group by 1) channeloff
on lower(users.globaluserid) = channeloff.global_user_id

left join (select actions.global_user_id
                , count(*) as dmsent
           from jt.saastr_actions actions
           join (select *
                 from channels.rooms
                 where applicationid = 'b9459b82-09b5-43f7-a730-c890dc882a8d'
                 and type = 'GROUP') channels
           on cast(actions.metadata->>'ChannelId' as int) = id
           where identifier = 'chatTextButton'
           and actions.metadata->>'Type' = 'submit'
           group by 1) dmsent
on lower(users.globaluserid) = dmsent.global_user_id

;

-- Old Code to tie users and channel behavior.  Not used because the "channels" and "chat" view metrics on Android not working.

/*
select count(*) as users
     , count(case when sessioncnt > 0 then 1 else null end) as activeusers
     , count(case when channellistcnt > 0 then 1 else null end) as channellistusers
     , count(case when ch1viewcnt > 0 or ch2viewcnt > 0 or ch3viewcnt > 0 or ch4viewcnt > 0 or ch5viewcnt > 0 or ch6viewcnt > 0 or ch7viewcnt > 0 or ch8viewcnt > 0 then 1 else null end) as viewchannel
     , count(case when ch1joincnt > 0 or ch2joincnt > 0 or ch3joincnt > 0 or ch4joincnt > 0 or ch5joincnt > 0 or ch6joincnt > 0 or ch7joincnt > 0 or ch8joincnt > 0 then 1 else null end) as joinchannel

     , count(case when ch1viewcnt > 0 then 1 else null end) as ch1viewcnt
     , count(case when ch2viewcnt > 0 then 1 else null end) as ch2viewcnt
     , count(case when ch3viewcnt > 0 then 1 else null end) as ch3viewcnt
     , count(case when ch4viewcnt > 0 then 1 else null end) as ch4viewcnt
     , count(case when ch5viewcnt > 0 then 1 else null end) as ch5viewcnt
     , count(case when ch6viewcnt > 0 then 1 else null end) as ch6viewcnt
     , count(case when ch7viewcnt > 0 then 1 else null end) as ch7viewcnt
     , count(case when ch8viewcnt > 0 then 1 else null end) as ch8viewcnt  

     , count(case when ch1joincnt > 0 then 1 else null end) as ch1joincnt
     , count(case when ch2joincnt > 0 then 1 else null end) as ch2joincnt
     , count(case when ch3joincnt > 0 then 1 else null end) as ch3joincnt
     , count(case when ch4joincnt > 0 then 1 else null end) as ch4joincnt
     , count(case when ch5joincnt > 0 then 1 else null end) as ch5joincnt
     , count(case when ch6joincnt > 0 then 1 else null end) as ch6joincnt
     , count(case when ch7joincnt > 0 then 1 else null end) as ch7joincnt
     , count(case when ch8joincnt > 0 then 1 else null end) as ch8joincnt 

     , count(case when ch1sentcnt > 0 then 1 else null end) as ch1sentcnt
     , count(case when ch2sentcnt > 0 then 1 else null end) as ch2sentcnt
     , count(case when ch3sentcnt > 0 then 1 else null end) as ch3sentcnt
     , count(case when ch4sentcnt > 0 then 1 else null end) as ch4sentcnt
     , count(case when ch5sentcnt > 0 then 1 else null end) as ch5sentcnt
     , count(case when ch6sentcnt > 0 then 1 else null end) as ch6sentcnt
     , count(case when ch7sentcnt > 0 then 1 else null end) as ch7sentcnt
     , count(case when ch8sentcnt > 0 then 1 else null end) as ch8sentcnt       

     , sum(ch1sentcnt) as ch1sentmsgcnt
     , sum(ch2sentcnt) as ch2sentmsgcnt
     , sum(ch3sentcnt) as ch3sentmsgcnt
     , sum(ch4sentcnt) as ch4sentmsgcnt
     , sum(ch5sentcnt) as ch5sentmsgcnt
     , sum(ch6sentcnt) as ch6sentmsgcnt
     , sum(ch7sentcnt) as ch7sentmsgcnt
     , sum(ch8sentcnt) as ch8sentmsgcnt  

     , count(case when ch1offcnt > 0 then 1 else null end) as ch1offcnt
     , count(case when ch2offcnt > 0 then 1 else null end) as ch2offcnt
     , count(case when ch3offcnt > 0 then 1 else null end) as ch3offcnt
     , count(case when ch4offcnt > 0 then 1 else null end) as ch4offcnt
     , count(case when ch5offcnt > 0 then 1 else null end) as ch5offcnt
     , count(case when ch6offcnt > 0 then 1 else null end) as ch6offcnt
     , count(case when ch7offcnt > 0 then 1 else null end) as ch7offcnt
     , count(case when ch8offcnt > 0 then 1 else null end) as ch8offcnt        
     
     , sum(dmsent) as dmsent
     , count(distinct case when dmsent > 0 then globaluserid else null end) as usersdmsent
from jt.saastr_users_channels;
*/

-- Pulling the channel numbers

select count(*) as users
     , count(case when sessioncnt > 0 then 1 else null end) as activeusers
     , count(case when channellistcnt > 0 then 1 else null end) as channellistusers
     , count(case when ch1viewcnt > 0 or ch2viewcnt > 0 or ch3viewcnt > 0 or ch4viewcnt > 0 or ch5viewcnt > 0 or ch6viewcnt > 0 or ch7viewcnt > 0 or ch8viewcnt > 0 then 1 else null end) as viewchannel
     , count(case when ch1joincnt > 0 or ch2joincnt > 0 or ch3joincnt > 0 or ch4joincnt > 0 or ch5joincnt > 0 or ch6joincnt > 0 or ch7joincnt > 0 or ch8joincnt > 0 then 1 else null end) as joinchannel

     , count(case when ch1viewcnt > 0 then 1 else null end) as ch1viewcnt
     , count(case when ch2viewcnt > 0 then 1 else null end) as ch2viewcnt
     , count(case when ch3viewcnt > 0 then 1 else null end) as ch3viewcnt
     , count(case when ch4viewcnt > 0 then 1 else null end) as ch4viewcnt
     , count(case when ch5viewcnt > 0 then 1 else null end) as ch5viewcnt
     , count(case when ch6viewcnt > 0 then 1 else null end) as ch6viewcnt
     , count(case when ch7viewcnt > 0 then 1 else null end) as ch7viewcnt
     , count(case when ch8viewcnt > 0 then 1 else null end) as ch8viewcnt  

     , count(case when ch1joincnt > 0 then 1 else null end) as ch1joincnt
     , count(case when ch2joincnt > 0 then 1 else null end) as ch2joincnt
     , count(case when ch3joincnt > 0 then 1 else null end) as ch3joincnt
     , count(case when ch4joincnt > 0 then 1 else null end) as ch4joincnt
     , count(case when ch5joincnt > 0 then 1 else null end) as ch5joincnt
     , count(case when ch6joincnt > 0 then 1 else null end) as ch6joincnt
     , count(case when ch7joincnt > 0 then 1 else null end) as ch7joincnt
     , count(case when ch8joincnt > 0 then 1 else null end) as ch8joincnt 

     , count(case when ch1sentcnt > 0 then 1 else null end) as ch1sentcnt
     , count(case when ch2sentcnt > 0 then 1 else null end) as ch2sentcnt
     , count(case when ch3sentcnt > 0 then 1 else null end) as ch3sentcnt
     , count(case when ch4sentcnt > 0 then 1 else null end) as ch4sentcnt
     , count(case when ch5sentcnt > 0 then 1 else null end) as ch5sentcnt
     , count(case when ch6sentcnt > 0 then 1 else null end) as ch6sentcnt
     , count(case when ch7sentcnt > 0 then 1 else null end) as ch7sentcnt
     , count(case when ch8sentcnt > 0 then 1 else null end) as ch8sentcnt       

     , sum(ch1sentcnt) as ch1sentmsgcnt
     , sum(ch2sentcnt) as ch2sentmsgcnt
     , sum(ch3sentcnt) as ch3sentmsgcnt
     , sum(ch4sentcnt) as ch4sentmsgcnt
     , sum(ch5sentcnt) as ch5sentmsgcnt
     , sum(ch6sentcnt) as ch6sentmsgcnt
     , sum(ch7sentcnt) as ch7sentmsgcnt
     , sum(ch8sentcnt) as ch8sentmsgcnt  

     , count(case when ch1offcnt > 0 then 1 else null end) as ch1offcnt
     , count(case when ch2offcnt > 0 then 1 else null end) as ch2offcnt
     , count(case when ch3offcnt > 0 then 1 else null end) as ch3offcnt
     , count(case when ch4offcnt > 0 then 1 else null end) as ch4offcnt
     , count(case when ch5offcnt > 0 then 1 else null end) as ch5offcnt
     , count(case when ch6offcnt > 0 then 1 else null end) as ch6offcnt
     , count(case when ch7offcnt > 0 then 1 else null end) as ch7offcnt
     , count(case when ch8offcnt > 0 then 1 else null end) as ch8offcnt        
     
     , sum(dmsent) as dmsent
     , count(distinct case when dmsent > 0 then globaluserid else null end) as usersdmsent
from jt.saastr_users_channels_2;



