-- seamless login welcome email funnel (delivered to clicking on the bnc link)
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
on d.applicationid = b.applicationid
left join jt.tm_eventcubesummary e
on d.applicationid = e.applicationid
order by 3,4;

select application_id
     , count(*)
from (select distinct application_id
           , device_id
      from jt.seamless_login_sessions) a
group by 1;

-- Device Division
select application_id
     , name
     , startdate
     , enddate
     , count(*) as total_users_logged_in_with_seamless_login
     , count(case when clicked_flag is null then 1 else null end) as total_users_logged_in_with_seamless_login_not_in_email_funnel
     , count(case when clicked_flag = true then 1 else null end) as total_users_logged_in_with_seamless_login_clicked_in_funnel
     , count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as total_users_logged_in_with_seamless_login_click_not_logged_by_mailgun
     , count(case when clicked_flag is null and emailaddress is null then 1 else null end) as total_users_logged_in_with_seamless_login_and_no_email_address
from (select distinct s.application_id
           , e.name
           , e.startdate
           , e.enddate
           , s.user_id
           , u.globaluserid
           , s.device_id
           , u.emailaddress
           , f.recipientemail
           , case
               when f.clicked_flag = true then true
               when g.clicked_flag = false then false
               else null
             end as clicked_flag
      from (select distinct user_id, device_id, application_id from jt.seamless_login_sessions where metrics_type_id = 1) s
      left join jt.seamless_login_users u
      on s.user_id = u.userid
      left join (select distinct recipientemail
                      , clicked_flag
                 from jt.seamless_fact_analysis 
                 where clicked_flag = true) f
      on u.emailaddress = f.recipientemail
      left join (select distinct recipientemail
                      , clicked_flag
                 from jt.seamless_fact_analysis 
                 where clicked_flag = false) g
      on u.emailaddress = g.recipientemail
      join jt.tm_eventcubesummary e
      on s.application_id = lower(cast(e.applicationid as varchar))
      ) a
group by 1,2,3,4
order by 3,4;