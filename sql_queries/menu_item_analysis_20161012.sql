
-- Cleaned up and selected menu choices for all events
DROP TABLE IF EXISTS JT.MenuChoices;
CREATE TEMPORARY TABLE JT.MenuChoices AS
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
;


-- Cleaned up and selected menu choices with a potential topic/item id as a target
DROP TABLE IF EXISTS JT.MenuItemTopic;
CREATE TEMPORARY TABLE JT.MenuItemTopic AS
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
     , TOPICS.TopicId
     , TOPICS.TopicCreated
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
           FROM PUBLIC.Ratings_Item A
           JOIN PUBLIC.Ratings_Topic B
           ON A.ParentTopicId = B.TopicId AND A.ApplicationId = B.ApplicationId
           WHERE A.ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND B.ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND A.IsDisabled = 0
           AND B.IsDisabled = 0
           AND B.IsHidden = 'false'
           GROUP BY 1,2,4
          ) ITEMS
ON CONFIG.Target::INTEGER = ITEMS.ItemId AND CONFIG.ApplicationId = ITEMS.ApplicationId
-- Get all of the non-disabled, non-hidden topics
LEFT JOIN (SELECT ApplicationId
                , TopicId
                , MIN(Created) AS TopicCreated
           FROM PUBLIC.Ratings_Topic
           WHERE ApplicationId IN (SELECT ApplicationId FROM JT.MenuEvents)
           AND IsDisabled = 0
           AND IsHidden = 'false'
           GROUP BY 1,2
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
     , NULL AS TopicId
     , NULL AS TopicCreated
     , NULL AS SubjectId
     , NULL AS SubjectCreated
-- Get all the Config Menu Items for the Events in Questions
FROM JT.MenuChoices CONFIG
WHERE (CONFIG.Target !~ '^[0-9]' OR CONFIG.Target IS NULL)
;


-- Check for bad item/topic ids
SELECT COUNT(*)
     , COUNT(CASE WHEN Target ~ '^[0-9]' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Target ~ '^[0-9]' AND ItemId IS NULL AND TopicId IS NULL AND SubjectId IS NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Target ~ '^[0-9]' AND ItemId IS NULL AND TopicId IS NULL AND SubjectId IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN Target ~ '^[0-9]' THEN 1 ELSE NULL END)::DECIMAL(12,4)
FROM MenuItemTopic
;

-- 13113	1005	0.07664150080073209792
-- 13113	194	0.01479447876153435522
-- 12223	131	0.01071749979546756116
-- 16068	12223	131	0.01071749979546756116
-- 28429	12223	131	0.01071749979546756116
-- 28431	12228	131	0.01071311743539417730
-- 28431	12228	187	0.01529277069021916912
-- 28431	12228	62	0.00507033038927052666


SELECT DISTINCT TypeId
FROM MenuItemTopic
WHERE Target LIKE '%http%'
;

SELECT COUNT(*)
     , COUNT(CASE WHEN Target LIKE '%http%' THEN 1 ELSE NULL END)
FROM MenuItemTopic
WHERE TypeId IN (9,13)
;




SELECT *
     , CASE 
          WHEN MicroApp LIKE '%http:%' THEN REGEXP_REPLACE(MicroApp, 'http://', '')
          WHEN MicroApp LIKE '%https:%' THEN REGEXP_REPLACE(MicroApp, 'https://', '')
          ELSE ''
       END AS CleanTarget
FROM JT.MenuClicks_Agg_Xref
WHERE MicroApp LIKE '%http%'
;




DROP TABLE IF EXISTS JT.MenuItemTopicTaps;
CREATE TEMPORARY TABLE JT.MenuItemTopicTaps AS

-- Non Target Id Menu Clicks (Non External Links)
SELECT MENU_CHOICES.ApplicationId
     , MENU_CHOICES.GridIndex
     , MENU_CHOICES.MicroApp
     , MENU_CHOICES.Title
     , MENU_CHOICES.TypeId
     , MENU_CHOICES.Target
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , TypeId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications'
           AND MicroApp <> 'Profile Button'
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
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
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
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications'
           AND MicroApp <> 'Profile Button'
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
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , ItemId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications'
           AND MicroApp <> 'Profile Button'
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
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , TopicId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications'
           AND MicroApp <> 'Profile Button'
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
     , COALESCE(MENU_CLICKS.UserCnt,0) AS UserCnt
     , COALESCE(MENU_CLICKS.TapCnt,0) AS TapCnt
FROM JT.MenuItemTopic MENU_CHOICES
LEFT JOIN (SELECT UPPER(Application_Id) AS ApplicationId
                , SubjectId
                , SUM(UserCnt) AS UserCnt
                , SUM(TapCnt) AS TapCnt
           FROM JT.MenuClicks_Agg_Xref
           WHERE MicroApp <> 'dd://switchevent/'
           AND UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications'
           AND MicroApp <> 'Profile Button'
           AND TypeId IS NULL
           AND SubjectId IS NOT NULL
           GROUP BY 1,2
          ) MENU_CLICKS
ON MENU_CHOICES.ApplicationId = MENU_CLICKS.ApplicationId AND MENU_CHOICES.SubjectId = MENU_CLICKS.SubjectId
WHERE MENU_CHOICES.SubjectId IS NOT NULL
;












SELECT SUM(UserCnt)
     , SUM(TapCnt)
           FROM JT.MenuClicks_Agg_Xref
           WHERE UpperMenuOptionFlag = 0
           AND MicroApp <> 'Notifications' AND MicroApp <> 'Profile Button'
           ;
           
          
-- 5,315,184
-- 25,534,565



SELECT SUM(UserCnt)
     , SUM(TapCnt)
FROM MenuItemTopicTaps
;

-- 4,946,054 (93%)
-- 24,407,351 (96%)



SELECT GridIndex
     , COUNT(DISTINCT EVENTS.ApplicationId)
     , SUM(MENU_ITEMS.UserCnt::DECIMAL(12,4))/SUM(UsersActive::DECIMAL(12,4)) AS WeightedAvg
     , AVG(MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4)) AS Avg
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4)) AS Median
FROM MenuItemTopicTaps MENU_ITEMS
JOIN JT.MenuEvents EVENTS
ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
WHERE EVENTS.UsersActive > 0
GROUP BY 1
ORDER BY 1
;


SELECT GridIndex
     , MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4)
FROM MenuItemTopicTaps MENU_ITEMS
JOIN JT.MenuEvents EVENTS
ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
WHERE EVENTS.UsersActive > 01

