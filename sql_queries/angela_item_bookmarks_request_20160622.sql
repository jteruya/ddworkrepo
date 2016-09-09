-- Get the Universe of Events that... (Temporary Table)
-- (1) Are not test events.
-- (2) Started on or after 1/1/2016
-- (3) Ended before the day the query was run.
DROP TABLE IF EXISTS AngelaRequestAllEvents
;

CREATE TEMPORARY TABLE AngelaRequestAllEvents AS
SELECT ECS.*
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
AND ECS.StartDate >= '2016-01-01'
AND ECS.EndDate < CURRENT_DATE
;

-- Get all the non-disabled users from the events population. (Temporary Table)
DROP TABLE IF EXISTS AngelaRequestAllEventUsers
;

CREATE TEMPORARY TABLE AngelaRequestAllEventUsers AS
SELECT DISTINCT USERS.ApplicationId
     , USERS.UserId
     , USERS.GlobalUserId
     , LOWER(USERS.GlobalUserId) AS LowerGlobalUserId
FROM PUBLIC.AuthDB_IS_Users USERS
JOIN AngelaRequestAllEvents EVENTS
ON USERS.ApplicationId = EVENTS.ApplicationId
AND IsDisabled = 0
;

-- Get the Universe of Non-Disabled Items (Temporary Table)
DROP TABLE IF EXISTS AngelaRequestAllItems
;

CREATE TEMPORARY TABLE AngelaRequestAllItems AS
SELECT DISTINCT ITEMS.ApplicationId 
     , ITEMS.ItemId
     , TOPICS.ListTypeId
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN AngelaRequestAllEvents EVENTS
ON ITEMS.ApplicationId = EVENTS.ApplicationId
-- Non-Disabled Sessions Only
WHERE ITEMS.IsDisabled = 0
-- Non-Disabled Agenda Topics Only
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = false
-- Pull Only Agenda (2), Exhibitor (3) and Speaker (4) Topics
AND TOPICS.ListTypeId IN (2,3,4)
;

-- Get the Universe of Item Bookmarks (Temporary Table)
DROP TABLE IF EXISTS AngelaRequestAllUserItemBookmarks
;

CREATE TEMPORARY TABLE AngelaRequestAllUserItemBookmarks AS
SELECT FAVS.*
     , ITEMS.ListTypeId
FROM PUBLIC.Ratings_UserFavorites FAVS
JOIN AngelaRequestAllEventUsers USERS ON FAVS.UserId = USERS.UserId
JOIN AngelaRequestAllItems ITEMS ON FAVS.ItemId = ITEMS.ItemId
;

-- Put it all together (at the event level)
DROP TABLE IF EXISTS AngelaRequestEventSummary
;

CREATE TEMPORARY TABLE AngelaRequestEventSummary AS
SELECT EVENTS.ApplicationId
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 2 THEN FAVS.FavoriteId ELSE NULL END) AS SessionBookmarkCnt
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 2 THEN FAVS.ItemId ELSE NULL END) AS BookmarkedSessionCnt
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 3 THEN FAVS.FavoriteId ELSE NULL END) AS ExhibitorBookmarkCnt
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 3 THEN FAVS.ItemId ELSE NULL END) AS BookmarkedExhibitorCnt
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 4 THEN FAVS.FavoriteId ELSE NULL END) AS SpeakerBookmarkCnt
     , COUNT(DISTINCT CASE WHEN FAVS.ListTypeId = 4 THEN FAVS.ItemId ELSE NULL END) AS BookmarkedSpeakerCnt
FROM AngelaRequestAllEvents EVENTS
LEFT JOIN AngelaRequestAllUserItemBookmarks FAVS
ON EVENTS.ApplicationId = FAVS.ApplicationId
GROUP BY 1
;

-- Session/Speaker Results
SELECT COUNT(CASE WHEN SessionBookmarkCnt > 0 THEN 1 ELSE NULL END) AS SessionBookmarkEventCnt
     , COUNT(CASE WHEN SpeakerBookmarkCnt > 0 THEN 1 ELSE NULL END) AS SpeakerBookmarkEventCnt
     , COUNT(*) AS TotalEvents
     , COUNT(CASE WHEN SessionBookmarkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS SessionBookmarkEventPct
     , COUNT(CASE WHEN SpeakerBookmarkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS SpeakerBookmarkEventPct     
FROM AngelaRequestEventSummary
;

-- Exhibitor Exclude Events w/o Exhibitors
SELECT COUNT(CASE WHEN ExhibitorBookmarkCnt > 0 THEN 1 ELSE NULL END) AS ExhibitorBookmarkEventCnt
     , COUNT(*) AS TotalExhibitorEvents
     , COUNT(CASE WHEN ExhibitorBookmarkCnt > 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS ExhibitorBookmarkEventPct
FROM AngelaRequestEventSummary
WHERE ApplicationId IN (SELECT DISTINCT ApplicationId
                        FROM AngelaRequestAllItems
                        WHERE ListTypeId = 3)
;

-- Do this at the Event/Item Level
DROP TABLE IF EXISTS AngelaRequestEventItemSummary
;

CREATE TEMPORARY TABLE AngelaRequestEventItemSummary AS
SELECT EVENTS.ApplicationId
     , ITEMS.ItemId
     , ITEMS.ListTypeId
     , COUNT(DISTINCT FAVS.FavoriteId) AS BookmarkCnt
FROM AngelaRequestAllEvents EVENTS
JOIN AngelaRequestAllItems ITEMS
ON EVENTS.ApplicationId = ITEMS.ApplicationId
LEFT JOIN AngelaRequestAllUserItemBookmarks FAVS
ON ITEMS.ItemId = FAVS.ItemId
GROUP BY 1,2,3
;

-- Item Level Average/Median Bookmarks
SELECT ListTypeId
     , COUNT(DISTINCT ApplicationId) AS EventCnt
     , COUNT(ItemId) AS ItemCnt
     , AVG(BookmarkCnt) AS AverageBookmarkCnt
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY BookmarkCnt) AS MedianBookmarkCnt
FROM AngelaRequestEventItemSummary
WHERE ListTypeId IN (2,4)
AND BookmarkCnt > 0
GROUP BY 1
UNION
SELECT ListTypeId
     , COUNT(DISTINCT ApplicationId) AS EventCnt
     , COUNT(ItemId) AS ItemCnt
     , AVG(BookmarkCnt) AS AverageBookmarkCnt
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY BookmarkCnt) AS MedianBookmarkCnt
FROM AngelaRequestEventItemSummary
WHERE ListTypeId IN (3)
AND ApplicationId IN (SELECT DISTINCT ApplicationId
                      FROM AngelaRequestAllItems
                      WHERE ListTypeId = 3)
AND BookmarkCnt > 0
GROUP BY 1
ORDER BY 1
;