-- On US Server

select *
from authdb_applications
where lower(name) like '%fi%europe%';

-- applicationId: E7DBE508-1E84-4EF9-BF3D-577C789C4DE5

-- Search for Exhibitor List ID for this event

select *
from ratings_topic 
where applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
and listtypeid = 3
and isdisabled = 0;

-- topicId: 10277813

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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277813'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277813'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277813'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitListSearch'
and a.metadata->>'ListId' = '10277813'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitMapSearch'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'submitMapSearch'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and a.metadata->>'View' = 'map'
group by 1,2,3,4,5) A) A;

-- Taps on "Surveys" in the menu

select count(*)
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
--where a.identifier = 'menuButton'
where a.identifier = 'menuItem'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
--and a.metadata->>'View' = 'surveys';
and a.metadata->>'Url' like '%survey%';

-- 265 clicks on the survey microapp
-- 361

select count(distinct a.global_user_id)
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
--where a.identifier = 'menuButton'
where a.identifier = 'menuItem'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
--and a.metadata->>'View' = 'surveys'
and a.metadata->>'Url' like '%survey%';

-- 147 unique users clicks on the surveys microapp
-- 235

select count(distinct lower(globaluserid)) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      -- 1819

select count(*)
from fact_views_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'item'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and a.metadata->>'ListId' = '10277813';

-- 16,068 exhibitor profile page views

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
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where a.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') c
on cast(a.metadata->>'ItemId' as int) = c.itemid
where a.identifier = 'item'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
group by 1,2,3
--order by 1,4,5
) a;


-- 993 unique users to the exhibitor profile page

select count(*) as totalbookmarks
     -- 2,987 bookmars
     , count(distinct global_user_id) as total_users_bookmarked
     -- 397 users
from (
select a.global_user_id
     , metadata->>'ItemId' as exhibitor_itemid
     , c.name as item_name
     , min(a.created) as bookmark_datetime
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where a.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') c
on cast(a.metadata->>'ItemId' as int) = c.itemid
where a.identifier = 'bookmarkButton'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and a.metadata->>'ToggledTo' = 'on'
group by 1,2,3
order by 1,4) a;

-- Follow Up (12/21/2015)
-- Can we have a device breakdown for the Exhibitor searches?


select device_type
     , count(*) as actioncnt
     , count(distinct global_user_id) as usercnt
from (
select a.global_user_id
     , a.device_type
     , a.device_id
     , a.metadata
     , a.created
     , a.mmm_info
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
where a.identifier = 'enterListSearchTextField'
and a.metadata->>'ListId' = '10277813'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5') a
group by 1;

-- Most Searched for Exhibitor on interactive map? (Not sure about this one)

drop table if exists jt.temp_ubm_search_terms_exhibitors
;

create table jt.temp_ubm_search_terms_exhibitors as

select
  i.itemid,
  i.name,
  lower(trim(i.name)) alias
from ratings_item i
join ratings_topic t
on i.parenttopicid = t.topicid
where 1=1
and i.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
and i.isdisabled = 0
and i.isarchived is false
and t.listtypeid = 3
;

drop table if exists jt.temp_ubm_search_terms_searches
;

create table jt.temp_ubm_search_terms_searches as
select
  globaluserid,
  searchterm,
  sum(results) results
from
( select distinct
    a.global_user_id globaluserid,
    a.created::date date,
    extract(hour from a.created)::int "hour",
    extract(minute from a.created)::int "minute",
    first_value(lower(trim(a.metadata ->> 'Text'))) over w searchterm,
    (first_value(a.metadata ->> 'Count') over w)::bigint results
  from fact_actions_live a
  where 1=1
  and a.identifier = 'submitMapSearch'
  and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
  and a.metadata->>'View' = 'map'
  window w as
  ( partition by a.global_user_id
    order by a.created::date,
    extract(hour from a.created)::int,
    extract(minute from a.created)::int
    rows between unbounded preceding and unbounded following
  )
) s
where 1=1
and results != 9223372036854775807
and results != 2147483647
group by 1,2
;

select
  e.itemid,
  e.name,
  count(distinct s.globaluserid) users
-- select name, searchterm, globaluserid
from jt.temp_ubm_search_terms_exhibitors e
join jt.temp_ubm_search_terms_searches s
on e.alias ilike s.searchterm||'%'
group by 1,2
order by users desc
;

-- Number of clicks on ‘View on map’ (from exhibitor detail view)

select count(*) as totalmapviewcnt
     , count(distinct a.global_user_id) as totalusercnt
from fact_actions_live a
join (select distinct lower(globaluserid) as global_user_id
      from authdb_is_users b
      where isdisabled = 0
      and applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5') b
on a.global_user_id = b.global_user_id
join (select a.*
      from ratings_item a
      join ratings_topic b
      on a.parenttopicid = b.topicid
      where a.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.applicationid = 'E7DBE508-1E84-4EF9-BF3D-577C789C4DE5'
      and b.listtypeid = 3
      and a.isdisabled = 0
      and b.isdisabled = 0
      and b.ishidden = 'false') c
on cast(a.metadata->>'ItemId' as int) = c.itemid
where a.identifier = 'exhibitorProfileButton'
and a.application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and a.metadata->>'Type' = 'map';

-- 596 clicks on view on map
-- 209 unique users

