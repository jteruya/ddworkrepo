-- Eventcube Summary Adoption
select extract(year from startdate)::int * 10 + extract(quarter from startdate)::int as quarter
     , count(*) as event_cnt
     , avg(adoption) as adoption_avg
     , percentile_cont(0.5) within group (order by adoption) as adoption_med
from jt.tm_eventcubesummary
where openevent = 0
and adoption is not null
and startdate is not null
and startdate >= '2014-10-01'
and startdate <= '2015-07-28'
group by 1
order by 1;


-- Eventcube Summary Adoption
select count(*) as event_cnt
     , avg(adoption) as adoption_avg
     , percentile_cont(0.5) within group (order by adoption) as adoption_med
from jt.tm_eventcubesummary
where openevent = 0
and adoption is not null
and startdate is not null
and startdate >= '2015-07-01'
and startdate <= '2015-07-28';





-- Adoption Dashboard Logic (Modified)

select application_id
     , user_id
     , count(*) as sessions
into jt.july_fact_sessions
from fact_sessions
where metrics_type_id = 1
and start_date >= '2015-07-01'
group by application_id, user_id;

select application_id
     , user_id
     , count(*) as sessions
into jt.june_fact_sessions
from fact_sessions
where metrics_type_id = 1
and start_date >= '2015-06-01'
and start_date <= '2015-06-30'
group by application_id, user_id;


select quarter
     , count(*) as event_cnt
     , percentile_cont(0.5) within group (order by pct_adoptionratio) as adoption_med 
     , avg(pct_adoptionratio) as adoption_avg

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
            , extract(year from ecs.startdate)::int * 10 + extract(quarter from ecs.startdate)::int as quarter
            , u.*
            , CASE WHEN s.User_Id IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM authdb_is_users u
       --LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analytics_Sessions WHERE CAST(StartDate AS DATE) >= '2014-10-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       left join jt.july_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       --JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId::varchar
       JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-07-01'
       AND ecs.StartDate <= '2015-07-28'
      ) t
GROUP BY ApplicationId, startdate, enddate, quarter
HAVING COUNT(*) >= 10) a --Filter out likely Test Events
group by quarter;




select quarter
     , count(*) as event_cnt
     , percentile_cont(0.5) within group (order by pct_adoptionratio) as adoption_med 
     , avg(pct_adoptionratio) as adoption_avg

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
            , extract(year from ecs.startdate)::int * 10 + extract(quarter from ecs.startdate)::int as quarter
            , u.*
            , CASE WHEN s.User_Id IS NOT NULL THEN 1 ELSE 0 END AS Adopter_Ind
       FROM authdb_is_users u
       --LEFT JOIN (SELECT ApplicationId, UserId, COUNT(*) AS Sessions FROM analytics_Sessions WHERE CAST(StartDate AS DATE) >= '2014-10-01' GROUP BY ApplicationId, UserId) s ON u.ApplicationId = s.ApplicationId AND u.UserId = s.UserId
       left join jt.june_fact_sessions s on lower(u.applicationid::varchar) = s.application_id and u.userid = s.user_id 
       --JOIN ReportingDB.dbo.EventCubeSummary ecs ON u.ApplicationId = ecs.ApplicationId::varchar
       JOIN jt.tm_eventcubesummary ecs ON u.applicationid = upper(ecs.applicationid::varchar)
       WHERE u.IsDisabled != 1
       AND ecs.OpenEvent = 0 --CLOSED EVENT Filter
       AND ecs.StartDate >= '2015-06-01'
       AND ecs.StartDate <= '2015-06-30'
      ) t
GROUP BY ApplicationId, startdate, enddate, quarter
HAVING COUNT(*) >= 10) a --Filter out likely Test Events
group by quarter;
