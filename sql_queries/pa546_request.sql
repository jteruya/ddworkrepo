-- Check in US Server
select *
from authdb_applications
where lower(applicationid) = 'ff43974d-5d6e-4895-8a1f-bda52134c3e6';
-- No, EU Server

select count(*) as msgsentcnt
     , count(distinct actions.global_user_id) as msgsentuserscnt
from fact_actions_live actions
join (select distinct lower(globaluserid) as global_user_id
           , userid
      from authdb_is_users
      where applicationid = 'FF43974D-5D6E-4895-8A1F-BDA52134C3E6'
      and isdisabled = 0) users
on actions.global_user_id = users.global_user_id
join (select distinct rooms.id, members.userid
      from channels.rooms rooms
      join channels.members members
      on rooms.id = members.channelid
      where rooms.applicationid = 'ff43974d-5d6e-4895-8a1f-bda52134c3e6'
      and rooms.type = 'GROUP') rooms
on cast(actions.metadata->>'ChannelId' as bigint) = rooms.id
and users.userid = rooms.userid
where actions.application_id = 'ff43974d-5d6e-4895-8a1f-bda52134c3e6'
and actions.identifier = 'chatTextButton'
and actions.metadata->>'Type' = 'submit'
;


-- DM Messages Sent: 2753
-- DM Messages Sent Users: 451
