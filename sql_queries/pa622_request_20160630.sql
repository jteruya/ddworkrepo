-- Check to Make Sure this is an EU Event
SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(ApplicationId) = '93c9bbec-3e27-4045-977e-ad3f8316db86'
;

-- Create a Temporary Table with Users (Non-Disabled) and Counts in DM Rooms
CREATE TEMPORARY TABLE UserDirectMessagesSent AS
SELECT ACTIONS.Global_User_Id
     , COUNT(*) AS MessageSentCnt
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN (SELECT *
      FROM Channels.Rooms
      WHERE ApplicationId = '93c9bbec-3e27-4045-977e-ad3f8316db86'
      AND Type = 'GROUP') ROOMS
ON CAST(ACTIONS.Metadata->>'ChannelId' AS INT) = ROOMS.Id
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS GlobalUserId
      FROM PUBLIC.AuthDB_IS_Users
      WHERE LOWER(ApplicationId) = '93c9bbec-3e27-4045-977e-ad3f8316db86'
      AND IsDisabled = 0) USERS
ON ACTIONS.Global_User_Id = USERS.GlobalUserId
WHERE ACTIONS.Application_Id = '93c9bbec-3e27-4045-977e-ad3f8316db86'
AND ACTIONS.Identifier = 'chatTextButton'
AND ACTIONS.Metadata->>'Type' = 'submit'
GROUP BY 1
;

-- Get Results
SELECT COUNT(*) AS UserCnt
     , AVG(MessageSentCnt) AS MessageSentAvgCnt
     , SUM(MessageSentCnt) AS TotalMessageSentCnt
FROM UserDirectMessagesSent
;