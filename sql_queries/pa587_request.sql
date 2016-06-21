-- Confirm that event is in the EU
select *
from authdb_applications
where lower(applicationid) = '1c472828-12f5-4739-916f-440eed505a07'
;
-- Confirmed

-- How many direct messages were sent via app
select count(*) as msgsentcnt
     , count(distinct global_user_id) as msgusercnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as globaluserid
           , userid
      from authdb_is_users
      where lower(applicationid) = '1c472828-12f5-4739-916f-440eed505a07'
      --and isdisabled = 0
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id 
where actions.application_id = '1c472828-12f5-4739-916f-440eed505a07'
and rooms.applicationid = '1c472828-12f5-4739-916f-440eed505a07'
and actions.identifier = 'chatTextButton'
and rooms.type = 'GROUP'
;

-- 109 Messages
-- 12 Users

-- How many topic messages were sent via app
select cast(actions.metadata->>'ChannelId' as int) as channel
     , count(*) as msgsentcnt
     , count(distinct global_user_id) as msgusercnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as globaluserid
           , userid
      from authdb_is_users
      where lower(applicationid) = '1c472828-12f5-4739-916f-440eed505a07'
      and isdisabled = 0
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id 
where actions.application_id = '1c472828-12f5-4739-916f-440eed505a07'
and rooms.applicationid = '1c472828-12f5-4739-916f-440eed505a07'
and actions.identifier = 'chatTextButton'
and rooms.type = 'TOPIC'
group by 1
;

-- By Channel
-- 3213	7	2
-- 4687	2	2

-- 9 Messages
-- 4 Users