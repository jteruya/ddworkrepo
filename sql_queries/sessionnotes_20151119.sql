select count(*) as totalcnt

     --id = itemid
     -- Reason Code 1
     , count(case when lower(pagepath) like '%/client/notes/notes.html?id=%' then 1 else null end) as form1cnt
     
     -- Reason Code 2
     , count(case when lower(pagepath) like '%/client/notes/notes.html?isbundlecredentials%' then 1 else null end) as form2cnt
     
     -- Reason Code 3
     , count(case when lower(pagepath) like '%/client/notes/notes.html?binaryversion=%' then 1 else null end) as form3cnt
     
     -- Reason Code 4 (Last Used: 2/8/2015) Looks Obsolete
     , count(case when lower(pagepath) like '%/client/notes/notes.html?oauth_timestamp=%' then 1 else null end) as form4cnt
     
     -- Reason Code 5
     , count(case when lower(pagepath) like '%/client/notes/all-notes.html?isbundlecredentials%' then 1 else null end) as allnotesform1cnt
     
     -- Reason Code 6
     , count(case when lower(pagepath) like '%/client/notes/all-notes.html?binaryversion=%' then 1 else null end) as allnotesform2cnt
     
     -- Reason Code 7
     , count(case when lower(pagepath) like '%/client/notes/all-notes.html?authbypasstoken=%' then 1 else null end) as allnotesform3cnt

     -- Reason Code 8
     , count(case when lower(pagepath) like '%/client/notes/all-notes.html?t%' then 1 else null end) as allnotesunknowncnt
     
     -- Reason Code 9
     , count(case when lower(pagepath) = '/client/notes/all-notes.html' then 1 else null end) as allnotesform1cnt
     
     -- Reason Code 10 (Last Used: 7/7/2015) Looks Obsolete
     , count(case when lower(pagepath) = '/notes/all-notes.html' then 1 else null end) as allnotesform2cnt
     
from google.session_notes_pageview_counts;


select reasoncode
     , min(date) as mindate
     , max(date) as maxdate
from (
select *
     , case
         when lower(pagepath) like '%/client/notes/notes.html?id=%' then 1
         when lower(pagepath) like '%/client/notes/notes.html?isbundlecredentials%' then 2
         when lower(pagepath) like '%/client/notes/notes.html?binaryversion=%' then 3
         when lower(pagepath) like '%/client/notes/notes.html?oauth_timestamp=%' then 4
         when lower(pagepath) like '%/client/notes/all-notes.html?isbundlecredentials%' then 5
         when lower(pagepath) like '%/client/notes/all-notes.html?binaryversion=%' then 6
         when lower(pagepath) like '%/client/notes/all-notes.html?authbypasstoken=%' then 7
         when lower(pagepath) like '%/client/notes/all-notes.html?t%' then 8
         when lower(pagepath) = '/client/notes/all-notes.html' then 9
         when lower(pagepath) = '/notes/all-notes.html' then 10
       end as reasoncode
from google.session_notes_pageview_counts) a
group by 1;




select itemid
from ratings_item
where isdisabled = 0
and lower(description) like '%/client/notes/notes.html?id=%';


select *
from ratings_item
where isdisabled = 0
and lower(description) like '%notes.html%'
and itemid not in (select itemid
from ratings_item
where isdisabled = 0
and lower(description) like '%/client/notes/notes.html?id=%');












-----------------------

/* Parse Google Analytics Data */

drop table if exists jt.sessionnotes_pageview_parse;
create table jt.sessionnotes_pageview_parse as
select pagepath
     , split_part(split_part(lower(pagepath), 'applicationid=', 2), '&', 1) as applicationid
     , split_part(split_part(lower(pagepath), 'isbundlecredentials=', 2), '&', 1) as isbundlecredentials
     , split_part(split_part(lower(pagepath), 'id=', 2), '&', 1) as id
     , split_part(split_part(lower(pagepath), 'binaryversion=', 2), '&', 1) as binaryversion
     , split_part(split_part(lower(pagepath), 'oauth_signature=', 2), '&', 1) as oauth_signature
     , split_part(split_part(lower(pagepath), 'oauth_consumer_key=', 2), '&', 1) as oauth_consumer_key
     , split_part(split_part(lower(pagepath), 'oauth_nonce=', 2), '&', 1) as oauth_nonce
     , split_part(split_part(lower(pagepath), 'oauth_token=', 2), '&', 1) as oauth_token
     , split_part(split_part(lower(pagepath), 'oauth_version=', 2), '&', 1) as oauth_version
     , split_part(split_part(lower(pagepath), 'oauth_timestamp=', 2), '&', 1) as oauth_timestamp
     , split_part(split_part(lower(pagepath), 'oauth_signature_method=', 2), '&', 1) as oauth_signature_method
     , split_part(split_part(lower(pagepath), 'authbypasstoken=', 2), '&', 1) as authbypasstoken
     , pageviews
from google.session_notes_pageview_counts;

/* Get Session Description Data */

drop table if exists jt.sessionnotes_item_url;
create table jt.sessionnotes_item_url as
select a.applicationid
     , a.itemid
     , case
         when lower(a.description) like '%notes.html%'
         then coalesce(split_part(split_part(a.description, 'webapp.doubledutch.me', 2), '"', 1), split_part(split_part(a.description, 'dd.test.s3.amazonaws.com', 2), '"', 1), split_part(split_part(a.description, 'build.doubledutch.me', 2), '"', 1))
         else null
       end as notesurl
     , a.created
     , a.updated
     , a.isdisabled
from ratings_item a
join ratings_topic b
on a.parenttopicid = b.topicid
and b.listtypeid = 2;

-- Events Population

drop table if exists jt.sessionnotes_events;
create table jt.sessionnotes_events as
select a.bundleid
     , a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.canregister
     , case
          when d.applicationid is not null then 1
          else 0
       end as sessionnoteavailflag
     , case
          when c.applicationid is not null then 1
          else 0
       end as sessionnoteflag
from (select * 
      from authdb_applications
      where startdate >= '2015-01-01') a
left join eventcube.testevents b
on a.applicationid = b.applicationid
left join (select distinct applicationid
           from jt.sessionnotes_item_url
           where isdisabled = 0
           and notesurl is not null) d
on a.applicationid = d.applicationid
left join (select distinct upper(applicationid) as applicationid
           from jt.sessionnotes_pageview_parse
           where length(applicationid) > 0) c
on a.applicationid = c.applicationid
where b.applicationid is null;


/*
drop table if exists jt.sessionnotes_events;
create table jt.sessionnotes_events as
select a.bundleid
     , a.applicationid
     , a.name
     , a.startdate
     , a.enddate
     , a.canregister
     , case
          when c.applicationid is not null then 1
          else 0
       end as sessionnoteflag
from (select * 
      from authdb_applications
      where startdate >= '2015-01-01') a
left join eventcube.testevents b
on a.applicationid = b.applicationid
left join (select distinct upper(applicationid) as applicationid
           from jt.sessionnotes_pageview_parse
           where length(applicationid) > 0) c
on a.applicationid = c.applicationid
where b.applicationid is null;
*/


/* Events with at least one session notes% */
select canregister
     , count(*) as eventcnt
     , count(case when sessionnoteavailflag = 1 then 1 else null end) as sessionnoteavailcnt
     , count(case when sessionnoteflag = 1 then 1 else null end) as sessionnoteviewcnt
     , count(case when sessionnoteflag = 1 then 1 else null end)/count(*)::decimal(12,4) as sessionnoteviewpct
     , count(case when sessionnoteavailflag = 1 and sessionnoteflag = 1 then 1 else null end) as sessionnoteviewavailcnt
     , count(case when sessionnoteavailflag = 1 and sessionnoteflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as sessionnoteviewavailpct
     , count(case when sessionnoteavailflag = 0 and sessionnoteflag = 1 then 1 else null end) as sessionnotenotavialcnt
     , count(case when sessionnoteavailflag = 0 and sessionnoteflag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as sessionnotenotavialpct
from jt.sessionnotes_events
group by 1;




drop table if exists jt.sessionnotes_pageview_users;
create table jt.sessionnotes_pageview_users as
select upper(b.applicationid) as applicationid
     , upper(a.oauth_token) as globaluserid
     , case
         when b.applicationid is not null then 1
         else 0
       end as userfoundflag
     , case
         when b.applicationid is not null and isdisabled = 0 then 0
         when b.applicationid is not null and isdisabled = 1 then 1
         else null
       end isdisabled
     , count(*) as userpageviewcnt
from (select * 
           from jt.sessionnotes_pageview_parse 
           where applicationid is not null and applicationid <> '') a
left join authdb_is_users b
on a.applicationid = lower(b.applicationid)
and a.oauth_token = lower(b.globaluserid)
group by 1,2,3,4;





select a.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , b.canregister
     --, count(*) as totalusercnt
     , count(case when a.isdisabled = 0 then 1 else null end) as activeusercnt
     --, count(case when c.applicationid is not null then 1 else null end) as sessnotecnt
     , count(case when a.isdisabled = 0 and c.applicationid is not null then 1 else null end) as activesessnotecnt
     , case
          when count(case when a.isdisabled = 0 then 1 else null end) > 0 
          then count(case when a.isdisabled = 0 and c.applicationid is not null then 1 else null end)::decimal(12,4)/count(case when a.isdisabled = 0 then 1 else null end)::decimal(12,4) 
          else null
       end as activesessnotepct
from authdb_is_users a
join (select * 
      from jt.sessionnotes_events
      where sessionnoteflag = 1) b
on a.applicationid = b.applicationid
left join (select * from jt.sessionnotes_pageview_users
           where applicationid is not null) c
on a.applicationid = c.applicationid
and a.globaluserid = c.globaluserid
group by 1,2,3,4,5
order by activesessnotepct desc;










--------- How long they use this feature?



/*
select b.*
from (select * 
      from jt.sessionnotes_events
      where sessionnoteflag = 1) a
left join (select * from jt.sessionnotes_pageview_users
           where applicationid is not null) b
on a.applicationid = b.applicationid
join (select * 
      from authdb_applications
      where enddate < '2015-11-01') c
on a.applicationid = c.applicationid
join ;
*/

drop table if exists jt.sessionnotes_pageview_users_view;
create table jt.sessionnotes_pageview_users_view as
select a.*
from fact_views a
join (select * 
      from jt.sessionnotes_pageview_users
      where applicationid is not null) b
on a.application_id = lower(b.applicationid)
and a.global_user_id = lower(b.globaluserid);


drop table if exists jt.sessionnotes_pageview_users_session;
create table jt.sessionnotes_pageview_users_session as
select a.*
     , b.globaluserid
from fact_sessions a
join authdb_is_users b
on a.application_id = lower(b.applicationid)
and a.user_id = b.userid
join (select a.*
           , b.userid 
      from jt.sessionnotes_pageview_users a
      join authdb_is_users b
      on a.globaluserid = b.globaluserid
      where a.applicationid is not null) c
on b.applicationid = c.applicationid
and b.globaluserid = c.globaluserid;




drop table if exists jt.sessionnotes_pageview_users_stats;
create table jt.sessionnotes_pageview_users_stats as
select application_id
     , global_user_id
     , sessionnoteduration
     , b.userfreq
from (select lead(created, 1) over (partition by application_id, global_user_id, device_id order by created) - created as sessionnoteduration
           , lag(identifier, 1) over (partition by application_id, global_user_id, device_id order by created) as previousview
           , *
      from jt.sessionnotes_pageview_users_view) a
left join (select a.applicationid
                , globaluserid
                , sum(b.pageviews) as userfreq
           from jt.sessionnotes_pageview_users a
           join jt.sessionnotes_pageview_parse b
           on b.applicationid = lower(a.applicationid)
           and b.oauth_token = lower(a.globaluserid)
           --where lower(a.applicationid) = '19c85f2b-1280-4c6d-96c0-c80c76633d1a'
           --and lower(a.globaluserid) = '6c9149c3-31a3-4891-8a9a-4b64c71fbf6b'
           group by 1,2) b
on a.application_id = lower(b.applicationid)
and a.global_user_id = lower(b.globaluserid)
where identifier = 'web'
and sessionnoteduration < interval '10' minute;
      





select avg(sessionnoteduration)
     , median(cast(EXTRACT(EPOCH FROM sessionnoteduration) as int))
from jt.sessionnotes_pageview_users_stats;

select avg(cnt)
     , median(cnt)
from (
select application_id
     , global_user_id
     , count(*) as cnt
from jt.sessionnotes_pageview_users_stats
group by 1,2) a;


-- Example

select *
from authdb_is_users
where applicationid = '5E55960F-3D01-48BD-BF51-D4932D6FD6E5';



