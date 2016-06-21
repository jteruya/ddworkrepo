-- Double Check that Event is EU
select *
from authdb_applications
where lower(applicationid) = '4dccdc48-e962-444e-9229-e45502f392f2'
;
-- Confirmed

-- How many direct messages were sent via app
select count(*) as msgsentcnt
     , count(distinct global_user_id) as msgusercnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as globaluserid
           , userid
      from authdb_is_users
      where lower(applicationid) = '4dccdc48-e962-444e-9229-e45502f392f2'
      and isdisabled = 0
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id 
where actions.application_id = '4dccdc48-e962-444e-9229-e45502f392f2'
and rooms.applicationid = '4dccdc48-e962-444e-9229-e45502f392f2'
and actions.identifier = 'chatTextButton'
and rooms.type = 'GROUP'
;
-- 2896 messages
-- 273 users

-- average direct message sent per person
select avg(msgsentcnt) as avgmsgsentperuser
from (
select actions.global_user_id
     , count(*) as msgsentcnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as globaluserid
           , userid
      from authdb_is_users
      where lower(applicationid) = '4dccdc48-e962-444e-9229-e45502f392f2'
      and isdisabled = 0
      ) users
on actions.global_user_id = users.globaluserid
join channels.rooms rooms
on cast(actions.metadata->>'ChannelId' as int) = rooms.id 
where actions.application_id = '4dccdc48-e962-444e-9229-e45502f392f2'
and rooms.applicationid = '4dccdc48-e962-444e-9229-e45502f392f2'
and actions.identifier = 'chatTextButton'
and rooms.type = 'GROUP'
group by 1
) a
;

-- 10.61 messages per user (of the 273 users)