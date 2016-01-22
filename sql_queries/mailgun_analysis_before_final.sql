drop table jt.mailgun_events_lvl_1;
drop table jt.mailgun_events_lvl_2;
drop table jt.mailgun_events_lvl_3;
drop table jt.mailgun_events_lvl_4;
drop table jt.mailgun_events_spine;
drop table jt.mailgun_events_summary;
drop table jt.mailgun_strange_paths;


-- Level 1 Steps (Accepted or Rejected)
-- Mailgun Email Approval Actions
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_1
from mailgun.events
where (eventstatus = 'accepted' or eventstatus = 'rejected')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 2 Steps (Delivered and/or Failed)
-- Delivery Status Actions
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_2
from mailgun.events
where (eventstatus = 'delivered' or eventstatus = 'failed')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 3 Steps (Opened and/or Complained)
-- Actions within the email client 
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_3
from mailgun.events
where (eventstatus = 'opened' or eventstatus = 'complained')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Level 4 Steps (Clicked and/or Unsubscribed and/or Stored)
-- Actions within the email
select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.mailgun_events_lvl_4
from mailgun.events
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored')
and applicationid = '61998951-8b62-414b-8e80-c1f56a7834b9';

-- Create the spine of unique messages
select a.*
into jt.mailgun_events_spine
from (select messageid
      from jt.mailgun_events_lvl_1
      union 
      select messageid
      from jt.mailgun_events_lvl_2
      union
      select messageid
      from jt.mailgun_events_lvl_3
      union
      select messageid
      from jt.mailgun_events_lvl_4) a;

-- Get the boolean flags and counts for each of the messages
select a.*
     , case 
         when b.eventstatus = 'accepted' then true
         else false
       end as accepted_flag
       
     , case 
         when b.eventstatus = 'rejected' then true
         else false
       end as rejected_flag  
            
     , case
         when c.messageid is not null then true
         else false
       end as delivered_flag
     , coalesce(c.cnt,0) as delivered_cnt
     
     , case
         when d.messageid is not null then true
         else false
       end as failed_flag
     , coalesce(d.cnt,0) as failed_cnt
     
     , case
         when e.messageid is not null then true
         else false
       end as opened_flag
     , coalesce(e.cnt,0) as opened_cnt
     
     , case
         when f.messageid is not null then true
         else false
       end as complained_flag
     , coalesce(f.cnt,0) as complained_cnt
     
     , case
         when g.messageid is not null then true
         else false
       end as clicked_flag
     , coalesce(g.cnt,0) as clicked_cnt
     
     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
     , coalesce(h.cnt,0) as unsubscribed_cnt
     
     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
     , coalesce(i.cnt,0) as stored_cnt

into jt.mailgun_events_summary
from jt.mailgun_events_spine a
left join jt.mailgun_events_lvl_1 b
on a.messageid = b.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'delivered' group by messageid) c
on a.messageid = c.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_2 where eventstatus = 'failed' group by messageid) d
on a.messageid = d.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'opened' group by messageid) e
on a.messageid = e.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_3 where eventstatus = 'complained' group by messageid) f
on a.messageid = f.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'clicked' group by messageid) g
on a.messageid = g.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'unsubscribed' group by messageid) h
on a.messageid = h.messageid
left join (select messageid, count(*) as cnt from jt.mailgun_events_lvl_4 where eventstatus = 'stored' group by messageid) i
on a.messageid = i.messageid;


-- This gets the paths that might don't follow the hierarchy and are suspicious.
select messageid
     , accepted_flag
     , rejected_flag
     , delivered_flag
     , failed_flag
     , opened_flag
     , complained_flag
     , clicked_flag
     , unsubscribed_flag
     , stored_flag
into jt.mailgun_strange_paths
from jt.mailgun_events_summary
where (accepted_flag = false and rejected_flag = false)
or ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
or ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false);


-- Info
select distinct coalesce(a.messageid, b.messageid, c.messageid, d.messageid) as messageid
     , coalesce(a.applicationid, b.applicationid, c.applicationid, d.applicationid) as applicationid
     , coalesce(a.recipientemail, b.recipientemail, c.recipientemail, d.recipientemail) as recipientemail
     , coalesce(a.senderemail, b.senderemail, c.senderemail, d.senderemail) as senderemail
     , coalesce(a.subject, b.subject, c.subject, d.subject) as subject
from jt.mailgun_events_lvl_1 a
full outer join jt.mailgun_events_lvl_2 b
on a.messageid = b.messageid
full outer join jt.mailgun_events_lvl_3 c
on a.messageid = c.messageid
full outer join jt.mailgun_events_lvl_4 d
on a.messageid = d.messageid;