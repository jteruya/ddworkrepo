-- Get the Universe of Non-Disabled Users (Temporary Table)
DROP TABLE IF EXISTS AllEventUsers
;

CREATE TEMPORARY TABLE AllEventUsers AS
SELECT DISTINCT ApplicationId
     , UserId
     , GlobalUserId
     , LOWER(GlobalUserId) AS LowerGlobalUserId
FROM PUBLIC.AuthDB_IS_Users
WHERE ApplicationId = '39B10FA0-2D39-42E7-BB8A-F375E5DFC7E9'
AND IsDisabled = 0
;

-- Get the Universe of Non-Disabled Agenda Items (Temporary Table)
DROP TABLE IF EXISTS AllItems
;

CREATE TEMPORARY TABLE AllItems AS
SELECT DISTINCT ITEMS.ItemId
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS ON ITEMS.ParentTopicId = TOPICS.TopicId
WHERE ITEMS.ApplicationId = '39B10FA0-2D39-42E7-BB8A-F375E5DFC7E9'
-- Non-Disabled Sessions Only
AND ITEMS.IsDisabled = 0
-- Non-Disabled Agenda Topics Only
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = false
-- Pull Only Agenda Topics
AND TOPICS.ListTypeId = 2
;


-- Get the Universe of Session Bookmarks (Temporary Table)
DROP TABLE IF EXISTS AllUserSessionBookmarks
;

CREATE TEMPORARY TABLE AllUserSessionBookmarks AS
SELECT FAVS.*
FROM PUBLIC.Ratings_UserFavorites FAVS
JOIN AllEventUsers USERS ON FAVS.UserId = USERS.UserId
JOIN AllItems ITEMS ON FAVS.ItemId = ITEMS.ItemId
WHERE FAVS.ApplicationId = '39B10FA0-2D39-42E7-BB8A-F375E5DFC7E9'
;


-- Get the Universe of Session Bookmark Actions within App
DROP TABLE IF EXISTS JT.AllUserSessionBookmarkActions
;

CREATE TABLE JT.AllUserSessionBookmarkActions (
   Application_Id VARCHAR,
   Global_User_Id VARCHAR,
   Item_Id INT
)
;

INSERT INTO JT.AllUserSessionBookmarkActions (
SELECT ACTIONS.Application_Id
     , ACTIONS.Global_User_Id
     , ACTIONS.Item_Id
FROM (SELECT *
           , CAST(Metadata->>'ItemId' AS INT) AS Item_Id
      FROM PUBLIC.Fact_Actions_Live
      --JOIN AllItems ITEMS ON CAST(ACTIONS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId
      WHERE Application_Id = '39b10fa0-2d39-42e7-bb8a-f375e5dfc7e9'
      -- Pull Only Bookmark Actons
      AND Identifier = 'bookmarkButton'
      -- Pull Only Bookmark Actions where there user toggled on
      AND Metadata->>'ToggledTo' = 'on'
     ) ACTIONS
JOIN AllEventUsers USERS ON ACTIONS.Global_User_Id = USERS.LowerGlobalUserId
JOIN AllItems ITEMS ON ACTIONS.Item_Id = ITEMS.ItemId
)
;

-- Get the Universe of Sessions within App
/*
DROP TABLE IF EXISTS JT.AllUserSessions
;

CREATE TABLE JT.AllUserSessions AS (
SELECT * FROM PUBLIC.Fact_Sessions_Live 
LIMIT 0
)
;

INSERT INTO JT.AllUserSessions (
SELECT SESSIONS.*
FROM (SELECT *
      FROM PUBLIC.Fact_Sessions_Live
      --JOIN AllItems ITEMS ON CAST(ACTIONS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId
      WHERE Application_Id = '39b10fa0-2d39-42e7-bb8a-f375e5dfc7e9'
     ) SESSIONS
JOIN AllEventUsers USERS ON SESSIONS.Global_User_Id = USERS.LowerGlobalUserId
)
;

*/

-- Check Counts (Expect Actual Bookmarks to be less than Bookmark Actions)
SELECT COUNT(*)
FROM AllUserSessionBookmarks
;
-- 385,748

SELECT COUNT(*)
FROM JT.AllUserSessionBookmarkActions
;
-- 76,603


-- Putting It All Together
CREATE TABLE JT.AllUsersSummary AS
SELECT USERS.ApplicationId
     , USERS.GlobalUserId
     , COUNT(DISTINCT FAVS.ItemId) AS BookmarkedSessions
     , COUNT(DISTINCT ACTIONS.Item_Id) AS BookmarkedSessionActions
     , COALESCE(SESSIONS.SESSIONS,0) AS AppSessions
FROM AllEventUsers USERS
LEFT JOIN AllUserSessionBookmarks FAVS ON USERS.UserId = FAVS.UserId
LEFT JOIN JT.AllUserSessionBookmarkActions ACTIONS ON USERS.LowerGlobalUserId = ACTIONS.Global_User_Id
LEFT JOIN EventCube.Agg_Session_per_AppUser SESSIONS ON USERS.UserId = SESSIONS.UserId
GROUP BY 1,2,5
;

-- Results
SELECT ApplicationId
     , COUNT(*) AS RegisteredUsers
     , COUNT(CASE WHEN BookmarkedSessions > 0 AND AppSessions = 0 THEN 1 ELSE NULL END) AS NonActiveUsersBookmars
     , COUNT(CASE WHEN AppSessions > 0 THEN 1 ELSE NULL END) AS ActiveUsers
FROM JT.AllUsersSummary
GROUP BY 1;
