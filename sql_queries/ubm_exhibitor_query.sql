


-- Search Exhibitors (Verified)
select *
from fact_actions a
join ratings_topic b
on a.application_id = lower(b.applicationid)
and cast(a.metadata->>'listid' as int) = topicid
where a.identifier = 'submitlistsearch' 
and b.listtypeid = 3
limit 100;

-- Search Exhibitors - No Results (Verified)
select *
from fact_actions a
join ratings_topic b
on a.application_id = lower(b.applicationid)
and cast(a.metadata->>'listid' as int) = topicid
where a.identifier = 'submitlistsearch'
and cast(a.metadata->>'numrows' as int) = 0 
and b.listtypeid = 3
limit 100;


-- Clicking on Map (Verified)
select *
from fact_actions
where identifier = 'exhibitorprofilebutton' 
and metadata->>'type'='map'
limit 100;

