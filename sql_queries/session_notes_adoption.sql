-- Drop Session Note Actions Table
drop table if exists jt.session_notes_fact_actions
;

-- Create Session Note Actions Table
create table jt.session_notes_fact_actions as
select * from fact_actions_live limit 0
;

-- Insert into Session Note Action Table
insert into jt.session_notes_fact_actions
select *
from fact_actions_live
where identifier in ('addSessionNoteButton',
                     'enterTextSessionNote',
                     'saveSessionNoteButton',
                     'shareSessionNotesButton',
                     'editSessionNoteButton'
                     )
;

-- Drop Session Notes User Spine
drop table if exists jt.session_notes_user_spine_main
;

-- Create Session Notes User Spine
create table jt.session_notes_user_spine_main
( applicationid uuid,
  globaluserid uuid,
  identifier text,
  actions int
)
;

-- Insert Into Session Notes User Spine
insert into jt.session_notes_user_spine_main
select
  s.application_id::uuid,
  s.global_user_id::uuid,
  i.identifier,
  coalesce(a.actions,0) actions
from
( select distinct
    application_id,
    global_user_id
  from jt.session_notes_fact_actions
  where 1=1
  and identifier in
  ( 'addSessionNoteButton',
    'enterTextSessionNote',
    'saveSessionNoteButton',
    'shareSessionNotesButton',
    'editSessionNoteButton'
  )
  and application_id is not null
  and global_user_id is not null
) s
join
( select 'addSessionNoteButton' identifier union all
  select 'enterTextSessionNote' identifier union all
  select 'saveSessionNoteButton' identifier union all
  select 'shareSessionNotesButton' identifier union all
  select 'editSessionNoteButton' identifier
) i
on 1=1
left join
( select
    application_id,
    global_user_id,
    identifier,
    count(*) actions
  from jt.session_notes_fact_actions
  where 1=1
  and identifier in
  ( 'addSessionNoteButton',
    'enterTextSessionNote',
    'saveSessionNoteButton',
    'shareSessionNotesButton',
    'editSessionNoteButton'
  )
  and application_id is not null
  and global_user_id is not null
  group by 1,2,3
) a
on 1=1
and s.application_id = a.application_id
and s.global_user_id = a.global_user_id
and i.identifier = a.identifier
order by 1,2,3
;




-- Events that have Session Notes Enabled
select count(ecs.applicationid)
     -- 572
     , count(case when ecs.nativesessionnotes = 1 then 1 else null end)
     -- 545
     , count(case when ecs.nativesessionnotes = 1 then 1 else null end)::decimal(12,4)/count(ecs.applicationid)::decimal(12,4)
     -- 94.95%
     , min(ecs.startdate)
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
where te.applicationid is null
and ecs.enddate < '2016-05-03'
and ecs.binaryversion >= '6.3'
;

-- Get Session Notes User Level (Non-Disabled Users)
drop table if exists jt.session_notes_user_spine_main_final
;

-- Create Table
create table jt.session_notes_user_spine_main_final as
select * from jt.session_notes_user_spine_main limit 0
;

-- Insert into Table
insert into jt.session_notes_user_spine_main_final
select main.*
from jt.session_notes_user_spine_main main
join eventcube.eventcubesummary ecs
on main.applicationid = ecs.applicationid::uuid
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
join (select distinct applicationid::uuid as application_id
           , globaluserid::uuid as global_user_id
           , userid
      from authdb_is_users
      where isdisabled = 0
      ) users
on main.globaluserid = users.global_user_id
and main.applicationid = users.application_id
where te.applicationid is null
and ecs.enddate < '2016-05-03'
and ecs.binaryversion >= '6.3'
and ecs.nativesessionnotes = 1
;

-- Results
select ecs.applicationid as "Application ID"
     , ecs.name as "Event Name"
     , ecs.startdate as "Event Start Date"
     , ecs.enddate as "Event End Date"
     , ecs.usersactive as "Active Users Count"
     , coalesce(final.usercnt,0) as "Session Notes Users Count"
     , coalesce(final.usercnt::decimal(12,4)/ecs.usersactive::decimal(12,4),0) as "Session Notes Users %"
from eventcube.eventcubesummary ecs
left join eventcube.testevents te
on ecs.applicationid = te.applicationid
left join (select applicationid
                , count(distinct globaluserid) as usercnt
           from jt.session_notes_user_spine_main_final
           group by 1
          ) final
on final.applicationid = ecs.applicationid::uuid
where te.applicationid is null
and ecs.enddate < '2016-05-03'
and ecs.binaryversion >= '6.3'
and ecs.nativesessionnotes = 1
order by 3,4
;


