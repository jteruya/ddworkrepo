
-- Get all Non-Disabled Registered Users
drop table if exists jt.pa549_registered_users;
create table jt.pa549_registered_users as
select distinct users.applicationid
     , users.globaluserid
     , users.userid
     , gud.externalimageid
     , gud.title
     , gud.company
     , ud.facebookuserid
     , ud.twitterusername
     , ud.linkedinid
from eventcube.eventcubesummary ecs
join (select distinct applicationid
           , globaluserid
           , userid
      from authdb_is_users
      where isdisabled = 0) users
on ecs.applicationid = users.applicationid
join ratings_globaluserdetails gud
on lower(users.globaluserid) = gud.globaluserid
join ratings_userdetails ud
on users.globaluserid = ud.globaluserid
and users.applicationid = ud.applicationid
left join eventcube.testevents tc
on ecs.applicationid = tc.applicationid
where tc.applicationid is null
and ecs.startdate >= '2016-01-01'
and ud.isdisabled = 0
and gud.isdisabled = 0
;

-- Look for Users w/ more than 1 record.
select applicationid
     , globaluserid
     , userid
from jt.pa549_registered_users
group by 1,2,3
having count(*) > 1
;

-- 2 Users w/ multiple records (Need to filter out):

-- Application ID: 7C048F26-EA82-405A-8549-57FD241DDB8C
-- Global User ID: E3576AAA-528E-43C2-9EDA-DC284ED8A651
-- User ID: 46770315

-- Application ID: 7C048F26-EA82-405A-8549-57FD241DDB8C
-- Global User ID: E3576AAA-528E-43C2-9EDA-DC284ED8A651
-- User ID: 46770316

select distinct application_id
     , global_user_id
from fact_views_live
where identifier = 'activities'
and application_id in (select distinct lower(applicationid) from jt.pa549_registered_users);


-- Get all Non-Disabled Active Users
drop table if exists jt.pa549_active_users;
create table jt.pa549_active_users as
select users.*
     , sessions.sessions
     , iphone_sessions
     , ipad_sessions
     , android_sessions
     , html5_sessions
     , case
         when activityfeed is not null then 1
         else 0
       end as activityfeedflag
from jt.pa549_registered_users users
join eventcube.agg_session_per_appuser sessions
on users.applicationid = sessions.applicationid
and users.userid = sessions.userid
left join (select distinct upper(application_id) as applicationid
                , upper(global_user_id) as globaluserid
           from fact_views_live
           where identifier = 'activities'
           and application_id in (select distinct lower(applicationid) from jt.pa549_registered_users)
           ) activityfeed
on users.applicationid = activityfeed.applicationid
and users.globaluserid = activityfeed.globaluserid
-- Include only users that have sessions
where sessions > 0
-- Exclude two duplicate users
and users.applicationid <> '7C048F26-EA82-405A-8549-57FD241DDB8C' 
and users.globaluserid <> 'E3576AAA-528E-43C2-9EDA-DC284ED8A651' 
and users.userid <> 46770315 
and users.userid <> 46770316
;

select count(*)
from jt.pa549_registered_users;
-- 842944

select count(*)
from jt.pa549_active_users;
-- 478534

-- Check if join w/ agg_session_per_appuser caused duplicates
select applicationid
     , globaluserid
     , userid
from jt.pa549_active_users
group by 1,2,3
having count(*) > 1
;
-- None

-- Overall Results
select count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
;

-- Results (by Device Type)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
group by 1
;


-- Results (by Reg Type)
select case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1
;

-- Results (by Event Type)
select case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1
;

-- Results (by Device Type & Reg Type)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"   
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1,2
;


-- Results (by Event Type & Reg Type)
select case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"   
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1,2
;


-- Results (by Device Type & Event Type)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"   
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1,2
;


-- Results (by Device Type & Event Type & Reg Type)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
group by 1,2,3
;


-- Overall Results (No Linked In Account)
select count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
and linkedinid is null
;


-- Results (by Device Type & No LinkedIn)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
and linkedinid is null
group by 1
;


-- Results (by Reg Type & No LinkedIn)
select case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
and linkedinid is null
group by 1
;

-- Results (by Event Type & No LinkedIn)
select case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
and linkedinid is null
group by 1
;

-- Overall Results (Linked In Account)
select count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
and linkedinid is not null
;

-- Results (by Device Type & LinkedIn)
select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as "Device Type"
     , count(*) as "Active Users Count"
     , count(distinct applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users
where activityfeedflag = 1
and linkedinid is not null
group by 1
;


-- Results (by Reg Type & LinkedIn)
select case
          when ecs.openevent = 0 then 'closed'
          else 'open'
       end as "Event Registration Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
and linkedinid is not null
group by 1
;

-- Results (by Event Type & LinkedIn)
select case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as "Event Type"
     , count(*) as "Active Users Count"
     , count(distinct users.applicationid) as "Event Count"
     
     -- User Counts
     , count(case when externalimageid is not null then 1 else null end) as "Active Users w/Image Count"
     , count(case when title is not null and trim(title) <> '' then 1 else null end) as "Active Users w/Title Count"
     , count(case when company is not null and trim(company) <> '' then 1 else null end) as "Active Users w/Company Count"
     , count(case when facebookuserid > 0 then 1 else null end) as "Active Users w/FB Account Count"
     , count(case when twitterusername is not null then 1 else null end) as "Active Users w/Twitter Account Count"
     , count(case when linkedinid is not null then 1 else null end) as "Active Users w/ Linkedin Account Count"

     -- User Percents
     , count(case when externalimageid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Image %"
     , count(case when title is not null and trim(title) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Title %"
     , count(case when company is not null and trim(company) <> '' then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Company %"
     , count(case when facebookuserid > 0 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/FB Account %"
     , count(case when twitterusername is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/Twitter Account %"
     , count(case when linkedinid is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as "Active Users w/ Linkedin Account %"  
from jt.pa549_active_users users
join eventcube.eventcubesummary ecs
on users.applicationid = ecs.applicationid
where activityfeedflag = 1
and linkedinid is not null
group by 1
;

