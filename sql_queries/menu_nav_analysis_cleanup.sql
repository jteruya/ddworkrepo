-- Heatmap Spine (All Categories and Positions)
CREATE TEMPORARY TABLE MenuItemCatPosition AS
SELECT GridIndex
     , TypeId
     , ListTypeId
     , CASE 
          WHEN GridIndex = 0 THEN '1st Menu Item'
          WHEN GridIndex = 1 THEN '2nd Menu Item'
          WHEN GridIndex = 2 THEN '3rd Menu Item'
          WHEN GridIndex = 3 THEN '4th Menu Item'
          WHEN GridIndex = 4 THEN '5th Menu Item'
          WHEN GridIndex = 5 THEN '6th Menu Item'
          WHEN GridIndex = 6 THEN '7th Menu Item'
          WHEN GridIndex = 7 THEN '8th Menu Item'
          WHEN GridIndex = 8 THEN '9th Menu Item'
          WHEN GridIndex = 9 THEN '10th Menu Item'
          ELSE NULL
       END AS Position
     , CASE
          WHEN TypeId = 1 THEN 'Custom Event Items'
          WHEN TypeId = 2 AND ListTypeId = 1 THEN 'Event Info'
          WHEN TypeId = 2 AND ListTypeId = 2 THEN 'Agenda'
          WHEN TypeId = 2 AND ListTypeId = 3 THEN 'Exhibitor'
          WHEN TypeId = 2 AND ListTypeId = 4 THEN 'Speakers'
          WHEN TypeId = 4 THEN 'Downloads'
          WHEN TypeId = 3 THEN 'Subject Event'
          WHEN TypeId = 5 THEN 'Activity Feed'
          WHEN TypeId = 6 THEN 'Leaderboard'
          WHEN TypeId = 7 THEN 'Favorites'
          WHEN TypeId = 8 THEN 'Attendees'
          WHEN TypeId = 9 THEN 'External Website'
          WHEN TypeId = 10 THEN 'Map'
          WHEN TypeId = 11 THEN 'Photo Feed'
          WHEN TypeId = 12 THEN 'Survey'
          WHEN TypeId = 13 THEN 'App By DoubleDutch'
          WHEN TypeId = 14 THEN 'Leads'
          WHEN TypeId = 15 THEN 'QRCodeScanner'
          WHEN TypeId = 16 THEN 'Update'
          WHEN TypeId = 17 THEN 'Profile'
          WHEN TypeId = 18 THEN 'Exhibitior Dashboard'
          WHEN TypeId = 19 THEN 'Poll'
          WHEN TypeId = 20 THEN 'Targeted Offers'
          WHEN TypeId = 200 THEN 'Settings'
          WHEN TypeId = 201 THEN 'Badges'
          WHEN TypeId = 205 THEN 'Messages'
          WHEN TypeId = 206 THEN 'Channels'
          WHEN TypeId = 207 THEN 'Meetings'
          ELSE NULL
       END AS MicroAppCat
FROM (SELECT DISTINCT GridIndex
      FROM JT.MenuItemTopicTaps
      WHERE GridIndex >= 0 AND GridIndex <= 9
     ) ALL_INDEX
JOIN (SELECT TypeId
           , CASE 
                WHEN TypeId = 2 THEN ListTypeId 
                ELSE NULL 
             END AS ListTypeId
      FROM JT.MenuItemTopicTaps
      WHERE GridIndex >= 0 AND GridIndex <= 9
      GROUP BY 1,2
      HAVING COUNT(*) >= 200
     ) ALL_TYPES
ON 1 = 1
;


-- All Taps
CREATE TEMPORARY TABLE MenuItemCatPositionTaps AS
SELECT MENU_ITEMS.ApplicationId
     , MENU_ITEMS.GridIndex
     , MENU_ITEMS.TypeId
     , MENU_ITEMS.ListTypeId
     , MENU_ITEMS.UserCnt
     , EVENTS.UsersActive
FROM JT.MenuItemTopicTaps MENU_ITEMS
JOIN JT.MenuEvents EVENTS
ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
;

-- Event Organizer Content Heatmap


SELECT GridIndex
     , TypeId
     , ListTypeId
FROM MenuItemCatPosition SPINE
LEFT JOIN JT.MenuItemTopicTaps MENU_ITEMS
ON SPINE.GridIndex = MENU_ITEMS.GridIndex AND 
;


-- Tap Heatmap Data
SELECT SPINE.TypeId
     , SPINE.ListTypeId
     , SPINE.GridIndex
     , SPINE.Position
     , COUNT(DISTINCT CASE WHEN MENU_TAPS.ApplicationId IS NOT NULL THEN MENU_TAPS.ApplicationId ELSE NULL) AS 
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY MENU_TAPS.UserCnt::DECIMAL(12,4)/MENU_TAPS.UsersActive::DECIMAL(12,4)) AS MedianPct
FROM MenuItemCatPosition SPINE
LEFT JOIN (SELECT *
           FROM MenuItemCatPositionTaps
           WHERE TypeId IS NOT NULL
           AND TypeId NOT IN (-3, -2)
           AND (TypeId <> 2 OR (TypeId = 2 AND ListTypeId IS NOT NULL))
           AND UsersActive > 0 
           AND UsersActive >= UserCnt
          ) MENU_TAPS
ON (MENU_TAPS.TypeId = 2 AND SPINE.TypeId = MENU_TAPS.TypeId AND SPINE.ListTypeId = MENU_TAPS.ListTypeId AND SPINE.GridIndex = MENU_TAPS.GridIndex) 
OR (MENU_TAPS.TypeId <> 2 AND SPINE.TypeId = MENU_TAPS.TypeId AND SPINE.GridIndex = MENU_TAPS.GridIndex)                  
GROUP BY 1,2,3,4
;
          

                
                             