drop table if exists jt.email_funnel_delivered;
drop table if exists jt.email_funnel_delivered_once;
drop table if exists jt.email_funnel_delivered_more_than_once;
drop table if exists jt.email_funnel_events_lvl_2;
drop table if exists jt.email_funnel_events_lvl_3;
drop table if exists jt.email_funnel_events_lvl_4;
drop table if exists jt.email_funnel_events_spine;
drop table if exists jt.email_funnel_events_summary;
drop table if exists jt.email_funnel_strange_paths;
drop table if exists jt.email_funnel_fact_analysis;
drop table if exists jt.email_funnel_login_funnel;




/* Table: email_funnel_delivered
   Desciption: Email Delivery Staging Table */

select a.applicationid
     , b.name
     , b.eventtype
     , a.messageid
     , a.subject
     , case
         when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'passwordresetemail'
         when a.subject like '%sent you a message%' then 'messagealertemail'
         when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'welcomeemail'
         when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'dailydigestemail'
         when a.subject like 'Your Session Notes' then 'sessionnotealertemail'
         when a.subject like 'Your Beacon Message Info' then 'beaconmessageinfoemail'
         when a.subject like 'Exhibitor Opportunity %' then 'exhibitoropportunityemail'
         when a.subject like 'Your Leads Report %' then 'leadsreportemailemail'
         when a.subject like 'Set Up Lead Scanning For %' then 'setupleadscanningcalltoactionemail'
         when a.subject like 'Activity Flagged %' then 'activityflaggedemail'
         when a.subject like '% has requested a meeting' then 'meetingrequestemail'
         when a.subject is null then 'nullsubjectemail'
         else 'unknownemail'
       end as emailsubjectcatg
     , a.recipientemail
     , a.senderemail
     , a.eventstatus
     , a.clickurl
     , a.id
     , a.eventtimestamp
into jt.email_funnel_delivered
from mailgun_events a
join authdb_applications b
on a.applicationid::varchar = lower(b.applicationid)
where a.eventstatus = 'delivered'
and a.subject like 'Welcome to %'
and (a.applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or a.applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E'
or a.applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831');



/* Table: email_funnel_delivered_once
   Description: This contains emails that were only delivered once. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.email_funnel_delivered_once
from jt.email_funnel_delivered
group by 1,2,3,4,5,6,7
having count(*) = 1;

/* Table: email_funnel_delivered_more_than_once
   Description: This contains emails that were delivered more than once - anomaly. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.email_funnel_delivered_more_than_once
from jt.email_funnel_delivered
group by 1,2,3,4,5,6,7
having count(*) > 1;


/* Table: email_funnel_events_lvl_2
   Description: This contains all emails with 'delivered' and/or 'failed' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.email_funnel_events_lvl_2
from mailgun_events
where (eventstatus = 'delivered' or eventstatus = 'failed')
and (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E'
or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831');

/* Table: email_funnel_events_lvl_3
   Description: This contains all emails with 'opened' and/or 'complained' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
     , case
        when devicetype is null then 'no data'
        else devicetype
       end as devicetype
     , case
        when clienttype is null then 'no data'
        else clienttype
       end as clienttype
     , case
        when clientos is null then 'no data'
        else clientos
       end as clientos
     , case
        when useragent is null then 'no data'
        else useragent
       end as useragent
into jt.email_funnel_events_lvl_3
from mailgun_events
where (eventstatus = 'opened' or eventstatus = 'complained')
and (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E'
or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831');

/* Table: email_funnel_events_lvl_4
   Description: This contains all email with 'clicked' and/or 'unsubscribed' and/or 'stored' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
     , case
        when devicetype is null then 'no data'
        else devicetype
       end as devicetype
     , case
        when clienttype is null then 'no data'
        else clienttype
       end as clienttype
     , case
        when clientos is null then 'no data'
        else clientos
       end as clientos
     , case
        when useragent is null then 'no data'
        else useragent
       end as useragent
into jt.email_funnel_events_lvl_4
from mailgun_events
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored')
and (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E'
or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831');

/* Table: email_funnel_events_spine
   Description: This staging table is a spine table with all of the messageids.
*/

select a.*
into jt.email_funnel_events_spine
from jt.email_funnel_delivered_once a
join (select distinct messageid
      from jt.email_funnel_events_lvl_2
      union
      select distinct messageid
      from jt.email_funnel_events_lvl_3
      union
      select distinct messageid
      from jt.email_funnel_events_lvl_4) b
on a.messageid = b.messageid;


/* Table: email_funnel_events_summary
   Description: This staging table tracks the different states that a message flows through.
*/

select a.*
     , case
         when c.messageid is not null then true
         else false
       end as delivered_flag
     , case
         when c.messageid is not null then c.eventtimestamp
         else null
       end as delivered_time
--     , coalesce(c.cnt,0) as delivered_cnt

     , case
         when d.messageid is not null then true
         else false
       end as failed_flag
     , case
         when d.messageid is not null then d.eventtimestamp
         else null
       end as failed_time
--    , coalesce(d.cnt,0) as failed_cnt

     , case
         when e.messageid is not null then true
         else false
       end as opened_flag
     , case
         when e.messageid is not null then e.eventtimestamp
         else null
       end as opened_time
--     , coalesce(e.cnt,0) as opened_cnt

     , case
         when f.messageid is not null then true
         else false
       end as complained_flag
     , case
         when f.messageid is not null then f.eventtimestamp
         else null
       end as complained_time
--     , coalesce(f.cnt,0) as complained_cnt

     , case
         when g.messageid is not null then true
         else false
       end as clicked_flag
     , case
         when g.messageid is not null then g.eventtimestamp
         else null
       end as clicked_time
--     , coalesce(g.cnt,0) as clicked_cnt

     , case
         when j.messageid is not null then true
         else false
       end as clicked_download_flag
     , case
         when j.messageid is not null then g.eventtimestamp
         else null
       end as clicked_download_time

     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
     , case
         when h.messageid is not null then i.eventtimestamp
         else null
       end as unsubscribed_time
--     , coalesce(i.cnt,0) as stored_cnt

     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
     , case
         when i.messageid is not null then i.eventtimestamp
         else null
       end as stored_time
--     , coalesce(i.cnt,0) as stored_cnt
into jt.email_funnel_events_summary
from jt.email_funnel_events_spine a
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_2 where eventstatus = 'delivered' group by 1) c
on a.messageid = c.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_2 where eventstatus = 'failed' group by 1) d
on a.messageid = d.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_3 where eventstatus = 'opened' group by 1) e
on a.messageid = e.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_3 where eventstatus = 'complained' group by 1) f
on a.messageid = f.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_4 where eventstatus = 'clicked' group by 1) g
on a.messageid = g.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_4 where eventstatus = 'unsubscribed' group by 1) h
on a.messageid = h.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_4 where eventstatus = 'stored' group by 1) i
on a.messageid = i.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.email_funnel_events_lvl_4 where eventstatus = 'clicked' and clickurl like '%download%' group by 1) j
on a.messageid = j.messageid;





/* Table: email_funnel_strange_paths
   Description: This table contains the emails where anolalous events paths (e.g. "Opened" event but no "Delivered" event) occur.
*/

select applicationid
     , case
         when recipientemail like '%<%>%' then substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1))
         else recipientemail
       end as recipientemail
     , messageid
     , delivered_flag
     , failed_flag
     , opened_flag
     , complained_flag
     , clicked_flag
     , unsubscribed_flag
     , stored_flag
     , case
         when ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false)
            then 1
         when ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
            then 2
         else -1
       end as case_type
into jt.email_funnel_strange_paths
from jt.email_funnel_events_summary
where ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
or ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false);



/* Table: email_funnel_fact_analysis
   Description: This table contains the messages that are not in the strange_paths table.
*/

select a.applicationid
     , a.eventtype
     , a.emailsubjectcatg
     , case
         when a.recipientemail like '%<%>%' then substring(a.recipientemail from (position('<' in a.recipientemail) + 1) for (position('>' in a.recipientemail) - position('<' in a.recipientemail) - 1))
         else a.recipientemail
       end as recipientemail
     , a.messageid
     , a.delivered_flag
     , a.delivered_time
     , a.failed_flag
     , a.failed_time
     , case
         when b.case_type = 1 then true
         else a.opened_flag
       end as opened_flag
     , a.opened_time
     , a.complained_flag
     , a.complained_time
     , a.clicked_flag
     , a.clicked_time
     , a.clicked_download_flag
     , a.clicked_download_time
     , a.unsubscribed_flag
     , a.unsubscribed_time
     , a.stored_flag
     , a.stored_time
into jt.email_funnel_fact_analysis
from jt.email_funnel_events_summary a
left join jt.email_funnel_strange_paths b
on a.messageid = b.messageid and a.applicationid = b.applicationid
where b.applicationid is null
or (b.applicationid is not null and b.case_type <> -1);




/* Table: email_funnel_login_funnel
   Description: This contains the funnel at the event level
*/

select d.applicationid
     , e.name as eventname
     , cast(e.startdate as date)
     , cast(e.enddate as date)
     , u.registered_attendees
     , d.delivered_count
     , d.delivered_count::decimal(12,4)/u.registered_attendees::decimal(12,4) as delivered_pct
     , coalesce(o.opened_count,0) as opened_count
     , coalesce(o.opened_count,0)::decimal(12,4)/d.delivered_count::decimal(12,4) as opened_pct
     , coalesce(c.clicked_count,0) as clicked_count
     , coalesce(c.clicked_count,0)::decimal(12,4)/coalesce(o.opened_count,0)::decimal(12,4) as clicked_pct
     , coalesce(a.clicked_download_count,0) as clicked_download_count
     , coalesce(a.clicked_download_count,0)::decimal(12,4)/coalesce(o.opened_count,0)::decimal(12,4) as clicked_download_pct
into jt.email_funnel_login_funnel
from (select lower(applicationid) as applicationid
           , count(*) as registered_attendees
      from authdb_is_users
      where (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
      or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E'
      or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831')
      and isdisabled = 0
      group by 1) u
left join (select applicationid
           , count(*) as delivered_count
      from (select distinct applicationid
                , recipientemail
           from jt.email_funnel_fact_analysis
           where delivered_flag = true) x
      group by 1) d
on u.applicationid = d.applicationid::varchar
left join (select applicationid
                , count(*) as opened_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.email_funnel_fact_analysis
                 where opened_flag = true) x
            group by 1) o
on d.applicationid = o.applicationid
left join (select applicationid
                , count(*) as clicked_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.email_funnel_fact_analysis
                 where clicked_flag = true) x
            group by 1) c
on d.applicationid = c.applicationid
left join (select applicationid
                , count(*) as clicked_download_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.email_funnel_fact_analysis
                 where clicked_download_flag = true) x
            group by 1) a
on d.applicationid = a.applicationid
left join authdb_applications e
on d.applicationid::varchar = lower(e.applicationid)
order by 3,4;



select *
from jt.email_funnel_login_funnel;


-----------------------Run On Alfred--------------------------

drop table if exists jt.email_funnel_agg_session_per_appuser;

create table jt.email_funnel_agg_session_per_appuser as
select s.application_id as applicationid
     , s.user_id as userid
from (select * from public.fact_sessions where (application_id = 'ad948081-37d1-4860-9325-c03e7641eed0' or application_id = '01daab86-09e3-4dde-8b31-2cde722e211e' or application_id = '8b37a4ca-f023-43b3-801f-189eb7506831')) s
join (select * from authdb_is_users where (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0' or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E' or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831') and isdisabled = 0) u
on s.user_id = u.userid
group by s.application_id, s.user_id;


/* Active Users */
select applicationid
     , count(*)
from jt.email_funnel_agg_session_per_appuser
group by 1;
--148


select applicationid
     , count(*) from
(select distinct global_user_id
from fact_actions 
where (application_id = 'ad948081-37d1-4860-9325-c03e7641eed0' or application_id = '01daab86-09e3-4dde-8b31-2cde722e211e' or application_id = '8b37a4ca-f023-43b3-801f-189eb7506831')
and lower(identifier) in ('bookmarkbutton', 'checkinbutton', 'likebutton', 'followbutton', 'ratebutton', 'submitcommentbutton', 'submitpollbutton', 'submitsurveyresponsebutton')) a
join (select * from authdb_is_users where (applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0' or applicationid = '01DAAB86-09E3-4DDE-8B31-2CDE722E211E' or applicationid = '8B37A4CA-F023-43B3-801F-189EB7506831') and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid
group by 1;

"Bookmarks" -> 'bookmarkbutton'
"CheckIns" -> 'checkinbutton'
"Likes" -> 'likebutton'
"Follows" -> 'followbutton'
"Ratings" -> 'ratebutton'
"Updates" -> 
"Comments" -> 'submitcommentbutton'
"PollResponses" -> 'submitpollbutton'
"SurveyResponses" -> 'submitsurveyresponsebutton'

--138

-- Test TINTech 


drop table if exists jt.email_funnel_agg_session_per_appuser;

create table jt.email_funnel_agg_session_per_appuser as
select s.application_id as applicationid
     , s.user_id as userid
from (select * from public.fact_sessions where application_id = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8') s
join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) u
on s.user_id = u.userid
group by s.application_id, s.user_id;

/* Active Users */
select count(*)
from jt.email_funnel_agg_session_per_appuser;
--CMS: 206
--SQL: 195



/* Likes, Comments/Status, Follow, Checkins */
select count(*) 
from (
select distinct userid from ratings_usercheckinlikes where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 'false'
union
select distinct userid from ratings_usercheckincomments where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 'false'
union 
select distinct userid from ratings_userfavorites where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 'false'
union 
select distinct userid from ratings_usercheckins where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
union
select distinct a.userid from (select * from ratings_usertrust where isdisabled = 'false') a 
join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) b 
on a.userid = b.userid
--union
--select distinct a.userid from (select * from ratings_userbadges) a 
--join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) b 
--on a.userid = b.userid
) a
join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) u
on a.userid = u.userid;

select count(*) from
(select distinct global_user_id
from fact_actions 
where application_id = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
and lower(identifier) in ('likebutton', 'submitcommentbutton'/*,'followbutton', 'checkinbutton','submitsendmessage'*/,'submitpostbutton'/*,'submitpollbutton','submitsurveyresponsebutton','submitglobalsearch','submitlistsearch','submitleadnotebutton'*/,'bookmarkbutton')) a
join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid;

select count(*) from
(select distinct global_user_id
from fact_actions 
where application_id = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
and lower(identifier) in ('bookmarkbutton', 'checkinbutton', 'likebutton', 'followbutton', 'ratebutton', 'submitcommentbutton', 'submitpollbutton', 'submitsurveyresponsebutton')) a
join (select * from authdb_is_users where applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid;

-- TinTech
-- 136
--SQL(new): 131
--SQL: 126
--CMS: 127


-- Performance Support Symposium
-- 904434f2-c7c7-4c84-a972-bee9ef324900

select count(*) 
from (
select distinct userid from ratings_usercheckinlikes where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 'false'
union
select distinct userid from ratings_usercheckincomments where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 'false'
union 
select distinct userid from ratings_userfavorites where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 'false'
union 
select distinct userid from ratings_usercheckins where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
union
select distinct a.userid from (select * from ratings_usertrust where isdisabled = 'false') a 
join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) b 
on a.userid = b.userid
--union
--select distinct a.userid from (select * from ratings_userbadges) a 
--join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) b 
--on a.userid = b.userid
) a
join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) u
on a.userid = u.userid;

select count(*) from
(select distinct global_user_id
from fact_actions 
where application_id = '904434f2-c7c7-4c84-a972-bee9ef324900'
and lower(identifier) in ('likebutton', 'submitcommentbutton','followbutton', 'checkinbutton','submitsendmessage','submitpostbutton','submitpollbutton','submitsurveyresponsebutton','submitglobalsearch','submitlistsearch','submitleadnotebutton','bookmarkbutton')) a
join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid;

select count(*) from
(select distinct global_user_id
from fact_actions 
where application_id = '904434f2-c7c7-4c84-a972-bee9ef324900'
and lower(identifier) in ('likebutton', 'submitcommentbutton'/*,'followbutton', 'checkinbutton','submitsendmessage'*/,'submitpostbutton'/*,'submitpollbutton','submitsurveyresponsebutton','submitglobalsearch','submitlistsearch','submitleadnotebutton'*/,'bookmarkbutton')) a
join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid;

select count(*) from
(select distinct global_user_id
from fact_actions 
where application_id = '904434f2-c7c7-4c84-a972-bee9ef324900'
and lower(identifier) in ('bookmarkbutton', 'checkinbutton', 'likebutton', 'followbutton', 'ratebutton', 'submitcommentbutton', 'submitpollbutton', 'submitsurveyresponsebutton')) a
join (select * from authdb_is_users where applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' and isdisabled = 0) u
on upper(a.global_user_id) = u.globaluserid;

-- 187
-- SQL(new): 188
-- SQL: 186
-- CMS: 191