-- Double Check that Event is US
select *
from authdb_applications
where lower(applicationid) = '53c77db0-58c3-4231-a973-49ee0a32bc18'
;
-- Confirmed

-- How many direct messages were sent via app
select count(*) as msgsentcnt
     , count(distinct global_user_id) as msgusercnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as globaluserid
           , userid
      from authdb_is_users
      where lower(applicationid) = '53c77db0-58c3-4231-a973-49ee0a32bc18'
      and isdisabled = 0
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id 
where actions.application_id = '53c77db0-58c3-4231-a973-49ee0a32bc18'
and rooms.applicationid = '53c77db0-58c3-4231-a973-49ee0a32bc18'
and actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit'
and rooms.type = 'GROUP'
;
-- 82 messages
-- 39 users