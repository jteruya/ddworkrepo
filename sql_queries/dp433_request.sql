-- On US Server

select *
from authdb_applications
where applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31';

-- Exists on US Server

select *
from ratings_topic 
where applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
and listtypeid = 3
and isdisabled = 0;

-- topicId: 10277802

-- All Exhibitor Searches and results

select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.metadata
     , a.created
     , a.mmm_info
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277802'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
group by 1,2,3,4,5) A;

select count(*)
     , count(distinct global_user_id)
from (
select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.metadata
     , a.created
     , a.mmm_info
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277802'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
group by 1,2,3,4,5) A) a;

-- Any Search with no results

select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.metadata
     , a.created
     , a.mmm_info
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277802'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
group by 1,2,3,4,5) A
where resultcnt::int = 0;

select count(*)
     , count(distinct global_user_id)
from (
select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.metadata
     , a.created
     , a.mmm_info
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277802'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
group by 1,2,3,4,5) A
where resultcnt::int = 0) a;

-- Map Searches

select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , case
         when resultcnt::bigint = 2147483647 or resultcnt::bigint = 9223372036854775807 then 'Error'
         else resultcnt
       end as resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.mmm_info
     , a.metadata
     , a.created
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitMapSearch'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'View' = 'map'
group by 1,2,3,4,5) A;
--where (mmm_info like '%iPhone%' or mmm_info like '%iPad%')
--and resultcnt::bigint <> 2147483647
--and resultcnt::bigint <> 9223372036854775807
--and resultcnt::bigint <> 1;

select count(*)
     , count(distinct global_user_id)
from (
select distinct global_user_id
     , device_id
     , mmm_info
     , finalcreated
     , lastsearchterm
     , case
         when resultcnt::bigint = 2147483647 or resultcnt::bigint = 9223372036854775807 then 'Error'
         else resultcnt
       end as resultcnt
from (
select a.global_user_id
     , a.device_id
     , a.mmm_info
     , a.metadata
     , a.created
     , max(a.created) as finalcreated
     , first_value(a.metadata->>'Text') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as lastsearchterm
     , first_value(a.metadata->>'Count') over (partition by a.global_user_id, a.device_id, extract(day from a.created), extract(hour from a.created), extract(minute from a.created), substring(a.metadata->>'Text' from 1 for 1) order by a.created desc) as resultcnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitMapSearch'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'View' = 'map'
group by 1,2,3,4,5) A) A;

-- Taps on "Surveys" in the menu

select count(*)
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'menuItem'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'Url' like '%survey%';

-- 278 clicks on the survey microapp

select count(distinct a.global_user_id)
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'menuItem'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'Url' like '%survey%';


-- 177 unique users clicks on the surveys microapp

select count(distinct lower(globaluserid)) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
      -- 915

select count(*)
from fact_views_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
where a.identifier = 'item'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'ListId' = '10277802';

-- 5,399 exhibitor profile page views


select count(distinct global_user_id) from (
select a.global_user_id
     , metadata->>'ItemId' as exhibitor_itemid
     , c.name as item_name
     , min(a.created) as first_view_datetime
     , count(*) as view_count
from fact_views_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where a.applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
      and b.applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
      and b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') c
on cast(a.metadata->>'ItemId' as int) = c.itemid
where a.identifier = 'item'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
group by 1,2,3
--order by 1,4,5
) a;

-- 442 unique users to the exhibitor profile page

select count(*) as totalbookmarks
     -- 415 bookmars
     , count(distinct global_user_id) as total_users_bookmarked
     -- 108 users
from (
select a.global_user_id
     , metadata->>'ItemId' as exhibitor_itemid
     , c.name as item_name
     , min(a.created) as bookmark_datetime
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31') b
on a.global_user_id = b.global_user_id
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where a.applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
      and b.applicationid = '7C56BC3C-B8BD-42A9-B11B-6B221B661C31'
      and b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') c
on cast(a.metadata->>'ItemId' as int) = c.itemid
where a.identifier = 'bookmarkButton'
and a.application_id = '7c56bc3c-b8bd-42a9-b11b-6b221b661c31'
and a.metadata->>'ToggledTo' = 'on'
group by 1,2,3
order by 1,4) a;