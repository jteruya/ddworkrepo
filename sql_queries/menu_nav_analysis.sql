-- Get Events (Non Test Events starting from 6/1/2016)
DROP TABLE IF EXISTS JT.MenuEvents;
CREATE TABLE JT.MenuEvents AS
SELECT ECS.*
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-06-01'
AND ECS.EndDate < CURRENT_DATE
;

-- Get Non-Disabled Users
DROP TABLE IF EXISTS JT.MenuEventUsers;
CREATE TABLE JT.MenuEventUsers AS
SELECT DISTINCT USERS.ApplicationId
     , USERS.GlobalUserId
     , USERS.UserId
     , LOWER(USERS.GlobalUserId) AS LowerGlobalUserId
FROM AuthDB_IS_Users USERS
JOIN JT.MenuEvents EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationID
WHERE IsDisabled = 0
;

-- Get Granular Data
DROP TABLE IF EXISTS JT.MenuClicks;
CREATE TABLE JT.MenuClicks AS
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.MenuEvents EVENTS
ON ACTIONS.Application_Id = LOWER(EVENTS.ApplicationId)
JOIN JT.MenuEventUsers USERS
ON ACTIONS.Global_User_Id = USERS.LowerGlobalUserId
WHERE ACTIONS.Identifier = 'menuItem'
;


CREATE INDEX ON JT.MenuClicks (Application_Id);


INSERT INTO JT.MenuClicks
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.MenuEvents EVENTS
ON ACTIONS.Application_Id = LOWER(EVENTS.ApplicationId)
JOIN JT.MenuEventUsers USERS
ON ACTIONS.Global_User_Id = USERS.LowerGlobalUserId
WHERE ACTIONS.Identifier = 'notificationsButton'
;

INSERT INTO JT.MenuClicks
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.MenuEvents EVENTS
ON ACTIONS.Application_Id = LOWER(EVENTS.ApplicationId)
JOIN JT.MenuEventUsers USERS
ON ACTIONS.Global_User_Id = USERS.LowerGlobalUserId
WHERE ACTIONS.Identifier = 'profileButton'
AND ACTIONS.Metadata->>'View' <> 'attendees'
;

INSERT INTO JT.MenuClicks
SELECT ACTIONS.*
FROM PUBLIC.Fact_Actions_Live ACTIONS
JOIN JT.MenuEvents EVENTS
ON ACTIONS.Application_Id = LOWER(EVENTS.ApplicationId)
JOIN JT.MenuEventUsers USERS
ON ACTIONS.Global_User_Id = USERS.LowerGlobalUserId
WHERE ACTIONS.Identifier IN ('menuButton','menuSlide')
;


DROP TABLE IF EXISTS JT.MenuClicks_EventUsers;
CREATE TABLE JT.MenuClicks_EventUsers AS
SELECT CLICKS.*
FROM JT.MenuClicks CLICKS
JOIN JT.MenuEventUsers USERS
ON CLICKS.Global_User_Id = USERS.LowerGlobalUserId
AND CLICKS.Application_Id = LOWER(USERS.ApplicationId)
;

CREATE INDEX ON JT.MenuClicks_EventUsers (Application_Id);

-- User Count Agg (Event/Micro App Level)
DROP TABLE IF EXISTS JT.MenuClicks_EventUsers_Agg;
CREATE TABLE JT.MenuClicks_EventUsers_Agg AS
SELECT Application_Id
     , Global_User_Id
     , CASE
         WHEN Identifier = 'menuItem' THEN Metadata->>'Url'
         WHEN Identifier = 'notificationsButton' THEN 'Notifications'
         WHEN Identifier = 'profileButton' THEN 'Profile Button'
       END AS MicroApp
     , COUNT(*) AS TapCnt
     , MIN(Created) AS FirstTap
     --, COUNT(CASE WHEN Device_Type = 'ios' THEN 1 ELSE NULL END) AS iOSTapCnt
     --, COUNT(CASE WHEN Device_Type = 'android' THEN 1 ELSE NULL END) AS AndroidTapCnt
     --, COUNT(DISTINCT CASE WHEN Device_Type = 'ios' THEN Global_User_Id ELSE NULL END) AS iOSUserCnt
     --, COUNT(DISTINCT CASE WHEN Device_Type = 'android' THEN Global_User_Id ELSE NULL END) AS AndroidUserCnt
FROM JT.MenuClicks_EventUsers
GROUP BY 1,2,3
;



-- Count Agg (Event/Micro App Level)
DROP TABLE IF EXISTS JT.MenuClicks_Agg;
CREATE TABLE JT.MenuClicks_Agg AS
SELECT Application_Id
     , MicroApp
     , SUM(TapCnt) AS TapCnt
     --, COUNT(CASE WHEN Device_Type = 'ios' THEN 1 ELSE NULL END) AS iOSTapCnt
     --, COUNT(CASE WHEN Device_Type = 'android' THEN 1 ELSE NULL END) AS AndroidTapCnt
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(DISTINCT CASE WHEN TapCnt = 1 THEN Global_User_Id ELSE NULL END) AS OneTapUserCnt
     , COUNT(DISTINCT CASE WHEN TapCnt = 2 THEN Global_User_Id ELSE NULL END) AS TwoTapUserCnt
     , COUNT(DISTINCT CASE WHEN TapCnt = 3 THEN Global_User_Id ELSE NULL END) AS ThreeTapUserCnt
     , COUNT(DISTINCT CASE WHEN TapCnt = 4 THEN Global_User_Id ELSE NULL END) AS FourTapUserCnt 
     , COUNT(DISTINCT CASE WHEN TapCnt = 5 THEN Global_User_Id ELSE NULL END) AS FiveTapUserCnt
     , COUNT(DISTINCT CASE WHEN TapCnt > 5 THEN Global_User_Id ELSE NULL END) AS FiveorMoreTapUserCnt 
     --, COUNT(DISTINCT CASE WHEN Device_Type = 'ios' THEN Global_User_Id ELSE NULL END) AS iOSUserCnt
     --, COUNT(DISTINCT CASE WHEN Device_Type = 'android' THEN Global_User_Id ELSE NULL END) AS AndroidUserCnt
FROM JT.MenuClicks_EventUsers_Agg
GROUP BY 1,2
;

-- Count Agg (Event App Level)
/*
DROP TABLE IF EXISTS JT.MenuClicks_Event_Agg;
CREATE TABLE JT.MenuClicks_Event_Agg AS
SELECT Application_Id
     , COUNT(*) AS TapCnt
     , COUNT(CASE WHEN Device_Type = 'ios' THEN 1 ELSE NULL END) AS iOSTapCnt
     , COUNT(CASE WHEN Device_Type = 'android' THEN 1 ELSE NULL END) AS AndroidTapCnt
     , COUNT(DISTINCT Global_User_Id) AS UserCnt
     , COUNT(DISTINCT CASE WHEN Device_Type = 'ios' THEN Global_User_Id ELSE NULL END) AS iOSUserCnt
     , COUNT(DISTINCT CASE WHEN Device_Type = 'android' THEN Global_User_Id ELSE NULL END) AS AndroidUserCnt
FROM JT.MenuClicks
GROUP BY 1
;
*/


-- Parse out Item/Topic/Subject IDs
DROP TABLE IF EXISTS JT.MenuClicks_Agg_Item_List;
CREATE TABLE JT.MenuClicks_Agg_Item_List AS

-- Item Clicks
SELECT AGG.Application_Id, AGG.MicroApp, CAST(SUBSTRING(AGG.MicroApp,11, LENGTH(AGG.MicroApp) - 10) AS INT) AS TargetId, 'Item' AS TargetType, ITEM.ItemId, TOPIC.TopicId, TOPIC.ListTypeId, CAST(NULL AS INT) AS SubjectId, AGG.TapCnt, AGG.UserCnt
FROM JT.MenuClicks_Agg AGG
LEFT JOIN Ratings_Item ITEM
ON ITEM.ItemId = CAST(SUBSTRING(AGG.MicroApp,11, LENGTH(AGG.MicroApp) - 10) AS INT) AND UPPER(AGG.ApplicatIon_Id) = ITEM.ApplicationId
LEFT JOIN Ratings_Topic TOPIC
ON ITEM.ParentTopicId = TOPIC.TopicId AND ITEM.ApplicationId = TOPIC.ApplicationId
WHERE AGG.MicroApp LIKE 'dd://item/%'

UNION ALL

-- Topic Clicks
SELECT AGG.Application_Id, AGG.MicroApp
     , CASE
          WHEN MicroApp LIKE 'dd://topicinfo/%' THEN CAST(SUBSTRING(MicroApp,16, LENGTH(MicroApp) - 15) AS INT)
          WHEN MicroApp LIKE 'dd://topic/%' THEN CAST(SUBSTRING(MicroApp,12, LENGTH(MicroApp) - 11) AS INT)
          WHEN MicroApp LIKE 'dd://agenda/%' THEN CAST(SUBSTRING(MicroApp,13, LENGTH(MicroApp) - 12) AS INT)
       END AS TargetId
     , 'Topic' AS TargetType
     , NULL AS ItemId, TOPIC.TopicId, TOPIC.ListTypeId, NULL AS SubjectId, AGG.TapCnt, AGG.UserCnt
FROM (SELECT Application_Id
           , MicroApp
           , CASE
               WHEN MicroApp LIKE 'dd://topicinfo/%' THEN CAST(SUBSTRING(MicroApp,16, LENGTH(MicroApp) - 15) AS INT)
               WHEN MicroApp LIKE 'dd://topic/%' THEN CAST(SUBSTRING(MicroApp,12, LENGTH(MicroApp) - 11) AS INT)
               WHEN MicroApp LIKE 'dd://agenda/%' THEN CAST(SUBSTRING(MicroApp,13, LENGTH(MicroApp) - 12) AS INT)
             END AS TopicId
           , TapCnt
           , UserCnt
      FROM JT.MenuClicks_Agg
      WHERE MicroApp LIKE 'dd://topicinfo/%' OR MicroApp LIKE 'dd://topic/%' OR MicroApp LIKE 'dd://agenda/%'
     ) AGG
LEFT JOIN Ratings_Topic TOPIC
ON AGG.TopicId = TOPIC.TopicId AND UPPER(AGG.Application_Id) = TOPIC.ApplicationId

UNION ALL

-- Subject Clicks
SELECT AGG.Application_Id, AGG.MicroApp, CAST(SUBSTRING(AGG.MicroApp,15, LENGTH(AGG.MicroApp) - 14) AS INT) AS TargetId, 'Subject' AS TargetType, NULL AS ItemId, NULL AS TopicId, NULL AS ListTypeId, SUBJECT.SubjectId, AGG.TapCnt, AGG.UserCnt
FROM JT.MenuClicks_Agg AGG
LEFT JOIN Ratings_Subject SUBJECT
ON SUBJECT.SubjectId = CAST(SUBSTRING(AGG.MicroApp,15, LENGTH(AGG.MicroApp) - 14) AS INT) AND UPPER(AGG.Application_Id) = SUBJECT.ApplicationId
WHERE AGG.MicroApp LIKE 'dd://subjects/%'
;






-- ????
/*
DROP TABLE IF EXISTS JT.MenuClicks_Agg_Buckets;
CREATE TABLE JT.MenuClicks_Agg_Buckets AS
SELECT A.Application_Id
     , SUM(A.TapCnt) AS TotalTapCnt
     , COALESCE(B.TapCnt,0) AS ItemCnt
     , SUM(CASE WHEN MicroApp = 'dd://activityfeed/' THEN A.TapCnt ELSE 0 END) AS ActivityFeedTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://about/' THEN A.TapCnt ELSE 0 END) AS AboutTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://channels/' THEN A.TapCnt ELSE 0 END) AS ChannelsTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://favorites/' THEN A.TapCnt ELSE 0 END) AS FavoritesTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://friends/' THEN A.TapCnt ELSE 0 END) AS FriendsTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://leaderboard/' THEN A.TapCnt ELSE 0 END) AS LeaderBoardTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://leads/' THEN A.TapCnt ELSE 0 END) AS LeadsTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://map/' THEN A.TapCnt ELSE 0 END) AS MapTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://messages/' THEN A.TapCnt ELSE 0 END) AS MessagesTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://photofeed/' THEN A.TapCnt ELSE 0 END) AS PhotoFeedTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://qrcodescanner/' THEN A.TapCnt ELSE 0 END) AS QRScannerTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://users/' THEN A.TapCnt ELSE 0 END) AS UsersTapCnt
     , SUM(CASE WHEN MicroApp = 'dd://survey/' THEN A.TapCnt ELSE 0 END) AS SurveyCnt
     , SUM(CASE WHEN MicroApp = 'dd://poll/' THEN A.TapCnt ELSE 0 END) AS PollCnt
     , SUM(CASE WHEN MicroApp = 'dd://switchevent/' THEN A.TapCnt ELSE 0 END) AS SwitchEventCnt
     , SUM(CASE WHEN MicroApp = 'dd://profile/' THEN A.TapCnt ELSE 0 END) AS ProfileCnt
     , SUM(CASE WHEN MicroApp = 'dd://meetings/' THEN A.TapCnt ELSE 0 END) AS MeetingsCnt
     , SUM(CASE WHEN MicroApp = 'dd://update/' THEN A.TapCnt ELSE 0 END) AS UpdateCnt
     , SUM(CASE WHEN MicroApp = 'dd://targetedoffers' THEN A.TapCnt ELSE 0 END) AS TargetedOffersCnt
     , SUM(CASE WHEN MicroApp LIKE 'dd://hashtag/%' THEN A.TapCnt ELSE 0 END) AS HashTagCnt
     , SUM(CASE WHEN MicroApp = 'tt://globalsearch' THEN A.TapCnt ELSE 0 END) AS GlobalSearchTopCnt
     , SUM(CASE WHEN MicroApp = 'tt://activityfeed' THEN A.TapCnt ELSE 0 END) AS ActivityFeedTopCnt
     , SUM(CASE WHEN MicroApp = 'tt://badges' THEN A.TapCnt ELSE 0 END) AS BadgesTopCnt
     , SUM(CASE WHEN MicroApp = 'tt://settings' THEN A.TapCnt ELSE 0 END) AS SettingsTopCnt          
     , SUM(CASE WHEN MicroApp LIKE '%http%' THEN A.TapCnt ELSE 0 END) AS LinkCnt
     , SUM(CASE WHEN MicroApp IS NULL THEN A.TapCnt ELSE 0 END) AS ErrorCnt
     , (SUM(CASE WHEN MicroApp = 'dd://activityfeed/' 
                  OR MicroApp = 'dd://about/'
                  OR MicroApp = 'dd://channels/'
                  OR MicroApp = 'dd://favorites/'
                  OR MicroApp = 'dd://friends/'
                  OR MicroApp = 'dd://leaderboard/'
                  OR MicroApp = 'dd://leads/'
                  OR MicroApp = 'dd://map/'
                  OR MicroApp = 'dd://messages/'
                  OR MicroApp = 'dd://photofeed/'
                  OR MicroApp = 'dd://qrcodescanner/'
                  OR MicroApp = 'dd://users/' 
                  OR MicroApp = 'dd://survey/'
                  OR MicroApp = 'dd://poll/'
                  OR MicroApp = 'dd://switchevent/'
                  OR MicroApp = 'dd://profile/'
                  OR MicroApp = 'dd://meetings/'
                  OR MicroApp = 'dd://update/'
                  OR MicroApp = 'dd://targetedoffers'
                  OR MicroApp LIKE 'dd://hashtag/%'
                  OR MicroApp = 'tt://globalsearch'
                  OR MicroApp = 'tt://activityfeed'
                  OR MicroApp = 'tt://badges'
                  OR MicroApp = 'tt://settings'
                  OR MicroApp LIKE '%http%'
                  OR MicroApp IS NULL THEN A.TapCnt ELSE 0 END)::DECIMAL(12,4) + COALESCE(B.TapCnt,0))/SUM(A.TapCnt)::DECIMAL(12,4) AS Pct
FROM JT.MenuClicks_Agg A
LEFT JOIN (SELECT Application_Id
                , SUM(TapCnt) AS TapCnt
           FROM JT.MenuClicks_Agg_Item_List
           GROUP BY 1) B
ON A.Application_Id = B.Application_Id
GROUP BY 1,3
;
*/

-- XREF
DROP TABLE IF EXISTS JT.MenuClicks_Agg_Xref;
CREATE TABLE JT.MenuClicks_Agg_Xref AS
SELECT A.Application_Id
     , A.MicroApp
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.TapCnt DESC) AS TapCntRank
     , A.TapCnt
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.iOSTapCnt DESC) AS iOSTapCntRank     
     --, A.iOSTapCnt
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.AndroidTapCnt DESC) AS AndroidTapCntRank     
     --, A.AndroidTapCnt
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.UserCnt DESC) AS UserCntRank     
     , A.UserCnt
     , A.OneTapUserCnt
     , A.TwoTapUserCnt
     , A.ThreeTapUserCnt
     , A.FourTapUserCnt
     , A.FiveTapUserCnt
     , A.FiveorMoreTapUserCnt
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.iOSUserCnt DESC) AS iOSUserCntRank     
     --, A.iOSUserCnt
     --, RANK() OVER (PARTITION BY A.Application_Id ORDER BY A.AndroidUserCnt DESC) AS AndroidUserCntRank     
     --, A.AndroidUserCnt
     , CASE 
          WHEN A.MicroApp = 'dd://activityfeed/' THEN 5 
          WHEN A.MicroApp = 'dd://about/' THEN -1
          WHEN A.MicroApp = 'dd://channels/' THEN 206
          WHEN A.MicroApp = 'dd://favorites/' THEN 7
          WHEN A.MicroApp = 'dd://friends/' THEN -1
          WHEN A.MicroApp = 'dd://leaderboard/' THEN 6
          WHEN A.MicroApp = 'dd://leads/' THEN 14
          WHEN A.MicroApp = 'dd://map/' THEN 10
          WHEN A.MicroApp = 'dd://messages/' THEN 205
          WHEN A.MicroApp = 'dd://photofeed/' THEN 11
          WHEN A.MicroApp = 'dd://qrcodescanner/' THEN 15
          WHEN A.MicroApp = 'dd://users/' THEN 8
          WHEN A.MicroApp = 'dd://survey/' THEN 12
          WHEN A.MicroApp = 'dd://poll/' THEN 19
          WHEN A.MicroApp = 'dd://switchevent/' THEN -1
          WHEN A.MicroApp = 'dd://profile/' THEN 17
          WHEN A.MicroApp = 'dd://meetings/' THEN 207
          WHEN A.MicroApp = 'dd://update/' THEN 16
          WHEN A.MicroApp = 'dd://targetedoffers' THEN 20
          WHEN A.MicroApp LIKE '%doubledutch.me/mobile-about.html%' THEN 13
          WHEN A.MicroApp = 'Notifications' THEN -2
          WHEN A.MicroApp = 'Profile Button' THEN -3
          ELSE NULL
       END AS TypeId
     , B.ItemId
     , B.TopicId
     , B.ListTypeId
     , B.SubjectId
     --, C.TapCnt AS TotalTapCnt
     --, C.iOSTapCnt AS TotaliOSTapCnt
     --, C.AndroidTapCnt AS TotalAndroidTapCnt
     --, C.UserCnt AS TotalUserCnt
     --, C.iOSUserCnt AS TotaliOSUserCnt
     --, C.AndroidUserCnt AS TotalAndroidUserCnt
     , CASE
         WHEN A.MicroApp LIKE 'tt://%' THEN 1
         ELSE 0
       END AS UpperMenuOptionFlag
     , CASE
         WHEN A.MicroApp LIKE '%http%' AND A.MicroApp NOT LIKE '%doubledutch.me/mobile-about.html%' THEN 1
         ELSE 0
       END AS ExternalWebFlag
FROM JT.MenuClicks_Agg A
--JOIN JT.MenuClicks_Event_Agg C
--ON A.Application_Id = C.Application_Id
LEFT JOIN JT.MenuClicks_Agg_Item_List B
ON A.Application_Id = B.Application_Id AND A.MicroApp = B.MicroApp
;


-- Users XREF
DROP TABLE IF EXISTS JT.MenuClicks_Users_Agg_Xref;
CREATE TABLE JT.MenuClicks_Users_Agg_Xref AS
SELECT A.Application_Id
     , A.Global_User_Id
     , A.MicroApp
     , A.TapCnt
     , CASE 
          WHEN A.MicroApp = 'dd://activityfeed/' THEN 5 
          WHEN A.MicroApp = 'dd://about/' THEN -1
          WHEN A.MicroApp = 'dd://channels/' THEN 206
          WHEN A.MicroApp = 'dd://favorites/' THEN 7
          WHEN A.MicroApp = 'dd://friends/' THEN -1
          WHEN A.MicroApp = 'dd://leaderboard/' THEN 6
          WHEN A.MicroApp = 'dd://leads/' THEN 14
          WHEN A.MicroApp = 'dd://map/' THEN 10
          WHEN A.MicroApp = 'dd://messages/' THEN 205
          WHEN A.MicroApp = 'dd://photofeed/' THEN 11
          WHEN A.MicroApp = 'dd://qrcodescanner/' THEN 15
          WHEN A.MicroApp = 'dd://users/' THEN 8
          WHEN A.MicroApp = 'dd://survey/' THEN 12
          WHEN A.MicroApp = 'dd://poll/' THEN 19
          WHEN A.MicroApp = 'dd://switchevent/' THEN -1
          WHEN A.MicroApp = 'dd://profile/' THEN 17
          WHEN A.MicroApp = 'dd://meetings/' THEN 207
          WHEN A.MicroApp = 'dd://update/' THEN 16
          WHEN A.MicroApp = 'dd://targetedoffers' THEN 20
          WHEN A.MicroApp LIKE '%doubledutch.me/mobile-about.html%' THEN 13
          WHEN A.MicroApp = 'Notifications' THEN -2
          WHEN A.MicroApp = 'Profile Button' THEN -3
          ELSE NULL
       END AS TypeId
     , B.ItemId
     , B.TopicId
     , B.ListTypeId
     , B.SubjectId
     , CASE
         WHEN A.MicroApp LIKE 'tt://%' THEN 1
         ELSE 0
       END AS UpperMenuOptionFlag
     , CASE
         WHEN A.MicroApp LIKE '%http%' AND A.MicroApp NOT LIKE '%doubledutch.me/mobile-about.html%' THEN 1
         ELSE 0
       END AS ExternalWebFlag
FROM JT.MenuClicks_EventUsers_Agg A
--JOIN JT.MenuClicks_Event_Agg C
--ON A.Application_Id = C.Application_Id
LEFT JOIN JT.MenuClicks_Agg_Item_List B
ON A.Application_Id = B.Application_Id AND A.MicroApp = B.MicroApp
;



-- Cleaned up and selected menu choices for all events
DROP TABLE IF EXISTS JT.MenuChoices;
CREATE TABLE JT.MenuChoices AS
SELECT DISTINCT ApplicationId
     , GridIndex
     , LAST_VALUE(MicroApp) OVER (PARTITION BY ApplicationId, GridIndex ORDER BY Created ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS MicroApp
     , LAST_VALUE(Title) OVER (PARTITION BY ApplicationId, GridIndex ORDER BY Created ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Title
     , MAX(Created) OVER (PARTITION BY ApplicationId, GridIndex) AS Created
     , LAST_VALUE(Target) OVER (PARTITION BY ApplicationId, GridIndex ORDER BY Created ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Target
     , LAST_VALUE(TypeId) OVER (PARTITION BY ApplicationId, GridIndex ORDER BY Created ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TypeId
FROM PUBLIC.Ratings_ApplicationConfigGridItems
WHERE Selected = 'true'
AND ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
UNION ALL
SELECT ApplicationId
     , -1 AS GridIndex
     , 'Notifications' AS MicroApp
     , 'Notifications' AS Title
     , NULL AS Created
     , 'Notifications' AS Target
     , -2 AS TypeId
FROM JT.MenuEvents
UNION ALL
SELECT ApplicationId
     , -2 AS GridIndex
     , 'Profile Button' AS MicroApp
     , 'Profile Button' AS Title
     , NULL AS Created
     , 'Profile Button' AS Target
     , -3 AS TypeId
FROM JT.MenuEvents
;




-- Cleaned up and selected menu choices with a potential topic/item id as a target
DROP TABLE IF EXISTS JT.MenuItemTopic;
CREATE TABLE JT.MenuItemTopic AS
SELECT CONFIG.ApplicationId
     , CONFIG.GridIndex
     , CONFIG.MicroApp
     , CONFIG.Title
     , CONFIG.TypeId
     , CONFIG.Target
     , CONFIG.Created
     -- If in the unusual event the same id is used for both a topic and an item, we will go with the following precedent for assigning the target of the microapp
     -- (1) Topic, (2) Item
     , CASE WHEN TOPICS.TopicId IS NULL THEN ITEMS.ItemId ELSE NULL END AS ItemId
     , CASE WHEN TOPICS.TopicCreated IS NULL THEN ITEMS.ItemCreated ELSE NULL END AS ItemCreated
     , CASE WHEN ITEMS.ItemId IS NOT NULL THEN ITEMS.ListTypeId ELSE NULL END AS ItemListTypeId 
     , TOPICS.TopicId
     , TOPICS.TopicCreated
     , CASE WHEN TOPICS.TopicId IS NOT NULL THEN TOPICS.ListTypeId ELSE NULL END AS TopicListTypeId
     , SUBJECTS.SubjectId
     , SUBJECTS.SubjectCreated
-- Get all the Config Menu Items for the Events in Questions
FROM JT.MenuChoices CONFIG
-- Get all of the non-disabled items (in non-disabled, non-hidden topics)
LEFT JOIN (SELECT A.ApplicationId
                , A.ItemId
                , MIN(A.Created) AS ItemCreated
                , B.TopicId
                , MIN(B.Created) AS TopicCreated
                , B.ListTypeId
           FROM PUBLIC.Ratings_Item A
           JOIN PUBLIC.Ratings_Topic B
           ON A.ParentTopicId = B.TopicId AND A.ApplicationId = B.ApplicationId
           WHERE A.ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND B.ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND A.IsDisabled = 0
           AND B.IsDisabled = 0
           AND B.IsHidden = 'false'
           GROUP BY 1,2,4,6
          ) ITEMS
ON CONFIG.Target::INTEGER = ITEMS.ItemId AND CONFIG.ApplicationId = ITEMS.ApplicationId
-- Get all of the non-disabled, non-hidden topics
LEFT JOIN (SELECT ApplicationId
                , TopicId
                , MIN(Created) AS TopicCreated
                , ListTypeId
           FROM PUBLIC.Ratings_Topic
           WHERE ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND IsDisabled = 0
           AND IsHidden = 'false'
           GROUP BY 1,2,4
          ) TOPICS
ON CONFIG.Target::INTEGER = TOPICS.TopicId AND CONFIG.ApplicationId = TOPICS.ApplicationId
-- Get all of the non-disabled, non-hidden subjects
LEFT JOIN (SELECT ApplicationId
                , SubjectId
                , MIN(Created) AS SubjectCreated
           FROM PUBLIC.Ratings_Subject
           WHERE ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND IsDisabled = 0
           GROUP BY 1,2
          ) SUBJECTS
ON CONFIG.Target::INTEGER = SUBJECTS.SubjectId AND CONFIG.ApplicationId = SUBJECTS.ApplicationId
-- Menu Item has a target that is an ID (Topic or Item)
WHERE CONFIG.Target ~ '^[0-9]'
-- Config is only pulling from events that we are working with
--AND CONFIG.Selected = 'true'
UNION ALL
-- Get all menu items that do not have targets or do not have id targets
SELECT ApplicationId
     , GridIndex
     , MicroApp
     , Title
     , TypeId
     , Target
     , Created
     , NULL AS ItemId
     , NULL AS ItemCreated
     , NULL AS ItemListTypeId
     , NULL AS TopicId
     , NULL AS TopicCreated
     , NULL AS TopicListTypeId
     , NULL AS SubjectId
     , NULL AS SubjectCreated
-- Get all the Config Menu Items for the Events in Questions
FROM JT.MenuChoices CONFIG
WHERE (CONFIG.Target !~ '^[0-9]' OR CONFIG.Target IS NULL)
;



DROP TABLE IF EXISTS JT.MenuItemTopicTaps;
CREATE TABLE JT.MenuItemTopicTaps AS

-- Non Target Id Menu Clicks (Non External Links)
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CHOICES.ItemListTypeId, MENU_CHOICES.TopicListTypeId) AS ListTypeId
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
     , COALESCE(MENU_CLICKS.OneTapUserCnt,0) AS OneTapUserCnt
     , COALESCE(MENU_CLICKS.TwoTapUserCnt,0) AS TwoTapUserCnt
     , COALESCE(MENU_CLICKS.ThreeTapUserCnt,0) AS ThreeTapUserCnt
     , COALESCE(MENU_CLICKS.FourTapUserCnt,0) AS FourTapUserCnt
     , COALESCE(MENU_CLICKS.FiveTapUserCnt,0) AS FiveTapUserCnt
     , COALESCE(MENU_CLICKS.FiveorMoreTapUserCnt,0) AS FiveOrMoreTapUserCnt
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , TypeId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
                , SUM(OneTapUserCnt) AS OneTapUserCnt
                , SUM(TwoTapUserCnt) AS TwoTapUserCnt
                , SUM(ThreeTapUserCnt) AS ThreeTapUserCnt
                , SUM(FourTapUserCnt) AS FourTapUserCnt
                , SUM(FiveTapUserCnt) AS FiveTapUserCnt
                , SUM(FiveOrMoreTapUserCnt) AS FiveOrMoreTapUserCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           --AND MicroApp <> 'Notifications'
           --AND MicroApp <> 'Profile Button'
           AND TypeId IS NOT NULL
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.TypeId = MENU_CLICKS.TypeId
WHERE MENU_CHOICES.ItemId IS NULL AND MENU_CHOICES.TopicId IS NULL AND MENU_CHOICES.SubjectId IS NULL AND MENU_CHOICES.TypeId NOT IN (9)

UNION ALL

-- Target Id Menu Clicks (External Links)
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CHOICES.ItemListTypeId, MENU_CHOICES.TopicListTypeId) AS ListTypeId     
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
     , COALESCE(MENU_CLICKS.OneTapUserCnt,0) AS OneTapUserCnt
     , COALESCE(MENU_CLICKS.TwoTapUserCnt,0) AS TwoTapUserCnt
     , COALESCE(MENU_CLICKS.ThreeTapUserCnt,0) AS ThreeTapUserCnt
     , COALESCE(MENU_CLICKS.FourTapUserCnt,0) AS FourTapUserCnt
     , COALESCE(MENU_CLICKS.FiveTapUserCnt,0) AS FiveTapUserCnt
     , COALESCE(MENU_CLICKS.FiveorMoreTapUserCnt,0) AS FiveOrMoreTapUserCnt   
FROM (SELECT *
           , CASE 
                WHEN Target LIKE '%http:%' THEN REGEXP_REPLACE(Target, 'http://', '')
                WHEN Target LIKE '%https:%' THEN REGEXP_REPLACE(Target, 'https://', '')
                ELSE ''
             END AS CleanTarget
      FROM JT.MenuItemTopic
      WHERE ItemId IS NULL AND TopicId IS NULL AND SubjectId IS NULL AND TypeId IN (9)
     ) MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , CASE 
                     WHEN MicroApp LIKE '%http:%' THEN REGEXP_REPLACE(MicroApp, 'http://', '')
                     WHEN MicroApp LIKE '%https:%' THEN REGEXP_REPLACE(MicroApp, 'https://', '')
                     ELSE ''
                  END AS CleanTarget
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
                , SUM(OneTapUserCnt) AS OneTapUserCnt
                , SUM(TwoTapUserCnt) AS TwoTapUserCnt
                , SUM(ThreeTapUserCnt) AS ThreeTapUserCnt
                , SUM(FourTapUserCnt) AS FourTapUserCnt
                , SUM(FiveTapUserCnt) AS FiveTapUserCnt
                , SUM(FiveOrMoreTapUserCnt) AS FiveOrMoreTapUserCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           --AND MicroApp <> 'Notifications'
           --AND MicroApp <> 'Profile Button'
           AND MicroApp LIKE '%http%'         
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.CleanTarget = MENU_CLICKS.CleanTarget

UNION ALL

-- Menu Choices (Item) w/ Item Clicks
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CHOICES.ItemListTypeId, MENU_CHOICES.TopicListTypeId) AS ListTypeId     
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
     , COALESCE(MENU_CLICKS.OneTapUserCnt,0) AS OneTapUserCnt
     , COALESCE(MENU_CLICKS.TwoTapUserCnt,0) AS TwoTapUserCnt
     , COALESCE(MENU_CLICKS.ThreeTapUserCnt,0) AS ThreeTapUserCnt
     , COALESCE(MENU_CLICKS.FourTapUserCnt,0) AS FourTapUserCnt
     , COALESCE(MENU_CLICKS.FiveTapUserCnt,0) AS FiveTapUserCnt
     , COALESCE(MENU_CLICKS.FiveorMoreTapUserCnt,0) AS FiveOrMoreTapUserCnt 
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , ItemId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
                , SUM(OneTapUserCnt) AS OneTapUserCnt
                , SUM(TwoTapUserCnt) AS TwoTapUserCnt
                , SUM(ThreeTapUserCnt) AS ThreeTapUserCnt
                , SUM(FourTapUserCnt) AS FourTapUserCnt
                , SUM(FiveTapUserCnt) AS FiveTapUserCnt
                , SUM(FiveOrMoreTapUserCnt) AS FiveOrMoreTapUserCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           --AND MicroApp <> 'Notifications'
           --AND MicroApp <> 'Profile Button'
           AND TypeId IS NULL
           AND ItemId IS NOT NULL
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.ItemId = MENU_CLICKS.ItemId
WHERE MENU_CHOICES.ItemId IS NOT NULL

UNION ALL 

-- Menu Choice (Topics) w/ Topic Clicks
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CHOICES.ItemListTypeId, MENU_CHOICES.TopicListTypeId) AS ListTypeId     
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
     , COALESCE(MENU_CLICKS.OneTapUserCnt,0) AS OneTapUserCnt
     , COALESCE(MENU_CLICKS.TwoTapUserCnt,0) AS TwoTapUserCnt
     , COALESCE(MENU_CLICKS.ThreeTapUserCnt,0) AS ThreeTapUserCnt
     , COALESCE(MENU_CLICKS.FourTapUserCnt,0) AS FourTapUserCnt
     , COALESCE(MENU_CLICKS.FiveTapUserCnt,0) AS FiveTapUserCnt
     , COALESCE(MENU_CLICKS.FiveorMoreTapUserCnt,0) AS FiveOrMoreTapUserCnt   
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , TopicId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
                , SUM(OneTapUserCnt) AS OneTapUserCnt
                , SUM(TwoTapUserCnt) AS TwoTapUserCnt
                , SUM(ThreeTapUserCnt) AS ThreeTapUserCnt
                , SUM(FourTapUserCnt) AS FourTapUserCnt
                , SUM(FiveTapUserCnt) AS FiveTapUserCnt
                , SUM(FiveOrMoreTapUserCnt) AS FiveOrMoreTapUserCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           --AND MicroApp <> 'Notifications'
           --AND MicroApp <> 'Profile Button'
           AND TypeId IS NULL
           AND ItemId IS NULL
           AND TopicId IS NOT NULL
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.TopicId = MENU_CLICKS.TopicId
WHERE MENU_CHOICES.TopicId IS NOT NULL

UNION ALL
-- MenuChoice (Subjects) w/ Subject Clicks
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CHOICES.ItemListTypeId, MENU_CHOICES.TopicListTypeId) AS ListTypeId     
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
     , COALESCE(MENU_CLICKS.OneTapUserCnt,0) AS OneTapUserCnt
     , COALESCE(MENU_CLICKS.TwoTapUserCnt,0) AS TwoTapUserCnt
     , COALESCE(MENU_CLICKS.ThreeTapUserCnt,0) AS ThreeTapUserCnt
     , COALESCE(MENU_CLICKS.FourTapUserCnt,0) AS FourTapUserCnt
     , COALESCE(MENU_CLICKS.FiveTapUserCnt,0) AS FiveTapUserCnt
     , COALESCE(MENU_CLICKS.FiveorMoreTapUserCnt,0) AS FiveOrMoreTapUserCnt  
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , SubjectId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
                , SUM(OneTapUserCnt) AS OneTapUserCnt
                , SUM(TwoTapUserCnt) AS TwoTapUserCnt
                , SUM(ThreeTapUserCnt) AS ThreeTapUserCnt
                , SUM(FourTapUserCnt) AS FourTapUserCnt
                , SUM(FiveTapUserCnt) AS FiveTapUserCnt
                , SUM(FiveOrMoreTapUserCnt) AS FiveOrMoreTapUserCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           --AND MicroApp <> 'Notifications'
           --AND MicroApp <> 'Profile Button'
           AND TypeId IS NULL
           AND SubjectId IS NOT NULL
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.SubjectId = MENU_CLICKS.SubjectId
WHERE MENU_CHOICES.SubjectId IS NOT NULL
;


CREATE TEMPORARY TABLE MenuUserClickCnt AS
SELECT CLICKS.Application_Id
     , CLICKS.Global_User_Id
     , SUM(CASE WHEN CLICKS.TapCnt IS NOT NULL THEN CLICKS.TapCnt ELSE 0 END) AS TapCnt 
FROM JT.MenuClicks_Users_Agg_Xref CLICKS
GROUP BY 1,2
;


SELECT Application_Id
     , SUM(TapCnt)::DECIMAL(12,4)/COUNT(Global_User_Id)::DECIMAL(12,4)
     , AVG(TapCnt)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TapCnt)
FROM MenuUserClickCnt
GROUP BY 1
;









-- Get Index (Old)
/*
DROP TABLE IF EXISTS JT.MenuClicks_Agg_Xref_Index;
CREATE TABLE JT.MenuClicks_Agg_Xref_Index AS
SELECT A.*
     , COALESCE(B.GridIndex,C.GridIndex,D.GridIndex, E.GridIndex) AS GridIndex
     , COALESCE(B.Created, C.Created, D.Created, E.Created) AS GridCreated
     , COALESCE(B.Selected, C.Selected, D.Selected, E.Selected) AS Selected
     , COALESCE(C.IsDisabled, D.IsDisabled) AS IsDisabled
     , D.IsHidden
FROM JT.MenuClicks_Agg_Xref A
LEFT JOIN (SELECT *
           FROM PUBLIC.Ratings_ApplicationConfigGridItems
           WHERE ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)) B
ON A.TypeId IS NOT NULL AND A.Application_Id = LOWER(B.ApplicationID) AND A.TypeId = B.TypeId
LEFT JOIN (SELECT A.*
                , B.IsDisabled
           FROM PUBLIC.Ratings_ApplicationConfigGridItems A
           JOIN PUBLIC.Ratings_Item B
           ON A.Target::INTEGER = B.ItemId AND A.ApplicationId = B.ApplicationId
           WHERE A.Target ~ '^[0-9]'
           AND A.ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)) C
ON A.ItemId IS NOT NULL AND A.Application_Id = LOWER(C.ApplicationID) AND A.ItemId = C.Target::INTEGER
LEFT JOIN (SELECT A.*
                , B.IsDisabled
                , B.IsHidden AS IsHidden
           FROM PUBLIC.Ratings_ApplicationConfigGridItems A
           JOIN PUBLIC.Ratings_Topic B
           ON A.Target::INTEGER = B.TopicId AND A.ApplicationId = B.ApplicationId
           WHERE A.Target ~ '^[0-9]') D
ON A.ParentTopicId IS NOT NULL AND A.Application_Id = LOWER(D.ApplicationID) AND A.ParentTopicId = C.Target::INTEGER
LEFT JOIN (SELECT *
           FROM PUBLIC.Ratings_ApplicationConfigGridItems) E
ON A.ExternalWebFlag = 1 AND A.Application_Id = LOWER(E.ApplicationID) AND A.MicroApp = E.Target
;
*/

/*
-- Check % of 
SELECT COUNT(*)
     , COUNT(CASE WHEN GridIndex IS NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN GridIndex IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
FROM JT.MenuClicks_Agg_Xref_Index
WHERE UpperMenuOptionFlag = 0
-- Not Listed in AppConfigGridItem
AND MicroApp <> 'dd://switchevent/'
AND Selected = 'true'
;


-- Correlation Exp
SELECT TypeId
     , MicroApp
     , COUNT(*) AS Events
     , MIN(GridIndex) AS HighestGridIndex
     , MAX(GridIndex) AS LowestGridIndex
     , AVG(GridIndex) AS AvgGridIndex
     , STDDEV_SAMP(GridIndex) AS GridIndexSpread
     , CORR(TapCnt::DECIMAL(12,4)/TotalTapCnt::DECIMAL(12,4), GridIndex) AS TapCorr
     , CORR(UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4), GridIndex) AS UserCorr
FROM JT.MenuClicks_Agg_Xref_Index
WHERE TypeId IS NOT NULL
AND TypeId > 0
GROUP BY 1,2
ORDER BY 6
;
*/


SELECT GridIndex
     , COUNT(*)
     , AVG(UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4)) AS UserPct
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4))
FROM JT.MenuClicks_Agg_Xref_Index
WHERE /*GridIndex IS NOT NULL
AND */Selected = 'true'
AND MicroApp <> 'dd://switchevent/'
GROUP BY 1
ORDER BY 1
;


SELECT GridIndex
     , COUNT(*)
     , AVG(UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4)) AS UserPct
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4))
FROM JT.MenuClicks_Agg_Xref_Index
WHERE GridIndex IS NOT NULL
AND Selected = 'true'
AND Application_Id IN (SELECT LOWER(ApplicationId)
                       FROM PUBLIC.Ratings_ApplicationConfigGridItems
                       WHERE ApplicationID IN (SELECT DISTINCT UPPER(Application_Id) FROM JT.MenuClicks_Agg_Xref_Index)
                       AND Selected = 'true'
                       GROUP BY 1
                       HAVING MAX(GridIndex) < 12)
GROUP BY 1
ORDER BY 1
;


SELECT Application_Id
     , MicroApp
     , GridIndex
     , UserCnt::DECIMAL(12,4)/TotalUserCnt::DECIMAL(12,4) AS UserPct
FROM (SELECT *
      FROM (SELECT *
                 , MAX(GridCreated) OVER (PARTITION BY Application_Id, GridIndex) AS MaxMicroAppCreated
            FROM JT.MenuClicks_Agg_Xref_Index
            WHERE GridIndex IS NOT NULL
            AND Selected = 'true'
            AND LOWER(Application_Id) = 'e8fe2a1c-8527-4e98-952e-e6636d3b901d'
            ) A
      WHERE GridCreated = MaxMicroAppCreated
      ) A
WHERE GridIndex IS NOT NULL
AND Selected = 'true'
AND (IsDisabled = 0 OR IsDisabled IS NULL)
AND GridIndex = 0         
;


SELECT *
FROM PUBLIC.Ratings_ApplicationConfigGridItems
WHERE LOWER(ApplicationId) = 'e8fe2a1c-8527-4e98-952e-e6636d3b901d'
;

SELECT *
FROM JT.MenuClicks_Agg_Xref_Index
WHERE LOWER(Application_Id) = 'e8fe2a1c-8527-4e98-952e-e6636d3b901d'
AND GridIndex IS NOT NULL
AND Selected = 'true'  
AND (IsDisabled = 0 OR IsDisabled IS NULL)
;

SELECT *
FROM AuthDB_Applications
WHERE LOWER(ApplicationId) = 'e8fe2a1c-8527-4e98-952e-e6636d3b901d'
;

SELECT *
FROM Ratings_Item
WHERE ItemId = 10715255

;


SELECT *
FROM PUBLIC.Ratings_ApplicationConfigGridItems ITEMS

WHERE LOWER(ITEMS.ApplicationId) = 'e8fe2a1c-8527-4e98-952e-e6636d3b901d'
AND ITEMS.Selected = 'true'
AND Target IS NULL
ORDER BY GridIndex
;

