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
FROM PUBLIC.AuthDB_IS_Users USERS
JOIN JT.SessionScanEventsPop EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
WHERE EVENTS.EnableSessionScansFlag = TRUE
;

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
     , ITEMS.ItemId
     , ITEMS.Name
     , CASE WHEN BOOKMARKS.GlobalUserId IS NOT NULL THEN 1 ELSE 0 END AS BookmarkFlag
     , CASE WHEN SCANS.ScannedUserId IS NOT NULL THEN 1 ELSE 0 END AS ScanFlag
FROM JT.SessionScanUserPop USERS
JOIN JT.SessionScanItemPop ITEMS
ON USERS.ApplicationId = ITEMS.ApplicationId
LEFT JOIN (SELECT DISTINCT UPPER(Global_User_Id) AS GlobalUserId
                , CAST(Metadata->>'ItemId' AS INT) AS ItemId
           FROM JT.SessionScanBookmarkPop
          ) BOOKMARKS
ON ITEMS.ItemId = BOOKMARKS.ItemId AND USERS.GlobalUserId = BOOKMARKS.GlobalUserId
LEFT JOIN (SELECT DISTINCT ScannedUserId
                , ItemId
           FROM PUBLIC.Ratings_Scans
          ) SCANS
ON ITEMS.ItemId = SCANS.ItemId AND USERS.UserId = SCANS.ScannedUserId
;


DROP TABLE IF EXISTS JT.SessionScanUserCount;
CREATE TABLE JT.SessionScanUserCount AS
SELECT ApplicationId
     , ItemId
     , COUNT(CASE WHEN BookmarkFlag = 1 THEN 1 ELSE NULL END) AS BookmarkUsers
     , COUNT(CASE WHEN ScanFlag = 1 THEN 1 ELSE NULL END) AS ScannedUsers
     , COUNT(CASE WHEN ScanFlag = 1 THEN 1 ELSE NULL END) - COUNT(CASE WHEN BookmarkFlag = 1 THEN 1 ELSE NULL END) AS DIFF
FROM JT.SessionScanUser USERS
GROUP BY 1,2
;



SELECT *
FROM JT.SessionScanUserCount
JOIN 
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