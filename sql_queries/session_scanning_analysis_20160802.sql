-- Get Event Population
DROP TABLE IF EXISTS JT.SessionScanEventsPop;
CREATE TABLE JT.SessionScanEventsPop AS
SELECT ECS.*
     , CASE WHEN SETTING.ApplicationId IS NOT NULL THEN TRUE ELSE FALSE END AS EnableSessionScansFlag 
FROM (SELECT *
           , Fn_Parent_BinaryVersion(BinaryVersion) AS ParentBinaryVersion
      FROM EventCube.EventCubeSummary
     ) ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
LEFT JOIN (SELECT SETTING.*
           FROM PUBLIC.Ratings_ApplicationConfigSettings SETTING
           WHERE SETTING.Name = 'EnableSessionScans'
           AND SETTING.SettingValue = 'True'
          ) SETTING
ON ECS.ApplicationId = SETTING.ApplicationID
WHERE TE.ApplicationId IS NULL AND ParentBinaryVersion >= '6.07' AND ECS.EndDate < CURRENT_DATE
;

-- Get User Population
DROP TABLE IF EXISTS JT.SessionScanUserPop;
CREATE TABLE JT.SessionScanUserPop AS
SELECT DISTINCT USERS.ApplicationId
     , USERS.UserId
     , USERS.GlobalUserId
     , USERS.IsDisabled
     , COALESCE(SESSIONS.SessionCnt,0) AS SessionCnt
FROM PUBLIC.AuthDB_IS_Users USERS
JOIN JT.SessionScanEventsPop EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , UPPER(Global_User_Id) AS GlobalUserId
                , COUNT(DISTINCT Session_Id) AS SessionCnt
           FROM PUBLIC.Fact_Sessions_Live SESSIONS
           JOIN JT.SessionScanEventsPop EVENTS
           ON SESSIONS.Application_Id = LOWER(EVENTS.ApplicationId)
           WHERE EVENTS.EnableSessionScansFlag = TRUE
           GROUP BY 1,2
          ) SESSIONS
ON USERS.GlobalUserId = SESSIONS.GlobalUserId AND USERS.ApplicationId = SESSIONS.ApplicationId
WHERE EVENTS.EnableSessionScansFlag = TRUE
;


SELECT COUNT(*)
     , COUNT(CASE WHEN Active = 0 THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Active IS NULL THEN 1 ELSE NULL END)
FROM JT.SessionScanUserPop
;
-- 68625
-- 68790
-- 68625



-- Get User Session Items
DROP TABLE IF EXISTS JT.SessionScanItemPop;
CREATE TABLE JT.SessionScanItemPop AS
SELECT ITEMS.*
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN JT.SessionScanEventsPop EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId
WHERE TOPICS.ListTypeId = 2 AND EVENTS.EnableSessionScansFlag = TRUE
;


-- Get Session Bookmarks
DROP TABLE IF EXISTS JT.SessionScanBookmarkPop;
CREATE TABLE JT.SessionScanBookmarkPop AS
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.SessionScanUserPop USERS
ON ACTIONS.Application_Id = LOWER(USERS.ApplicationId) AND ACTIONS.Global_User_Id = LOWER(USERS.GlobalUserId)
JOIN JT.SessionScanItemPop ITEMS
ON ITEMS.ItemId = CAST(ACTIONS.Metadata->>'ItemId' AS INT)
WHERE ACTIONS.Identifier = 'bookmarkButton'
and ACTIONS.Metadata->>'ToggledTo' = 'on'
;



-- Compare Item Counts
DROP TABLE IF EXISTS JT.SessionScanItemCounts;
CREATE TABLE JT.SessionScanItemCounts AS
SELECT ITEMS.ApplicationId
     , ITEMS.ItemId
     , ITEMS.Name
     , COALESCE(BOOKMARKS.BookmarkUsers, 0) AS BookmarkUsers
     , COALESCE(SCANS.ScannedUsers,0) AS ScannedUsers
FROM JT.SessionScanItemPop ITEMS
LEFT JOIN (SELECT CAST(Metadata->>'ItemId' AS INT) AS ItemId
                , COUNT(DISTINCT Global_User_Id) AS BookmarkUsers
           FROM JT.SessionScanBookmarkPop
           GROUP BY 1
          ) BOOKMARKS
ON ITEMS.ItemId = BOOKMARKS.ItemId
LEFT JOIN (SELECT ItemId
                , COUNT(DISTINCT ScannedUserId) AS ScannedUsers
           FROM PUBLIC.Ratings_Scans
           GROUP BY 1
          ) SCANS
ON ITEMS.ItemId = SCANS.ItemId
;

-- User/Item Level Fact Table
DROP TABLE IF EXISTS JT.SessionScanUser;
CREATE TABLE JT.SessionScanUser AS
SELECT USERS.ApplicationId
     , USERS.UserId
     , USERS.GlobalUserId
     , USERS.SessionCnt
     , ITEMS.ItemId
     , ITEMS.Name
     , CASE WHEN BOOKMARKS.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS BookmarkFlag
     , CASE WHEN SCANS.ScannedUserId IS NOT NULL THEN 1 ELSE 0 END AS ScanFlag
FROM JT.SessionScanUserPop USERS
JOIN JT.SessionScanItemPop ITEMS
ON USERS.ApplicationId = ITEMS.ApplicationId
LEFT JOIN (SELECT DISTINCT UPPER(Application_Id) AS ApplicationId 
                , UPPER(Global_User_Id) AS GlobalUserId
                , CAST(Metadata->>'ItemId' AS INT) AS ItemId
           FROM JT.SessionScanBookmarkPop
          ) BOOKMARKS
ON ITEMS.ItemId = BOOKMARKS.ItemId AND USERS.GlobalUserId = BOOKMARKS.GlobalUserId AND BOOKMARKS.ApplicationId = ITEMS.ApplicationId
LEFT JOIN (SELECT DISTINCT ScannedUserId
                , ItemId
           FROM PUBLIC.Ratings_Scans
          ) SCANS
ON ITEMS.ItemId = SCANS.ItemId AND USERS.UserId = SCANS.ScannedUserId
WHERE USERS.IsDisabled = 0
AND ITEMS.IsDisabled = 0
;


DROP TABLE IF EXISTS JT.SessionScanUserCount;
CREATE TABLE JT.SessionScanUserCount AS
SELECT USERS.ApplicationId
     , USERS.ItemId
     , EVENTS.Registrants
     , COUNT(CASE WHEN USERS.BookmarkFlag = 1 THEN 1 ELSE NULL END) AS BookmarkUsers
     , COUNT(CASE WHEN USERS.ScanFlag = 1 THEN 1 ELSE NULL END) AS ScannedUsers
     , COUNT(CASE WHEN USERS.BookmarkFlag = 1 AND USERS.ScanFlag = 1 THEN 1 ELSE NULL END) AS BookmarkScanUsers
FROM JT.SessionScanUser USERS
JOIN JT.SessionScanEventsPop EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
GROUP BY 1,2,3
;

-- Scans > Bookmarks
SELECT AVG(Book)
     , AVG(Scan)
FROM (
SELECT *
     , (BookmarkUsers - BookmarkScanUsers)::DECIMAL(12,4)/BookmarkScanUsers::DECIMAL(12,4) AS Book
     , (ScannedUsers - BookmarkScanUsers)::DECIMAL(12,4)/BookmarkScanUsers::DECIMAL(12,4) AS Scan
FROM JT.SessionScanUserCount
WHERE ScannedUsers > BookmarkUsers
AND ScannedUsers > 0
AND BookmarkUsers > 0 
AND BookmarkScanUsers > 0
) A
;

-- Bookmarks > Scans
SELECT AVG(Book)
     , AVG(Scan)
FROM (
SELECT *
     , (BookmarkUsers - BookmarkScanUsers)::DECIMAL(12,4)/BookmarkScanUsers::DECIMAL(12,4) AS Book
     , (ScannedUsers - BookmarkScanUsers)::DECIMAL(12,4)/BookmarkScanUsers::DECIMAL(12,4) AS Scan
FROM JT.SessionScanUserCount
WHERE ScannedUsers < BookmarkUsers
AND ScannedUsers > 0
AND BookmarkUsers > 0 
) A
;



DROP TABLE IF EXISTS JT.SessionScanUserEventCount;
CREATE TABLE JT.SessionScanUserEventCount AS
SELECT USERS.ApplicationId
     , EVENTS.Registrants
     , EVENTS.UsersActive
     , COUNT(DISTINCT CASE WHEN USERS.BookmarkFlag = 1 THEN USERS.UserId ELSE NULL END) AS BookmarkUsers
     , COUNT(DISTINCT CASE WHEN USERS.ScanFlag = 1 THEN USERS.UserId ELSE NULL END) AS ScannedUsers
FROM JT.SessionScanUser USERS
JOIN JT.SessionScanEventsPop EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
GROUP BY 1,2,3
;


SELECT AVG(ScanPct)
     , AVG(BookmarkPct)
FROM (
SELECT *
     , ScannedUsers::DECIMAL(12,4)/Registrants::DECIMAL(12,4) AS ScanPct
     , BookmarkUsers::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS BookmarkPct
FROM JT.SessionScanUserEventCount
) A
;
-- 5,307

SELECT AVG(Med)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Med)
FROM (
SELECT *
     , (ScannedUsers - BookmarkUsers)::DECIMAL(12,4)/ScannedUsers::DECIMAL(12,4) * 100 AS Med
FROM JT.SessionScanUserCount
WHERE ScannedUsers > 0
AND (ScannedUsers - BookmarkUsers)::DECIMAL(12,4)/ScannedUsers::DECIMAL(12,4) < 0
) A
;


SELECT COUNT(*)
     , AVG(Med)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Med)
     , MAX(Med)
     , AVG(Diff)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Diff)
     , MAX(Diff)
FROM (
SELECT *
     , (ScannedUsers - BookmarkUsers) AS DIFF
     , (ScannedUsers - BookmarkUsers)::DECIMAL(12,4)/BookmarkUsers::DECIMAL(12,4) * 100 AS Med
FROM JT.SessionScanUserCount
WHERE ScannedUsers > 0
AND BookmarkUsers > 0
AND (ScannedUsers - BookmarkUsers)::DECIMAL(12,4) > 0
) A
;


SELECT COUNT(*)
     , AVG(Med)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Med)
     , MAX(Med)
     , AVG(Diff)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Diff)
     , MAX(Diff)
FROM (
SELECT *
     , (ScannedUsers - BookmarkUsers) AS DIFF
     , (ScannedUsers - BookmarkUsers)::DECIMAL(12,4)/ScannedUsers::DECIMAL(12,4) * 100 AS Med
FROM JT.SessionScanUserCount
WHERE ScannedUsers > 0
AND BookmarkUsers > 0
AND (ScannedUsers - BookmarkUsers)::DECIMAL(12,4) < 0
) A
;



SELECT ITEMCOUNTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , COUNT(CASE WHEN ScannedUsers > BookmarkUsers THEN 1 ELSE NULL END) AS ScanGreaterBookmarkItemCount
     , COUNT(CASE WHEN ScannedUsers < BookmarkUsers THEN 1 ELSE NULL END) AS ScanLessBookmarkItemCount
     , COUNT(CASE WHEN ScannedUsers = BookmarkUsers THEN 1 ELSE NULL END) AS ScanEqualBookmarkItemCount
FROM JT.SessionScanItemCounts ITEMCOUNTS
JOIN JT.SessionScanEventsPop EVENTS
ON ITEMCOUNTS.ApplicationId = EVENTS.ApplicationId
GROUP BY 1,2,3,4
ORDER BY 3,4
--WHERE ScannedUsers > 0
;


SELECT COUNT(*)
     , AVG(A.DIFF)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY A.DIFF)
     , stddev(A.DIFF)
FROM JT.SessionScanUserCount A
JOIN JT.SessionScanEventsPop B
ON A.ApplicationId = B.ApplicationId
WHERE A.ScannedUsers > 0 AND A.BookmarkUsers > 0
;


SELECT B.EventType
     , COUNT(*)
     , AVG(A.DIFF)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY A.DIFF)
     , stddev(A.DIFF)
FROM JT.SessionScanUserCount A
JOIN JT.SessionScanEventsPop B
ON A.ApplicationId = B.ApplicationId
WHERE A.ScannedUsers > 0 AND A.BookmarkUsers > 0
GROUP BY 1
;


SELECT B.EventType
     , B.OpenEvent
     , COUNT(*)
     , AVG(A.DIFF)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY A.DIFF)
     , stddev(A.DIFF)
FROM JT.SessionScanUserCount A
JOIN JT.SessionScanEventsPop B
ON A.ApplicationId = B.ApplicationId
WHERE A.ScannedUsers > 0 AND A.BookmarkUsers > 0
GROUP BY 1,2
;


SELECT B.OpenEvent
     , COUNT(*)
     , AVG(A.DIFF)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY A.DIFF)
     , stddev(A.DIFF)
FROM JT.SessionScanUserCount A
JOIN JT.SessionScanEventsPop B
ON A.ApplicationId = B.ApplicationId
WHERE A.ScannedUsers > 0 AND A.BookmarkUsers > 0
GROUP BY 1
;

-- Question: How effective are bookmark counts at predicting attendance






--S1: Bookmark: True, Scan: True
--S2: Bookmark: True, Scan: False
--S3: Bookmark: False, Scan: True
--S4: Bookmark: False, Scan: False



SELECT *
FROM 