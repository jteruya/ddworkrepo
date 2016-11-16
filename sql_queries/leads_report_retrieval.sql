truncate table jt.ratings_leads;
truncate table jt.ratings_globaluserdetails;

select
 e.applicationid,
 e.eventname,
 e.itemid,
 e.itemname,
 e.lr_access,
 l.leadid,
 l.itemid,
 l.scanneruserid,
 l.userid,
 l.emailaddress,
 l.identifier,
 regexp_replace(l.scanneddata, E'[\\n\\r]+', ' ', 'g' ) as scanneddate,
 regexp_replace(l.notes, E'[\\n\\r]+', ' ', 'g' ) as notes,
 --l.scanneddata,
 --l.notes,
 l.created,
 l.updated,
 l.source,
 ud.emailaddress as scanneremailaddress, ud.username as scannerusername,
 ud.firstname as scannerfirstname, ud.lastname as scannerlastname, ud.title as scannertitle,
 ud.company as scannercompany, ud.created as scannercreated
                                   from
                                   ( select 
                                   e.applicationid,
                                   a.name eventname,
                                   e.exhibitoritemid itemid,
                                   i.name itemname,
                                   case when e.isdisabled is false then 'Y' else 'N' end lr_access
                                   from ratings_exhibitorfeatureaccess e
                                   join authdb_applications a on upper(e.applicationid) = a.applicationid
                                   join ratings_item i on e.exhibitoritemid = i.itemid
                                   where 
                                   lower(a.applicationid) = 'd5cf3faf-8657-4cd8-8725-d37fd3f3d9df'
                                   and e.featurename = 'LeadScanning'
                                   ) e
                                  join
                                   ( select *
                                   from jt.ratings_leads l
                                   ) l
                                   on e.itemid = l.itemid
                                   
                                   join 
                                   
                                   authdb_is_users auth
                                   on  l.scanneruserid=auth.userid
                                   join
                                   jt.ratings_globaluserdetails ud
                                   
                                   on lower(auth.globaluserid)=lower(ud.globaluserid);