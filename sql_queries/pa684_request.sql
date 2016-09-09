-- Get Events Population from US Server:
-- (1) Not a Test Event
-- (2) Event starts on or after 1/1/2016

DROP TABLE IF EXISTS PA684_Events;
CREATE TEMPORARY TABLE PA684_Events AS
SELECT ECS.*
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND StartDate >= '2016-01-01'
;
-- 2080 Events

-- Pull in Application Point Metadata (Not part of Robin refresh as of 8/22/2016):
-- Create tables in "JT" schema.
CREATE TABLE JT.Ratings_ApplicationUserPointTypes (
        MappingId INT
      , ApplicationId VARCHAR
      , PointTypeId INT
      , Points INT
      , Created TIMESTAMP
      , TopicId INT
)
;

CREATE TABLE JT.Ratings_UserPointTypes (
        TypeId INT
      , Description VARCHAR
      , Points INT
)
;
-- Run the following commands in Robin command line to populate data from read slave.
-- (1) java -jar DBSync-1.1.1.jar json/adhoc/jt_ratings_userpointtypes.json
-- (1) java -jar DBSync-1.1.1.jar json/adhoc/jt_ratings_applicationuserpointtypes.json

-- (1) What overall % of events are using Gamification?

-- % of Events with Leaderboard Microapp
SELECT COUNT(*) AS EventCnt
     , COUNT(CASE WHEN GRID_ITEMS.ApplicationId IS NOT NULL THEN 1 ELSE NULL END) AS LBEventCnt
     , COUNT(CASE WHEN GRID_ITEMS.ApplicationId IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS LBEventPct
FROM PA684_Events EVENTS
LEFT JOIN (SELECT DISTINCT ApplicationId
           FROM PUBLIC.Ratings_ApplicationConfigGridItems
           WHERE TypeId IN (6,9) AND Selected = 'True') GRID_ITEMS
ON EVENTS.ApplicationId = GRID_ITEMS.ApplicationId
;
-- Total Events: 2,080
-- Events w/ LB: 1,609
-- % of Total Event w/ LB: 77.36%


-- Global Points
DROP TABLE IF EXISTS PA684_Global_Points;
CREATE TEMPORARY TABLE PA684_Global_Points AS
SELECT EVENTS.ApplicationId
     , DEFAULT_VALUES.TypeId AS PointTypeId
     , DEFAULT_VALUES.Points AS DefaultPoints
     , COALESCE(DELTA_VALUES.Points, DEFAULT_VALUES.Points) AS Points
FROM PA684_Events EVENTS
JOIN (SELECT *
      FROM JT.Ratings_UserPointTypes
      WHERE TypeId IN (12,11,20,2,7,15,17,9,18,19,21)) DEFAULT_VALUES
ON 1 = 1
LEFT JOIN (SELECT UPPER(ApplicationId) AS ApplicationId
                , PointTypeId
                , Points
                , TopicId
                , Created
                , ROW_NUMBER() OVER (PARTITION BY ApplicationId, PointTypeId, TopicId ORDER BY Created DESC) AS RowNum
           FROM JT.Ratings_ApplicationUserPointTypes
           WHERE TopicId IS NULL) DELTA_VALUES
ON EVENTS.ApplicationId = DELTA_VALUES.ApplicationId
AND DEFAULT_VALUES.TypeId = DELTA_VALUES.PointTypeId
AND (DELTA_VALUES.RowNum IS NULL OR (DELTA_VALUES.RowNum IS NOT NULL AND DELTA_VALUES.RowNum = 1))
;


-- List Points
DROP TABLE IF EXISTS PA684_List_Points;
CREATE TEMPORARY TABLE PA684_List_Points AS
SELECT EVENTS.ApplicationId
     , DELTA_VALUES.TopicId
     , DEFAULT_VALUES.Points AS DefaultPoints
     , DELTA_VALUES.PointTypeId AS PointTypeId
     , DELTA_VALUES.Points AS Points
FROM PA684_Events EVENTS
JOIN (SELECT *
      FROM JT.Ratings_UserPointTypes
      WHERE TypeId IN (12,11,20,2,7,15,17,9,18,19,21)) DEFAULT_VALUES
ON 1 = 1
JOIN (SELECT UPPER(TYPES.ApplicationId) AS ApplicationId
           , TYPES.PointTypeId
           , TYPES.Points
           , TYPES.TopicId
           , TYPES.Created
           , ROW_NUMBER() OVER (PARTITION BY TYPES.ApplicationId, TYPES.PointTypeId, TYPES.TopicId ORDER BY TYPES.Created DESC) AS RowNum
      FROM JT.Ratings_ApplicationUserPointTypes TYPES
      JOIN PUBLIC.Ratings_Topic TOPICS
      ON TYPES.TopicId = TOPICS.TopicId
      WHERE TYPES.TopicId IS NOT NULL
      AND TOPICS.IsDisabled = 0
      AND TOPICS.IsHidden = 'false') DELTA_VALUES
ON EVENTS.ApplicationId = DELTA_VALUES.ApplicationId AND DEFAULT_VALUES.TypeId = DELTA_VALUES.PointTypeId
WHERE DELTA_VALUES.RowNum = 1
--AND DEFAULT_VALUES.Points <> DELTA_VALUES.Points
;


-- Gamification Settings
DROP TABLE IF EXISTS PA684_Event_Game_Settings;
CREATE TEMPORARY TABLE PA684_Event_Game_Settings AS
SELECT EVENTS.ApplicationId
     , COUNT(CASE WHEN SETTINGS.Name = 'ShowUserBadges' AND SETTINGS.SettingValue = 'False' THEN 1 ELSE NULL END) AS BadgesOffFlag
     , COUNT(CASE WHEN SETTINGS.Name = 'PrivateAchievements' AND SETTINGS.SettingValue = 'True' THEN 1 ELSE NULL END) AS HideAchievementsFlag
FROM PUBLIC.Ratings_ApplicationConfigSettings SETTINGS
JOIN PA684_Events EVENTS
ON SETTINGS.ApplicationId = EVENTS.ApplicationId
GROUP BY 1
;

-- Putting it all together
DROP TABLE IF EXISTS PA684_Event_All;
CREATE TEMPORARY TABLE PA684_Event_All AS
SELECT EVENTS.ApplicationId
     , GP.Points AS GlobalPoints
     , SETTINGS.BadgesOffFlag
     , SETTINGS.HideAchievementsFlag
     , CASE WHEN GRID_ITEMS.ApplicationId IS NULL THEN 1 ELSE 0 END AS LBOffFlag
     , CASE WHEN GP.Points = 0 AND SETTINGS.BadgesOffFlag = 1 AND SETTINGS.HideAchievementsFlag = 1 AND (CASE WHEN GRID_ITEMS.ApplicationId IS NULL THEN 1 ELSE 0 END) = 1 THEN 1 ELSE 0 END AS GameOffFlag
FROM PA684_Events EVENTS
JOIN (SELECT ApplicationId
           , SUM(Points) AS Points
      FROM PA684_Global_Points
      GROUP BY 1) GP
ON EVENTS.ApplicationId = GP.ApplicationId
JOIN PA684_Event_Game_Settings SETTINGS
ON EVENTS.ApplicationId = SETTINGS.ApplicationId
LEFT JOIN (SELECT DISTINCT ApplicationId
           FROM PUBLIC.Ratings_ApplicationConfigGridItems
           WHERE TypeId IN (6,9) AND Selected = 'True') GRID_ITEMS
ON EVENTS.ApplicationId = GRID_ITEMS.ApplicationId
;

-- Customers that request CSM to turn off gameification
SELECT COUNT(*)
     , COUNT(CASE WHEN GameOffFlag = 1 THEN 1 ELSE NULL END) AS GameOffCnt
     , COUNT(CASE WHEN GameOffFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS GameOffPct
FROM PA684_Event_All
;

-- Total Events; 2,080
-- Gameification Off: 55
-- Total Gameificaiton: 2.6%


-- (2) What % of events using Leaderboard have List Specific points that are DIFFERENT in value from Global Points.
/*
SELECT COUNT(*) AS EventCnt
     , COUNT(CASE WHEN GRID_ITEMS.ApplicationId IS NOT NULL THEN 1 ELSE NULL END) AS LBEventCnt
     , COUNT(CASE WHEN GRID_ITEMS.ApplicationId IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS LBEventPct
FROM PA684_Events EVENTS
LEFT JOIN (SELECT DISTINCT UPPER(ApplicationId) AS ApplicationId
           FROM PA684_List_Points) GRID_ITEMS
ON EVENTS.ApplicationId = GRID_ITEMS.ApplicationId
;
-- Total Events: 2,080
-- Events w/ LB: 94
-- % of Total Event w/ LB: 4.52%
*/

SELECT COUNT(DISTINCT ApplicationId) FROM (
SELECT LIST.ApplicationId
     , LIST.TopicId
     , LIST.PointTypeId
     , LIST.Points AS ListPoints
     , GLOBAL.Points AS GlobalPoints
FROM PA684_List_Points LIST
JOIN PA684_Global_Points GLOBAL
ON LIST.ApplicationId = GLOBAL.ApplicationId AND LIST.PointTypeId = GLOBAL.PointTypeId
WHERE LIST.Points <> GLOBAL.Points
) A
;

-- 72 Events
-- 3.46%
