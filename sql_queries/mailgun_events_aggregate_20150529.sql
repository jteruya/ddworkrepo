drop table if exists jt.mailgun_events_aggregate;

select mailgundate
     , eventstatus
     , emailsubjectcatg
     , eventtype
     , count(*)
into jt.mailgun_events_aggregate
from (select cast(to_timestamp(a.eventtimestamp/1000) as date) as mailgundate
           , a.applicationid
           , a.eventstatus
           , case
               when b.eventtype = 'Conference (>2:1 session:exhibitor ratio)' then 'Conference'
               when b.eventtype = 'Expo (<2:1 session:exhibitor ratio)' then 'Expo'
               when b.eventtype = '' then 'No Event Type'
               when b.eventtype = '_Unknown' then 'Unknown'
               else b.eventtype 
             end as eventtype
           , a.emailsubjectcatg
      from (select *
                 , 'accepted' as eventstatus 
            from jt.accepted 
            union 
            select * 
                 , 'delivered' as eventstatus
            from jt.delivered) a
      join kevin.tm_eventcubesummary b
      on a.applicationid = b.applicationid
      where eventstatus = 'delivered' or eventstatus = 'accepted') a
group by mailgundate, eventstatus, emailsubjectcatg, eventtype
order by mailgundate;

drop table if exists jt.mailgun_events_aggregate_delivered;


select mailgundate
     , eventstatus
     , emailsubjectcatg
     , eventtype
     , count(*)
into jt.mailgun_events_aggregate_delivered
from (select cast(to_timestamp(a.eventtimestamp/1000) as date) as mailgundate
           , a.applicationid
           , a.eventstatus
           , case 
               when b.eventtype = 'Conference (>2:1 session:exhibitor ratio)' then 'Conference'
               when b.eventtype = 'Expo (<2:1 session:exhibitor ratio)' then 'Expo'
               when b.eventtype = '' then 'No Event Type'
               when b.eventtype = '_Unknown' then 'Unknown'
               else b.eventtype 
             end as eventtype
           , a.emailsubjectcatg
      from (select applicationid
                 , emailsubjectcatg
                 , delivered_time as eventtimestamp
                 , 'delivered' as eventstatus 
            from jt.mailgun_fact_analysis
            where delivered_flag = true
            union 
            select applicationid
                 , emailsubjectcatg
                 , opened_time as eventtimestamp
                 , 'opened' as eventstatus
            from jt.mailgun_fact_analysis
            where opened_flag = true
            union 
            select applicationid
                 , emailsubjectcatg
                 , clicked_time as eventtimestamp
                 , 'clicked' as eventstatus
            from jt.mailgun_fact_analysis
            where clicked_flag = true
            union 
            select applicationid
                 , emailsubjectcatg
                 , unsubscribed_time as eventtimestamp
                 , 'unsubscribed' as eventstatus
            from jt.mailgun_fact_analysis
            where unsubscribed_flag = true
            union 
            select applicationid
                 , emailsubjectcatg
                 , complained_time as eventtimestamp
                 , 'complained' as eventstatus
            from jt.mailgun_fact_analysis
            where complained_flag = true
            union 
            select applicationid
                 , emailsubjectcatg
                 , stored_time as eventtimestamp
                 , 'stored' as eventstatus
            from jt.mailgun_fact_analysis
            where stored_flag = true) a  
      join kevin.tm_eventcubesummary b
      on a.applicationid = b.applicationid) a
group by mailgundate, eventstatus, emailsubjectcatg, eventtype
order by mailgundate;







