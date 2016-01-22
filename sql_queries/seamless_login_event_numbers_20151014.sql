-- Robin
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , b.eventtype
     , b.canregister
     , a.name
     , a.settingvalue
from public.ratings_applicationconfigsettings a
join authdb_applications b
on a.applicationid = b.applicationid
left join eventcube.testevents c
on b.applicationid = c.applicationid
where c.applicationid is null
and b.startdate >= '2015-07-01' 
and b.startdate <= '2015-09-30'
and lower(a.name) like '%seamless%'
and lower(a.settingvalue) = 'true'
order by b.startdate, b.enddate, b.applicationid;


-- Robin (all time - no test)
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , b.eventtype
     , b.canregister
     , a.name
     , a.settingvalue
from public.ratings_applicationconfigsettings a
join authdb_applications b
on a.applicationid = b.applicationid
left join eventcube.testevents c
on b.applicationid = c.applicationid
where c.applicationid is null
and lower(a.name) like '%seamless%'
and lower(a.settingvalue) = 'true'
order by b.startdate, b.enddate, b.applicationid;


-- Robin (all time - with test)
select b.applicationid
     , b.name
     , b.startdate
     , b.enddate
     , b.eventtype
     , b.canregister
     , a.name
     , a.settingvalue
from public.ratings_applicationconfigsettings a
join authdb_applications b
on a.applicationid = b.applicationid
where lower(a.name) like '%seamless%'
and lower(a.settingvalue) = 'true'
order by b.startdate, b.enddate, b.applicationid;


-- Alfred
select *
from jt.adoption_report_testevents
where applicationid = '883D2398-9505-4801-99B1-5CE132C294B8';


select *
from jt.authdb_applications_type_2
where applicationid = '883D2398-9505-4801-99B1-5CE132C294B8';






select u.applicationid
     , a.name as event_name
     , a.startdate
     , a.enddate
     , sum(case when s.applicationid is not null and s.userid is not null then 1 else 0 end) as app_session_users
     , count(*) as total_registered_users
     , 1.0*sum(case when s.applicationid is not null and s.userid is not null then 1 else 0 end)/count(*) as adoption
from (select * from public.authdb_is_users where isdisabled = 0) u
join (select * from public.authdb_applications where (applicationid = 'D32B1CA4-89AB-4F75-AE45-15CF7779EEA9' or
applicationid = 'B6AF7AF5-40B0-4703-B23B-1CECBEAD4959' or
applicationid = 'AA96A6C1-254A-4E15-A484-A905CFE51094' or
applicationid = 'C2A82ECE-E62E-49E3-ADBC-A7913E498C8C' or
applicationid = '94C8AE08-E6F8-4A60-AC74-5CFD22D0DFAE' or
applicationid = '5FD4FE4E-9250-4737-B290-8A39F901B09E' or
applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0' or
applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88' or
applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900' or
applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8' or
applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA' or
applicationid = '3E92F6B3-59A3-4078-9BE0-42DD25C8CCC2' or
applicationid = '85874647-B187-49EF-8A45-E3B5720E1755' or
applicationid = 'C5468C7A-2AB0-4C9C-B3AE-70AB9ADA5FB2' or
applicationid = '647855A5-D887-48EF-840A-ED94B9167256' or
applicationid = '6EA54427-5C85-4F74-9990-4E75FDA045D9' or
applicationid = 'F55A2027-98F5-46B8-8C57-CE33D3BC31C1' or
applicationid = '73EADDEC-0D97-4FB3-AA64-D828B90AA23E' or
applicationid = '2B3250F0-43C3-4A19-A595-2255218099CA' or
applicationid = '95FF9F31-7D87-4008-B2A4-E999E594F926' or
applicationid = '4D61E684-2E9E-492B-B0FF-1E902A3F97C7' or
applicationid = 'DAAFA085-BF3E-4493-A05A-70845A2818AC' or
applicationid = '8630EE10-D9BC-44BC-8886-CF82FB37751B' or
applicationid = 'F1DC4B72-B77E-42E8-8509-05FF3999ED30' or
applicationid = 'B368098D-9551-4943-823D-28E8BA4C2DAC' or
applicationid = '883D2398-9505-4801-99B1-5CE132C294B8' or
applicationid = '425995D6-0CC0-49DD-B400-6C75417C7917' or
applicationid = '2F321B9E-CD35-4FC4-A3BC-ACC4955584F1' or
applicationid = '1DDEEDE1-3CFD-4DAB-831A-DC8937150CF0' or
applicationid = '1572A0C9-0EC2-4B95-B42C-75805BF4738C' or
applicationid = '1A43B0FF-7F20-4ECD-8309-457284BB5444' or
applicationid = '53D9162D-9620-4681-AF90-BCB7D09270B8' or
applicationid = '70C7C52F-3709-474A-8A44-DB6F099A3AA3' or
applicationid = '91AA2298-3665-44A3-8D4F-64543A1674F7')) a
on u.applicationid = a.applicationid
left join (select applicationid, userid from jt.adoption_report_agg_session_per_appuser) s
on lower(u.applicationid::varchar) = s.applicationid and u.userid = s.userid
left join jt.adoption_report_testevents t
on a.applicationid = t.applicationid
--where t.applicationid is null
group by u.applicationid, a.name, a.startdate, a.enddate
order by startdate, enddate, applicationid;




select *
from authdb_applications
where applicationid = '4D61E684-2E9E-492B-B0FF-1E902A3F97C7'
or applicationid = 'F1DC4B72-B77E-42E8-8509-05FF3999ED30';


select *
from jt.authdb_applications_type_2
where applicationid = 'F1DC4B72-B77E-42E8-8509-05FF3999ED30'
or applicationid = '4D61E684-2E9E-492B-B0FF-1E902A3F97C7';


select *
from authdb_applications
where applicationid = '1DDEEDE1-3CFD-4DAB-831A-DC8937150CF0';


select *
from authdb_is_users
where applicationid = '1DDEEDE1-3CFD-4DAB-831A-DC8937150CF0';