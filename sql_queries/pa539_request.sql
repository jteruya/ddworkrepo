-- Check to see if app is on the US server
select *
from authdb_applications
where lower(applicationid) = 'fc1a9ee1-ea81-4986-89b7-f5e624bc23d3';
-- Yes

-- Truncate Custom Table w/ Unhashed Records
truncate table jt.ratings_globaluserdetails;
-- Pull Unhashed Records from Prod

-- Run Custom Report
select distinct on(a.global_user_id, a.metadata->>'ItemId') a.global_user_id as "GlobalUserID", a.metadata->>'ItemId' as "Item ID", b.emailaddress as "Email Address", b.firstname as "First Name", b.lastname as "Last Name"
from public.fact_views_live as a
inner join jt.ratings_globaluserdetails as b on a.global_user_id=lower(b.globaluserid) 
where application_id='fc1a9ee1-ea81-4986-89b7-f5e624bc23d3' 
and identifier='item'
and metadata->>'ItemId' in ('10646188','10648554','10671192','10749599','10749670','10749796','10749797','10749798','10749799','10749800','10968075')
order by 2
;

