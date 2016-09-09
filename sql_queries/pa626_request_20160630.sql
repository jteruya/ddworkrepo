-- Check to Make Sure this is an EU Event
SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(ApplicationId) = 'a3f2923e-03b7-43f8-b577-2525a084c71e'
;

-- Create a Temporary Table with Users (Non-Disabled) and Counts in DM Rooms
CREATE TEMPORARY TABLE UserDirectMessagesSent AS
SELECT ACTIONS.Global_User_Id
     , COUNT(*) AS MessageSentCnt
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN (SELECT *
      FROM Channels.Rooms
      WHERE ApplicationId = 'a3f2923e-03b7-43f8-b577-2525a084c71e'
      AND Type = 'GROUP') ROOMS
ON CAST(ACTIONS.Metadata->>'ChannelId' AS INT) = ROOMS.Id
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS GlobalUserId
      FROM PUBLIC.AuthDB_IS_Users
      WHERE LOWER(ApplicationId) = 'a3f2923e-03b7-43f8-b577-2525a084c71e'
      AND IsDisabled = 0) USERS
ON ACTIONS.Global_User_Id = USERS.GlobalUserId
WHERE ACTIONS.Application_Id = 'a3f2923e-03b7-43f8-b577-2525a084c71e'
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