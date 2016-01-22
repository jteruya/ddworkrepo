drop table if exists jt.robin_usercubesummary;
create table jt.robin_usercubesummary as (select * from eventcube.usercubesummary);

select count(*)
from jt.tm_usercubesummary;
--1,777,872

select count(*)
from jt.robin_usercubesummary;
--1,738,732

--Diff1: 1,777,872 - 1,738,732 = 39,140

select count(*) from (
select applicationid, globaluserid, userid
from jt.tm_usercubesummary
except
select applicationid::uuid, globaluserid::uuid, userid
from jt.robin_usercubesummary) a;
--40,489

select count(*) from (
select applicationid::uuid, globaluserid::uuid, userid
from jt.robin_usercubesummary
except
select applicationid, globaluserid, userid
from jt.tm_usercubesummary) a;
--1,349

--Diff2: 40,489 - 1,349 = 39,140

--Diff1 = Diff2


-- 1,737,383 Matching (1,777,872 - 40,489) or (1,738,732 - 1,349)  (1,737,383/1,738,732) = 99.92%


--281,284 match values on all fields (16.19%)
-- Auditing Fields For Matching Records
select count(case when 
name_flag = 1 and 
startdate_flag = 1 and 
enddate_flag = 1 and 
openevent_flag = 1 and 
leadscanning_flag = 1 and 
surveyson_flag = 1 and 
interactivemap_flag = 1 and 
leaderboard_flag = 1 and 
bookmarking_flag = 1 and 
photofeed_flag = 1 and 
attendeeslist_flag = 1 and 
qrcode_flag = 1 and 
exhibitorreqinfo_flag = 1 and 
exhibitormsg_flag = 1 and 
privatemsging_flag = 1 and 
peoplematching_flag = 1 and 
socialnetworks_flag = 1 and 
ratingson_flag = 1 and 
eventtype_flag = 1 and 
eventsize_flag = 1 and 
accountcustomerdomain_flag = 1 and 
servicetiername_flag = 1 and 
app365indicator_flag = 1 and 
ownername_flag = 1 and 
binaryversion_flag = 1 and 
devicetype_flag = 1 and 
device_flag = 1 and 
facebook_flag = 1 and 
twitter_flag = 1 and 
linkedin_flag = 1 and 
firsttimestamp_flag = 1 and 
lasttimestamp_flag = 1 and 
active_flag = 1 and 
engaged_flag = 1 and 
sessions_flag = 1 and 
posts_flag = 1 and 
postsimage_flag = 1 and 
postsitem_flag = 1 and 
likes_flag = 1 and 
comments_flag = 1 and 
bookmarks_flag = 1 and 
follows_flag = 1 and 
checkins_flag = 1 and 
checkinsheadcount_flag = 1 and 
ratings_flag = 1 and 
reviews_flag = 1 and 
surveys_flag = 1 then 1 else null end) as all_correct_cnt
, count(*) as total_cnt
from (
select t.applicationid
, t.globaluserid
, t.userid
, case when t.name=r.name then 1 else 0 end as name_flag
, case when t.startdate=r.startdate then 1 else 0 end as startdate_flag
, case when t.enddate=r.enddate then 1 else 0 end as enddate_flag
, case when t.openevent=r.openevent then 1 else 0 end as openevent_flag
, case when t.leadscanning=r.leadscanning then 1 else 0 end as leadscanning_flag
, case when t.surveyson=r.surveyson then 1 else 0 end as surveyson_flag
, case when t.interactivemap=r.interactivemap then 1 else 0 end as interactivemap_flag
, case when t.leaderboard=r.leaderboard then 1 else 0 end as leaderboard_flag
, case when t.bookmarking=r.bookmarking then 1 else 0 end as bookmarking_flag
, case when t.photofeed=r.photofeed then 1 else 0 end as photofeed_flag
, case when t.attendeeslist=r.attendeeslist then 1 else 0 end as attendeeslist_flag
, case when t.qrcode=r.qrcode then 1 else 0 end as qrcode_flag
, case when t.exhibitorreqinfo=r.exhibitorreqinfo then 1 else 0 end as exhibitorreqinfo_flag
, case when t.exhibitormsg=r.exhibitormsg then 1 else 0 end as exhibitormsg_flag
, case when t.privatemsging=r.privatemsging then 1 else 0 end as privatemsging_flag
, case when t.peoplematching=r.peoplematching then 1 else 0 end as peoplematching_flag
, case when t.socialnetworks=r.socialnetworks then 1 else 0 end as socialnetworks_flag
, case when t.ratingson=r.ratingson then 1 else 0 end as ratingson_flag
, case when t.eventtype=r.eventtype then 1 else 0 end as eventtype_flag
, case when t.eventsize=r.eventsize then 1 else 0 end as eventsize_flag
, case when t.accountcustomerdomain=r.accountcustomerdomain then 1 else 0 end as accountcustomerdomain_flag
, case when t.servicetiername=r.servicetiername then 1 else 0 end as servicetiername_flag
, case when t.app365indicator=r.app365indicator then 1 else 0 end as app365indicator_flag
, case when t.ownername=r.ownername then 1 else 0 end as ownername_flag
, case when t.binaryversion=r.binaryversion then 1 else 0 end as binaryversion_flag
, case when t.devicetype=r.devicetype then 1 else 0 end as devicetype_flag
, case when t.device=r.device then 1 else 0 end as device_flag
, case when t.facebook=r.facebook then 1 else 0 end as facebook_flag
, case when t.twitter=r.twitter then 1 else 0 end as twitter_flag
, case when t.linkedin=r.linkedin then 1 else 0 end as linkedin_flag
, case when t.firsttimestamp=r.firsttimestamp then 1 else 0 end as firsttimestamp_flag
, case when t.lasttimestamp=r.lasttimestamp then 1 else 0 end as lasttimestamp_flag
, case when t.active=r.active then 1 else 0 end as active_flag
, case when t.engaged=r.engaged then 1 else 0 end as engaged_flag
, case when t.sessions=r.sessions then 1 else 0 end as sessions_flag
, case when t.posts=r.posts then 1 else 0 end as posts_flag
, case when t.postsimage=r.postsimage then 1 else 0 end as postsimage_flag
, case when t.postsitem=r.postsitem then 1 else 0 end as postsitem_flag
, case when t.likes=r.likes then 1 else 0 end as likes_flag
, case when t.comments=r.comments then 1 else 0 end as comments_flag
, case when t.bookmarks=r.bookmarks then 1 else 0 end as bookmarks_flag
, case when t.follows=r.follows then 1 else 0 end as follows_flag
, case when t.checkins=r.checkins then 1 else 0 end as checkins_flag
, case when t.checkinsheadcount=r.checkinsheadcount then 1 else 0 end as checkinsheadcount_flag
, case when t.ratings=r.ratings then 1 else 0 end as ratings_flag
, case when t.reviews=r.reviews then 1 else 0 end as reviews_flag
, case when t.surveys=r.surveys then 1 else 0 end as surveys_flag
from jt.tm_usercubesummary t
join jt.robin_usercubesummary r
on t.applicationid = r.applicationid::uuid and t.globaluserid = r.globaluserid::uuid and t.userid = r.userid) a;


select count(case when name_flag = 0 then 1 else null end) as name_flag_not_match_count
, count(case when startdate_flag = 0 then 1 else null end) as startdate_flag_not_match_count
, count(case when enddate_flag = 0 then 1 else null end) as enddate_flag_not_match_count
, count(case when openevent_flag = 0 then 1 else null end) as openevent_flag_not_match_count
, count(case when leadscanning_flag = 0 then 1 else null end) as leadscanning_flag_not_match_count
, count(case when surveyson_flag = 0 then 1 else null end) as surveyson_flag_not_match_count
, count(case when interactivemap_flag = 0 then 1 else null end) as interactivemap_flag_not_match_count
, count(case when leaderboard_flag = 0 then 1 else null end) as leaderboard_flag_not_match_count
, count(case when bookmarking_flag = 0 then 1 else null end) as bookmarking_flag_not_match_count
, count(case when photofeed_flag = 0 then 1 else null end) as photofeed_flag_not_match_count
, count(case when attendeeslist_flag = 0 then 1 else null end) as attendeeslist_flag_not_match_count
, count(case when qrcode_flag = 0 then 1 else null end) as qrcode_flag_not_match_count
, count(case when exhibitorreqinfo_flag = 0 then 1 else null end) as exhibitorreqinfo_flag_not_match_count
, count(case when exhibitormsg_flag = 0 then 1 else null end) as exhibitormsg_flag_not_match_count
, count(case when privatemsging_flag = 0 then 1 else null end) as privatemsging_flag_not_match_count
, count(case when peoplematching_flag = 0 then 1 else null end) as peoplematching_flag_not_match_count
, count(case when socialnetworks_flag = 0 then 1 else null end) as socialnetworks_flag_not_match_count
, count(case when ratingson_flag = 0 then 1 else null end) as ratingson_flag_not_match_count
, count(case when eventtype_flag = 0 then 1 else null end) as eventtype_flag_not_match_count
, count(case when eventsize_flag = 0 then 1 else null end) as eventsize_flag_not_match_count
, count(case when accountcustomerdomain_flag = 0 then 1 else null end) as accountcustomerdomain_flag_not_match_count
, count(case when servicetiername_flag = 0 then 1 else null end) as servicetiername_flag_not_match_count
, count(case when app365indicator_flag = 0 then 1 else null end) as app365indicator_flag_not_match_count
, count(case when ownername_flag = 0 then 1 else null end) as ownername_flag_not_match_count
, count(case when binaryversion_flag = 0 then 1 else null end) as binaryversion_flag_not_match_count
, count(case when devicetype_flag = 0 then 1 else null end) as devicetype_flag_not_match_count
, count(case when device_flag = 0 then 1 else null end) as device_flag_not_match_count
, count(case when facebook_flag = 0 then 1 else null end) as facebook_flag_not_match_count
, count(case when twitter_flag = 0 then 1 else null end) as twitter_flag_not_match_count
, count(case when linkedin_flag = 0 then 1 else null end) as linkedin_flag_not_match_count
, count(case when firsttimestamp_flag = 0 then 1 else null end) as firsttimestamp_flag_not_match_count
, count(case when lasttimestamp_flag = 0 then 1 else null end) as lasttimestamp_flag_not_match_count
, count(case when active_flag = 0 then 1 else null end) as active_flag_not_match_count
, count(case when engaged_flag = 0 then 1 else null end) as engaged_flag_not_match_count
, count(case when sessions_flag = 0 then 1 else null end) as sessions_flag_not_match_count
, count(case when posts_flag = 0 then 1 else null end) as posts_flag_not_match_count
, count(case when postsimage_flag = 0 then 1 else null end) as postsimage_flag_not_match_count
, count(case when postsitem_flag = 0 then 1 else null end) as postsitem_flag_not_match_count
, count(case when likes_flag = 0 then 1 else null end) as likes_flag_not_match_count
, count(case when comments_flag = 0 then 1 else null end) as comments_flag_not_match_count
, count(case when bookmarks_flag = 0 then 1 else null end) as bookmarks_flag_not_match_count
, count(case when follows_flag = 0 then 1 else null end) as follows_flag_not_match_count
, count(case when checkins_flag = 0 then 1 else null end) as checkins_flag_not_match_count
, count(case when checkinsheadcount_flag = 0 then 1 else null end) as checkinsheadcount_flag_not_match_count
, count(case when ratings_flag = 0 then 1 else null end) as ratings_flag_not_match_count
, count(case when reviews_flag = 0 then 1 else null end) as reviews_flag_not_match_count
, count(case when surveys_flag = 0 then 1 else null end) as surveys_flag_not_match_count
from (
select t.applicationid
, t.globaluserid
, t.userid
, case when t.name=r.name then 1 else 0 end as name_flag
, case when t.startdate=r.startdate then 1 else 0 end as startdate_flag
, case when t.enddate=r.enddate then 1 else 0 end as enddate_flag
, case when t.openevent=r.openevent then 1 else 0 end as openevent_flag
, case when t.leadscanning=r.leadscanning then 1 else 0 end as leadscanning_flag
, case when t.surveyson=r.surveyson then 1 else 0 end as surveyson_flag
, case when t.interactivemap=r.interactivemap then 1 else 0 end as interactivemap_flag
, case when t.leaderboard=r.leaderboard then 1 else 0 end as leaderboard_flag
, case when t.bookmarking=r.bookmarking then 1 else 0 end as bookmarking_flag
, case when t.photofeed=r.photofeed then 1 else 0 end as photofeed_flag
, case when t.attendeeslist=r.attendeeslist then 1 else 0 end as attendeeslist_flag
, case when t.qrcode=r.qrcode then 1 else 0 end as qrcode_flag
, case when t.exhibitorreqinfo=r.exhibitorreqinfo then 1 else 0 end as exhibitorreqinfo_flag
, case when t.exhibitormsg=r.exhibitormsg then 1 else 0 end as exhibitormsg_flag
, case when t.privatemsging=r.privatemsging then 1 else 0 end as privatemsging_flag
, case when t.peoplematching=r.peoplematching then 1 else 0 end as peoplematching_flag
, case when t.socialnetworks=r.socialnetworks then 1 else 0 end as socialnetworks_flag
, case when t.ratingson=r.ratingson then 1 else 0 end as ratingson_flag
, case when t.eventtype=r.eventtype then 1 else 0 end as eventtype_flag
, case when t.eventsize=r.eventsize then 1 else 0 end as eventsize_flag
, case when t.accountcustomerdomain=r.accountcustomerdomain then 1 else 0 end as accountcustomerdomain_flag
, case when (t.servicetiername is null and r.servicetiername = '') or (t.servicetiername=r.servicetiername) then 1 else 0 end as servicetiername_flag
, case when t.app365indicator=r.app365indicator then 1 else 0 end as app365indicator_flag
, case when t.ownername=r.ownername then 1 else 0 end as ownername_flag
, case when t.binaryversion=r.binaryversion then 1 else 0 end as binaryversion_flag
, case when t.devicetype=r.devicetype then 1 else 0 end as devicetype_flag
, case when t.device=r.device then 1 else 0 end as device_flag
, case when t.facebook=r.facebook then 1 else 0 end as facebook_flag
, case when t.twitter=r.twitter then 1 else 0 end as twitter_flag
, case when t.linkedin=r.linkedin then 1 else 0 end as linkedin_flag
, case when t.firsttimestamp=r.firsttimestamp then 1 else 0 end as firsttimestamp_flag
, case when t.lasttimestamp=r.lasttimestamp then 1 else 0 end as lasttimestamp_flag
, case when t.active=r.active then 1 else 0 end as active_flag
, case when t.engaged=r.engaged then 1 else 0 end as engaged_flag
, case when t.sessions=r.sessions then 1 else 0 end as sessions_flag
, case when t.posts=r.posts then 1 else 0 end as posts_flag
, case when t.postsimage=r.postsimage then 1 else 0 end as postsimage_flag
, case when t.postsitem=r.postsitem then 1 else 0 end as postsitem_flag
, case when t.likes=r.likes then 1 else 0 end as likes_flag
, case when t.comments=r.comments then 1 else 0 end as comments_flag
, case when t.bookmarks=r.bookmarks then 1 else 0 end as bookmarks_flag
, case when t.follows=r.follows then 1 else 0 end as follows_flag
, case when t.checkins=r.checkins then 1 else 0 end as checkins_flag
, case when t.checkinsheadcount=r.checkinsheadcount then 1 else 0 end as checkinsheadcount_flag
, case when t.ratings=r.ratings then 1 else 0 end as ratings_flag
, case when t.reviews=r.reviews then 1 else 0 end as reviews_flag
, case when t.surveys=r.surveys then 1 else 0 end as surveys_flag
from jt.tm_usercubesummary t
join jt.robin_usercubesummary r
on t.applicationid = r.applicationid::uuid and t.globaluserid = r.globaluserid::uuid and t.userid = r.userid) a;



select count(*) as total_records
     , count(case when t.sessions = r.sessions then 1 else null end) as total_records_match
     , count(case when t.sessions <> r.sessions then 1 else null end) as total_record_not_match
     , count(case when t.sessions > r.sessions then 1 else null end) as total_tm_more_than_robin
     , count(case when t.sessions < r.sessions then 1 else null end) as total_tm_less_than_robin
from jt.tm_usercubesummary t
join jt.robin_usercubesummary r
on t.applicationid = r.applicationid::uuid and t.globaluserid = r.globaluserid::uuid and t.userid = r.userid;




select *
from PUBLIC.AuthDB_Applications
where lower(applicationid) = '4bc0f63f-45bd-46c9-8954-fb08e043f33e'


select *
from EventCube.DimEventsSFDC
where applicationid = '3d9d65d1-fa72-49d8-a415-2e32700fe334';

select distinct u.applicationid
     , sf.eventtype
FROM EventCube.DimUsers U
LEFT OUTER JOIN EventCube.DimEventsSFDC SF ON lower(U.ApplicationId) = CAST(SF.ApplicationId AS VARCHAR)
where lower(u.applicationid) = '3d9d65d1-fa72-49d8-a415-2e32700fe334';

select applicationid
from EventCube.DimEventsSFDC
where CAST(ApplicationId AS VARCHAR) = '3d9d65d1-fa72-49d8-a415-2e32700fe334';


select bookmarks
from EventCube.DimUserSocialNetworks limit 10;


select *
from EventCube.FactBookmarks;

select *
from EventCube.DimEvents limit 1;


