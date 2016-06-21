select item.name as "Session Name"
     , item.itemid as "Session ID"
     , item.localstarttime as "Event Start Time"
from ratings_item item
join ratings_topic topic
on item.parenttopicid = topic.topicid
where item.applicationid = '169B1A0E-F9D4-4526-919C-9BF0DA41D55E'
and topic.applicationid = '169B1A0E-F9D4-4526-919C-9BF0DA41D55E'
and topic.listtypeid = 2
and topic.ishidden = 'false'
and item.isdisabled = 0
order by 3;
