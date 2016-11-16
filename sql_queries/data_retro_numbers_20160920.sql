-- All Events in the last 6 months
DROP TABLE IF EXISTS JT.Retro_Events;
CREATE TABLE JT.Retro_Events AS
SELECT ECS.*
     , Fn_Parent_BinaryVersion(BinaryVersion) AS ParentBinaryVersion
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.EndDate < CURRENT_DATE
AND ECS.StartDate >= CURRENT_DATE - INTERVAL '6' Month
;

SELECT *
FROM JT.Retro_Events
;

-- Audit Event Count
SELECT COUNT(*)
FROM JT.Retro_Events
;
-- 1,540 Events

-- Flags for Events w/Features
DROP TABLE IF EXISTS JT.Retro_Events_Feature_List;
CREATE TABLE JT.Retro_Events_Feature_List AS
SELECT EVENTS.ApplicationId
     , CONFIG.Name
FROM JT.Retro_Events EVENTS
JOIN PUBLIC.Ratings_ApplicationConfigSettings CONFIG
ON EVENTS.ApplicationId = CONFIG.ApplicationId
WHERE ((CONFIG.Name = 'EnableSessionScans' AND EVENTS.ParentBinaryVersion >= '6.07' AND SettingValue ILIKE '%true%')
OR (CONFIG.Name = 'DisableStatusUpdate' AND EVENTS.ParentBinaryVersion >= '6.05' AND SettingValue ILIKE '%true%'))
UNION
SELECT EVENTS.ApplicationId
     , 'EnableNestedAgenda' AS Name
FROM JT.Retro_Events EVENTS
JOIN (SELECT DISTINCT ITEM.ApplicationId
      FROM Ratings_Item ITEM
      JOIN Ratings_Topic TOPIC
      ON ITEM.ParentTopicId = TOPIC.TopicId
      WHERE ITEM.ParentItemId IS NOT NULL
      AND ITEM.IsDisabled = 0
      AND TOPIC.IsDisabled = 0
      AND TOPIC.ListTypeId = 2
      AND TOPIC.IsHidden = false) NA
ON EVENTS.ApplicationId = NA.ApplicationId
AND EVENTS.ParentBinaryVersion >= '6.17'
;

SELECT Name
     , COUNT(*) AS EventCnt
     , COUNT(*)::DECIMAL(12,4)/1540.0 AS EventPct
FROM JT.Retro_Events_Feature_List
GROUP BY 1
;

-- Attendee Session Scanning: 49 Events (3.18%)
-- Organizer Only Feeds: 5 Events (0.32%)
-- Nested Agenda: 3 Events (0.19%)

-- Attendee Session Scanning Analysis

-- Get All Nested Event Users
/*
DROP TABLE IF EXISTS JT.Retro_Events_Nested_Users;
CREATE TABLE JT.Retro_Events_Nested_Users AS
SELECT DISTINCT USERS.ApplicationId
     , USERS.UserId
     , USERS.GlobalUserId
     , USERS.IsDisabled
FROM PUBLIC.AuthDB_IS_Users USERS
JOIN JT.Retro_Events_Feature_List EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
WHERE EVENTS.Name = 'EnableSessionScans'
;
*/

-- Get All Nested Event Sessions
DROP TABLE IF EXISTS JT.Retro_Events_Scans_Sessions;
CREATE TABLE JT.Retro_Events_Scans_Sessions AS
SELECT DISTINCT ITEMS.ApplicationId
     , ITEMS.ItemId
     , ITEMS.Name
     , ITEMS.ParentTopicId
     , ITEMS.IsDisabled AS ItemIsDisabled
     , TOPICS.IsDisabled AS TopicIsDisabled
     , TOPICS.IsHidden AS TopicIsHidden
FROM PUBLIC.Ratings_Item ITEMS
JOIN JT.Retro_Events_Feature_List EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
WHERE EVENTS.Name = 'EnableSessionScans'
AND TOPICS.ListTypeId = 2
;

-- Get All Scans (Item Level)
DROP TABLE IF EXISTS JT.Retro_Events_Scans_Sessions_Agg;
CREATE TABLE JT.Retro_Events_Scans_Sessions_Agg AS
SELECT SESSIONS.ApplicationId
     , SESSIONS.ItemId
     , SESSIONS.ItemIsDisabled
     , SESSIONS.TopicIsDisabled
     , SESSIONS.TopicIsHidden
     , COUNT(DISTINCT SCANS.ScannerUserId) AS ScannerUserCnt
     , COUNT(DISTINCT SCANS.ScannedUserId) AS ScannedUserCnt
FROM JT.Retro_Events_Scans_Sessions SESSIONS
LEFT JOIN PUBLIC.Ratings_Scans SCANS
ON SESSIONS.ItemId = SCANS.ItemId
WHERE SESSIONS.ItemIsDisabled = 0 AND SESSIONS.TopicIsDisabled = 0 AND SESSIONS.TopicIsHidden = FALSE
GROUP BY 1,2,3,4,5
;

-- Per Items (Over Time)
SELECT CAST(EXTRACT(YEAR FROM EVENTS.StartDate) * 100 + EXTRACT(MONTH FROM EVENTS.StartDate) AS INT) AS YYYYMM
     , COUNT(DISTINCT EVENTS.ApplicationId) AS EventCnt
     , COUNT(CASE WHEN SESSIONS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS TotalItemCnt
     , COUNT(CASE WHEN SCANS.ScannedUserCnt > 0 THEN 1 ELSE NULL END) AS TotalScannedItemCnt
     , COUNT(CASE WHEN SCANS.ScannedUserCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN SESSIONS.ItemId IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4) AS TotalScannedItemPct
FROM (SELECT EVENTS.*
      FROM JT.Retro_Events EVENTS
      JOIN JT.Retro_Events_Feature_List FEATURE
      ON EVENTS.ApplicationId = FEATURE.ApplicationId
      WHERE FEATURE.Name = 'EnableSessionScans') EVENTS
LEFT JOIN (SELECT *
           FROM JT.Retro_Events_Scans_Sessions
           WHERE ItemIsDisabled = 0 AND TopicIsDisabled = 0 AND TopicIsHidden = FALSE) SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
LEFT JOIN JT.Retro_Events_Scans_Sessions_Agg SCANS
ON SESSIONS.ApplicationId = SCANS.ApplicationId AND SESSIONS.ItemId = SCANS.ItemId
GROUP BY 1
ORDER BY 1
;

-- Per Users (Over Time)
SELECT CAST(EXTRACT(YEAR FROM EVENTS.StartDate) * 100 + EXTRACT(MONTH FROM EVENTS.StartDate) AS INT) AS YYYYMM
     , COUNT(DISTINCT EVENTS.ApplicationId) AS EventCnt
     , SUM(EVENTS.UsersActive) AS TotalActiveUsers
     , COUNT(DISTINCT CASE WHEN SCANS.ScannerUserId IS NOT NULL THEN SCANS.ScannerUserId ELSE NULL END) AS TotalScanners
     , COUNT(DISTINCT CASE WHEN SCANS.ScannedUserId IS NOT NULL THEN SCANS.ScannedUserId ELSE NULL END) AS TotalScanned
     , COUNT(DISTINCT CASE WHEN SCANS.ScannedUserId IS NOT NULL THEN SCANS.ScannedUserId ELSE NULL END)::DECIMAL(12,4)/SUM(EVENTS.UsersActive)::DECIMAL(12,4) AS TotalScannedPct
FROM (SELECT EVENTS.*
      FROM JT.Retro_Events EVENTS
      JOIN JT.Retro_Events_Feature_List FEATURE
      ON EVENTS.ApplicationId = FEATURE.ApplicationId
      WHERE FEATURE.Name = 'EnableSessionScans') EVENTS
LEFT JOIN (SELECT *
           FROM JT.Retro_Events_Scans_Sessions
           WHERE ItemIsDisabled = 0 AND TopicIsDisabled = 0 AND TopicIsHidden = FALSE) SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
LEFT JOIN PUBLIC.Ratings_Scans SCANS
ON SESSIONS.ItemId = SCANS.ItemId
GROUP BY 1
ORDER BY 1
;

-- Looking bad over time.  This might be happening because the feature is line-itemed.
-- Look at the % increase of bookmarking.




-- Nested Agenda
-- Get all Agenda Items
DROP TABLE IF EXISTS JT.Retro_Nested_Items;
CREATE TABLE JT.Retro_Nested_Items AS
SELECT ITEM.*
FROM PUBLIC.Ratings_Item ITEM
JOIN (SELECT DISTINCT ApplicationId
      FROM JT.Retro_Events_Feature_List
      WHERE Name = 'EnableNestedAgenda'
     ) EVENT
ON ITEM.ApplicationId = EVENT.ApplicationId
JOIN PUBLIC.Ratings_Topic TOPIC
ON ITEM.ParentTopicId = TOPIC.TopicId
WHERE ITEM.IsDisabled = 0
AND TOPIC.IsDisabled = 0
AND TOPIC.IsHidden = 'false'
AND TOPIC.ListTypeId = 2
;

-- Get all Users
DROP TABLE IF EXISTS JT.Retro_Events_Nested_Users;
CREATE TABLE JT.Retro_Events_Nested_Users AS
SELECT DISTINCT USERS.ApplicationId
     , USERS.UserId
     , USERS.GlobalUserId
     , USERS.IsDisabled
FROM PUBLIC.AuthDB_IS_Users USERS
JOIN JT.Retro_Events_Feature_List EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
WHERE EVENTS.Name = 'EnableNestedAgenda'
;

-- Session Category Breakdown 
DROP TABLE IF EXISTS JT.Retro_Nested_Items_Cat;
CREATE TABLE JT.Retro_Nested_Items_Cat AS
SELECT ITEMS.ApplicationId
     , ITEMS.ItemId
     , CASE
         WHEN ITEMS.ParentItemId IS NOT NULL THEN 'Child'
         WHEN ITEMS.ParentItemId IS NULL AND PARENTS.ParentItemId IS NULL THEN 'NonParent'
         WHEN ITEMS.ParentItemId IS NULL AND PARENTS.ParentItemId IS NOT NULL THEN 'Parent'
       END AS ItemCategory
FROM JT.Retro_Nested_Items ITEMS
LEFT JOIN (SELECT ApplicationId
                , ParentItemId
                , COUNT(*) AS ChildIdCnt
           FROM JT.Retro_Nested_Items
           WHERE ParentItemId IS NOT NULL
           GROUP BY 1,2
          ) PARENTS
ON ITEMS.ItemId = PARENTS.ParentItemId AND ITEMS.ApplicationId = PARENTS.ApplicationId
;

-- Get Relevant Nested Actions
DROP TABLE IF EXISTS JT.Retro_Nested_Actions;
CREATE TABLE JT.Retro_Nested_Actions AS
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN (SELECT DISTINCT LOWER(ApplicationId) AS Application_Id
      FROM JT.Retro_Events_Feature_List
      WHERE Name = 'EnableNestedAgenda'
     ) EVENT
ON ACTIONS.Application_Id = EVENT.Application_Id
JOIN JT.Retro_Events_Nested_Users USERS
ON ACTIONS.Global_User_ID = LOWER(USERS.GlobalUserId)
WHERE ACTIONS.Identifier IN ('sessionDetailButton', 'attachmentButton', 'bookmarkButton', 'itemButton')
AND USERS.IsDisabled = 0
;

-- Get Relevant Nested Views
DROP TABLE IF EXISTS JT.Retro_Nested_Views;
CREATE TABLE JT.Retro_Nested_Views AS
SELECT VIEWS.*
FROM PUBLIC.Fact_Views_Live VIEWS
JOIN (SELECT DISTINCT LOWER(ApplicationId) AS Application_Id
      FROM JT.Retro_Events_Feature_List
      WHERE Name = 'EnableNestedAgenda'
     ) EVENT
ON VIEWS.Application_Id = EVENT.Application_Id
JOIN JT.Retro_Events_Nested_Users USERS
ON VIEWS.Global_User_ID = LOWER(USERS.GlobalUserId)
WHERE VIEWS.Identifier IN ('list', 'bookmarks', 'item')
AND USERS.IsDisabled = 0
;


-- Bookmarking (iOS)
DROP TABLE IF EXISTS JT.Retro_Nested_Bookmarks_IOS_Agg;
CREATE TABLE JT.Retro_Nested_Bookmarks_IOS_Agg AS
SELECT ACTIONS.Application_Id
     , ACTIONS.Global_User_Id
     , COUNT(DISTINCT ACTIONS.ItemId) AS BookmarkItemCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent' THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS NonChildItemBkmkCnt
     , COUNT(DISTINCT CASE WHEN (ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent') AND Metadata->>'View' = 'list' THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS NonChildListViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN (ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent') AND Metadata->>'View' = 'item' THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS NonChildItemViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS ChildItemBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND Metadata->>'View' = 'list' THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS ChildListViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND Metadata->>'View' = 'item' AND CAST(ACTIONS.Metadata->>'AssociatedViewItemId' AS INT) <> CAST(ACTIONS.Metadata->>'ItemId' AS INT) THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS ChildParentViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND Metadata->>'View' = 'item' AND CAST(ACTIONS.Metadata->>'AssociatedViewItemId' AS INT) = CAST(ACTIONS.Metadata->>'ItemId' AS INT) THEN ACTIONS.Metadata->>'ItemId' ELSE NULL END) AS ChildChildViewBkmkCnt
FROM JT.Retro_Nested_Boomkarks ACTIONS
JOIN JT.Retro_Nested_Items_Cat ITEMS
ON ACTIONS.ItemId = ITEMS.ItemId AND ACTIONS.Application_Id = LOWER(ITEMS.ApplicationId)
WHERE ACTIONS.Identifier = 'bookmarkButton'
AND (Metadata->>'View' = 'list' OR Metadata->>'View' = 'item')
AND Device_Type = 'ios'
GROUP BY 1,2
;

-- Android Item View Correction (Metrics Issue)
DROP TABLE IF EXISTS JT.Retro_Nested_Bookmarks_Android_ItemView_Corr;
CREATE TABLE JT.Retro_Nested_Bookmarks_Android_ItemView_Corr AS
SELECT SESSION_VIEW.*
FROM JT.Retro_Nested_Views SESSION_VIEW
WHERE SESSION_VIEW.Identifier = 'item'
AND SESSION_VIEW.Device_Type = 'android'
UNION ALL
SELECT SESSION_ACTIONS.*
FROM JT.Retro_Nested_Actions SESSION_ACTIONS
JOIN JT.Retro_Nested_Items_Cat ITEMS
ON CAST(SESSION_ACTIONS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId AND SESSION_ACTIONS.Application_Id = LOWER(ITEMS.ApplicationId)
WHERE SESSION_ACTIONS.Identifier = 'bookmarkButton'
AND SESSION_ACTIONS.Metadata->>'View' = 'item'
AND SESSION_ACTIONS.Device_Type = 'android'
ORDER BY Application_Id, Global_User_Id, Created
;

-- Create Empty Table for Python Script Results
DROP TABLE IF EXISTS JT.Retro_Nested_Bookmarks_Android_ItemView_Corr_Final;
CREATE TABLE JT.Retro_Nested_Bookmarks_Android_ItemView_Corr_Final (
     Application_Id VARCHAR,
     Global_User_Id VARCHAR,
     Created TIMESTAMP,
     Identifier VARCHAR,
     ItemId INT,
     Metric_Type VARCHAR,
     ViewItemId INT
);

-- All individual bookmark action metrics cleaned up
DROP TABLE IF EXISTS JT.Retro_Nested_Boomkarks;
CREATE TABLE JT.Retro_Nested_Boomkarks AS 
SELECT *
     , 'item' AS ViewType
     , 'android' AS device_type
FROM JT.Retro_Nested_Bookmarks_Android_ItemView_Corr_Final
WHERE Identifier = 'bookmarkButton'
UNION ALL
SELECT Application_Id
     , Global_User_Id
     , Created
     , Identifier
     , CAST(Metadata->>'ItemId' AS INT) AS ItemId
     , Metric_Type
     , NULL AS ViewItemId
     , 'list' AS ViewType
     , device_type
FROM JT.Retro_Nested_Actions
WHERE Identifier = 'bookmarkButton'
AND Metadata->>'View' = 'list'
AND Device_Type = 'android'
UNION ALL
SELECT Application_Id
     , Global_User_Id
     , Created
     , Identifier
     , CAST(Metadata->>'ItemId' AS INT) AS ItemId
     , Metric_Type
     , NULL AS ViewItemId
     , Metadata->>'View' as ViewType
     , Device_Type
FROM JT.Retro_Nested_Actions ACTIONS
WHERE ACTIONS.Identifier = 'bookmarkButton'
AND (Metadata->>'View' = 'list' OR Metadata->>'View' = 'item')
AND Device_Type = 'ios'
;


-- Bookmarking (Android)
DROP TABLE IF EXISTS JT.Retro_Nested_Bookmarks_Android_Agg;
CREATE TABLE JT.Retro_Nested_Bookmarks_Android_Agg AS
SELECT ACTIONS.Application_Id
     , ACTIONS.Global_User_Id
     , COUNT(DISTINCT ACTIONS.ItemId) AS BookmarkItemCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent' THEN ACTIONS.ItemId ELSE NULL END) AS NonChildItemBkmkCnt
     , COUNT(DISTINCT CASE WHEN (ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent') AND ACTIONS.ViewType = 'list' THEN ACTIONS.ItemId ELSE NULL END) AS NonChildListViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN (ITEMS.ItemCategory = 'Parent' OR ITEMS.ItemCategory = 'NonParent') AND ACTIONS.ViewType = 'item' THEN ACTIONS.ItemId ELSE NULL END) AS NonChildItemViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' THEN ACTIONS.ItemId ELSE NULL END) AS ChildItemBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND ACTIONS.ViewType = 'list' THEN ACTIONS.ItemId ELSE NULL END) AS ChildListViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND ACTIONS.ViewType = 'item' AND ACTIONS.ViewItemId <> ACTIONS.ItemId THEN ACTIONS.ItemId ELSE NULL END) AS ChildParentViewBkmkCnt
     , COUNT(DISTINCT CASE WHEN ITEMS.ItemCategory = 'Child' AND ACTIONS.ViewType = 'item' AND ACTIONS.ViewItemId = ACTIONS.ItemId THEN ACTIONS.ItemId ELSE NULL END) AS ChildChildViewBkmkCnt
FROM JT.Retro_Nested_Boomkarks ACTIONS
JOIN JT.Retro_Nested_Items_Cat ITEMS
ON ACTIONS.ItemId = ITEMS.ItemId AND ACTIONS.Application_Id = LOWER(ITEMS.ApplicationId)
WHERE ACTIONS.Device_Type = 'android'
GROUP BY 1,2
;

-- iOS and Android Results
DROP TABLE IF EXISTS JT.Retro_Nested_Bookmarks_Agg;
CREATE TABLE JT.Retro_Nested_Bookmarks_Agg AS
SELECT Application_Id
     , Global_User_Id
     , SUM(BookmarkItemCnt) AS BookmarkItemCnt
     , SUM(NonChildItemBkmkCnt) AS NonChildItemBkmkCnt
     , SUM(NonChildListViewBkmkCnt) AS NonChildListViewBkmkCnt
     , SUM(NonChildItemViewBkmkCnt) AS NonChildItemViewBkmkCnt
     , SUM(ChildItemBkmkCnt) AS ChildItemBkmkCnt
     , SUM(ChildListViewBkmkCnt) AS ChildListViewBkmkCnt
     , SUM(ChildParentViewBkmkCnt) AS ChildParentViewBkmkCnt
     , SUM(ChildChildViewBkmkCnt) AS ChildChildViewBkmkCnt
FROM (SELECT *
      FROM JT.Retro_Nested_Bookmarks_Android_Agg
      UNION ALL
      SELECT *
      FROM JT.Retro_Nested_Bookmarks_IOS_Agg
     ) A
GROUP BY 1,2
;


------------
---- Results
------------

---- View Check

-- List View
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
GROUP BY 1,2
ORDER BY 1,2
;

-- Users at the Agenda
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
AND CAST(Metadata->>'ListId' AS INT) IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items)
GROUP BY 1,2
ORDER BY 1,2
;

-- Users Non Agenda List
SELECT VIEWS.Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views VIEWS
JOIN Ratings_Topic TOPICS
ON CAST(VIEWS.Metadata->>'ListId' AS INT) = TOPICS.TopicId
WHERE VIEWS.Identifier = 'list'
AND CAST(VIEWS.Metadata->>'ListId' AS INT) NOT IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items)
GROUP BY 1,2
ORDER BY 1,2
;


SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
AND Metadata->>'Type' = 'Sessions'
GROUP BY 1,2
ORDER BY 1,2
;


SELECT *
FROM (
SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
EXCEPT 
(
SELECT VIEWS.*
FROM JT.Retro_Nested_Views VIEWS
JOIN Ratings_Topic TOPICS
ON CAST(VIEWS.Metadata->>'ListId' AS INT) = TOPICS.TopicId
WHERE VIEWS.Identifier = 'list'
AND CAST(VIEWS.Metadata->>'ListId' AS INT) NOT IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items)
UNION ALL
SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
AND CAST(Metadata->>'ListId' AS INT) IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items)
UNION ALL
SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'list'
AND Metadata->>'Type' = 'Sessions'
)
) a
;


-- My Agenda View Breakdown
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'bookmarks'
GROUP BY 1,2
ORDER BY 1,2
;

-- My Agenda View Breakdown (Type = Agenda)
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'bookmarks'
AND Metadata->>'Type' = 'agenda'
GROUP BY 1,2
ORDER BY 1,2
;


SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'bookmarks'
EXCEPT 
(
SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'bookmarks'
AND Metadata->>'Type' = 'agenda'
)
;


-- Item View Breakdown
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
GROUP BY 1,2
ORDER BY 1,2
;

-- Agenda Only
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items)
GROUP BY 1,2
ORDER BY 1,2
;

-- Non Agenda Only
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views VIEWS
JOIN Ratings_Item ITEMS
ON CAST(VIEWS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId
JOIN Ratings_Topic TOPICS
ON TOPICS.TopicId = ITEMS.ParentTopicId
WHERE VIEWS.Identifier = 'item'
AND TOPICS.ListTypeId <> 2
GROUP BY 1,2
ORDER BY 1,2
;

SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
EXCEPT
(
SELECT *
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items)
UNION ALL
SELECT VIEWS.*
FROM JT.Retro_Nested_Views VIEWS
JOIN Ratings_Item ITEMS
ON CAST(VIEWS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId
JOIN Ratings_Topic TOPICS
ON TOPICS.TopicId = ITEMS.ParentTopicId
WHERE VIEWS.Identifier = 'item'
AND TOPICS.ListTypeId <> 2
)
;

-- Child Breakdown
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items_Cat WHERE ItemCategory = 'Child')
GROUP BY 1,2
ORDER BY 1,2
;

-- Parent Breakdown
SELECT Application_Id
     , Device_Type
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(*)
FROM JT.Retro_Nested_Views
WHERE Identifier = 'item'
AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items_Cat WHERE ItemCategory <> 'Child')
GROUP BY 1,2
ORDER BY 1,2
;



-- User View Funnel
SELECT Application_Id
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , EVENTS.UsersActive
     , COUNT(DISTINCT CASE WHEN Identifier = 'list' AND CAST(Metadata->>'ListId' AS INT) IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items) THEN Global_User_Id ELSE NULL END) AS AgendaUser
     , COUNT(DISTINCT CASE WHEN Identifier = 'item' AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items) THEN Global_User_Id ELSE NULL END) AS SessionDetailUser
     , COUNT(DISTINCT CASE WHEN Identifier = 'item' AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items_Cat WHERE ItemCategory = 'Child') THEN Global_User_Id ELSE NULL END) AS ChildSessionDetailUser
     , COUNT(DISTINCT CASE WHEN Identifier = 'bookmarks' AND Metadata->>'Type' = 'agenda' THEN Global_User_Id ELSE NULL END) AS MyAgendaUser
     , COUNT(DISTINCT CASE WHEN Identifier = 'list' AND CAST(Metadata->>'ListId' AS INT) IN (SELECT DISTINCT ParentTopicID FROM JT.Retro_Nested_Items) THEN Global_User_Id ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS AgendaPct
     , COUNT(DISTINCT CASE WHEN Identifier = 'item' AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items) THEN Global_User_Id ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS SessionDetailPct
     , COUNT(DISTINCT CASE WHEN Identifier = 'item' AND CAST(Metadata->>'ItemId' AS INT) IN (SELECT DISTINCT ItemId FROM JT.Retro_Nested_Items_Cat WHERE ItemCategory = 'Child') THEN Global_User_Id ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS ChildSessionDetailPct
     , COUNT(DISTINCT CASE WHEN Identifier = 'bookmarks' AND Metadata->>'Type' = 'agenda' THEN Global_User_Id ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS MyAgendaPct
FROM JT.Retro_Nested_Views VIEWS
JOIN JT.Retro_Events EVENTS
ON VIEWS.Application_Id = LOWER(EVENTS.ApplicationId)
GROUP BY 1,2,3,4,5
ORDER BY 3,4,1
;


-- % Bookmarks
SELECT Application_Id
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , EVENTS.UsersActive
     , COUNT(*) AS BkmkUserCnt
     , COUNT(CASE WHEN NonChildItemBkmkCnt > 0 THEN 1 ELSE NULL END) AS ParentBkmkUserCnt
     , COUNT(CASE WHEN ChildItemBkmkCnt > 0 THEN 1 ELSE NULL END) AS ChildBkmkUserCnt
     , COUNT(*)::DECIMAL(12,4)/EVENTS.UsersActive AS BkmkUserPct
     , COUNT(CASE WHEN NonChildItemBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive AS ParentBkmkUserPct
     , COUNT(CASE WHEN ChildItemBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/EVENTS.UsersActive AS ChildBkmkUserPct
FROM JT.Retro_Nested_Bookmarks_Agg AGG
JOIN JT.Retro_Events EVENTS
ON AGG.Application_Id = LOWER(EVENTS.ApplicationId)
GROUP BY 1,2,3,4,5
ORDER BY 3,4,1
;



-- % Of Users Bookmarking (Old)
SELECT Application_Id
     , EVENTS.UsersActive
     , COUNT(*) AS BookmarkUsersCnt
     , COUNT(CASE WHEN NonChildListViewBkmkCnt > 0 OR NonChildItemBkmkCnt > 0 THEN 1 ELSE NULL END) AS NonChildBookmarkUserCnt
     , COUNT(CASE WHEN NonChildListViewBkmkCnt > 0 THEN 1 ELSE NULL END) AS NonChildListBookmarkUserCnt
     , COUNT(CASE WHEN NonChildItemBkmkCnt > 0 THEN 1 ELSE NULL END) AS NonChildBookmarkUserCnt
     , COUNT(CASE WHEN ChildParentViewBkmkCnt > 0 OR ChildListViewBkmkCnt > 0 OR ChildChildViewBkmkCnt > 0 THEN 1 ELSE NULL END) AS ChildBookmarkUserCnt
     , COUNT(CASE WHEN ChildParentViewBkmkCnt > 0 THEN 1 ELSE NULL END) AS ChildParentBookmarkUserCnt
     , COUNT(CASE WHEN ChildListViewBkmkCnt > 0 THEN 1 ELSE NULL END) AS ChildParentListBookmarkUserCnt
     , COUNT(CASE WHEN ChildChildViewBkmkCnt > 0 THEN 1 ELSE NULL END) AS ChildChildBookmarkUserCnt
     , COUNT(*)::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS BookmarkUsersPct
     , COUNT(CASE WHEN NonChildListViewBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS NonChildListBookmarkUserPct
     , COUNT(CASE WHEN NonChildItemBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS NonChildBookmarkUserPct
     , COUNT(CASE WHEN ChildParentViewBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS ChildParentBookmarkUserPct
     , COUNT(CASE WHEN ChildListViewBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS ChildParentListBookmarkUserPct
     , COUNT(CASE WHEN ChildChildViewBkmkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS ChildChildBookmarkUserPct
FROM JT.Retro_Nested_Bookmarks_Agg AGG
JOIN JT.Retro_Events EVENTS
ON AGG.Application_Id = LOWER(EVENTS.ApplicationId)
GROUP BY 1,2
ORDER BY 1
;



SELECT *
FROM JT.Retro_Nested_Bookmarks_Agg LIMIT 10
;



-- User Bookmarking to Demonstrate Baseline

-- Where in the feature are Users Bookmarking

-- Parent Items
SELECT Application_Id
     , SUM(NonChildItemBkmkCnt) AS BookmarkCnt
     , SUM(NonChildListViewBkmkCnt) AS AgendaViewBookmarkCnt
     , SUM(NonChildItemViewBkmkCnt) AS SessionDetailViewBookmarkCnt
     , SUM(NonChildListViewBkmkCnt)::DECIMAL(12,4)/SUM(NonChildItemBkmkCnt)::DECIMAL(12,4) AS AgendaViewBookmarkPct
     , SUM(NonChildItemViewBkmkCnt)::DECIMAL(12,4)/SUM(NonChildItemBkmkCnt)::DECIMAL(12,4) AS SessionDetailViewBookmarkPct
FROM JT.Retro_Nested_Bookmarks_Agg AGG
GROUP BY 1
;

-- Child Items
SELECT Application_Id
     , SUM(ChildItemBkmkCnt) AS BookmarkCnt
     , SUM(ChildListViewBkmkCnt) AS AgendaViewBookmarkCnt
     , SUM(ChildParentViewBkmkCnt) AS ParentViewBookmarkCnt
     , SUM(ChildChildViewBkmkCnt) AS SessionDetailViewBookmarkCnt
     , SUM(ChildParentViewBkmkCnt)::DECIMAL(12,4)/SUM(ChildItemBkmkCnt)::DECIMAL(12,4) AS ParentViewBookmarkCnt     
     , SUM(ChildListViewBkmkCnt)::DECIMAL(12,4)/SUM(ChildItemBkmkCnt)::DECIMAL(12,4) AS AgendaViewBookmarkPct
     , SUM(ChildChildViewBkmkCnt)::DECIMAL(12,4)/SUM(ChildItemBkmkCnt)::DECIMAL(12,4) AS SessionDetailViewBookmarkCnt
FROM JT.Retro_Nested_Bookmarks_Agg AGG
GROUP BY 1
;


-- Benchmark
SELECT AVG(PCT)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY PCT) FROM (
SELECT A.Application_Id
     , B.UsersActive
     , A.UserCnt
     , A.UserCnt::DECIMAL(12,4)/B.UsersActive::DECIMAL(12,4) AS PCT
FROM JT.MenuClicks_Agg_Xref_Index A
LEFT JOIN EventCube.EventCubeSummary B
ON A.Application_Id = LOWER(B.ApplicationId)
WHERE A.MicroApp ILIKE '%agenda%'
AND B.UsersActive > 0 AND B.UsersActive > A.UserCnt
) A
;


SELECT ApplicationId AS "Application ID"
     , Name AS "Event Name"
     , StartDate AS "Start Date"
     , EndDate AS "End Date"
     , CASE WHEN OpenEvent = 1 THEN 'Open Reg' ELSE 'Close Red' END AS "Reg Type"
     , CASE WHEN EventType = '' THEN 'Unknown' ELSE EventType END AS "Event Type"
FROM JT.Retro_Events
WHERE LOWER(ApplicationId) IN ('05a138b1-476b-427d-a8d6-b0ee290da98d','0bbf776c-3a06-499b-9203-010d52d6e152','8df6d9e3-973e-4502-bf86-0b2efcf591bd')
ORDER BY 3,4
;

