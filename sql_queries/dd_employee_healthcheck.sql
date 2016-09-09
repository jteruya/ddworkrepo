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
from authdb_is_users users
left join ratings_usergroupsmapping mappings
on users.userid = mappings.userid
left join (select *
           from ratings_usergroups
           where applicationid = 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB'
           and isdisabled = false) groups
on mappings.usergroupid = groups.usergroupid 
where users.applicationid = 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB'
-- attendee
and users.userid <> 43066564
and users.userid <> 43066542
and users.userid <> 43065409
and users.userid <> 43065117
and users.userid <> 43064536
and users.userid <> 43064495
and users.userid <> 43063835
and users.userid <> 43063731
and users.userid <> 43063685
and users.userid <> 43063650
and users.userid <> 43063646
and users.userid <> 43063645
and users.userid <> 43062749
and users.userid <> 43062731
and users.userid <> 43062728
and users.userid <> 43062724
and users.userid <> 43062721
and users.userid <> 43062703
and users.userid <> 43062697
and users.userid <> 43062663
and users.userid <> 43062657
and users.userid <> 43062656
and users.userid <> 43062654
and users.userid <> 43062653
and users.userid <> 43062652
and users.userid <> 43062650
and users.userid <> 43062644
and users.userid <> 43062641
and users.userid <> 43062639
and users.userid <> 43062637
and users.userid <> 43062628
and users.userid <> 43062198
and users.userid <> 43062195
and users.userid <> 43062194
and users.userid <> 43062193
and users.userid <> 43062191
and users.userid <> 43062190
and users.userid <> 43062186
and users.userid <> 43062184
and users.userid <> 43062179
and users.userid <> 43062177
and users.userid <> 43062176
and users.userid <> 43062175
and users.userid <> 43062174
and users.userid <> 43062173
and users.userid <> 43062171
and users.userid <> 43062170
and users.userid <> 43062169
and users.userid <> 43062168
and users.userid <> 43062167
and users.userid <> 43062166
and users.userid <> 43062165
and users.userid <> 43062164
and users.userid <> 43062163
and users.userid <> 43062162
and users.userid <> 43062161
and users.userid <> 43062160
and users.userid <> 43062158
and users.userid <> 43062156
and users.userid <> 43062134
-- chloe test
and users.userid <> 45975651
-- lance rube crown
and users.userid <> 45128021
;

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
order by 1
;





select *
from kevin.ratings_globaluserdetails
where globaluserid in (
select distinct globaluserid
from pride_users
where created >= '2014-01-01'
and isdisabled = 1
and extract(year from updated)::int * 100 + extract(month from updated) = 201608
)
and applicationid = 'BFFEE970-C8B3-4A2D-89EF-A9C012000ABB'
;





