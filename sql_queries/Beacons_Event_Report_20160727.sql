-- Event Population
SELECT LOWER(ECS.ApplicationId) AS Application_Id
     , ECS.Name
     , ECS.StartDate
     , ECS.EndDate
     /*, CASE
         WHEN SETTING.SettingValue = 'False' THEN 'On'
         WHEN SETTING.SettingValue = 'True' THEN 'Off'
         ELSE NULL
       END AS BeaconSetting*/
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
/*lEFT JOIN (SELECT *
           FROM PUBLIC.Ratings_ApplicationConfigSettings
           WHERE Name ILIKE '%Beacon%'
          ) SETTING
ON ECS.ApplicationId = SETTING.ApplicationId*/
WHERE TE.ApplicationId IS NULL
AND StartDate >= '2016-01-01'
AND EndDate <= CURRENT_DATE
ORDER BY 3,4,1
;

-- Events w/ Beacons Count
SELECT STATES.Application_Id
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , COUNT(*) AS BeaconStateCount
FROM PUBLIC.Fact_States_Live STATES
JOIN (SELECT LOWER(ECS.ApplicationId) AS Application_Id
           , ECS.Name
           , ECS.StartDate
           , ECS.EndDate
      FROM EventCube.EventCubeSummary ECS
      LEFT JOIN EventCube.TestEvents TE
      ON ECS.ApplicationId = TE.ApplicationId
      WHERE TE.ApplicationId IS NULL
      AND StartDate >= '2016-01-01'
      AND EndDate <= CURRENT_DATE
      ) EVENTS
ON STATES.Application_Id = EVENTS.Application_Id
WHERE STATES.Identifier = 'beacons'
GROUP BY 1,2,3,4
ORDER BY 3,4,1
;