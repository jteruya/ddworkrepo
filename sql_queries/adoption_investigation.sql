
--- Initial Calculation Using TM Tables

-- 2014 Q4
-- Event Count: 288
--Median: 58.47
--Average: 58.60
select distinct count(*) over (partition by 1) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by 1) as median_adoption 
     , avg(pct_adoptionratio) over (partition by 1) as average_adoption 

from (
SELECT ApplicationId,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2014-10-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2014-10-01'
       AND ecs.StartDate <= '2014-12-31'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events

-- 2015 Q1
--Median: 68.01
--Average: 66.01
select distinct count(*) over (partition by 1) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by 1) as median_adoption 
     , avg(pct_adoptionratio) over (partition by 1) as average_adoption 

from (
SELECT ApplicationId,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-01-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-01-01'
       AND ecs.StartDate <= '2015-03-31'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events


-- 2015 Q2
--Median: 65.38
--Average: 62.88
select distinct count(*) over (partition by 1) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by 1) as median_adoption 
     , avg(pct_adoptionratio) over (partition by 1) as average_adoption 

from (
SELECT ApplicationId,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-04-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-04-01'
       AND ecs.StartDate <= '2015-06-30'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events



-- 2015 Q3
--Median: 22.35
--Average: 28.44
select distinct count(*) over (partition by 1) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by 1) as median_adoption 
     , avg(pct_adoptionratio) over (partition by 1) as average_adoption 

from (
SELECT ApplicationId,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-24'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events



-- By Eventtype

-- 2014 Q4
-- Event Count: 288
--Median: 58.47
--Average: 58.60
select distinct eventtype 
     , count(*) over (partition by eventtype) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by eventtype) as median_adoption 
     , avg(pct_adoptionratio) over (partition by eventtype) as average_adoption 

from (
SELECT ApplicationId,
       eventtype,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2014-10-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2014-10-01'
       AND ecs.StartDate <= '2014-12-31'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype
HAVING COUNT(*) >= 10) a
order by eventtype;--Filter out likely Test Events

-- 2015 Q1
--Median: 68.01
--Average: 66.01
select distinct eventtype 
     , count(*) over (partition by eventtype) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by eventtype) as median_adoption 
     , avg(pct_adoptionratio) over (partition by eventtype) as average_adoption 
from (
SELECT ApplicationId,
       eventtype,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-01-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-01-01'
       AND ecs.StartDate <= '2015-03-31'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events


-- 2015 Q2
--Median: 65.38
--Average: 62.88
select distinct eventtype 
     , count(*) over (partition by eventtype) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by eventtype) as median_adoption 
     , avg(pct_adoptionratio) over (partition by eventtype) as average_adoption 

from (
SELECT ApplicationId,
       eventtype,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-04-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-04-01'
       AND ecs.StartDate <= '2015-06-30'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events



-- 2015 Q3
--Median: 22.35
--Average: 28.44
select distinct eventtype 
     , count(*) over (partition by eventtype) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by eventtype) as median_adoption 
     , avg(pct_adoptionratio) over (partition by eventtype) as average_adoption 

from (
SELECT ApplicationId,
       eventtype,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-24'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype
HAVING COUNT(*) >= 10) a;--Filter out likely Test Events







select distinct startdatemonth, startdateday
     , count(*) over (partition by startdatemonth, startdateday) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by startdatemonth, startdateday) as median_adoption 
     , avg(pct_adoptionratio) over (partition by startdatemonth, startdateday) as average_adoption 

from (
SELECT ApplicationId,
       eventtype,
       startdate,
       startdatemonth,
       startdateday,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , month(ecs.startdate) as startdatemonth
            , day(ecs.startdate) as startdateday
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-05-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-05-01'
       AND ecs.StartDate <= '2015-07-14'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype, startdatemonth, startdateday
HAVING COUNT(*) >= 10) a
order by startdatemonth, startdateday;--Filter out likely Test Events








select distinct startdatemonth, startdateday
     , count(*) over (partition by startdatemonth, startdateday) as event_count 
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over(partition by startdatemonth, startdateday) as median_adoption 
     , avg(pct_adoptionratio) over (partition by startdatemonth, startdateday) as average_adoption 

from (
SELECT ApplicationId,
       eventtype,
       startdate,
       startdatemonth,
       startdateday,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM AuthDB.dbo.IS_Users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM AnalyticsDB.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-28'
       --AND ecs.StartDate < DATEADD(dd,-5,CAST(GETDATE() AS DATE)) --Event has to have started within the time window
      ) t
GROUP BY ApplicationId, startdate, enddate, eventtype, startdatemonth, startdateday
HAVING COUNT(*) >= 10) a
order by startdatemonth, startdateday;--Filter out likely Test Events


--- Additional Work by Quarter

select distinct quarter
     , count(*) over (partition by quarter) as event_cnt
     , percentile_cont(0.5) within group (order by pct_adoptionratio) over (partition by quarter) as adoption_med 
     , avg(pct_adoptionratio) over (partition by quarter) as adoption_avg

from (
SELECT ApplicationId,
       quarter,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , datepart(year, ecs.startdate) * 10 + datepart(quarter, ecs.startdate) as quarter
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM authdb.dbo.is_users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analyticsdb.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       --left join jt.july_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       --JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-28'
      ) t
GROUP BY ApplicationId, startdate, enddate, quarter
HAVING COUNT(*) >= 10) a; --Filter out likely Test Events





       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , datepart(year, ecs.startdate) * 10 + datepart(quarter, ecs.startdate) as quarter
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       into reportingdb.dbo.jt_quarter_3_users
       FROM authdb.dbo.is_users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analyticsdb.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       --left join jt.july_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       --JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-28';
       
       
       
SELECT ApplicationId,
       quarter,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
into reportingdb.dbo.jt_quarter_3_events
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , datepart(year, ecs.startdate) * 10 + datepart(quarter, ecs.startdate) as quarter
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM authdb.dbo.is_users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analyticsdb.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-07-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       --left join jt.july_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       --JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-28'
      ) t
GROUP BY ApplicationId, startdate, enddate, quarter



SELECT ApplicationId,
       quarter,
       startdate,
       enddate,
       SUM(Adopter_Ind) AS UsersActive, --Those in the Attendee list that had 1+ sessions
       COUNT(*) AS Registrants, --Count of all Attendess in App's List
       CASE WHEN SUM(Adopter_Ind) = 0 THEN 0 ELSE ROUND(100 * CAST(SUM(Adopter_Ind) AS NUMERIC) / CAST(COUNT(*) AS NUMERIC),2) END AS PCT_AdoptionRatio
into reportingdb.dbo.jt_quarter_2_events
FROM (
       SELECT ecs.Name
            , ecs.StartDate
            , ecs.EndDate
            , ecs.EventType
            , datepart(year, ecs.startdate) * 10 + datepart(quarter, ecs.startdate) as quarter
            , u.*
            , CASE WHEN s.UserId IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM authdb.dbo.is_users u
       LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analyticsdb.dbo.Sessions WHERE CAST(StartDate AS DATE) >= '2015-06-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       --left join jt.july_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId
       --JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-06-01'
       AND ecs.StartDate <= '2015-06-30'
      ) t
GROUP BY ApplicationId, startdate, enddate, quarter




SELECT ApplicationId
     , UserId
     , COUNT(*) AS Sessions 
FROM analyticsdb.dbo.Sessions 
WHERE CAST(StartDate AS DATE) >= '2015-07-01' 
GROUP BY ApplicationId, UserId


SELECT *
FROM reportingdb.dbo.jt_quarter_2_events;