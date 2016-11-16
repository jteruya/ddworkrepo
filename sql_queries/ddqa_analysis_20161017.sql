-- Get Finished 2016 Events
DROP TABLE IF EXISTS JT.QAEvents;
CREATE TABLE JT.QAEvents AS
SELECT ECS.*
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
--AND ECS.EndDate < CURRENT_DATE
;

-- Get All Non-Disabled Event Sessions
DROP TABLE IF EXISTS JT.QAEventSessions;
CREATE TABLE JT.QAEventSessions AS
SELECT ITEMS.*
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN JT.QAEvents EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId AND TOPICS.ApplicationId = EVENTS.ApplicationId
WHERE TOPICS.ListTypeId = 2
AND ITEMS.IsDisabled = 0
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = 'false'
;

-- Event/Item Level Agg
DROP TABLE IF EXISTS JT.QAEventSessionFlag;
CREATE TABLE JT.QAEventSessionFlag AS
SELECT EVENTS.ApplicationId
     , SESSIONS.ItemId
     , CASE WHEN SESSIONS.ApplicationId IS NOT NULL AND Description ILIKE '%vote.doubledutch.me%' THEN 1 ELSE 0 END AS QASessionFlag
FROM JT.QAEvents EVENTS 
LEFT JOIN JT.QAEventSessions SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
;

-- Get all (DD Votes) web views from the events.
DROP TABLE IF EXISTS JT.QAEventSessionViews;
CREATE TABLE JT.QAEventSessionViews AS
SELECT VIEWS.*
FROM PUBLIC.Fact_Views_Live VIEWS
JOIN JT.QAEvents EVENTS
ON VIEWS.Application_Id = LOWER(EVENTS.ApplicationId)
WHERE VIEWS.Identifier = 'web'
AND VIEWS.Metadata->>'Url' ILIKE '%vote.doubledutch.me%'
;

-- Agg all clicks and users of URL for each events
DROP TABLE IF EXISTS JT.QAEventClickAgg;
CREATE TABLE JT.QAEventClickAgg AS
SELECT SESSIONS.ApplicationId
     , COUNT(*) AS SessionCnt
     , COUNT(CASE WHEN QASessionFlag = 1 THEN 1 ELSE NULL END) AS QASessionCnt
     , COUNT(DISTINCT CASE WHEN CLICKS.Global_User_Id IS NOT NULL THEN CLICKS.Global_User_Id  ELSE NULL END) AS UserCnt
     , COUNT(CASE WHEN CLICKS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS TapCnt
FROM JT.QAEventSessionFlag SESSIONS
LEFT JOIN (SELECT Application_Id
                , Global_User_Id
                , Metadata->>'Url'
                , CASE 
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 73 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 72 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) = '' THEN -1
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 72 for 8) = '' THEN -1
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') = 0 AND SUBSTRING(Metadata->>'Url' from 68 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 68 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') = 0 AND SUBSTRING(Metadata->>'Url' from 67 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 67 for 8)::INT
                     ELSE 0
                  END AS ItemId
                FROM JT.QAEventSessionViews
          ) CLICKS
ON CLICKS.ItemId = SESSIONS.ItemId AND SESSIONS.ApplicationId = UPPER(CLICKS.Application_Id)
GROUP BY 1
;


-- Agg all clicks and users of URL for each Session (just in case but no necessarily used)
DROP TABLE IF EXISTS JT.QAEventSessionClickAgg;
CREATE TABLE JT.QAEventSessionClickAgg AS
SELECT SESSIONS.ApplicationId
     , SESSIONS.ItemId
     , SESSIONS.QASessionFlag
     , COUNT(DISTINCT CASE WHEN CLICKS.Global_User_Id IS NOT NULL THEN CLICKS.Global_User_Id  ELSE NULL END) AS UserCnt
     , COUNT(CASE WHEN CLICKS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS TapCnt
FROM JT.QAEventSessionFlag SESSIONS
LEFT JOIN (SELECT Application_Id
                , Global_User_Id
                , Metadata->>'Url'
                , CASE 
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 73 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 72 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 73 for 8) = '' THEN -1
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') > 0 AND SUBSTRING(Metadata->>'Url' from 72 for 8) = '' THEN -1
                     WHEN Metadata->>'Url' ILIKE '%https://%' AND POSITION('$' IN Metadata->>'Url') = 0 AND SUBSTRING(Metadata->>'Url' from 68 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 68 for 8)::INT
                     WHEN Metadata->>'Url' ILIKE '%http://%' AND POSITION('$' IN Metadata->>'Url') = 0 AND SUBSTRING(Metadata->>'Url' from 67 for 8) <> '' THEN SUBSTRING(Metadata->>'Url' from 67 for 8)::INT
                     ELSE 0
                  END AS ItemId
                FROM JT.QAEventSessionViews
          ) CLICKS
ON CLICKS.ItemId = SESSIONS.ItemId AND SESSIONS.ApplicationId = UPPER(CLICKS.Application_Id)
GROUP BY 1,2,3
;



-- Event Count/Percent Breakdown
SELECT COUNT(*) AS EventCnt
     , COUNT(CASE WHEN AGG.QASessionCnt > 0 THEN 1 ELSE NULL END) AS QAEventCnt
     , COUNT(CASE WHEN AGG.QASessionCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS QAEventPct
FROM JT.QAEventClickAgg AGG
JOIN JT.QAEvents EVENTS
ON AGG.ApplicationId = EVENTS.ApplicationId
;
-- Event: 2531
-- QA Event: 115
-- QA Event %: 4.54%
 
-- Average % of Sessions and Active Users for events with DDQA 
SELECT AVG(AGG.QASessionCnt::DECIMAL(12,4)/AGG.SessionCnt::DECIMAL(12,4)) AS AvgSessions
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AGG.QASessionCnt::DECIMAL(12,4)/AGG.SessionCnt::DECIMAL(12,4)) AS MedianSessions
     , AVG(AGG.UserCnt::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4)) AS AvgActiveUsers
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AGG.UserCnt::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4)) AS MedianActiveUsers
FROM JT.QAEventClickAgg AGG
JOIN JT.QAEvents EVENTS
ON AGG.ApplicationId = EVENTS.ApplicationId
WHERE QASessionCnt > 0
;

-- Event Level Breakdown for events with DDQA 
SELECT AGG.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , EVENTS.UsersActive
     , AGG.SessionCnt
     , AGG.QASessionCnt
     , AGG.QASessionCnt::DECIMAL(12,4)/AGG.SessionCnt::DECIMAL(12,4) AS QASessionPct
     , AGG.UserCnt AS QAUserCnt
     , AGG.TapCnt AS QATapCnt
     , AGG.UserCnt::DECIMAL(12,4)/EVENTS.UsersActive::DECIMAL(12,4) AS UsersActivePct
FROM JT.QAEventClickAgg AGG
JOIN JT.QAEvents EVENTS
ON AGG.ApplicationId = EVENTS.ApplicationId
WHERE QASessionCnt > 0
ORDER BY 3,4
;




-- Future Events
DROP TABLE IF EXISTS JT.QAFutureEvents;
CREATE TABLE JT.QAFutureEvents AS
SELECT ECS.*
     , A.AccountId
     , A.AccountName
FROM EventCube.EventCubeSummary ECS
JOIN SalesForce.Implementation I
ON ECS.ApplicationId = UPPER(I.ApplicationId)
JOIN SalesForce.Account A
ON I.AccountId = A.AccountId
WHERE ECS.StartDate >= CURRENT_DATE
;

-- Future Events (EU)
DROP TABLE IF EXISTS JT.QAFutureEvents;
CREATE TABLE JT.QAFutureEvents AS
SELECT ECS.*
     , ACCOUNTS.Account18CharId
FROM EventCube.EventCubeSummary ECS
JOIN JT.Accounts ACCOUNTS
ON ECS.ApplicationId = ACCOUNTS.ApplicationId
WHERE ECS.StartDate >= CURRENT_DATE
;


-- Future Events' Sessions
DROP TABLE IF EXISTS JT.QAFutureEventSessions;
CREATE TABLE JT.QAFutureEventSessions AS
SELECT ITEMS.*
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN JT.QAFutureEvents EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId AND TOPICS.ApplicationId = EVENTS.ApplicationId
WHERE TOPICS.ListTypeId = 2
AND ITEMS.IsDisabled = 0
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = 'false'
;

-- Future Event/Item Level Agg
DROP TABLE IF EXISTS JT.QAFutureEventSessionFlag;
CREATE TABLE JT.QAFutureEventSessionFlag AS
SELECT EVENTS.ApplicationId
     , SESSIONS.ItemId
     , CASE WHEN SESSIONS.ApplicationId IS NOT NULL AND Description ILIKE '%vote.doubledutch.me%' THEN 1 ELSE 0 END AS QASessionFlag
FROM JT.QAFutureEvents EVENTS 
LEFT JOIN JT.QAFutureEventSessions SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
;


-- Account Event Level w/only 
DROP TABLE IF EXISTS JT.QAFutureAccountEventSession;
CREATE TABLE JT.QAFutureAccountEventSession AS
SELECT EVENTS.AccountId
     , EVENTS.AccountName
     , ACCOUNTS.DiamondAccount
     , ACCOUNTS.DiamondScore
     , ACCOUNTS.PlatformTier
     , EVENTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , COUNT(CASE WHEN SESSIONS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS SessionCnt
     , COUNT(CASE WHEN SESSIONS.QASessionFlag IS NOT NULL AND SESSIONS.QASessionFlag = 1 THEN 1 ELSE NULL END) AS QASessionCnt
FROM JT.QAFutureEvents EVENTS
JOIN JT.Accounts ACCOUNTS
ON EVENTS.AccountId = ACCOUNTS.Account18CharId AND EVENTS.ApplicationId = UPPER(ACCOUNTS.ApplicationId)
LEFT JOIN JT.QAFutureEventSessionFlag SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
WHERE AccountName NOT ILIKE '%DoubleDutch%'
GROUP BY 1,2,3,4,5,6,7,8,9
;

-- Account Event Level w/only  (EU)
DROP TABLE IF EXISTS JT.QAFutureAccountEventSession;
CREATE TABLE JT.QAFutureAccountEventSession AS
SELECT EVENTS.Account18CharId
     --, EVENTS.AccountName
     , ACCOUNTS.DiamondAccount
     , ACCOUNTS.DiamondScore
     , ACCOUNTS.PlatformTier
     , EVENTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , COUNT(CASE WHEN SESSIONS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS SessionCnt
     , COUNT(CASE WHEN SESSIONS.QASessionFlag IS NOT NULL AND SESSIONS.QASessionFlag = 1 THEN 1 ELSE NULL END) AS QASessionCnt
FROM JT.QAFutureEvents EVENTS
JOIN JT.Accounts ACCOUNTS
ON EVENTS.Account18CharId = ACCOUNTS.Account18CharId AND EVENTS.ApplicationId = UPPER(ACCOUNTS.ApplicationId)
LEFT JOIN JT.QAFutureEventSessionFlag SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
GROUP BY 1,2,3,4,5,6,7,8
;

-- Event Breakdown (Attachment)
SELECT *
FROM JT.QAFutureAccountEventSession
WHERE QASessionCnt > 0
ORDER BY StartDate, EndDate
;

-- Diamond Account Breakdown
SELECT CASE
         WHEN DiamondAccount = 0 THEN 'Non-Diamond Account'
         ELSE 'Diamond Account'
       END AS AccountType
     , COUNT(*) AS EventCnt
FROM JT.QAFutureAccountEventSession
WHERE QASessionCnt > 0
GROUP BY 1
ORDER BY 2 DESC
;

-- US
--Diamond Account	10
--Non-Diamond Account	5

-- Nondiamond Account
SELECT PlatformTier
     , COUNT(*) AS EventCnt
FROM JT.QAFutureAccountEventSession
WHERE QASessionCnt > 0
GROUP BY 1
ORDER BY 2 DESC
;

--Standard Platform	4
--Premium	4
--Legacy: Basic	2
--Enterprise	1
--Standard Price Book	1
--Legacy: Enterprise	1
--Basic	1
--Enterprise Platform	1



-- Get All Events
DROP TABLE IF EXISTS JT.QAAllEvents;
CREATE TABLE JT.QAAllEvents AS
SELECT EVENTS.*
     , A.AccountId
     , A.AccountName
     , ACCOUNTS.DiamondAccount
     , ACCOUNTS.DiamondScore
     , ACCOUNTS.PlatformTier
FROM PUBLIC.AuthDB_Applications EVENTS
JOIN SalesForce.Implementation I
ON EVENTS.ApplicationId = UPPER(I.ApplicationId)
JOIN SalesForce.Account A
ON I.AccountId = A.AccountId
JOIN JT.Accounts ACCOUNTS
ON A.AccountId = ACCOUNTS.Account18CharId AND EVENTS.ApplicationId = UPPER(ACCOUNTS.ApplicationId)
WHERE AccountName NOT ILIKE '%DoubleDutch%'
;


-- Get All Non-Disabled Event Sessions
DROP TABLE IF EXISTS JT.QAAllEventSessions;
CREATE TABLE JT.QAAllEventSessions AS
SELECT ITEMS.*
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN JT.QAAllEvents EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId AND TOPICS.ApplicationId = EVENTS.ApplicationId
WHERE TOPICS.ListTypeId = 2
AND ITEMS.IsDisabled = 0
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = 'false'
;

SELECT *
FROM JT.QAAllEventSessions
;

-- Event/Item Level Agg
DROP TABLE IF EXISTS JT.QAAllEventSessionFlag;
CREATE TABLE JT.QAAllEventSessionFlag AS
SELECT EVENTS.ApplicationId
     , SESSIONS.ItemId
     , CASE WHEN SESSIONS.ApplicationId IS NOT NULL AND SESSIONS.Description ILIKE '%vote.doubledutch.me%' THEN 1 ELSE 0 END AS QASessionFlag
FROM JT.QAAllEvents EVENTS 
LEFT JOIN JT.QAAllEventSessions SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
;

DROP TABLE IF EXISTS JT.QAAllEventSessionAgg;
CREATE TABLE JT.QAAllEventSessionAgg AS
SELECT EVENTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , EVENTS.AccountId
     , EVENTS.AccountName
     , EVENTS.DiamondAccount
     , EVENTS.DiamondScore
     , EVENTS.PlatformTier
     , COUNT(CASE WHEN SESSIONS.ItemId IS NOT NULL THEN 1 ELSE NULL END) AS SessionCnt
     , COUNT(CASE WHEN SESSIONS.QASessionFlag = 1 THEN 1 ELSE NULL END) AS QASessionCnt
FROM JT.QAAllEvents EVENTS
LEFT JOIN JT.QAAllEventSessionFlag SESSIONS
ON EVENTS.ApplicationId = SESSIONS.ApplicationId
GROUP BY 1,2,3,4,5,6,7,8,9
ORDER BY 3,4
;


SELECT AccountId
     , AccountName
     , COUNT(*)
FROM JT.QAAllEventSessionAgg
WHERE EndDate < CURRENT_DATE
GROUP BY 1,2
;

DROP TABLE QAAllEventFutureMaybe;
CREATE TEMPORARY TABLE QAAllEventFutureMaybe AS
SELECT AGG.*
     , CASE WHEN ACCT.PastEventCnt > 0 THEN 1 ELSE 0 END AS Flag
FROM JT.QAAllEventSessionAgg AGG
LEFT JOIN (SELECT AccountId
                , COUNT(*) AS PastEventCnt
           FROM JT.QAAllEventSessionAgg
           WHERE EndDate < CURRENT_DATE
           AND QASessionCnt > 0
           GROUP BY 1
          ) ACCT
ON AGG.AccountId = ACCT.AccountId
WHERE StartDate >= CURRENT_DATE
AND QASessionCnt = 0
ORDER BY StartDate, EndDate
;

SELECT AccountId
     , AccountName
     , DiamondAccount
     , DiamondScore
     , PlatformTier
     , ApplicationId
     , Name
     , CAST(StartDate AS DATE)
     , CAST(EndDate AS DATE)
     , SessionCnt
     , QASessionCnt
FROM QAAllEventFutureMaybe
WHERE Flag = 1
ORDER BY StartDate, EndDate
;

SELECT *
FROM QAAllEventFutureMaybe
;

SELECT ACCOUNTS.AccountId
     , ACCOUNTS.AccountName
     , EVENTS.ApplicationId
     , EVENTS.Name
     , EVENTS.StartDate
     , EVENTS.EndDate
     , COUNT(*) AS SessionCnt
     , COUNT(CASE WHEN SESSIONS.QASessionFlag = 1 THEN 1 ELSE NULL END) AS QASessionCnt
FROM JT.QAEventSessionFlag SESSIONS
JOIN JT.QAEvents EVENTS
ON SESSIONS.ApplicationId = EVENTS.ApplicationId
LEFT JOIN (SELECT IMP.ApplicationId
                , ACCT.AccountId
                , ACCT.AccountName
           FROM Salesforce.Implementation IMP
           LEFT JOIN Salesforce.Account ACCT
           ON IMP.AccountId = ACCT.AccountId
          ) ACCOUNTS
ON EVENTS.ApplicationId = ACCOUNTS.ApplicationId
WHERE StartDate >= CURRENT_DATE OR EndDate >= CURRENT_DATE
GROUP BY 1,2,3,4,5,6
HAVING COUNT(CASE WHEN SESSIONS.QASessionFlag = 1 THEN 1 ELSE NULL END) > 0
ORDER BY StartDate DESC, EndDate
;
