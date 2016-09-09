drop table jt.ratings_globaluserdetails;
CREATE TABLE
    jt.ratings_globaluserdetails
    (
        globaluserid CHARACTER VARYING,
        emailaddress CHARACTER VARYING,
        username CHARACTER VARYING,
        firstname CHARACTER VARYING,
        lastname CHARACTER VARYING,
        title CHARACTER VARYING,
        company CHARACTER VARYING,
        phone CHARACTER VARYING,
        address1 varchar,
        address2 varchar,
        city varchar,
        stateprovinceregion varchar,
        postalcode varchar,
        country varchar,
        variabledata1 varchar,
        variabledata2 varchar,
        variabledata3 varchar,
        created TIMESTAMP(6) WITHOUT TIME ZONE
    );


select
  l.itemid exhibitorid,
  i.name exhibitorname,
  l.leadid,
  l.identifier,
--   id.userid userid_identifier,
  l.userid,
  g.firstname,
  g.lastname,
  g.emailaddress,
  g.title,
  g.company,
  g.phone,
  g.address1,
  g.address2,
  g.city,
  g.stateprovinceregion,
  g.postalcode,
  g.country,
  l.notes,
  case
    when m.leadqualificationvalue is null
    or m.leadqualificationvalue = 0 then null
    when m.leadqualificationvalue = 1 then 'bad'
    when m.leadqualificationvalue = 2 then 'neutral'
    when m.leadqualificationvalue = 3 then 'good'
    else 'other'
  end leadscore,
  l.scanneddata,
  case when l.source = 1 then 'scan' else 'other' end leadsource,
  l.scanneruserid scanner_userid,
  sg.firstname scanner_firstname,
  sg.lastname scanner_lastname,
  sg.emailaddress scanner_emailaddress,
  l.created "timestamp",
  g.variabledata1,
  g.variabledata2,
  g.variabledata3

from ratings_leads l
join ratings_item i on l.itemid = i.itemid

left join ratings_userdetails u on l.userid = u.userid

-- left join dbo.useridentifier id on l.identifier = id.useridentifierid
-- left join dbo.userdetails u on id.userid = u.userid
left join jt.ratings_globaluserdetails g on u.globaluserid = g.globaluserid

left join ratings_userdetails su on l.scanneruserid = su.userid
left join jt.ratings_globaluserdetails sg on su.globaluserid = sg.globaluserid

left join ratings_leadqualificationmappings m on l.leadid = m.leadid
where lower(i.applicationid) = '0dd15060-2a62-4e8c-8d02-4d16006626d2'
order by l.userid desc
;
           



