drop table reportingdb.dbo.jonathan_ios_2015_users2;

SELECT UserId
     , AppTypeId
     , os
INTO reportingdb.dbo.jonathan_ios_2015_users2
FROM
( SELECT DISTINCT UserId
       , LAST_VALUE(AppTypeId) OVER (PARTITION BY UserId ORDER BY PctSessions ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AppTypeId
       , LAST_VALUE(deviceosversion) OVER (PARTITION BY UserId ORDER BY PctSessions ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) os
  FROM
  ( SELECT DISTINCT S.UserId
         , AppTypeId
         , deviceosversion
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



select count(*) as total_users
     , count(case when apptypeid = 1 then 1 else null end) as total_ios_users
     , count(case when apptypeid = 1 and os like '6.%' then 1 else null end) as total_ios_6_users
     , cast(cast(count(case when apptypeid = 1 and os like '6.%' then 1 else null end) as decimal(12,4))/cast(count(case when apptypeid = 1 then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_6_users     
     , count(case when apptypeid = 1 and os like '7.%' then 1 else null end) as total_ios_7_users
     , cast(cast(count(case when apptypeid = 1 and os like '7.%' then 1 else null end) as decimal(12,4))/cast(count(case when apptypeid = 1 then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_7_users
     , count(case when apptypeid = 1 and os like '8.%' then 1 else null end) as total_ios_8_users
     , cast(cast(count(case when apptypeid = 1 and os like '8.%' then 1 else null end) as decimal(12,4))/cast(count(case when apptypeid = 1 then 1 else null end) as decimal(12,4)) as decimal(12,4)) as pct_ios_8_users
from reportingdb.dbo.jonathan_ios_2015_users2;


select top 100 *
from reportingdb.dbo.jonathan_ios_2015_users2
where os like '8.%';


