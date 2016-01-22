-- Q: What's the % of users (non-doubledutch) with access to only one event in EP?

select min(created)
     , max(created)
     , min(updated)
     , max(updated)
from ratings_dashboardusers;

-- Min Date: 2010-07-29
-- Max Date: 2015-12-05

select count(*) as totalusercnt
     , count(case when event_cnt >= 2 then 1 else null end) as manyevntusercnt 
     , count(case when event_cnt >= 2 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as manyevntuserpct
from (select userid
           , count(*) as event_cnt
      from ratings_dashboardusers
      group by 1) a;
      
-- Total Users: 10,595 
-- Multiple Event Users: 3,127
-- Multiple Event Users %: 29.51%

-- Create User Table

drop table if exists jt.ep_all_users;

create table jt.ep_all_users as
select a.userid
     , a.applicationid
     , b.globaluserid
     , b.emailaddressdomain
     , min(a.created) as first_created
     , max(a.updated) as last_updated
from (select * from authdb_is_users where applicationid = 'C6DEACD6-2869-4C8A-9CFC-8E7951AC7672' and isdisabled = 0) a   --59426 
join (select * from ratings_globaluserdetails where lower(emailaddressdomain) not like '%doubledutch%') b  --59426
on a.globaluserid = b.globaluserid
group by 1,2,3,4;

-- Q: What do users click on (attachments and Speakers, Session & Influential Attendees links)?

-- Monthly Breakdown


select cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth
     , event_label as linklabel
     , count(distinct a.global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'href'
group by 1,2
order by 1,2,3 desc;

-- Ranking (All Time)
select event_label as linklabel
     , count(distinct a.global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'href'
and date >= '2015-08-01'
group by 1
order by 2 desc;

select count(distinct a.global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'href'
and date >= '2015-08-01';

-- Ranking (All Monthly)
select cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth
     , event_label as linklabel
     , count(distinct a.global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'href'
and date >= '2015-08-01'
group by 1,2
order by 1,3 desc;

-- Q: Do users click on the "Surveys" and "Exportable Reports" subpages? For the "Surveys" subpage, do users drill down?

select a.yearmonth
     , count(distinct a.global_user_id) as pageviewusercnt
     , count(distinct case when a.page_path = '/analytics/reports' then a.global_user_id else null end) as exportablereportpgviewusercnt
     , count(distinct b.global_user_id) as exportablereportdownloadusercnt
     , count(distinct case when a.page_path = '/analytics/surveys' then a.global_user_id else null end) as surveyspgviewusercnt
     , count(distinct case when a.page_path = '/analytics/survey/<surveyId>/items' or a.page_path = '/analytics/survey/<surveyId>/<itemId>' then a.global_user_id else null end) as surveydrilldownpgviewusercnt
from (select distinct cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth, page_path, global_user_id from google.ep_pageview_counts) a
left join (select distinct cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth, global_user_id from google.ep_event_counts where event_category = 'href' and event_label <> 'Sessions' and event_label <> 'Speakers' and event_label <> 'InfluentialAttendees') b
on a.global_user_id = b.global_user_id and a.yearmonth = b.yearmonth
join jt.ep_all_users c
on a.global_user_id = lower(c.globaluserid)
group by 1
order by 1;


-- Q: Do users hover over icons in the top right for the different cards below the Event Timeline?

select cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth
     --, count(distinct event_label)
     , event_label as cardname
     , count(distinct global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'tooltip'
group by 1,2
order by 1,3 desc;

select event_label as cardname
     , count(distinct global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'tooltip'
and date >= '2015-11-01'
group by 1
order by 2 desc;

-- Q: Do users click on the timeframe or toggle the start and end dates?

select cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth
     , event_label as cardname
     , count(distinct global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'datepicker'
group by 1,2
order by 1,3 desc;

select event_label as cardname
     , count(distinct global_user_id) as usercnt
from google.ep_event_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'datepicker'
group by 1
order by 2 desc;

-- start date	933
-- end date	593
-- now	239

-- Timeframe selector doesn't have an event label.  This is causing the timeframe selector data not to be pulled out of GA.  Need to fix this.

select cast(extract(year from date) * 100 + extract(month from date) as integer) as yearmonth
     , count(distinct global_user_id) as usercnt
from google.ep_event_nolabel_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'timeframeselector'
group by 1
order by 1;

select count(distinct global_user_id) as usercnt
from google.ep_event_nolabel_counts a
join jt.ep_all_users b
on a.global_user_id = lower(b.globaluserid)
where event_category = 'timeframeselector';

-- timeframeselector 800

------ Ignore Bottom Stuff


-- EP Funnel

drop table if exists jt.ep_all_users_events;
create table jt.ep_all_users_events as
select a.userid
     , a.globaluserid
     , a.eventcnt
     , event_category
     , event_label
     , b.eventlabelcnt
from (select userid
           , globaluserid
           , count(*) as eventcnt
      from jt.ep_all_users
      group by 1,2) a
left join (select upper(global_user_id) as globaluserid
                , event_category
                , event_label
                , count(*) as eventlabelcnt
           from google.ep_event_counts
           group by 1,2,3
           union
           select upper(global_user_id) as globaluserid
                , event_category
                , null as event_label
                , count(*) as eventlabelcnt
           from google.ep_event_nolabel_counts
           group by 1,2,3) b
on a.globaluserid = b.globaluserid;


select distinct '"' || lower(event_category) || '-' || lower(event_label) || '"' as field_name
from google.ep_event_counts
union
select distinct '"' || lower(event_category) || '"' as fieldname
from google.ep_event_nolabel_counts
order by field_name;


select string_agg(field_name, ',') from (
select distinct '"' || lower(event_category) || '-' || lower(event_label) || '"' as field_name
from google.ep_event_counts
union
select distinct '"' || lower(event_category) || '"' as fieldname
from google.ep_event_nolabel_counts
order by field_name) a;





drop table if exists jt.ep_all_users_events_denorm;
create table jt.ep_all_users_events_denorm as
select b.userid
     , b.emailaddressdomain
     , b.eventcnt
     , coalesce(c.actioncnt,0) as actioncnt
     , ct.*
from crosstab(
   'select globaluserid
         , case
              when event_category = ''timeframeselector'' then upper(event_category)
              when event_category is null then ''NO EVENTS''
              else upper(event_category) || '' - '' || upper(event_label)
           end as eventcategory
         , eventlabelcnt
    from jt.ep_all_users_events'
  , 'select distinct case
                        when event_category = ''timeframeselector'' then upper(event_category)
                        else upper(event_category) || '' - '' || upper(event_label)
                     end as eventcategory
     from jt.ep_all_users_events
     where event_category is not null
     order by 1')
as ct(globaluserid text
, "BUTTON - RECOMMENDATIONS BACK" int
, "BUTTON - RECOMMENDATIONS FORWARD" int
, "CHECKBOX - APP VISITS" int
, "CHECKBOX - CHECKINS" int
, "CHECKBOX - COMMENTS" int
, "CHECKBOX - EVENT TIME" int
, "CHECKBOX - LIKES" int
, "CHECKBOX - NEW USERS" int
, "CHECKBOX - POLLS" int
, "CHECKBOX - PROMOTED POSTS" int
, "CHECKBOX - PUSH MESSAGES" int
, "CHECKBOX - STATUS UPDATES" int
, "CHECKBOX - TOTAL ACTIONS" int
, "CHECKBOX - WELCOME EMAILS" int
, "COLUMN - INFLUENTIALATTENDEES: INFLUENCERANK" int
, "COLUMN - INFLUENTIALATTENDEES: NAME" int
, "COLUMN - SESSIONS: AVERAGERATING" int
, "COLUMN - SESSIONS: BOOKMARKS" int
, "COLUMN - SESSIONS: CHECKINS" int
, "COLUMN - SESSIONS: ENGAGEMENT" int
, "COLUMN - SESSIONS: NAME" int
, "COLUMN - SESSIONS: POLLS" int
, "COLUMN - SESSIONS: POPULARITY" int
, "COLUMN - SESSIONS: REVIEWS" int
, "COLUMN - SESSIONS: SURVEYS" int
, "COLUMN - SESSIONS: UPDATES" int
, "COLUMN - SESSIONS: VIEWS" int
, "COLUMN - SPEAKERS: AVERAGERATING" int
, "COLUMN - SPEAKERS: BOOKMARKS" int
, "COLUMN - SPEAKERS: ENGAGEMENT" int
, "COLUMN - SPEAKERS: NAME" int
, "COLUMN - SPEAKERS: POPULARITY" int
, "COLUMN - SPEAKERS: REVIEWS" int
, "COLUMN - SPEAKERS: STATUSUPDATES" int
, "COLUMN - SPEAKERS: VIEWS" int
, "DATEPICKER - END DATE" int
, "DATEPICKER - NOW" int
, "DATEPICKER - START DATE" int
, "HREF - ACTIVEUSERSPERDAY" int
, "HREF - BADGEBREAKDOWNS" int
, "HREF - BADGESPERDAYBREAKDOWNS" int
, "HREF - BOOKMARKS" int
, "HREF - COMBINEDSURVEYRESULTS" int
, "HREF - CONNECTIONSPERDAY" int
, "HREF - EXHIBITORMEETINGREQUESTS" int
, "HREF - FOLLOWSPERDAY" int
, "HREF - FOLLOWSPERUSER" int
, "HREF - FREEFORMSURVEYRESULTS" int
, "HREF - GRIDSTATS" int
, "HREF - HASHTAGS" int
, "HREF - INFLUENTIALATTENDEES" int
, "HREF - ITEMLIST" int
, "HREF - ITEMSTATS" int
, "HREF - ITEMWITHRATINGS" int
, "HREF - LEADERBOARD" int
, "HREF - LEADS" int
, "HREF - LIKES" int
, "HREF - LIKESPERDAY" int
, "HREF - MENTIONSPERUSER" int
, "HREF - MULTIPLECHOICESURVEYRESULTS" int
, "HREF - NEWCOMMENTS" int
, "HREF - NEWUSERS" int
, "HREF - NOOFSTATUSUPDATESBYUSERS" int
, "HREF - NOOFSTATUSUPDATESINITEM" int
, "HREF - POINTSBREAKDOWNS" int
, "HREF - POLLRESULTSBYUSER" int
, "HREF - PROMOTEDPOSTCLICKTHROUGHS" int
, "HREF - RATINGSPERDAY" int
, "HREF - SESSIONS" int
, "HREF - SPEAKERS" int
, "HREF - STATUSUPDATEIMAGES" int
, "HREF - STATUSUPDATESANDCHECKINS" int
, "HREF - STATUSUPDATESBREAKDOWNS" int
, "HREF - STATUSUPDATESENTIMENT" int
, "HREF - STATUSUPDATESWITHASSOCIATEDCOMMENTSLIKES" int
, "HREF - SURVEYRESULTS" int
, "HREF - SURVEYRESULTSBYUSER" int
, "HREF - SURVEYS" int
, "HREF - USERACTIVITIESCOUNT" int
, "HREF - USERBADGES" int
, "HREF - USERREVIEWS" int
, "HREF - VISITSPERDAY" int
, "HREF - VISITSPERDAYBYAPPTYPE" int
, "HREF - VISITSPERUSER" int
, "MOMENT - POLL" int
, "MOMENT - PROMOTED POST" int
, "MOMENT - PUSH MESSAGE" int
, "MOMENT - WELCOME EMAIL" int
, "TAB - ENGAGEMENT TAB" int
, "TAB - MOMENTS TAB" int
, "TIMEFRAMESELECTOR" int
, "TOOLTIP - ADOPTION FUNNEL TOOLTIP" int
, "TOOLTIP - APP SECTION VISITS TOOLTIP" int
, "TOOLTIP - ENGAGEMENT SATISFACTION TOOLTIP" int
, "TOOLTIP - EVENT TIMELINE TOOLTIP" int
, "TOOLTIP - INFLUENTIALATTENDEES TOOLTIP" int
, "TOOLTIP - SESSIONS TOOLTIP" int
, "TOOLTIP - SPEAKERS TOOLTIP" int
, "TOOLTIP - TOP HASHTAGS TOOLTIP" int
, "TOOLTIP - TOP PHRASES TOOLTIP" int
, "TOOLTIP - TRENDING TOPICS TOOLTIP" int)
join (select globaluserid
           , userid
           , emailaddressdomain
           , count(distinct applicationid) as eventcnt
      from jt.ep_all_users
      group by 1,2,3) b
on ct.globaluserid = b.globaluserid
left join (select globaluserid
                , sum(eventlabelcnt) as actioncnt
           from jt.ep_all_users_events
           where event_category is not null
           group by 1) c
on ct.globaluserid = c.globaluserid;


select distinct case
                        when event_category = 'timeframeselector' then upper(event_category)
                        else upper(event_category) || ' - ' || upper(event_label)
                     end as eventcategory
     from jt.ep_all_users_events
     where event_category is not null
     order by 1;



-- Check to see what 

select count(*) as totalusers
     , count(case when actioncnt > 0 then 1 else null end) as actionusers
     , count(case when "DATEPICKER - END DATE" > 0 then 1 else null end) as "DATEPICKER - END DATE"
     , count(case when "DATEPICKER - NOW" > 0 then 1 else null end) as "DATEPICKER - NOW"
     , count(case when "DATEPICKER - START DATE" > 0 then 1 else null end) as "DATEPICKER - START DATE"
     , count(case when "HREF - ACTIVEUSERSPERDAY" > 0 then 1 else null end) as "HREF - ACTIVEUSERSPERDAY"
     , count(case when "HREF - BADGEBREAKDOWNS" > 0 then 1 else null end) as "HREF - BADGEBREAKDOWNS"
     , count(case when "HREF - BADGESPERDAYBREAKDOWNS" > 0 then 1 else null end) as "HREF - BADGESPERDAYBREAKDOWNS"
     , count(case when "HREF - BOOKMARKS" > 0 then 1 else null end) as "HREF - BOOKMARKS"
     , count(case when "HREF - COMBINEDSURVEYRESULTS" > 0 then 1 else null end) as "HREF - COMBINEDSURVEYRESULTS"
     , count(case when "HREF - CONNECTIONSPERDAY" > 0 then 1 else null end) as "HREF - CONNECTIONSPERDAY"
     , count(case when "HREF - EXHIBITORMEETINGREQUESTS" > 0 then 1 else null end) as "HREF - EXHIBITORMEETINGREQUESTS"
     , count(case when "HREF - FOLLOWSPERDAY" > 0 then 1 else null end) as "HREF - FOLLOWSPERDAY"
     , count(case when "HREF - FOLLOWSPERUSER" > 0 then 1 else null end) as "HREF - FOLLOWSPERUSER"
     , count(case when "HREF - FREEFORMSURVEYRESULTS" > 0 then 1 else null end) as "HREF - FREEFORMSURVEYRESULTS"
     , count(case when "HREF - GRIDSTATS" > 0 then 1 else null end) as "HREF - GRIDSTATS"
     , count(case when "HREF - HASHTAGS" > 0 then 1 else null end) as "HREF - HASHTAGS"
     , count(case when "HREF - INFLUENTIALATTENDEES" > 0 then 1 else null end) as "HREF - INFLUENTIALATTENDEES"
     , count(case when "HREF - ITEMLIST" > 0 then 1 else null end) as "HREF - ITEMLIST"
     , count(case when "HREF - ITEMSTATS" > 0 then 1 else null end) as "HREF - ITEMSTATS"
     , count(case when "HREF - ITEMWITHRATINGS" > 0 then 1 else null end) as "HREF - ITEMWITHRATINGS"
     , count(case when "HREF - LEADERBOARD" > 0 then 1 else null end) as "HREF - LEADERBOARD"
     , count(case when "HREF - LEADS" > 0 then 1 else null end) as "HREF - LEADS"
     , count(case when "HREF - LIKES" > 0 then 1 else null end) as "HREF - LIKES"
     , count(case when "HREF - LIKESPERDAY" > 0 then 1 else null end) as "HREF - LIKESPERDAY"
     , count(case when "HREF - MENTIONSPERUSER" > 0 then 1 else null end) as "HREF - MENTIONSPERUSER"
     , count(case when "HREF - MULTIPLECHOICESURVEYRESULTS" > 0 then 1 else null end) as "HREF - MULTIPLECHOICESURVEYRESULTS"
     , count(case when "HREF - NEWCOMMENTS" > 0 then 1 else null end) as "HREF - NEWCOMMENTS"
     , count(case when "HREF - NEWUSERS" > 0 then 1 else null end) as "HREF - NEWUSERS"
     , count(case when "HREF - NOOFSTATUSUPDATESBYUSERS" > 0 then 1 else null end) as "HREF - NOOFSTATUSUPDATESBYUSERS"
     , count(case when "HREF - NOOFSTATUSUPDATESINITEM" > 0 then 1 else null end) as "HREF - NOOFSTATUSUPDATESINITEM"
     , count(case when "HREF - POINTSBREAKDOWNS" > 0 then 1 else null end) as "HREF - POINTSBREAKDOWNS"
     , count(case when "HREF - POLLRESULTSBYUSER" > 0 then 1 else null end) as "HREF - POLLRESULTSBYUSER"
     , count(case when "HREF - PROMOTEDPOSTCLICKTHROUGHS" > 0 then 1 else null end) as "HREF - PROMOTEDPOSTCLICKTHROUGHS"
     , count(case when "HREF - RATINGSPERDAY" > 0 then 1 else null end) as "HREF - RATINGSPERDAY"
     , count(case when "HREF - SESSIONS" > 0 then 1 else null end) as "HREF - SESSIONS"
     , count(case when "HREF - SPEAKERS" > 0 then 1 else null end) as "HREF - SPEAKERS"
     , count(case when "HREF - STATUSUPDATEIMAGES" > 0 then 1 else null end) as "HREF - STATUSUPDATEIMAGES"
     , count(case when "HREF - STATUSUPDATESANDCHECKINS" > 0 then 1 else null end) as "HREF - STATUSUPDATESANDCHECKINS"
     , count(case when "HREF - STATUSUPDATESBREAKDOWNS" > 0 then 1 else null end) as "HREF - STATUSUPDATESBREAKDOWNS"
     , count(case when "HREF - STATUSUPDATESENTIMENT" > 0 then 1 else null end) as "HREF - STATUSUPDATESENTIMENT"
     , count(case when "HREF - STATUSUPDATESWITHASSOCIATEDCOMMENTSLIKES" > 0 then 1 else null end) as "HREF - STATUSUPDATESWITHASSOCIATEDCOMMENTSLIKES"
     , count(case when "HREF - SURVEYRESULTS" > 0 then 1 else null end) as "HREF - SURVEYRESULTS"
     , count(case when "HREF - SURVEYRESULTSBYUSER" > 0 then 1 else null end) as "HREF - SURVEYRESULTSBYUSER"
     , count(case when "HREF - SURVEYS" > 0 then 1 else null end) as "HREF - SURVEYS"
     , count(case when "HREF - USERACTIVITIESCOUNT" > 0 then 1 else null end) as "HREF - USERACTIVITIESCOUNT"
     , count(case when "HREF - USERBADGES" > 0 then 1 else null end) as "HREF - USERBADGES"
     , count(case when "HREF - USERREVIEWS" > 0 then 1 else null end) as "HREF - USERREVIEWS"
     , count(case when "HREF - VISITSPERDAY" > 0 then 1 else null end) as "HREF - VISITSPERDAY"
     , count(case when "HREF - VISITSPERDAYBYAPPTYPE" > 0 then 1 else null end) as "HREF - VISITSPERDAYBYAPPTYPE"
     , count(case when "HREF - VISITSPERUSER" > 0 then 1 else null end) as "HREF - VISITSPERUSER"
     , count(case when "MOMENT - POLL" > 0 then 1 else null end) as "MOMENT - POLL"
     , count(case when "TOOLTIP - ADOPTION FUNNEL TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - ADOPTION FUNNEL TOOLTIP"
     , count(case when "TOOLTIP - APP SECTION VISITS TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - APP SECTION VISITS TOOLTIP"
     , count(case when "TOOLTIP - ENGAGEMENT SATISFACTION TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - ENGAGEMENT SATISFACTION TOOLTIP"
     , count(case when "TOOLTIP - EVENT TIMELINE TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - EVENT TIMELINE TOOLTIP"
     , count(case when "TOOLTIP - INFLUENTIALATTENDEES TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - INFLUENTIALATTENDEES TOOLTIP"
     , count(case when "TOOLTIP - SESSIONS TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - SESSIONS TOOLTIP"
     , count(case when "TOOLTIP - SPEAKERS TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - SPEAKERS TOOLTIP"
     , count(case when "TOOLTIP - TOP HASHTAGS TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - TOP HASHTAGS TOOLTIP"
     , count(case when "TOOLTIP - TOP PHRASES TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - TOP PHRASES TOOLTIP"
     , count(case when "TOOLTIP - TRENDING TOPICS TOOLTIP" > 0 then 1 else null end) as "TOOLTIP - TRENDING TOPICS TOOLTIP"
from jt.ep_all_users_events_denorm;
      
-- 10,154

select *
from jt.ep_all_users_events_denorm limit 10;
      
      

select distinct case
                   when event_category = 'timeframeselector' then upper(event_category)
                   when event_category is null then 'NO EVENTS'
                   else upper(event_category) || ' - ' || upper(event_label)
                end as eventcategory
from google.ep_event_counts
order by 1;









---- Pivot Experiments

CREATE EXTENSION tablefunc;

select *
from crosstab(
     'select userid
           , globaluserid
           , eventcnt
           , case
                when event_category = ''timeframeselector'' then upper(event_category)
                when event_category is null then ''NO EVENTS''
                else upper(event_category) || '' - '' || upper(event_label)
             end as eventcategory
           , coalesce(eventlabelcnt,0) as eventlabelcnt
      from jt.ep_all_users_events',
     'select distinct case
                         when event_category = ''timeframeselector'' then upper(event_category)
                         when event_category is null then ''NO EVENTS''
                         else upper(event_category) || '' - '' || upper(event_label)
                      end as eventcategory
       from jt.ep_all_users_events
       order by 1')
as a(userid int, "Button" int, "Checkbox" int, "Column" int, "Datepicker" int, "Href" int, "Moment" int, "Tab" int, "Timeframe Selector" int, "Tooltip" int); 


select *
from crosstab3(
     'select userid
           , globaluserid
           , eventcnt
           , case
                when event_category = ''timeframeselector'' then upper(event_category)
                when event_category is null then ''NO EVENTS''
                else upper(event_category) || '' - '' || upper(event_label)
             end as eventcategory
           , coalesce(eventlabelcnt,0) as eventlabelcnt
      from jt.ep_all_users_events'); 







select *
from jt.ep_all_users_track
where userid = 43315528;



