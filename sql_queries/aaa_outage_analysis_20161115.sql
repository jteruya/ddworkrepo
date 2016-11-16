SELECT LOWER(BundleId)
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(ApplicationId) = '0aac5c1a-7651-4af7-a8d5-002bcee97098'
;
-- BundleId: F523A7C9-B61E-40FD-8522-A47BFA59A437

SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE BundleId = 'F523A7C9-B61E-40FD-8522-A47BFA59A437'
;

SELECT COUNT(*)
     , COUNT(CASE WHEN LoginFlowStartInitialMinDate IS NOT NULL OR EnterEmailMinDate IS NOT NULL THEN 1 ELSE NULL END)
FROM Dashboard.KPI_Login_Devices_Checklist
WHERE Bundle_Id = 'f523a7c9-b61e-40fd-8522-a47bfa59a437'
;
-- 652
-- 644




-- Get Device/User Sessions Aggs
DROP TABLE IF EXISTS JT.AAA_Sessions;
CREATE TABLE JT.AAA_Sessions AS
SELECT Device_Id
     , Global_User_Id
     , MIN(Created) AS FirstSessionDate
     , COUNT(DISTINCT Session_Id) AS SessionCnt
FROM PUBLIC.Fact_Sessions_Live
WHERE Application_Id = '0aac5c1a-7651-4af7-a8d5-002bcee97098'
GROUP BY 1,2
;

-- Get Device/User/Created Sessions Aggs
DROP TABLE IF EXISTS JT.AAA_Sessions_Date;
CREATE TABLE JT.AAA_Sessions_Date AS
SELECT Device_Id
     , Global_User_Id
     , Created::DATE AS SessionDate
     , COUNT(DISTINCT Session_Id) AS SessionCnt
FROM PUBLIC.Fact_Sessions_Live
WHERE Application_Id = '0aac5c1a-7651-4af7-a8d5-002bcee97098'
GROUP BY 1,2,3
;

DROP TABLE IF EXISTS JT.AAA_Actions_Date;
CREATE TABLE JT.AAA_Actions_Date AS
SELECT Device_Id
     , Global_User_Id
     , Created::DATE AS ActionDate
     , COUNT(*) AS ActionCnt
FROM PUBLIC.Fact_Actions_Live
WHERE Application_Id = '0aac5c1a-7651-4af7-a8d5-002bcee97098'
GROUP BY 1,2,3
;


-- Get Device/User Activity Feed Aggs
DROP TABLE IF EXISTS JT.AAA_ActivityFeed;
CREATE TABLE JT.AAA_ActivityFeed AS
SELECT Device_Id
     , Global_User_Id
     , MIN(Created) AS FirstViewDate
FROM PUBLIC.Fact_Views_Live
WHERE Application_Id = '0aac5c1a-7651-4af7-a8d5-002bcee97098'
AND Identifier = 'activities'
GROUP BY 1,2
;

-- Get Unique Non-Disabled Users
DROP TABLE IF EXISTS JT.AAA_Users;
CREATE TABLE JT.AAA_Users AS
SELECT DISTINCT UserId
     , GlobalUserId
FROM PUBLIC.AuthDB_IS_Users
WHERE ApplicationId = '0AAC5C1A-7651-4AF7-A8D5-002BCEE97098'
AND IsDisabled = 0
;

-- Get Device/Users XREF
DROP TABLE IF EXISTS JT.AAA_Device_Users_XREF;
CREATE TABLE JT.AAA_Device_Users_XREF AS
SELECT DISTINCT DEVICES.Device_Id
     , SESSIONS.Global_User_Id
     , CASE 
          WHEN USERS.GlobalUserId IS NOT NULL THEN 0
          WHEN SESSIONS.Global_User_Id IS NOT NULL AND USERS.GlobalUserId IS NULL THEN 1
          ELSE NULL
       END AS IsDisabled
FROM Dashboard.KPI_Login_Devices_Checklist DEVICES
LEFT JOIN JT.AAA_Sessions SESSIONS
ON DEVICES.Device_Id = SESSIONS.Device_Id
LEFT JOIN  JT.AAA_Users USERS
ON SESSIONS.Global_User_Id = LOWER(USERS.GlobalUserId)
WHERE DEVICES.Bundle_Id = 'f523a7c9-b61e-40fd-8522-a47bfa59a437'
;

-- Get Device/Users Funnel
DROP TABLE IF EXISTS JT.AAA_Device_Users_Funnel;
CREATE TABLE JT.AAA_Device_Users_Funnel AS
SELECT XREF.Global_User_Id, XREF.IsDisabled, DEVICES.*
     , CASE 
          WHEN FEEDS.Device_Id IS NOT NULL THEN 1 
          WHEN FEEDS.Device_Id IS NULL AND XREF.Device_Id IS NOT NULL THEN 0 
          ELSE NULL 
       END AS ActivityFeedFlag
FROM Dashboard.KPI_Login_Devices_Checklist DEVICES
LEFT JOIN JT.AAA_Device_Users_XREF XREF
ON DEVICES.Device_Id = XREF.Device_Id
LEFT JOIN JT.AAA_ActivityFeed FEEDS
ON DEVICES.Device_Id = FEEDS.Device_Id AND XREF.Global_User_Id = FEEDS.Global_User_Id
WHERE DEVICES.Bundle_Id = 'f523a7c9-b61e-40fd-8522-a47bfa59a437'
;

SELECT Global_User_Id
     , IsDisabled
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN ActivityFeedFlag = 1 THEN 1 ELSE NULL END) AS DeviceSuccessCnt
FROM JT.AAA_Device_Users_Funnel
WHERE Global_User_Id IS NOT NULL
GROUP BY 1,2
;

SELECT COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE AS YYYYMMDD
     , COUNT(*) AS DeviceTotal
     , COUNT(CASE WHEN Global_User_Id IS NULL THEN 1 ELSE NULL END) AS NoUserDeviceTotal
     , COUNT(CASE WHEN Global_User_Id IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS NoUserDevicePct
     , COUNT(CASE WHEN Global_User_Id IS NOT NULL THEN 1 ELSE NULL END) AS UserDeviceTotal 
     , COUNT(CASE WHEN Global_User_Id IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS UserDevicePct
FROM JT.AAA_Device_Users_Funnel
WHERE (IsDisabled = 0 OR IsDisabled IS NULL)
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE >= '2016-11-05'
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE <= '2016-11-09'
GROUP BY 1
ORDER BY 1
;


-- Devices that don't make it
SELECT COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE AS YYYYMMDD
     , COUNT(*) AS DeviceCnt
     , 
FROM JT.AAA_Device_Users_Funnel
WHERE Global_User_Id IS NULL
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE >= '2016-11-05'
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE <= '2016-11-09'
GROUP BY 1
ORDER BY 1
;


-- Devices that do have a user
SELECT COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE AS YYYYMMDD
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN ActivityFeedFlag = 1 THEN 1 ELSE NULL END) AS SuccessDeviceCnt
     , COUNT(CASE WHEN ActivityFeedFlag = 0 THEN 1 ELSE NULL END) AS NotSuccessDeviceCnt
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(DISTINCT CASE WHEN ActivityFeedFlag = 1 THEN Global_User_Id ELSE NULL END) AS SuccessUserCnt
     , COUNT(DISTINCT CASE WHEN ActivityFeedFlag = 0 THEN Global_User_Id ELSE NULL END) AS NotSuccessUserCnt
FROM JT.AAA_Device_Users_Funnel
WHERE Global_User_Id IS NOT NULL AND IsDisabled = 0
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE >= '2016-11-05'
AND COALESCE(LoginFlowStartInitialMinDate, EnterEmailMinDate, AccountPickerMinDate)::DATE <= '2016-11-09'
GROUP BY 1
ORDER BY 1
;

-- Session and Actions Agg per day
SELECT SESSIONS.SessionDate
     , COUNT(*) AS DeviceCnt
     , COUNT(DISTINCT SESSIONS.Global_User_Id) AS UserCnt
     , SUM(SESSIONS.SessionCnt) AS TotalSessionCnt
     , AVG(SESSIONS.SessionCnt) AS AvgSessionCnt
     , SUM(ACTIONS.ActionCnt) AS TotalActionCnt
     , AVG(ACTIONS.ActionCnt) AS AvgActionCnt
FROM (SELECT SESSIONS.*
      FROM JT.AAA_Sessions_Date SESSIONS
      JOIN JT.AAA_Device_Users_XREF XREF
      ON SESSIONS.Device_Id = XREF.Device_Id AND SESSIONS.Global_User_Id = XREF.Global_User_Id
      WHERE XREF.IsDisabled = 0
     ) SESSIONS
LEFT JOIN (SELECT ACTIONS.*
           FROM JT.AAA_Actions_Date ACTIONS
           JOIN JT.AAA_Device_Users_XREF XREF
           ON ACTIONS.Device_Id = XREF.Device_Id AND ACTIONS.Global_User_Id = XREF.Global_User_Id
           WHERE XREF.IsDisabled = 0
          ) ACTIONS
ON SESSIONS.Global_User_Id = ACTIONS.Global_User_Id AND SESSIONS.Device_Id = ACTIONS.Device_Id AND SESSIONS.SessionDate = ACTIONS.ActionDate
WHERE SESSIONS.SessionDate >= '2016-11-05'
AND SESSIONS.SessionDate <= '2016-11-09'
GROUP BY 1
ORDER BY 1
;


