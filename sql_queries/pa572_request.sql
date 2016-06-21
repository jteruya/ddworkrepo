-- Check to see if event is in EU
select *
from authdb_applications
where lower(applicationid) = '30f31548-1f06-42b7-8cf7-183b436b582b'
;
-- Confirmed

-- 1) Direct Messaging usage extract

select count(*) as "Unique DMs Sent"
     , count(distinct users.userid) as "Unique DM Sender Count"
     , count(distinct members.userid) as "Unique DM Recipient Count"
from public.fact_actions_live actions
join (select distinct userid
           , lower(globaluserid) as globaluserid
      from public.authdb_is_users
      where /*isdisabled = 0
      and*/ applicationid = '30F31548-1F06-42B7-8CF7-183B436B582B'
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id
join channels.members members
on rooms.id = members.channelid
and users.userid <> members.userid
where actions.application_id = '30f31548-1f06-42b7-8cf7-183b436b582b'
and actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit'
and rooms.type = 'GROUP'
;

-- Unique DMs Sent: 1177
-- Unique DM Sender Count: 370
-- Unqiue DM Recipient Count: 470

-- 2) Promoted post View & Click extract

-- promoted post (impression) for view
-- "Image" (boolean)
-- "ActivityId" (int, minimum 1)

-- promotedPost (action) for clicks
-- "ActivityId" (int, minimum 1)

-- Identify the promoted posts
select posts.mappingid
     , posts.linktext
     , posts.note
     , posts.displayafter
     -- This is on UTC + 2hour because of EU Summer Rules
     , posts.displayafter + (interval '1' second * tz.utcoffsetinseconds::int * 2) as displayafteroffset
from ratings_promotedposts posts
join ratings_timezones tz
on posts.timezoneid = tz.timezoneid
where posts.applicationid = '30f31548-1f06-42b7-8cf7-183b436b582b'
and ((linktext like '%MASTER THE COMPLEX%' or linktext like '%SYNERGY%' or linktext like '%COMET%')
or (note like '%MASTER THE COMPLEX%' or note like '%SYNERGY%' or note like '%COMET%'))
and displayafter >= '2016-05-17'
;

-- 5800 Discover the latest new about SYNERGY                   2016-05-17 16:00:00
-- 5802 Discover the latest news about COMET                    2016-05-18 10:00:00
-- 6235 Discover the latest news on SYNERGY                     2016-05-18 12:30:00
-- 5803 Discover the latest news on MASTER THE COMPLEX          2016-05-20 09:00:00
-- 5799 Discover the latest news on MASTER THE COMPLEX          2016-05-19 11:30:00

-- Views/Impressions of Promoted Posts
select cast(metadata->>'ActivityId' as int) as promotedpostmappingid
     , count(*) as "Impression Count"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_impressions_live
where application_id = '30f31548-1f06-42b7-8cf7-183b436b582b'
and identifier = 'promotedPost'
and metadata->>'ActivityId' in ('5800', '5802', '6235', '5803', '5799')
group by 1
;

promotedpostmappingid	Impression Count	Unique User Count
5799	4231	1013
5800	6533	1267
5802	6019	1253
5803	2279	572
6235	5093	1092

-- Clicks on Promoted Posts
select cast(metadata->>'ActivityId' as int) as promotedpostmappingid
     , count(*) as "Click Count"
     , count(distinct global_user_id) as "Unique User Count"
from public.fact_actions_live
where application_id = '30f31548-1f06-42b7-8cf7-183b436b582b'
and identifier = 'promotedPost'
and metadata->>'ActivityId' in ('5800', '5802', '6235', '5803', '5799')
group by 1
;

promotedpostmappingid	Click Count	Unique User Count
5799	8	6
5800	36	31
5802	24	19
5803	3	3
6235	7	7

-- 3) Accepted Push notification
-- Not possible.  We can count the subset of push notifications that were engaged with but not those that there were recieved and not engaged with.
