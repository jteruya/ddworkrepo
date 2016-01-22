drop table if exists jt.robin_eventcubesummary;
create table jt.robin_eventcubesummary as (select * from eventcube.eventcubesummary);


select count(*)
from jt.tm_eventcubesummary;
--3014

select count(*)
from jt.robin_eventcubesummary;
--3297

--Diff1 = 3297 - 3014 = 283

select count(*) from (
select applicationid
from jt.tm_eventcubesummary
except
select cast(applicationid as uuid)
from jt.robin_eventcubesummary) a;
--61

select count(*) from (
select cast(applicationid as uuid)
from jt.robin_eventcubesummary
except
select applicationid
from jt.tm_eventcubesummary) a;
--344

--Diff2 = 344 - 61 = 283

--Diff1 = Diff2

-- 2953 Matching (3014 - 61) or (3297 - 344) (2953/3297) = 89.57%

--0 match values on all fields (0.00%)
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
registrants_flag = 1 and 
downloads_flag = 1 and 
users_flag = 1 and 
usersactive_flag = 1 and 
usersengaged_flag = 1 and 
usersfacebook_flag = 1 and 
userstwitter_flag = 1 and 
userslinkedin_flag = 1 and 
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
surveys_flag = 1 and 
promotedposts_flag = 1 and 
globalpushnotifications_flag = 1 and 
adoption_flag = 1 and 
exhibitors_flag = 1 and 
polls_flag = 1 and 
pollresponses_flag = 1 then 1 else null end) as all_correct_cnt
, count(*) as total_cnt
from (
select t.applicationid
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
, case when t.registrants=r.registrants then 1 else 0 end as registrants_flag
, case when t.downloads=r.downloads then 1 else 0 end as downloads_flag
, case when t.users=r.users then 1 else 0 end as users_flag
, case when t.usersactive=r.usersactive then 1 else 0 end as usersactive_flag
, case when t.usersengaged=r.usersengaged then 1 else 0 end as usersengaged_flag
, case when t.usersfacebook=r.usersfacebook then 1 else 0 end as usersfacebook_flag
, case when t.userstwitter=r.userstwitter then 1 else 0 end as userstwitter_flag
, case when t.userslinkedin=r.userslinkedin then 1 else 0 end as userslinkedin_flag
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
, case when t.promotedposts=r.promotedposts then 1 else 0 end as promotedposts_flag
, case when t.globalpushnotifications=r.globalpushnotifications then 1 else 0 end as globalpushnotifications_flag
, case when t.adoption=r.adoption then 1 else 0 end as adoption_flag
, case when t.exhibitors=r.exhibitors then 1 else 0 end as exhibitors_flag
, case when t.polls=r.polls then 1 else 0 end as polls_flag
, case when t.pollresponses=r.pollresponses then 1 else 0 end as pollresponses_flag
from jt.tm_eventcubesummary t
join jt.robin_eventcubesummary r
on t.applicationid = r.applicationid::uuid) a;









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
, count(case when registrants_flag = 0 then 1 else null end) as registrants_flag_not_match_count
, count(case when downloads_flag = 0 then 1 else null end) as downloads_flag_not_match_count
, count(case when users_flag = 0 then 1 else null end) as users_flag_not_match_count
, count(case when usersactive_flag = 0 then 1 else null end) as usersactive_flag_not_match_count
, count(case when usersengaged_flag = 0 then 1 else null end) as usersengaged_flag_not_match_count
, count(case when usersfacebook_flag = 0 then 1 else null end) as usersfacebook_flag_not_match_count
, count(case when userstwitter_flag = 0 then 1 else null end) as userstwitter_flag_not_match_count
, count(case when userslinkedin_flag = 0 then 1 else null end) as userslinkedin_flag_not_match_count
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
, count(case when promotedposts_flag = 0 then 1 else null end) as promotedposts_flag_not_match_count
, count(case when globalpushnotifications_flag = 0 then 1 else null end) as globalpushnotifications_flag_not_match_count
, count(case when adoption_flag = 0 then 1 else null end) as adoption_flag_not_match_count
, count(case when exhibitors_flag = 0 then 1 else null end) as exhibitors_flag_not_match_count
, count(case when polls_flag = 0 then 1 else null end) as polls_flag_not_match_count
, count(case when pollresponses_flag = 0 then 1 else null end) as pollresponses_flag_not_match_count
from (
select t.applicationid
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
, case when t.eventsize=r.eventsize then 1 
       when t.eventsize is null and r.eventsize = '' then 1
       else 0 end as eventsize_flag
, case when t.accountcustomerdomain=r.accountcustomerdomain then 1 else 0 end as accountcustomerdomain_flag
, case when t.servicetiername is not null and t.servicetiername=r.servicetiername then 1 
       when t.servicetiername is null and r.servicetiername = '' then 1 
       else 0 end as servicetiername_flag
, case when t.app365indicator=r.app365indicator then 1 else 0 end as app365indicator_flag
, case when t.ownername=r.ownername then 1 else 0 end as ownername_flag
, case when t.binaryversion=r.binaryversion then 1 else 0 end as binaryversion_flag
, case when t.registrants=r.registrants then 1 else 0 end as registrants_flag
, case when t.downloads=r.downloads then 1 else 0 end as downloads_flag
, case when t.users=r.users then 1 else 0 end as users_flag
, case when t.usersactive=r.usersactive then 1 else 0 end as usersactive_flag
, case when t.usersengaged=r.usersengaged then 1 else 0 end as usersengaged_flag
, case when t.usersfacebook=r.usersfacebook then 1 else 0 end as usersfacebook_flag
, case when t.userstwitter=r.userstwitter then 1 else 0 end as userstwitter_flag
, case when t.userslinkedin=r.userslinkedin then 1 else 0 end as userslinkedin_flag
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
, case when t.promotedposts=r.promotedposts then 1 else 0 end as promotedposts_flag
, case when t.globalpushnotifications=r.globalpushnotifications then 1 else 0 end as globalpushnotifications_flag
, case when t.adoption is not null and t.adoption <> 0 and abs(t.adoption-r.adoption)/t.adoption <= 0.05 then 1 
       when t.adoption = 0 and r.adoption = 0 then 1
       when t.adoption is null and r.adoption is null then 1 
       else 0 
  end as adoption_flag
, case when t.exhibitors=r.exhibitors then 1 else 0 end as exhibitors_flag
, case when t.polls=r.polls then 1 else 0 end as polls_flag
, case when t.pollresponses=r.pollresponses then 1 else 0 end as pollresponses_flag
from jt.tm_eventcubesummary t
join jt.robin_eventcubesummary r
on t.applicationid = r.applicationid::uuid) a;




select t.applicationid
     , t.sessions
     , r.sessions
from jt.tm_eventcubesummary t
join jt.robin_eventcubesummary r
on t.applicationid = r.applicationid::uuid
where t.sessions <> r.sessions
--or t.registrants is null;





select count(case when t.postsitem = r.postsitem then 1 else null end) as total_records_match
     , count(case when t.postsitem <> r.postsitem then 1 else null end) as total_record_not_match
     , count(case when t.postsitem > r.postsitem then 1 else null end) as total_tm_more_than_robin
     , count(case when t.postsitem < r.postsitem then 1 else null end) as total_tm_less_than_robin
from jt.tm_eventcubesummary t
join jt.robin_eventcubesummary r
on t.applicationid = r.applicationid::uuid;


 
 






