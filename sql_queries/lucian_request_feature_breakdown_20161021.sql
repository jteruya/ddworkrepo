

SELECT ECS.*
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
;

SELECT COUNT(*) AS EventCnt
     , MIN(CASE WHEN AttendeeMeetings = 1 OR ExhibitorMeetings = 1 THEN StartDate ELSE NULL END)
     , COUNT(CASE WHEN AttendeeMeetings = 1 OR ExhibitorMeetings = 1 THEN 1 ELSE NULL END) AS MeetingScheduling
     , MIN(CASE WHEN AttendeeSessionScans = 1 THEN StartDate ELSE NULL END)
     , COUNT(CASE WHEN AttendeeSessionScans = 1 THEN 1 ELSE NULL END) AS AttendeeSessionScan
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
;

SELECT *
FROM AuthDB_Applications
WHERE ApplicationId = 'D3C831D9-BBB7-498D-8D4D-D9E856675E87'
;


SELECT ECS.*
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
AND (AttendeeMeetings = 1 OR ExhibitorMeetings = 1)
ORDER BY ECS.StartDate
;


SELECT ECS.ApplicationId
     , ECS.Name
     , ECS.StartDate
     , ECS.EndDate
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
AND AttendeeSessionScans = 1
EXCEPT
SELECT ECS.ApplicationId
     , ECS.Name
     , ECS.StartDate
     , ECS.EndDate
FROM EventCube.EventCubeSummary ECS     
JOIN SalesForce.Implementation IMP
ON ECS.ApplicationID = IMP.ApplicationId
WHERE ECS.StartDate >= '2016-01-01'
AND AttendeeSessionScans = 1
;

SELECT ECS.ApplicationId
     , ECS.Name
     , ECS.StartDate
     , ECS.EndDate
FROM EventCube.EventCubeSummary ECS     
JOIN SalesForce.Implementation IMP
ON ECS.ApplicationID = IMP.ApplicationId
WHERE ECS.StartDate >= '2016-01-01'
AND ECS.EndDate < CURRENT_DATE
AND AttendeeSessionScans = 1
EXCEPT
SELECT ECS.ApplicationId
     , ECS.Name
     , ECS.StartDate
     , ECS.EndDate
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
AND ECS.EndDate < CURRENT_DATE
AND AttendeeSessionScans = 1
;

-- Per Week Time Series
SELECT CAST(EXTRACT(YEAR FROM StartDate) * 100 + EXTRACT(WEEK FROM StartDate) AS INT) AS "Week of Year"
     , MIN(ECS.StartDate) AS "First Day of Week"
     , COUNT(*) AS "Total Event Count"
     , COUNT(CASE WHEN AttendeeSessionScans = 1 THEN 1 ELSE NULL END) AS "Session Scanning Event Count"
     , COUNT(CASE WHEN (AttendeeMeetings = 1 OR ExhibitorMeetings = 1) THEN 1 ELSE NULL END) AS "Attendee Meeting Event Count"
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-04-01'
AND ECS.StartDate < CURRENT_DATE
AND ECS.EndDate < CURRENT_DATE
-- Remove Live Engagement Tour (DD Event)
AND ECS.ApplicationId NOT IN ('D3C831D9-BBB7-498D-8D4D-D9E856675E87','AC6C7A6A-3598-43DF-BB17-C5C37CB2A637','1974D60B-9F4B-45B5-A303-05E3D4221338','174482BC-8223-4207-8CCD-D87B84AC6A78','C47C0971-46E5-4811-9042-02231E1CD4EE')
-- Remove Vecinos (DD Event)
AND ECS.ApplicationId NOT IN ('7E880965-99F7-447E-ACC7-ACCD3CEF255E')
-- Remove QA Test Bundle Event
AND ECS.ApplicationId NOT IN (SELECT DISTINCT EVENTS.ApplicationId
                              FROM AuthDB_Applications EVENTS
                              JOIN AuthDB_Bundles BUNDLES
                              ON EVENTS.BundleId = BUNDLES.BundleId
                              WHERE BUNDLES.Name ILIKE '%dextest%'
                             )
GROUP BY 1
ORDER BY 1
;

-- Per Month Time Series
SELECT CAST(EXTRACT(YEAR FROM StartDate) * 100 + EXTRACT(MONTH FROM StartDate) AS INT) AS "Month of Year"
     , MIN(ECS.StartDate) AS "First Day of Month"
     , COUNT(*) AS "Total Event Count"
     , COUNT(CASE WHEN AttendeeSessionScans = 1 THEN 1 ELSE NULL END) AS "Session Scanning Event Count"
     , COUNT(CASE WHEN (AttendeeMeetings = 1 OR ExhibitorMeetings = 1) THEN 1 ELSE NULL END) AS "Attendee Meeting Event Count"
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-04-01'
AND ECS.StartDate < CURRENT_DATE
AND ECS.EndDate < CURRENT_DATE
-- Remove Live Engagement Tour (DD Event)
AND ECS.ApplicationId NOT IN ('D3C831D9-BBB7-498D-8D4D-D9E856675E87','AC6C7A6A-3598-43DF-BB17-C5C37CB2A637','1974D60B-9F4B-45B5-A303-05E3D4221338','174482BC-8223-4207-8CCD-D87B84AC6A78','C47C0971-46E5-4811-9042-02231E1CD4EE')
-- Remove Vecinos (DD Event)
AND ECS.ApplicationId NOT IN ('7E880965-99F7-447E-ACC7-ACCD3CEF255E')
-- Remove QA Test Bundle Event
AND ECS.ApplicationId NOT IN (SELECT DISTINCT EVENTS.ApplicationId
                              FROM AuthDB_Applications EVENTS
                              JOIN AuthDB_Bundles BUNDLES
                              ON EVENTS.BundleId = BUNDLES.BundleId
                              WHERE BUNDLES.Name ILIKE '%dextest%'
                             )
GROUP BY 1
ORDER BY 1
;



SELECT ECS.ApplicationId AS "Application ID"
     , ECS.Name AS "Event Name"
     , ECS.StartDate AS "Start Date"
     , ECS.EndDate AS "End Date"
     , ECS.EventType AS "Event Type"
     , CASE WHEN ECS.OpenEvent = 0 THEN 'Closed Reg' ELSE 'Open Reg' END AS "Reg Type"
FROM EventCube.EventCubeSummary ECS     
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-04-01'
AND ECS.StartDate < CURRENT_DATE
AND ECS.EndDate < CURRENT_DATE
--AND AttendeeSessionScans = 1
AND (AttendeeMeetings = 1 OR ExhibitorMeetings = 1)
-- Remove Live Engagement Tour (DD Event)
AND ECS.ApplicationId NOT IN ('D3C831D9-BBB7-498D-8D4D-D9E856675E87','AC6C7A6A-3598-43DF-BB17-C5C37CB2A637','1974D60B-9F4B-45B5-A303-05E3D4221338','174482BC-8223-4207-8CCD-D87B84AC6A78','C47C0971-46E5-4811-9042-02231E1CD4EE')
-- Remove Vecinos (DD Event)
AND ECS.ApplicationId NOT IN ('7E880965-99F7-447E-ACC7-ACCD3CEF255E')
-- Remove QA Test Bundle Event
AND ECS.ApplicationId NOT IN (SELECT DISTINCT EVENTS.ApplicationId
                              FROM AuthDB_Applications EVENTS
                              JOIN AuthDB_Bundles BUNDLES
                              ON EVENTS.BundleId = BUNDLES.BundleId
                              WHERE BUNDLES.Name ILIKE '%dextest%'
                             )
ORDER BY 3,4
;

