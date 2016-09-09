SELECT *
FROM PUBLIC.AuthDB_Applications
WHERE LOWER(ApplicationId) = 'af310b9b-e31c-4851-8e33-22c210cdaaf0'
;

SELECT ITEMS.*
FROM PUBLIC.Ratings_Item ITEMS
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
WHERE ITEMS.ApplicationId = 'AF310B9B-E31C-4851-8E33-22C210CDAAF0'
AND ITEMS.IsDisabled = 0
AND TOPICS.ListTypeId = 4
AND TOPICS.IsDisabled = 0
AND TOPICS.IsHidden = false
;

-- Chip Heath, ItemId = 10446026

-- Bookmark Count:
SELECT COUNT(*) AS BookmarkCnt
     , COUNT(CASE WHEN IsDisabled = FALSE THEN 1 ELSE NULL END) AS NonDisabledBookmarkCnt
     , COUNT(CASE WHEN IsDisabled = TRUE THEN 1 ELSE NULL END) AS DisabledBookmarkCnt
     , COUNT(CASE WHEN IsDisabled = FALSE THEN 1 ELSE NULL END) * 2 + COUNT(CASE WHEN IsDisabled = true THEN 1 ELSE NULL END) * (-2) AS BookmarkScore
FROM PUBLIC.Ratings_UserFavorites
WHERE ItemId = 10446026
AND Created >= '2016-02-12'
AND Created < '2016-02-21'
;

-- 7 Bookmarks (Lines up with CMS)
-- 14 Points

-- Status Updates:
SELECT COUNT(*) AS StatusUpdateCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) AS NonDisabledStatusUpdateCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) AS DisabledStatusUpdateCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) * 5 + COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) * (-5) AS StatusUpdateScore
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECKINS.CheckInId = NOTES.CheckInId
WHERE CHECKINS.ItemId = 10446026
AND CHECKINS.Created >= '2016-02-12'
AND CHECKINS.Created < '2016-02-21'
;

-- 5 Status Updates (Lines up with CMS)
-- 25 Points

-- Speaker Ratings:
SELECT COUNT(*) AS RatingsCnt
     , COUNT(*) * 3 AS RatingsScore
FROM PUBLIC.Ratings_ItemRatings
WHERE ItemId = 10446026
AND IsDisabled = FALSE
AND Created >= '2016-02-12'
AND Created < '2016-02-21'
;

-- 8 Reviews
-- 24 Points

-- View Counts:
SELECT COUNT(*) AS ViewCnt
     , COUNT(DISTINCT VIEWS.Global_User_Id) AS UserCnt
FROM PUBLIC.Fact_Views_Live VIEWS
JOIN (SELECT DISTINCT ItemId
           , ParentTopicId
      FROM PUBLIC.Ratings_Item) ITEMS
ON CAST(VIEWS.Metadata->>'ItemId' AS INT) = ITEMS.ItemId
JOIN PUBLIC.Ratings_Topic TOPICS
ON ITEMS.ParentTopicId = TOPICS.TopicId
JOIN (SELECT DISTINCT LOWER(GlobalUserId) AS GlobalUserId
      FROM PUBLIC.AuthDB_IS_Users USERS
      WHERE ApplicationId = 'AF310B9B-E31C-4851-8E33-22C210CDAAF0'
      AND IsDisabled = 0) USERS
ON VIEWS.Global_User_Id = USERS.GlobalUserId
WHERE VIEWS.Identifier = 'item'
AND VIEWS.Application_Id = 'af310b9b-e31c-4851-8e33-22c210cdaaf0'
AND VIEWS.Created >= '2016-02-12'
AND VIEWS.Created < '2016-02-21'
AND ITEMS.ItemId = 10446026
;
-- 151

SELECT COUNT(*) AS LikeCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) AS NonDisabledLikeCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) AS DisabledLikeCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) * 2 + COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) * (-2) AS LikeScore
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECKINS.CheckInId = NOTES.CheckInId
JOIN PUBLIC.Ratings_UserCheckInLikes LIKES
ON CHECKINS.CheckInId = LIKES.CheckInId
WHERE CHECKINS.ItemId = 10446026
AND CHECKINS.Created >= '2016-02-12'
AND CHECKINS.Created < '2016-02-21'
;

-- 17 Likes
-- 34 Points

SELECT COUNT(*) AS CheckInCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) AS NonDisabledCheckInCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) AS DisabledCheckInCnt
     , COUNT(CASE WHEN CHECKINS.IsDisabled = FALSE OR CHECKINS.IsDisabled IS NULL THEN 1 ELSE NULL END) * 2 + COUNT(CASE WHEN CHECKINS.IsDisabled = TRUE THEN 1 ELSE NULL END) * (-2) AS CheckInScore
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
WHERE CHECKINS.ItemId = 10446026
AND CHECKINS.Created >= '2016-02-12'
AND CHECKINS.Created < '2016-02-21'
;

-- 5
-- 10