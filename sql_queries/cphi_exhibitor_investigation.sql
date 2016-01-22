select *
from authdb_applications
where lower(applicationid) = '616449eb-8d8b-43c8-a886-57567b3efe83';

-- Old Metrics Analysis

-- Number of exhibitor searches (0)
select count(*)
from fact_actions a
join ratings_topic b
on a.application_id = lower(b.applicationid)
and cast(a.metadata->>'listid' as int) = topicid
where a.identifier = 'submitlistsearch' 
and b.listtypeid = 3
and (a.application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or a.application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');;
-- 0

-- Unique Action Identifiers (No submitlistsearches)
select distinct identifier
from fact_actions
where (application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');

select distinct identifier
from fact_views
where (application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');

-- Number of searches for exhibitors with no results found (since 0 searches no searches with 0 results)


-- Most searched for exhibitor on interactive map (0)


select count(*)
from fact_actions
where lower(identifier) = 'submitmapsearch'
and (application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');
-- 0

select count(*)
from fact_actions
where lower(identifier) = 'entermapsearchtextfield'
and (application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');
--  113

-- Number of clicks on ‘view on map’ (0 since there is no exhibitorprofilebutton clicks)
select count(*)
from fact_actions
where lower(identifier) = 'exhibitorprofilebutton'
and (application_id = '616449eb-8d8b-43c8-a886-57567b3efe83' or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83');
-- 0





---------- Alfred Analysis 20151109 -----------

select *
from fact_views
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and created >= '2015-11-09 10:20:00'
and app_type_id = 1
and identifier = 'profilefiller'
limit 1000;


select *
from fact_views
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
order by created;

select binary_version
     , count(*)
from fact_sessions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
or application_id = '616449EB-8D8B-43C8-A886-57567B3EFE83'
group by binary_version;


-- null, 41
-- 5.9.0, 98377
-- 5.9.2.0, 38777


select binary_version
     , count(*)
from fact_views
where identifier = 'exhibitorprofile'
group by 1;

-- 5.18.0 
-- 5.24.1.0


select *
from authdb_applications
where lower(applicationid) = '616449eb-8d8b-43c8-a886-57567b3efe83';

select *
from authdb_applications
where bundleid = '4FD55FF5-9D3A-4650-9544-45BB8215B05C'
order by startdate, enddate;







select *
from fact_views
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
order by created;


select *
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
order by created;







select distinct binary_version
from fact_actions
where identifier = 'submitlistsearch';

-- submitlistsearch (not available for v5.9.x)

select distinct binary_version
from fact_actions
where identifier = 'entermapsearchtextfield';

-- this is available for 5.9

select distinct binary_version
from fact_actions
where identifier = 'submitmapsearch';

-- submitmapsearch (not available for v5.9.x)




-- Number of exhibitor searches 
select app_type_id
     , count(*)
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'enterlistsearchtextfield'
and metadata->>'listid' = '10276204'
group by 1;
--9,613

-- 1, 6,489
-- 2, 679
-- 3, 2,445

select count(*)
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'enterlistsearchtextfield'
and metadata->>'listid' = '10276205';
-- 0


select *
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and identifier = 'enterlistsearchtextfield'
and metadata->>'listid' = '10276204';


-- Number of searches for exhibitors with no results found 
-- Not possible because the current app is v5.9.x but the submitlistsearch metric isn't available until 5.10.x

-- Most searched for exhibitor on interactive map 
-- Not possible because the current app is v5.9.x but the submitmapsearch metric isn't available until 5.10.x

-- Number of clicks on ‘view on map’ (from exhibitor detail view)

-- 1481

select app_type_id
     , count(*)
from (
select *
     , lag(created) over (order by created) as lagcreated
     , lag(identifier) over (order by created) as lagidentifier
     , lag(metadata) over (order by created) as lagmetadata
from fact_views
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
--and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
) a
where identifier = 'map'
and created - lagcreated < interval '10' minute
and ((app_type_id = 3 and lagidentifier = 'item' and lagmetadata->>'type' = 'exhibitor') 
or (app_type_id in (1,2) and lagidentifier = 'item' and lagmetadata->>'type' = 'exhibitor'))
group by 1;


------------ Robin Analysis 20151109 -------------

select binaryversion
     , count(*)
from newmetrics.newmetrics_sessions 
group by binaryversion;

-- min 5.21.0.0
-- max 6.0.0.0

select *
from authdb_applications
where lower(name) like '%pride%'
and lower(name) not like '%pride:%';

-- find pride
-- 68FF6470-F9EB-43A1-B24A-A315BD80E1A2
-- 15740A5A-25D8-4DC6-A9ED-7F610FF94085


select binaryversion
     , count(*)
from newmetrics.newmetrics_sessions 
where applicationid <> 'bffee970-c8b3-4a2d-89ef-a9c012000abb'
and applicationid <> 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB'
group by binaryversion;


select count(*) 
from newmetrics.newmetrics_sessions
where applicationid = '616449eb-8d8b-43c8-a886-57567b3efe83'
or applicationid = '616449EB-8D8B-43C8-A886-57567B3EFE83';

-- 0 session in new metrics





select *
from ratings_topic
where applicationid = '616449eb-8d8b-43c8-a886-57567b3efe83' or applicationid = '616449EB-8D8B-43C8-A886-57567B3EFE83'
and listtypeid = 3;



select *
from fact_views_new
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
order by created;


select *
from fact_actions
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
order by created;



select *
from (
select *
     , lag(created) over (order by created) as lagcreated
     , lag(identifier) over (order by created) as lagidentifier
     , lag(metadata) over (order by created) as lagmetadata
from fact_views_new
where application_id = '616449eb-8d8b-43c8-a886-57567b3efe83'
--and global_user_id = '78858f61-19f4-45a1-8b83-f78837064f2e'
) a
where identifier = 'map'
--and created - lagcreated < interval '1' minute
and ((app_type_id = 3 and lagidentifier = 'item' and lagmetadata->>'type' = 'exhibitor') 
or (app_type_id in (1,2) and lagidentifier = 'item' and lagmetadata->>'type' = 'exhibitor'));