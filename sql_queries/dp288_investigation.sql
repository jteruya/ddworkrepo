select a.applicationid
     , a.bundleid
     , a.name
     , a.startdate
     , a.enddate
     , a.canregister
     , case
         when c.applicationid is not null then 1 
         else 0 
       end as globalpollflag
     , case
         when d.applicationid is not null then 1 
         else 0 
       end as globalsurveyflag
from authdb_applications a
left join eventcube.testevents b
on a.applicationid = b.applicationid
left join (select distinct applicationid from ratings_surveys where ispoll = 'true' and isdisabled = 'false') c
on a.applicationid = c.applicationid
left join (select distinct applicationid
           from ratings_surveys
           where ispoll = 'false' 
           and isdisabled = 'false'
           and itemid is null
           union 
           select distinct b.applicationid
           from ratings_surveymappings a
           join ratings_surveys b
           on a.surveyid = b.surveyid
           where a.isdisabled = 'false'
           and b.isdisabled = 'false'
           and b.ispoll = 'false'
           and b.itemid is null) d
on a.applicationid = d.applicationid           
where b.applicationid is null
and a.startdate >= '2015-01-01'
and a.enddate < '2016-01-01'
order by startdate, enddate, applicationid;


