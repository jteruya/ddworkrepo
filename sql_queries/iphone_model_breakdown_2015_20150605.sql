SELECT UserId
     , AppTypeId
     , Device
INTO reportingdb.dbo.jonathan_ios_2015_users2
FROM
( SELECT DISTINCT UserId
       , LAST_VALUE(AppTypeId) OVER (PARTITION BY UserId ORDER BY PctSessions ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AppTypeId
       , LAST_VALUE(MMMInfo) OVER (PARTITION BY UserId ORDER BY PctSessions ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) Device
  FROM
  ( SELECT DISTINCT S.UserId
         , AppTypeId
         , MMMInfo
         , 1.0*COUNT(*) OVER (PARTITION BY S.UserId, MMMInfo)/COUNT(*) OVER (PARTITION BY S.UserId) PctSessions
    FROM AnalyticsDB.dbo.Sessions S
    JOIN ReportingDB.dbo.DimUsers U ON S.UserId = U.UserId
    WHERE S.startdate >= '2015-01-01'
  ) S
) S;



select cnt_iphone_2_4
     , cast(cast(cnt_iphone_2_4 as decimal(12,4))/cast(total_ios as decimal(12,4)) as decimal(12,4)) as pct_iphone_2_4
     , cnt_iphone_5
     , cast(cast(cnt_iphone_5 as decimal(12,4))/cast(total_ios as decimal(12,4)) as decimal(12,4)) as pct_iphone_5
     , cnt_iphone_5_c
     , cast(cast(cnt_iphone_5_c as decimal(12,4))/cast(total_ios as decimal(12,4)) as decimal(12,4)) as pct_iphone_5
     , cnt_iphone_6
     , cast(cast(cnt_iphone_6 as decimal(12,4))/cast(total_ios as decimal(12,4)) as decimal(12,4)) as pct_iphone_6
     , cnt_iphone_6_plus
     , cast(cast(cnt_iphone_6_plus as decimal(12,4))/cast(total_ios as decimal(12,4)) as decimal(12,4)) as pct_iphone_6_plus
     , total_ios
     , total_users
from (
select count(case when apptypeid = 1 and (lower(device) like 'iphone%4,%' or lower(device) like 'iphone%3,%' or lower(device) like 'iphone%2,%') then 1 else null end) as cnt_iphone_2_4
     , count(case when apptypeid = 1 and (lower(device) like 'iphone%5,1%' or lower(device) like 'iphone%5,2%' or lower(device) like 'iphone%6,%') then 1 else null end) as cnt_iphone_5
     , count(case when apptypeid = 1 and (lower(device) like 'iphone%5,3%' or lower(device) like 'iphone%5,4%') then 1 else null end) as cnt_iphone_5_c
     , count(case when apptypeid = 1 and (lower(device) like 'iphone%7,2%') then 1 else null end) as cnt_iphone_6
     , count(case when apptypeid = 1 and (lower(device) like 'iphone%7,1%') then 1 else null end) as cnt_iphone_6_plus
     , count(case when apptypeid = 1 and lower(device) like '%iphone%' then 1 else null end) as total_ios
     , count(*) as total_users
from reportingdb.dbo.jonathan_ios_2015_users2) a;



select count(*)
from reportingdb.dbo.jonathan_ios_2015_users2
where apptypeid = 1 and lower(device) not like '%iphone%';
