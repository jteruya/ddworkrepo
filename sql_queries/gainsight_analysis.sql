SELECT *
FROM SalesForce.Account
WHERE UPPER(AccountName) LIKE '%GAINSIGHT%'
;

SELECT *
FROM SalesForce.Implementation
WHERE AccountId = '001E000000cQc9JIAS'
;

SELECT *
FROM EventCube.EventCubeSummary
WHERE ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
;

-- Users: 2561


-- Create Sessions Table
DROP TABLE IF EXISTS JT.GS_Sessions;
CREATE TABLE JT.GS_Sessions AS (
SELECT * FROM PUBLIC.Fact_Sessions_Live LIMIT 0)
;

DROP TABLE IF EXISTS JT.GS_Session_Duration;
CREATE TABLE JT.GS_Session_Duration (
   Application_Id VARCHAR,
   Global_User_Id VARCHAR,
   Session_Id VARCHAR,
   SessionStartTimeStamp TIMESTAMP,
   SessionEndTimeStamp TIMESTAMP,
   SessionSecDuration NUMERIC,
   PartialFlag BOOLEAN
)
;

-- Insert Raw Sessions Records
INSERT INTO JT.GS_Sessions (
   SELECT *
   FROM PUBLIC.Fact_Sessions_Live
   WHERE Application_Id = '39d51e66-eb65-4b1e-8005-9b8097745067'
);

-- Insert Session Duration Records (Full Records)
INSERT INTO JT.GS_Session_Duration (
SELECT Application_Id
     , Global_User_Id
     , Session_Id
     , MIN(To_TimeStamp(CAST(Metadata->>'Start' AS NUMERIC)/1000)) AS SessionStartTimeStamp
     , MAX(CAST(Created AS TIMESTAMP(0))) AS SessionEndTimeStamp
     , MAX(EXTRACT(EPOCH FROM CAST(CREATED AS TIMESTAMP(0)))) - MIN(CAST(Metadata->>'Start' AS NUMERIC))/1000 AS SessionSecDuration
     , FALSE AS PartialFlag
FROM JT.GS_Sessions
WHERE Identifier = 'end'
GROUP BY 1,2,3
);

-- Insert Session Duration Records (Partial Records)
INSERT INTO JT.GS_Session_Duration (
SELECT SESSIONS.Application_Id
     , SESSIONS.Global_User_Id
     , SESSIONS.Session_Id
     , MIN(CAST(Created AS TIMESTAMP(0))) AS SessionStartTimeStamp
     , MIN(CAST(Created AS TIMESTAMP(0))) AS SessionEndTimeStamp
     , 0 AS SessionSecDuration
     , TRUE AS PartialFlag
FROM JT.GS_Sessions SESSIONS
JOIN (SELECT Application_Id
           , Global_User_Id
           , Session_Id
      FROM JT.GS_Sessions
      WHERE Identifier = 'start'
      EXCEPT
      SELECT Application_Id
           , Global_User_Id
           , Session_Id
      FROM JT.GS_Sessions
      WHERE Identifier = 'end'
     ) ID
ON SESSIONS.Application_Id = ID.Application_Id
AND SESSIONS.Global_User_Id = ID.Global_User_Id
AND SESSIONS.Session_Id = ID.Session_Id
GROUP BY 1,2,3,6,7
)
;


SELECT COUNT(*)
     , COUNT(CASE WHEN PartialFlag IS TRUE THEN 1 ELSE NULL END)
FROM JT.GS_Session_Duration
;




-- User Groups Over Time
SELECT COUNT(*)
     , COUNT(CASE WHEN BeforeEventSessionCount > 0 THEN 1 ELSE NULL END) AS BeforeEventUsersCnt
     , COUNT(CASE WHEN EventSessionCount > 0 THEN 1 ELSE NULL END) AS EventUserCnt
     , COUNT(CASE WHEN BeforeEventSessionCount = 0 AND EventSessionCount > 0 THEN 1 ELSE NULL END) AS NetNewEventUserCnt
     , COUNT(CASE WHEN AfterEventSessionCount > 0 THEN 1 ELSE NULL END) AS AfterEventUsersCnt
     , COUNT(CASE WHEN BeforeEventSessionCount = 0 AND EventSessionCount = 0 AND AfterEventSessionCount > 0 THEN 1 ELSE NULL END) AS NetNewAfterEventUserCnt
FROM JT.GS_Session_User_Stats
;


-- Engagement over Time by Day (Users/Sessions)
SELECT EXTRACT(MONTH FROM SessionEndTimeStamp) || '-' || EXTRACT(DAY FROM SessionEndTimeStamp) AS MMDD
     , COUNT(*) AS SessionCount
     , COUNT(DISTINCT SESSIONS.Global_User_Id) AS UserCount
FROM JT.GS_Session_Duration SESSIONS
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0
     ) USERS
ON SESSIONS.Global_User_ID = USERS.Global_User_Id
GROUP BY 1
ORDER BY 1
;


-- DM Usage Data

-- Create DM Actions Table
DROP TABLE IF EXISTS JT.GS_DM_Actions;
CREATE TABLE JT.GS_DM_Actions AS (
SELECT * FROM PUBLIC.Fact_Actions_Live LIMIT 0)
;

-- Create DM Views Table
DROP TABLE IF EXISTS JT.GS_DM_Views;
CREATE TABLE JT.GS_DM_Views AS (
SELECT * FROM PUBLIC.Fact_Views_Live LIMIT 0)
;

-- Populate DM Actions Table
INSERT INTO JT.GS_DM_Actions (
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN Channels.Rooms ROOMS
ON CAST(ACTIONS.Metadata->>'ChannelId' AS INT) = ROOMS.Id
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0
     ) USERS
ON ACTIONS.Global_User_ID = USERS.Global_User_Id
WHERE ACTIONS.Application_Id = '39d51e66-eb65-4b1e-8005-9b8097745067'
AND ROOMS.ApplicationId = '39d51e66-eb65-4b1e-8005-9b8097745067'
AND ROOMS.Type = 'GROUP'
AND ACTIONS.Identifier = 'chatTextButton'
AND ACTIONS.Session_Id IN (SELECT DISTINCT Session_Id FROM JT.GS_Sessions)
)
;

-- Populate DM Views Table
INSERT INTO JT.GS_DM_Views (
SELECT VIEWS.*
FROM PUBLIC.Fact_Views_Live VIEWS
JOIN Channels.Rooms ROOMS
ON CAST(VIEWS.Metadata->>'ChannelId' AS INT) = ROOMS.Id
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0
     ) USERS
ON VIEWS.Global_User_ID = USERS.Global_User_Id
WHERE VIEWS.Application_Id = '39d51e66-eb65-4b1e-8005-9b8097745067'
AND ROOMS.ApplicationId = '39d51e66-eb65-4b1e-8005-9b8097745067'
AND ROOMS.Type = 'GROUP'
AND VIEWS.Identifier = 'chat'
AND VIEWS.Session_Id IN (SELECT DISTINCT Session_Id FROM JT.GS_Sessions)
)
;


-- Create User Session Table
DROP TABLE IF EXISTS JT.GS_Session_User_Stats;
CREATE TABLE JT.GS_Session_User_Stats AS (
SELECT USERS.Global_User_Id

     -- Overall Stats
     , MIN(SessionEndTimeStamp) AS FirstSessionTimeStamp
     , MAX(SessionEndTimeStamp) AS LastSessionTimeStamp
     , COUNT(CASE WHEN SESSIONS.Global_User_ID IS NOT NULL THEN 1 ELSE NULL END) AS SessionCount
     , SUM(SessionSecDuration) AS TotalDuration
     , AVG(SessionSecDuration) AS AverageSessionDuration
     
     -- Before Event Stats
     , MIN(CASE WHEN SessionEndTimeStamp < '2016-05-10' THEN SessionEndTimeStamp ELSE NULL END) AS FirstBeforeEventStartDate
     , MAX(CASE WHEN SessionEndTimeStamp < '2016-05-10' THEN SessionEndTimeStamp ELSE NULL END) AS LastBeforeEventStartDate
     , COUNT(CASE WHEN SessionEndTimeStamp < '2016-05-10' THEN 1 ELSE NULL END) AS BeforeEventSessionCount
     , SUM(CASE WHEN SessionEndTimeStamp < '2016-05-10' THEN SessionSecDuration ELSE NULL END) AS BeforeEventTotalDuration
     , AVG(CASE WHEN SessionEndTimeStamp < '2016-05-10' THEN SessionSecDuration ELSE NULL END) AS AverageBeforeEventSessionDuration
     
     -- During Event Stats
     , MIN(CASE WHEN SessionEndTimeStamp >= '2016-05-10' AND SessionEndTimeStamp < '2016-05-13' THEN SessionEndTimeStamp ELSE NULL END) AS FirstEventStartDate
     , MAX(CASE WHEN SessionEndTimeStamp >= '2016-05-10' AND SessionEndTimeStamp < '2016-05-13' THEN SessionEndTimeStamp ELSE NULL END) AS LastEventStartDate
     , COUNT(CASE WHEN SessionEndTimeStamp >= '2016-05-10' AND SessionEndTimeStamp < '2016-05-13' THEN 1 ELSE NULL END) AS EventSessionCount
     , SUM(CASE WHEN SessionEndTimeStamp >= '2016-05-10' AND SessionEndTimeStamp < '2016-05-13' THEN SessionSecDuration ELSE NULL END) AS EventTotalDuration     
     , AVG(CASE WHEN SessionEndTimeStamp >= '2016-05-10' AND SessionEndTimeStamp < '2016-05-13' THEN SessionSecDuration ELSE NULL END) AS AverageEventSessionDuration   
     
     -- After Event Stats
     , MIN(CASE WHEN SessionEndTimeStamp >= '2016-05-13' THEN SessionEndTimeStamp ELSE NULL END) AS FirstAfterEventStartDate
     , MAX(CASE WHEN SessionEndTimeStamp >= '2016-05-13' THEN SessionEndTimeStamp ELSE NULL END) AS LastAfterEventStartDate
     , COUNT(CASE WHEN SessionEndTimeStamp >= '2016-05-13' THEN 1 ELSE NULL END) AS AfterEventSessionCount
     , SUM(CASE WHEN SessionEndTimeStamp >= '2016-05-13' THEN SessionSecDuration ELSE NULL END) AS AfterEventTotalDuration       
     , AVG(CASE WHEN SessionEndTimeStamp >= '2016-05-13' THEN SessionSecDuration ELSE NULL END) AS AverageAfterEventSessionDuration     
       
FROM (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0
     ) USERS
LEFT JOIN JT.GS_Session_Duration SESSIONS
ON SESSIONS.Global_User_ID = USERS.Global_User_Id
GROUP BY 1
)
;

-- Create User DM Table
DROP TABLE IF EXISTS JT.GS_DM_User_Stats;
CREATE TABLE JT.GS_DM_User_Stats AS (
SELECT USERS.Global_User_Id
     , COALESCE(CHATVIEW.DMChatView,0) AS DMChatView
     , COALESCE(CHATVIEW.DMChatViewUsers,0) AS DMChatViewUsers
     , COALESCE(CHATACTIONS.DMChatMsgEntry,0) AS DMChatMsgEntry
     , COALESCE(CHATACTIONS.DMChatMsgEntryUsers,0) AS DMChatMsgEntryUsers
     , COALESCE(CHATACTIONS.DMChatMsgSend,0) AS DMChatMsgSend
     , COALESCE(CHATACTIONS.DMChatMsgSendUsers,0) AS DMChatMsgSendUsers     
     , COALESCE(CHATACTIONSRCVD.DMChatMsgRcvd,0) AS DMChatMsgRcvd
     , COALESCE(CHATACTIONSRCVD.DMChatMsgRcvdFromUsers, 0) AS DMChatMsgRcvdFromUsers
FROM (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0
     ) USERS
LEFT JOIN (SELECT Global_User_Id
                , COUNT(*) AS DMChatView
                , COUNT(DISTINCT Metadata->>'ChannelId') AS DMChatViewUsers
           FROM JT.GS_DM_Views
           GROUP BY 1
          ) CHATVIEW
ON USERS.Global_User_Id = CHATVIEW.Global_User_Id
LEFT JOIN (SELECT Global_User_Id
                , COUNT(CASE WHEN Metadata->>'Type' = 'entry' THEN 1 ELSE NULL END) AS DMChatMsgEntry
                , COUNT(DISTINCT CASE WHEN Metadata->>'Type' = 'entry' THEN Metadata->>'ChannelId' ELSE NULL END) AS DMChatMsgEntryUsers
                , COUNT(CASE WHEN Metadata->>'Type' = 'submit' THEN 1 ELSE NULL END) AS DMChatMsgSend
                , COUNT(DISTINCT CASE WHEN Metadata->>'Type' = 'submit' THEN Metadata->>'ChannelId' ELSE NULL END) AS DMChatMsgSendUsers                
           FROM JT.GS_DM_Actions 
           GROUP BY 1
          ) CHATACTIONS
ON USERS.Global_User_Id = CHATACTIONS.Global_User_Id    
LEFT JOIN (SELECT USERRCVD.Global_User_Id
                , COUNT(*) AS DMChatMsgRcvd
                , COUNT(DISTINCT CHATACTIONS.Global_User_Id) AS DMChatMsgRcvdFromUsers
           FROM JT.GS_DM_Actions CHATACTIONS
           JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
                      , UserId
                 FROM PUBLIC.AuthDB_IS_Users
                 WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
                ) USERSEND
           ON CHATACTIONS.Global_User_Id = USERSEND.Global_User_Id
           JOIN Channels.Members MEMBERS
           ON CAST(CHATACTIONS.Metadata->>'ChannelId' AS INT) = MEMBERS.ChannelId
           AND USERSEND.UserId <> MEMBERS.UserId
           JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
                      , UserId
                 FROM PUBLIC.AuthDB_IS_Users
                 WHERE ApplicationID = '39D51E66-EB65-4B1E-8005-9B8097745067'
                 AND IsDisabled = 0
                ) USERRCVD
           ON MEMBERS.UserId = USERRCVD.UserId
           WHERE CHATACTIONS.Metadata->>'Type' = 'submit'
           GROUP BY 1
          ) CHATACTIONSRCVD
ON USERS.Global_User_Id = CHATACTIONSRCVD.Global_User_Id
)
;


-- Topic Channels
-- Session Channels
-- Session Notes



-- Bookmarking
-- Follows
-- Likes
-- Surveys

--Status Updates, Likes, Comments, Check-Ins, Bookmarks, Item Ratings, Follows, Poll Responses, Survey Responses

DROP TABLE IF EXISTS JT.GS_Suspect_Engagement_User_Stats;
CREATE TABLE JT.GS_Suspect_Engagement_User_Stats AS (
SELECT USERS.Global_User_Id
     , USERS.UserId
     , COALESCE(STATUS_UPDATES.StatusUpdateCount, 0) AS StatusUpdateCount
     , COALESCE(CHECKINS.CheckInCount, 0) AS CheckInCount
     , COALESCE(LIKES.LikeCount, 0) AS LikeCount
     , COALESCE(COMMENTS.CommentCount, 0) AS CommentCount
     , COALESCE(BOOKMARKS.BookmarkCount, 0) AS BookmarkCount
     , COALESCE(FOLLOWS.FollowCount, 0) AS FollowCount
     , COALESCE(ITEM_RATINGS.ItemRatingCount, 0) AS ItemRatingCount
     , SESSIONS.SessionCount 
     , CAST(SESSIONS.TotalDuration AS BIGINT)
     , CAST(SESSIONS.AverageSessionDuration AS BIGINT)
FROM (SELECT DISTINCT LOWER(GlobalUserId) AS Global_User_Id
           , UserId
      FROM PUBLIC.AuthDB_IS_Users
      WHERE ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
      AND IsDisabled = 0) USERS
LEFT JOIN (SELECT CHECKINS.UserId
                , COUNT(*) AS StatusUpdateCount
           FROM PUBLIC.Ratings_UserCheckIns CHECKINS
           JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
           ON CHECKINS.CheckInId = NOTES.CheckInId
           WHERE CHECKINS.ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           GROUP BY 1
          ) STATUS_UPDATES
ON USERS.UserId = STATUS_UPDATES.UserId
LEFT JOIN (SELECT CHECKINS.UserId
                , COUNT(*) AS CheckInCount
           FROM PUBLIC.Ratings_UserCheckIns CHECKINS
           JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
           ON CHECKINS.CheckInId = NOTES.CheckInId
           WHERE CHECKINS.ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           AND ITEMID <> 1
           GROUP BY 1
          ) CHECKINS
ON USERS.UserId = CHECKINS.UserId
LEFT JOIN (SELECT CHECKINS.UserId
                , COUNT(*) AS LikeCount
           FROM PUBLIC.Ratings_UserCheckIns CHECKINS
           JOIN PUBLIC.Ratings_UserCheckInLikes LIKES
           ON CHECKINS.CheckInId = LIKES.CheckInId
           WHERE CHECKINS.ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           GROUP BY 1
          ) LIKES
ON USERS.UserId = LIKES.UserId
LEFT JOIN (SELECT CHECKINS.UserId
                , COUNT(*) AS CommentCount
           FROM PUBLIC.Ratings_UserCheckIns CHECKINS
           JOIN PUBLIC.Ratings_UserCheckInComments COMMENTS
           ON CHECKINS.CheckInId = COMMENTS.CheckInId
           WHERE CHECKINS.ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           GROUP BY 1
          ) COMMENTS
ON USERS.UserId = COMMENTS.UserId
-- Add Check-ins (after research)
LEFT JOIN (SELECT UserId
                , COUNT(*) AS BookmarkCount
           FROM PUBLIC.Ratings_UserFavorites
           WHERE ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           GROUP BY 1
          ) BOOKMARKS
ON USERS.UserId = BOOKMARKS.UserId
LEFT JOIN (SELECT UserId
                , COUNT(*) AS FollowCount
           FROM PUBLIC.Ratings_UserTrust
           GROUP BY 1
          ) FOLLOWS
ON USERS.UserId = FOLLOWS.UserId
LEFT JOIN (SELECT UserId
                , COUNT(*) AS ItemRatingCount
           FROM PUBLIC.Ratings_ItemRatings
           WHERE ApplicationId = '39D51E66-EB65-4B1E-8005-9B8097745067'
           GROUP BY 1
          ) ITEM_RATINGS
ON USERS.UserId = ITEM_RATINGS.UserId
JOIN JT.GS_Session_User_Stats SESSIONS
ON USERS.Global_User_Id = SESSIONS.Global_User_Id
-- No Surveys/Polls for Gainsight Pulse 2016
WHERE SESSIONS.SessionCount > 0   
)                  
;

SELECT *
FROM JT.GS_Suspect_Engagement_User_Stats
;

SELECT CORR(SESSIONS.SessionCount, USERS.DMChatView)
     , CORR(SESSIONS.SessionCount, USERS.DMChatViewUsers)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgEntry)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgEntryUsers)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgSend)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgSendUsers)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgRcvd)
     , CORR(SESSIONS.SessionCount, USERS.DMChatMsgRcvdFromUsers)

     , CORR(SESSIONS.TotalDuration, USERS.DMChatView)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatViewUsers)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgEntry)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgEntryUsers)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgSend)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgSendUsers)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgRcvd)
     , CORR(SESSIONS.TotalDuration, USERS.DMChatMsgRcvdFromUsers)

     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatView)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatViewUsers)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgEntry)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgEntryUsers)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgSend)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgSendUsers)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgRcvd)
     , CORR(SESSIONS.AverageSessionDuration, USERS.DMChatMsgRcvdFromUsers)

FROM JT.GS_Session_User_Stats SESSIONS
JOIN JT.GS_DM_User_Stats USERS
ON SESSIONS.Global_User_Id = USERS.Global_User_Id
;






SELECT DISTINCT TotalDuration
FROM JT.GS_Suspect_Engagement_User_Stats



