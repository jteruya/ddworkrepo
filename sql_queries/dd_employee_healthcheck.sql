-- Get Pride Application ID
select *
from authdb_applications
where lower(name) like '%pride%'
and lower(name) not like '%pride:%';

-- ApplicationID: BFFEE970-C8B3-4A2D-89EF-A9C012000ABB

---- Get DD users and group information
drop table if exists pride_users;
create temporary table pride_users as
select users.userid
     , users.globaluserid
     , users.applicationid
     , users.created
     , users.updated
     , users.isdisabled
     , groups.usergroupid
     , groups.name as groupname
from authdb_is_users users
left join ratings_usergroupsmapping mappings
on users.userid = mappings.userid
left join (select *
           from ratings_usergroups
           where applicationid = 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB'
           and isdisabled = false) groups
on mappings.usergroupid = groups.usergroupid 
where users.applicationid = 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB';

-- Get the Employee Numbers (added or left) via pride_users
select case
          when isdisabled = 1 then extract(year from updated)::int * 100 + extract(month from updated)::int 
          else extract(year from created)::int * 100 + extract(month from created)::int
       end as "Year Month"
     , count(case when isdisabled = 0 then 1 else null end) as "Number of Employees Added"
     , count(case when isdisabled = 1 then 1 else null end) as "Number of Employees that Left"
from (select distinct userid
           , created
           , updated
           , isdisabled
      from pride_users) users
where created >= '2014-01-01'
group by 1
order by 1;

-- Work on slicing the above by department
select groupname
     , case
          when isdisabled = 1 then extract(year from updated)::int * 100 + extract(month from updated)::int 
          else extract(year from created)::int * 100 + extract(month from created)::int
       end as year_month
     , count(case when isdisabled = 0 then 1 else null end) as addedcnt
     , count(case when isdisabled = 1 then 1 else null end) as leftcnt
from (select distinct userid
           , created
           , updated
           , isdisabled
           , groupname
      from pride_users
      where groupname is not null) users
where created >= '2014-01-01'
group by 1,2
order by 1;
      
