select distinct a.*
     , b.userid
     , b.isdisabled
from jt.ratings_globaluserdetails a
join authdb_is_users b
on a.globaluserid = b.globaluserid
where b.applicationid = '6BB9F2B6-7E20-4AAF-8C1D-8AC5F799C5EA'
and userid = 46115460
or userid = 46115423;

-- 636
-- 1121 distinct userids

select distinct id
from channels.rooms
where upper(applicationid) = '6BB9F2B6-7E20-4AAF-8C1D-8AC5F799C5EA'
and type = 'GROUP';

select a.channelid || '-' || a.userid as senderid
     , b.userid as recipientid
from (select *
      from channels.members
      where channelid in (select distinct id
                          from channels.rooms
                          where upper(applicationid) = '6BB9F2B6-7E20-4AAF-8C1D-8AC5F799C5EA'
                          and type = 'GROUP')
     ) a
join (select *
      from channels.members
      where channelid in (select distinct id
                          from channels.rooms
                          where upper(applicationid) = '6BB9F2B6-7E20-4AAF-8C1D-8AC5F799C5EA'
                          and type = 'GROUP')
     ) b
on a.channelid = b.channelid and a.userid <> b.userid;



;



select *
from channels.members
where channelid = 4323;