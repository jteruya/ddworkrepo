--drop table if exists jt.seamless_accepted;
drop table if exists jt.seamless_delivered;
drop table if exists jt.seamless_delivered_once;
drop table if exists jt.seamless_delivered_more_than_once;
drop table if exists jt.seamless_events_lvl_2;
drop table if exists jt.seamless_events_lvl_3;
drop table if exists jt.seamless_events_lvl_4;
drop table if exists jt.seamless_events_spine;
drop table if exists jt.seamless_events_summary;
drop table if exists jt.seamless_strange_paths;
drop table if exists jt.seamless_fact_analysis;
drop table if exists jt.seamless_login_funnel;


/*
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
into jt.seamless_email
from mailgun_events a
join jt.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'accepted'
and a.subject like 'Welcome to %'
and (a.applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2'
or a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or a.applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');
*/



/* Table: seamless_delivered
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
into jt.seamless_delivered
from mailgun_events a
join jt.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'delivered'
and a.subject like 'Welcome to %'
and (a.applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2'
or a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or a.applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');


/* Table: seamless_delivered_once
   Description: This contains emails that were only delivered once. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.seamless_delivered_once
from jt.seamless_delivered
group by 1,2,3,4,5,6,7
having count(*) = 1;

/* Table: seamless_delivered_more_than_once
   Description: This contains emails that were delivered more than once - anomaly. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.seamless_delivered_more_than_once
from jt.seamless_delivered
group by 1,2,3,4,5,6,7
having count(*) > 1;


/* Table: seamless_events_lvl_2
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
into jt.seamless_events_lvl_2
from mailgun_events
where (eventstatus = 'delivered' or eventstatus = 'failed')
and (applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2'
or applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');

/* Table: seamless_events_lvl_3
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
into jt.seamless_events_lvl_3
from mailgun_events
where (eventstatus = 'opened' or eventstatus = 'complained')
and (applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2'
or applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');

/* Table: seamless_events_lvl_4
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
into jt.seamless_events_lvl_4
from mailgun_events
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored')
and (applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2'
or applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or applicationid = '85874647-B187-49EF-8A45-E3B5720E1755');

/* Table: seamless_events_spine
   Description: This staging table is a spine table with all of the messageids.
*/

select a.*
into jt.seamless_events_spine
from jt.seamless_delivered_once a
join (select distinct messageid
      from jt.seamless_events_lvl_2
      union
      select distinct messageid
      from jt.seamless_events_lvl_3
      union
      select distinct messageid
      from jt.seamless_events_lvl_4) b
on a.messageid = b.messageid;


/* Table: seamless_events_summary
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
       end as clicked_bnc_flag
     , case
         when j.messageid is not null then j.eventtimestamp
         else null
       end as clicked_bnc_time       
     , case
         when j.messageid is not null then j.clientos
         else null
       end as clicked_bnc_clientos    
     , case
         when j.messageid is not null then j.devicetype
         else null
       end as clicked_bnc_devicetype  
     , case
         when j.messageid is not null then j.clienttype
         else null
       end as clicked_bnc_clienttype
     , case
         when j.messageid is not null then j.useragent
         else null
       end as clicked_bnc_useragent    
     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
     , case
         when h.messageid is not null then h.eventtimestamp
         else null
       end as unsubscribed_time
--     , coalesce(h.cnt,0) as unsubscribed_cnt

     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
     , case
         when i.messageid is not null then i.eventtimestamp
         else null
       end as stored_time
--     , coalesce(i.cnt,0) as stored_cnt
into jt.seamless_events_summary
from jt.seamless_events_spine a
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_2 where eventstatus = 'delivered' group by 1) c
on a.messageid = c.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_2 where eventstatus = 'failed' group by 1) d
on a.messageid = d.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_3 where eventstatus = 'opened' group by 1) e
on a.messageid = e.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_3 where eventstatus = 'complained' group by 1) f
on a.messageid = f.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_4 where eventstatus = 'clicked' group by 1) g
on a.messageid = g.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_4 where eventstatus = 'unsubscribed' group by 1) h
on a.messageid = h.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.seamless_events_lvl_4 where eventstatus = 'stored' group by 1) i
on a.messageid = i.messageid
left join (select a.messageid
                , a.eventtimestamp
                , b.clientos
                , b.devicetype
                , b.clienttype
                , b.useragent
           from (select messageid, min(eventtimestamp) as eventtimestamp from jt.seamless_events_lvl_4 where eventstatus = 'clicked' and clickurl like 'https://bnc.lt%' group by 1) a
           join (select distinct messageid, clientos, devicetype, clienttype, useragent, eventtimestamp from jt.seamless_events_lvl_4 where eventstatus = 'clicked' and clickurl like 'https://bnc.lt%') b
           on a.messageid = b.messageid and a.eventtimestamp = b.eventtimestamp) j
on a.messageid = j.messageid;


/* Table: seamless_strange_paths
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
into jt.seamless_strange_paths
from jt.seamless_events_summary
where ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
or ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false);


/* Table: seamless_fact_analysis
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
     , a.clicked_bnc_flag
     , a.clicked_bnc_time
     , a.clicked_bnc_clientos
     , a.clicked_bnc_devicetype
     , a.clicked_bnc_clienttype
     , a.clicked_bnc_useragent
     , a.unsubscribed_flag
     , a.unsubscribed_time
     , a.stored_flag
     , a.stored_time
into jt.seamless_fact_analysis
from jt.seamless_events_summary a
left join jt.seamless_strange_paths b
on a.messageid = b.messageid and a.applicationid = b.applicationid
where b.applicationid is null 
or (b.applicationid is not null and b.case_type <> -1);


/* Table: seamless_login_funnel
   Description: This contains the funnel at the event level
*/

drop table if exists jt.seamless_login_funnel;

select d.applicationid
     , e.name as eventname
     , e.startdate
     , e.enddate
     , d.delivered_count
     , coalesce(o.opened_count,0) as opened_count
     , cast(cast(coalesce(o.opened_count,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as opened_pct
     , coalesce(c.clicked_count,0) as clicked_count
     , cast(cast(coalesce(c.clicked_count,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_pct
     , coalesce(b.click_bnc_link,0) as click_bnc_link
     , cast(cast(coalesce(b.click_bnc_link,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_bnc_pct
     , coalesce(m.click_bnc_mobile,0) as click_bnc_mobile
     , cast(cast(coalesce(m.click_bnc_mobile,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_bnc_mobile_pct
     , coalesce(i.click_bnc_mobile_ios,0) as click_bnc_mobile_ios
     , cast(cast(coalesce(i.click_bnc_mobile_ios,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_bnc_mobile_ios_pct
     , coalesce(a.click_bnc_mobile_android,0) as click_bnc_mobile_android
     , cast(cast(coalesce(a.click_bnc_mobile_android,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_bnc_mobile_android_pct         
into jt.seamless_login_funnel
from (select applicationid
           , count(*) as delivered_count
      from (select distinct applicationid
                , recipientemail
           from jt.seamless_fact_analysis
           where delivered_flag = true) x
      group by 1) d
left join (select applicationid
                , count(*) as opened_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where opened_flag = true) x
            group by 1) o
on d.applicationid = o.applicationid
left join (select applicationid
                , count(*) as clicked_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where clicked_flag = true) x
            group by 1) c
on d.applicationid = c.applicationid
left join (select applicationid
                , count(*) as click_bnc_link
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where clicked_bnc_flag = true) x
            group by 1) b
on d.applicationid = b.applicationid
left join (select applicationid
                , count(*) as click_bnc_mobile
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where clicked_bnc_flag = true
                 and (clicked_bnc_devicetype = 'mobile'
                 or clicked_bnc_devicetype = 'tablet')) x
            group by 1) m            
on d.applicationid = m.applicationid
        
left join (select applicationid
                , count(*) as click_bnc_mobile_ios
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where clicked_bnc_flag = true
                 and (clicked_bnc_devicetype = 'mobile'
                 or clicked_bnc_devicetype = 'tablet')
                 and clicked_bnc_clientos = 'iOS') x
            group by 1) i            
on d.applicationid = i.applicationid
    
left join (select applicationid
                , count(*) as click_bnc_mobile_android
           from (select distinct applicationid
                      , recipientemail
                 from jt.seamless_fact_analysis
                 where clicked_bnc_flag = true
                 and (clicked_bnc_devicetype = 'mobile'
                 or clicked_bnc_devicetype = 'tablet')
                 and clicked_bnc_clientos = 'Android') x
            group by 1) a           
on d.applicationid = a.applicationid    
            
left join jt.tm_eventcubesummary e
on d.applicationid = e.applicationid
order by 3,4; 

select *
from jt.seamless_login_funnel;



/*
drop table if exists jt.seamless_login_funnel_device;

select b.applicationid
     , e.name
     , e.startdate
     , e.enddate
     , b.click_bnc_link as click_bnc_link
     , coalesce(m.click_mobile_bnc_link,0) as click_mobile_bnc_link
     , cast(cast(coalesce(m.click_mobile_bnc_link,0) as decimal(12,4))/cast(b.click_bnc_link as decimal(12,4)) as decimal(12,4)) as click_mobile_bnc_pct
     , coalesce(t.click_tablet_bnc_link,0) as click_tablet_bnc_link
     , cast(cast(coalesce(t.click_tablet_bnc_link,0) as decimal(12,4))/cast(b.click_bnc_link as decimal(12,4)) as decimal(12,4)) as click_tablet_bnc_pct     
     , coalesce(d.click_desktop_bnc_link,0) as click_desktop_bnc_link
     , cast(cast(coalesce(d.click_desktop_bnc_link,0) as decimal(12,4))/cast(b.click_bnc_link as decimal(12,4)) as decimal(12,4)) as click_desktop_bnc_pct
     , coalesce(o.click_other_bnc_link,0) as click_other_bnc_link
     , cast(cast(coalesce(o.click_other_bnc_link,0) as decimal(12,4))/cast(b.click_bnc_link as decimal(12,4)) as decimal(12,4)) as click_other_bnc_pct
into jt.seamless_login_funnel_device
from (select applicationid
           , count(*) as click_bnc_link
      from (select distinct a.applicationid
                 , a.recipientemail
            from (select applicationid
                       , recipientemail
                       , messageid
                  from jt.seamless_fact_analysis
                  where clicked_flag = true) a
            join (select *
                  from jt.seamless_events_lvl_4
                  where eventstatus = 'clicked'
                  and clickurl like 'https://bnc.lt%') b
            on a.messageid = b.messageid) x
       group by 1) b
       
left join (select applicationid
                , count(*) as click_mobile_bnc_link
           from (select distinct a.applicationid
                      , a.recipientemail
                 from (select applicationid
                       , recipientemail
                       , messageid
                  from jt.seamless_fact_analysis
                  where clicked_flag = true) a
            join (select *
                  from jt.seamless_events_lvl_4
                  where eventstatus = 'clicked'
                  and clickurl like 'https://bnc.lt%'
                  and devicetype = 'mobile') b
            on a.messageid = b.messageid) x
       group by 1) m
on m.applicationid = b.applicationid

left join (select applicationid
                , count(*) as click_tablet_bnc_link
           from (select distinct a.applicationid
                      , a.recipientemail
                 from (select applicationid
                       , recipientemail
                       , messageid
                  from jt.seamless_fact_analysis
                  where clicked_flag = true) a
            join (select *
                  from jt.seamless_events_lvl_4
                  where eventstatus = 'clicked'
                  and clickurl like 'https://bnc.lt%'
                  and devicetype = 'tablet') b
            on a.messageid = b.messageid) x
       group by 1) t
on t.applicationid = b.applicationid

left join (select applicationid
                , count(*) as click_desktop_bnc_link
           from (select distinct a.applicationid
                      , a.recipientemail
                 from (select applicationid
                       , recipientemail
                       , messageid
                  from jt.seamless_fact_analysis
                  where clicked_flag = true) a
            join (select *
                  from jt.seamless_events_lvl_4
                  where eventstatus = 'clicked'
                  and clickurl like 'https://bnc.lt%'
                  and devicetype = 'desktop') b
            on a.messageid = b.messageid) x
       group by 1) d
on d.applicationid = b.applicationid

left join (select applicationid
                , count(*) as click_other_bnc_link
           from (select distinct a.applicationid
                      , a.recipientemail
                 from (select applicationid
                       , recipientemail
                       , messageid
                  from jt.seamless_fact_analysis
                  where clicked_flag = true) a
            join (select *
                  from jt.seamless_events_lvl_4
                  where eventstatus = 'clicked'
                  and clickurl like 'https://bnc.lt%'
                  and devicetype <> 'desktop'
                  and devicetype <> 'mobile'
                  and devicetype <> 'tablet') b
            on a.messageid = b.messageid) x
       group by 1) o
on o.applicationid = b.applicationid

left join jt.tm_eventcubesummary e
on b.applicationid = e.applicationid
order by 3,4;


drop table if exists jt.seamless_login_funnel_device_count;

select m.applicationid
     , e.name
     , e.startdate
     , e.enddate
     , count(*) as message_cnt
     , count(case when message_device_cnt = 1 then 1 else null end) as one_device
     , cast(cast(count(case when message_device_cnt = 1 then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_one_device
     , count(case when message_device_cnt > 1 then 1 else null end) as more_than_one_device
     , cast(cast(count(case when message_device_cnt > 1 then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_more_than_one_device     
into jt.seamless_login_funnel_device_count
from (select c.applicationid
           , d.recipientemail
           , count(*) as message_device_cnt
      from (select applicationid
                 , messageid
                 , devicetype
                 , clientos
            from jt.seamless_events_lvl_4
            where eventstatus = 'clicked'
            and clickurl like 'https://bnc.lt%'
            group by 1,2,3,4
            ) c
      join (select applicationid
                 , messageid
                 , recipientemail
            from jt.seamless_delivered_once) d
      on c.messageid = d.messageid
      group by 1,2
      ) m
left join jt.tm_eventcubesummary e
on m.applicationid = e.applicationid
group by 1,2,3,4
order by 3,4;
*/


-- Email Funnel



-- Device/OS Funnel

--select *
--from jt.seamless_login_funnel_device;       

   
-- Prove that most people went through the funnel with only one device.       
-- Device defined as unique devicetype/OS (mailgun data limitation)
-- Scenario missed: if user clicks on welcome email with 2 different iOS phones this will be counted as one.

--select *
--from jt.seamless_login_funnel_device_count;






















-- Compare with non branch i/o logins


-- Compare with non-seamless login event adoption


-- How are the sessions different for seamless login?



