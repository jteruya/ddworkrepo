-- Checking to see that this event is in:
-- US Server: Yes
select *
from authdb_applications
where lower(applicationid) = '9e59da43-5a40-48f5-90b5-c32880763609';

-- Get attachment view counts
select b.itemid
     , b.name as agendaname
     , b.localstarttime
     , b.localendtime
     , d.fileid
     , d.name as filename
     , count(*) as totalviews
     , count(distinct a.global_user_id) as totalusers
from fact_actions_live a
join ratings_item b
on cast(a.metadata->>'ItemId' as int) = b.itemid
join ratings_topic c
on b.parenttopicid = c.topicid
join ratings_itemfiles d
on cast(a.metadata->>'FileId' as int) = d.fileid
where a.application_id = '9e59da43-5a40-48f5-90b5-c32880763609'
and lower(b.applicationid) = '9e59da43-5a40-48f5-90b5-c32880763609'
and lower(c.applicationid) = '9e59da43-5a40-48f5-90b5-c32880763609'
and c.listtypeid = 2
--and c.ishidden = false
and a.identifier = 'attachmentButton'
and a.metadata->>'ItemId' <> ''
group by 1,2,3,4,5,6
order by 5,6,1;


