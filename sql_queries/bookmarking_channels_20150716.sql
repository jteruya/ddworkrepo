


select *
from authdb_is_users
where userid = 44609087;

select *
from public.fact_views
where identifier = 'item'
and metadata->>'type' = 'speaker'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and global_user_id = 'b01557ae-a2c4-4cd0-95cc-d9b55cb8dd3e'
order by created;

select *
from public.fact_views
where identifier = 'item'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and global_user_id = 'b01557ae-a2c4-4cd0-95cc-d9b55cb8dd3e'
and created >= '2015-07-15'
order by created;


select app_type_id
     , metadata->>'view'
     , metadata->>'listtype'
     , count(*)
from public.fact_actions
where identifier = 'bookmarkbutton'
and created >= '2015-05-15'
group by 1,2,3;

select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and global_user_id = 'b01557ae-a2c4-4cd0-95cc-d9b55cb8dd3e'
and created >= '2015-07-15';

select *
from ratings_item
where itemid in (9114085, 7460737);

select *
from ratings_topic
where topicid = 10214285;





select metadata->>'view'
     , metadata->>'listtype'
     , count(*)
from public.fact_actions
where identifier = 'bookmarkbutton'
and created >= '2015-05-01'
group by 1,2;


drop table if exists jt.view_listtype;

select a.app_type_id
     , a.itemid
     , a.viewtype
     , a.listtype
into jt.view_listtype
from (select app_type_id
           , metadata->>'itemid' as itemid
           , metadata->>'view' as viewtype
           , case
               when app_type_id <> 3 then metadata->>'listtype' 
               else metadata->>'listtype '
               end as listtype
      from public.fact_actions 
      where identifier = 'bookmarkbutton'
      and created >= '2015-05-01'
      group by 1,2,3,4) a
join public.ratings_item i
on a.itemid::int = i.itemid
join (select *
      from public.ratings_topic
      where listtypeid = 2) t
on i.parenttopicid = t.topicid;
--where a.viewtype = 'list';





select *
from jt.view_listtype
where app_type_id = 1
and viewtype = 'item'
and listtype is null limit 1;

select app_type_id
           , metadata->>'itemid' as itemid
           , metadata->>'view' as viewtype
           , metadata
           , case
               when app_type_id <> 3 then metadata->>'listtype' 
               else metadata->>'listtype '
               end as listtype
      from public.fact_actions 
      where identifier = 'bookmarkbutton'
      and created >= '2015-05-01'
      and metadata->>'itemid' = '9293433';

select app_type_id
     , viewtype
     , listtype
     , count(*)
from jt.view_listtype
group by 1,2,3;




select *
from public.fact_actions 
      where identifier = 'bookmarkbutton'
      and application_id = '05392f8d-4224-4fc6-b246-1021c4d08f0f'
      and metadata->>'itemid' = '9136201' limit 2;

select *
from jt.view_listtype
where itemid::int = 9136201;


--815
select distinct itemid
from jt.view_listtype
where listtype is not null
except
select distinct itemid
from jt.view_listtype
where listtype is null;
--773

select distinct itemid
from jt.view_listtype
where listtype is null
except
select distinct itemid
from jt.view_listtype
where listtype is not null;


select *
from ratings_item
where itemid = 9142526;


select c.name
     , count(*)
from jt.view_listtype a
join ratings_item b
on a.itemid::int = b.itemid
join ratings_topic c
on b.parenttopicid = c.topicid
where a.listtype is not null
group by 1;
-- 2

select c.name
     , count(*)
from jt.view_listtype a
join ratings_item b
on a.itemid::int = b.itemid
join ratings_topic c
on b.parenttopicid = c.topicid
where a.listtype is null
group by 1;
--2







select *
from ratings_topic
where topicid = 10271623;

select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and metadata->>'viewtype' = 'list'
and metadata->>'listtype' <> 'agenda'
and metadata->>'listtype' <> 'regular'
and metadata->>'listtype' <> 'speakers'
and metadata->>'listtype' <> 'exhibitors'
and created >= '2015-05-01'
limit 1;




select *
from public.fact_actions 
where identifier = 'bookmarkbutton'
and application_id = '05392f8d-4224-4fc6-b246-1021c4d08f0f'
and metadata->>'view' = 'list';


select distinct global_user_id
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '05392f8d-4224-4fc6-b246-1021c4d08f0f'
and created >= '2015-07-15 13:00:00';

b13c0940-3ac7-45c6-8412-a0f0ce96f95c


select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '05392f8d-4224-4fc6-b246-1021c4d08f0f'
and global_user_id = 'b13c0940-3ac7-45c6-8412-a0f0ce96f95c'
order by created;

select *
from ratings_item
where itemid in (9136201, 9249572, 9249578, 9145244);


select metadata->>'view' as view
     , metadata->>'listtype ' as listtype
     , count(*)
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and app_type_id = 3
group by 1,2;

select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and app_type_id = 3 limit 1;


45EC741E-FCD2-4BC3-8B47-36BFD60D59A1



select *
from public.fact_actions
where app_type_id = 1
and metadata->>'view' = 'item'
and metadata->>'itemid' = '9293433';


select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and global_user_id = 'b01557ae-a2c4-4cd0-95cc-d9b55cb8dd3e'
and app_type_id = 3
and created >= '2015-07-16'
order by created;

select *
from public.fact_actions
where identifier = 'bookmarkbutton'
and application_id = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and global_user_id = 'b01557ae-a2c4-4cd0-95cc-d9b55cb8dd3e'
and app_type_id = 1
and created >= '2015-07-15'
order by created;



------------------Work Above-------------

-- Answer
drop table if exists jt.bookmarkbutton_action;

select app_type_id
     , application_id
     , identifier
     , created
     , cast(metadata->>'itemid' as int) as itemid
     , metadata->>'toggledto' as toggledto
     , metadata->>'view' as view
     , case
         when app_type_id in (1,2) then metadata->>'listtype' 
         else metadata->>'listtype '
       end as listtype
into jt.bookmarkbutton_action
from public.fact_actions
where identifier = 'bookmarkbutton'
and created >= '2015-05-01'
and metadata->>'toggledto' = 'on';


select count(*) as total_bookmarking
     , count(case when app_type_id in (3) then 1 else null end) as total_and_bookmarking
     , cast(cast(count(case when app_type_id in (3) then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_and_bookmarking
     , count(case when app_type_id in (3) and view = 'list' and listtype = 'agenda' then 1 else null end) as tot_and_agenda_speaker_bookmarking
     , cast(cast(count(case when app_type_id in (3) and view = 'list' and listtype = 'agenda' then 1 else null end) as decimal(12,4))/cast(count(case when app_type_id in (3) then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_and_agenda_speaker_bookmarking
     , count(case when app_type_id in (3) and view = 'item' and listtype = 'agenda' then 1 else null end) as tot_and_detailed_session_bookmarking
     , cast(cast(count(case when app_type_id in (3) and view = 'item' and listtype = 'agenda' then 1 else null end) as decimal(12,4))/cast(count(case when app_type_id in (3) then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_and_detailed_session_bookmarking       
     , count(case when app_type_id in (1,2) then 1 else null end) as total_ios_bookmarking
     , cast(cast(count(case when app_type_id in (1,2) then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_ios_bookmarking
     , count(case when app_type_id in (1,2) and view = 'list' and listtype = 'agenda' then 1 else null end) as total_ios_agenda_bookmarking
     , cast(cast(count(case when app_type_id in (1,2) and view = 'list' and listtype = 'agenda' then 1 else null end) as decimal(12,4))/cast(count(case when app_type_id in (1,2) then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_agenda_bookmarking
     , count(case when app_type_id in (1,2) and view = 'item' and listtype = 'agenda' then 1 else null end) as total_ios_linked_session_bookmarking
     , cast(cast(count(case when app_type_id in (1,2) and view = 'item' and listtype = 'agenda' then 1 else null end) as decimal(12,4))/cast(count(case when app_type_id in (1,2) then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_linked_session_bookmarking
     , count(case when view = 'item' and listtype is null then 1 else null end) as total_ios_detailed_session_bookmarking
     , cast(cast(count(case when app_type_id in (1,2) and view = 'item' and listtype is null then 1 else null end) as decimal(12,4))/cast(count(case when app_type_id in (1,2) then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_detailed_session_bookmarking
from jt.bookmarkbutton_action a
join public.ratings_item i
on a.itemid::int = i.itemid
join (select *
      from public.ratings_topic
      where listtypeid = 2) t
on i.parenttopicid = t.topicid
join jt.tm_eventcubesummary e
on a.application_id = e.applicationid::varchar;


-- Julia Response

-- Sessions/User Staging Table
select application_id
     , user_id
     , app_type_id
     , start_date
into jt.event_sessions
from fact_sessions f
join jt.tm_eventcubesummary e
on f.application_id = e.applicationid::varchar
where start_date >= '2015-05-01'
and metrics_type_id = 1;

-- Sessions Breakdowns
select count(*) as total_sessions
     , count(case when app_type_id in (1,2) then 1 else null end) as ios_total_sessions
     , cast(cast(count(case when app_type_id in (1,2) then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as ios_pct_sessions
     , count(case when app_type_id in (3) then 1 else null end) as and_total_sessions
     , cast(cast(count(case when app_type_id in (3) then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as and_pct_sessions
from jt.event_sessions;

-- Number of Users (Android/iOS)      
select count(*) - b.total_users_in_both as total_users
     , count(case when app_type_id = 1 then 1 else null end) - b.total_users_in_both as ios_total_user
     , cast(cast(count(case when app_type_id = 1 then 1 else null end) - b.total_users_in_both as decimal(12,4))/cast(count(*) - b.total_users_in_both as decimal(12,4)) as decimal(12,4)) as ios_pct_user
     , count(case when app_type_id = 3 then 1 else null end) - b.total_users_in_both as and_total_user
     , cast(cast(count(case when app_type_id = 3 then 1 else null end) - b.total_users_in_both as decimal(12,4))/cast(count(*) - b.total_users_in_both as decimal(12,4)) as decimal(12,4)) as and_pct_user
     , b.total_users_in_both
     , cast(cast(b.total_users_in_both as decimal(12,4))/cast(count(*) - b.total_users_in_both as decimal(12,4)) as decimal(12,4)) as pct_users_in_both
from (select distinct case when app_type_id in (1,2) then 1 else 3 end as app_type_id
           , user_id
      from jt.event_sessions) a
join (select count(*) as total_users_in_both
      from (select distinct user_id
            from jt.event_sessions
            where app_type_id in (1,2)) i
      join (select distinct user_id
            from jt.event_sessions
            where app_type_id in (3)) a
      on a.user_id = i.user_id) b
on 1 = 1
join (select user_id
      from jt.event_sessions
      group by 1
      having count(*) > 30) c
on a.user_id = c.user_id
group by b.total_users_in_both; 
