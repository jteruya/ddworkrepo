select
  'us ratings' "server",
  a.applicationid,
  a.name eventname,
  a.startdate::date startdate,
  a.enddate::date enddate,
  coalesce(u.users_loaded_in_cms,0) users_loaded_in_cms
from authdb_applications a
left join
( select
    applicationid,
    count(*) users_loaded_in_cms
  from authdb_is_users
  where isdisabled = 0
  group by 1
) u
on a.applicationid = u.applicationid
where startdate <= '2016-04-20'
and enddate >= '2016-04-21' --between '2016-04-20 22:07:00'::date and '2016-04-21 09:47:00'::date
order by users_loaded_in_cms desc
;