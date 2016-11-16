SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(ApplicationId) = '44579c07-7c8f-4d4c-b309-324c9f675186'
;
-- Start Date: 2016-11-11
-- End Date: 2016-11-11

SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE BundleId = '3478D44B-9962-4C4D-BD0E-B1281C4F2BDC'
;
-- 19

-- Get Non-Disabled Users
DROP TABLE IF EXISTS JT.ACRARHP_Users;
CREATE TABLE JT.ACRARHP_Users AS
SELECT DISTINCT UserId, GlobalUserId
FROM PUBLIC.AuthDB_IS_Users
WHERE ApplicationId = '44579C07-7C8F-4D4C-B309-324C9F675186'
AND IsDisabled = 0
;

-- Examine Client Metrics (Sessions, Actions, Views)
-- Get Session Counts for Users
DROP TABLE IF EXISTS JT.ACRARHP_Users_Sessions;
CREATE TABLE JT.ACRARHP_Users_Sessions AS
SELECT SESSIONS.Global_User_Id
     , COUNT(DISTINCT SESSIONS.Session_Id) AS SessionCnt
FROM PUBLIC.Fact_Sessions_Live SESSIONS
JOIN JT.ACRARHP_Users USERS
ON SESSIONS.Global_User_Id = LOWER(USERS.GlobalUserId)
WHERE SESSIONS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
GROUP BY 1
;

SELECT Binary_Version
     , Device_Type
     , COUNT(DISTINCT Device_Id)
FROM PUBLIC.Fact_Sessions_Live SESSIONS
WHERE SESSIONS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
AND Global_User_Id = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
AND Device_Id NOT IN (SELECT DISTINCT Device_Id FROM PUBLIC.Fact_Sessions_Live WHERE Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186' AND Global_User_Id <> 'ffffffff-ffff-ffff-ffff-ffffffffffff')
GROUP BY 1,2
;

SELECT DISTINCT Global_User_Id
FROM PUBLIC.Fact_Views_Live SESSIONS
WHERE SESSIONS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
AND Binary_Version = '6.25.1'
AND Device_Type = 'ios'
;


-- Get Action Counts for Users
DROP TABLE IF EXISTS JT.ACRARHP_Users_Actions;
CREATE TABLE JT.ACRARHP_Users_Actions AS
SELECT ACTIONS.Global_User_Id
     , COUNT(*) AS ActionsCnt
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.ACRARHP_Users USERS
ON ACTIONS.Global_User_Id = LOWER(USERS.GlobalUserId)
WHERE ACTIONS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
GROUP BY 1
;

-- Get Views Counts for Users
DROP TABLE IF EXISTS JT.ACRARHP_Users_Views;
CREATE TABLE JT.ACRARHP_Users_Views AS
SELECT VIEWS.Global_User_Id
     , COUNT(*) AS ViewsCnt
FROM PUBLIC.Fact_Views_Live VIEWS
JOIN JT.ACRARHP_Users USERS
ON VIEWS.Global_User_Id = LOWER(USERS.GlobalUserId)
WHERE VIEWS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
GROUP BY 1
;

-- Test for any difference
SELECT DISTINCT Global_User_Id
FROM JT.ACRARHP_Users_Sessions
EXCEPT
SELECT DISTINCT Global_User_Id
FROM JT.ACRARHP_Users_Views
EXCEPT
SELECT DISTINCT Global_User_Id
FROM JT.ACRARHP_Users_Views
-- None

-- Break down sessions by date, version and device type
DROP TABLE IF EXISTS JT.ACRARHP_Date_Version_Users_Sessions;
CREATE TABLE JT.ACRARHP_Date_Version_Users_Sessions AS
SELECT SESSIONS.Created::Date AS Created
     , SESSIONS.Binary_Version
     , SESSIONS.Device_Type
     , SESSIONS.Global_User_Id
     , COUNT(DISTINCT SESSIONS.Session_Id) AS SessionCnt
FROM PUBLIC.Fact_Sessions_Live SESSIONS
JOIN JT.ACRARHP_Users USERS
ON SESSIONS.Global_User_Id = LOWER(USERS.GlobalUserId)
WHERE SESSIONS.Application_Id = '44579c07-7c8f-4d4c-b309-324c9f675186'
GROUP BY 1,2,3,4
;


SELECT Device_Type
     , Binary_Version
     , SUM(SessionCnt) AS TotalSessionCnt
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
FROM JT.ACRARHP_Date_Version_Users_Sessions
GROUP BY 1,2
;


SELECT COUNT(*)
     , COUNT(DISTINCT CASE WHEN DeviceType IN (1,2) THEN UserId ELSE NULL END) AS iOSUserCnt
     , COUNT(DISTINCT CASE WHEN DeviceType IN (3) THEN UserId ELSE NULL END) AS AndroidUserCnt
FROM PUBLIC.Ratings_AppleDevices
WHERE UPPER(ApplicationId) = '44579C07-7C8F-4D4C-B309-324C9F675186'
;



-- Examine Ratings Data
DROP TABLE IF EXISTS JT.ACRARHP_Users_Posts;
CREATE TABLE JT.ACRARHP_Users_Posts AS
SELECT USERS.UserId
     , USERS.GlobalUserId
     , CHECKINS.CheckInId
     , CHECKINS.ItemId
     , NOTES.Notes
     , NOTES.Created
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECKINS.CheckInId = NOTES.CheckInId 
JOIN JT.ACRARHP_Users USERS
ON CHECKINS.UserId = USERS.UserId
WHERE CHECKINS.ApplicationId = '44579C07-7C8F-4D4C-B309-324C9F675186'
AND (CHECKINS.IsDisabled = 'false' OR CHECKINS.IsDisabled IS NULL)
;


SELECT Created::Date AS Date
     , CAST(EXTRACT(HOUR FROM Created) AS INT) AS Hour
     , COUNT(*) AS Post
     , COUNT(CASE WHEN SESSIONS.Global_User_Id IS NULL THEN 1 ELSE NULL END) AS MysteryPostCnt
     , COUNT(CASE WHEN SESSIONS.Global_User_Id IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS MysterPostPct
FROM JT.ACRARHP_Users_Posts POSTS
LEFT JOIN JT.ACRARHP_Users_Sessions SESSIONS
ON POSTS.GlobalUserId = UPPER(SESSIONS.Global_User_Id)
GROUP BY 1,2
ORDER BY 1,2
;


SELECT *
FROM JT.ACRARHP_Date_Version_Users_Sessions
;


SELECT Bundle_Id
     , Binary_Version
     , COUNT(DISTINCT CASE WHEN Device_Type = 'ios' THEN Device_Id ELSE NULL END) AS iOSDeviceCnt
     , COUNT(DISTINCT CASE WHEN Device_Type = 'android' THEN Device_Id ELSE NULL END) AS AndroidDeviceCnt
FROM Dashboard.KPI_Login_Checkpoint_Metrics
WHERE Identifier = 'webLoginSuccess'
GROUP BY 1,2
ORDER BY 2
;

SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(BundleId) = '6139846a-5197-4f15-bdf8-2a2a4bdd28a7'
;

-- D7F58060-4C6B-4279-AA1C-B2E6FE8B50A3
-- ARM TechCon 2016
-- 10/25/2016
-- 10/27/2016

SELECT Binary_Version
     , Device_Type
     , COUNT(DISTINCT Device_Id)
     , COUNT(DISTINCT Global_User_Id)
FROM PUBLIC.Fact_Sessions_Live SESSIONS
WHERE SESSIONS.Application_Id = 'd7f58060-4c6b-4279-aa1c-b2e6fe8b50a3'
GROUP BY 1,2
;

SELECT *
FROM PUBLIC.Fact_Sessions_Live SESSIONS
WHERE SESSIONS.Application_Id = 'd7f58060-4c6b-4279-aa1c-b2e6fe8b50a3'
AND Global_User_Id = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
;
