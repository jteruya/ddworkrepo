-- Posts per Day (in 2016)
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDD
     , COUNT(CASE WHEN NOTES.CheckInId IS NOT NULL OR IMAGES.CheckInId IS NOT NULL THEN 1 ELSE NULL END) AS PostCnt
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
LEFT JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECKINS.CheckInId = NOTES.CheckInId
LEFT JOIN PUBLIC.Ratings_UserCheckInImages IMAGES
ON CHECKINS.CheckInId = IMAGES.CheckInId
WHERE CHECKINS.Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;

-- Posts per 15 Minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_Posts;
CREATE TABLE JT.SOEP_Benchmark_Posts AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(CASE WHEN NOTES.CheckInId IS NOT NULL OR IMAGES.CheckInId IS NOT NULL THEN 1 ELSE NULL END) AS PostCnt
     , COUNT(CASE WHEN IMAGES.CheckInId IS NOT NULL THEN 1 ELSE NULL END) AS ImagePostCnt
FROM PUBLIC.Ratings_UserCheckIns CHECKINS
JOIN PUBLIC.AuthDB_Applications EVENTS
ON CHECKINS.ApplicationId = EVENTS.ApplicationId
LEFT JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECKINS.CheckInId = NOTES.CheckInId
LEFT JOIN PUBLIC.Ratings_UserCheckInImages IMAGES
ON CHECKINS.CheckInId = IMAGES.CheckInId
WHERE CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
AND EVENTS.CanRegister = 'true'
GROUP BY 1,2,3
ORDER BY 1,2,3
;


-- Likes per Day (in 2016)
SELECT CAST(EXTRACT(YEAR FROM Created) * 10000 + EXTRACT(MONTH FROM Created) * 100 + EXTRACT(DAY FROM Created) AS INT) AS YYYYMMDD
     , COUNT(*) AS LikesCnt
FROM PUBLIC.Ratings_UserCheckInLikes
WHERE Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;

-- Likes per 15 minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_Likes;
CREATE TABLE JT.SOEP_Benchmark_Likes AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(*) AS LikeCnt
FROM PUBLIC.Ratings_UserCheckInLikes CHECKINS
JOIN PUBLIC.AuthDB_Applications EVENTS
ON CHECKINS.ApplicationId = EVENTS.ApplicationId
WHERE CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
AND EVENTS.CanRegister = 'true'
GROUP BY 1,2,3
ORDER BY 1,2,3
;


-- Comments per Day (in 2016)
SELECT CAST(EXTRACT(YEAR FROM Created) * 10000 + EXTRACT(MONTH FROM Created) * 100 + EXTRACT(DAY FROM Created) AS INT) AS YYYYMMDD
     , COUNT(*) AS CommentCnt
FROM PUBLIC.Ratings_UserCheckInComments
WHERE Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;


-- Comments per 15 Minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_Comments;
CREATE TABLE JT.SOEP_Benchmark_Comments AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(*) AS LikeCnt
FROM PUBLIC.Ratings_UserCheckInComments CHECKINS
JOIN PUBLIC.AuthDB_Applications EVENTS
ON CHECKINS.ApplicationId = EVENTS.ApplicationId
WHERE CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
AND EVENTS.CanRegister = 'true'
GROUP BY 1,2,3
ORDER BY 1,2,3
;



-- Follows per Day (in 2016)
SELECT CAST(EXTRACT(YEAR FROM Created) * 10000 + EXTRACT(MONTH FROM Created) * 100 + EXTRACT(DAY FROM Created) AS INT) AS YYYYMMDD
     , COUNT(*) AS FollowCnt
FROM PUBLIC.Ratings_UserTrust
WHERE Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;

-- Follows per 15 Minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_Follows;
CREATE TABLE JT.SOEP_Benchmark_Follows AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(*) AS LikeCnt
FROM PUBLIC.Ratings_UserTrust CHECKINS
JOIN (SELECT DISTINCT UserId
      FROM PUBLIC.AuthDB_IS_Users USERS
      JOIN PUBLIC.AuthDB_Applications EVENTS
      ON USERS.ApplicationId = EVENTS.ApplicationId
      WHERE EVENTS.CanRegister = 'true'
     ) USERS
ON CHECKINS.UserId = USERS.UserId
WHERE CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
GROUP BY 1,2,3
ORDER BY 1,2,3
;

-- Bookmarks per Day (in 2016)
SELECT CAST(EXTRACT(YEAR FROM Created) * 10000 + EXTRACT(MONTH FROM Created) * 100 + EXTRACT(DAY FROM Created) AS INT) AS YYYYMMDD
     , COUNT(*) AS BookmarkCnt
FROM PUBLIC.Ratings_UserFavorites
WHERE Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;

-- Bookmarks per 15 Minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_Bookmarks;
CREATE TABLE JT.SOEP_Benchmark_Bookmarks AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(*) AS LikeCnt
FROM PUBLIC.Ratings_UserFavorites CHECKINS
JOIN PUBLIC.AuthDB_Applications EVENTS
ON CHECKINS.ApplicationId = EVENTS.ApplicationId
WHERE CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
AND EVENTS.CanRegister = 'true'
GROUP BY 1,2,3
ORDER BY 1,2,3
;


-- Activity Feed View (in 2016)
SELECT CAST(EXTRACT(YEAR FROM Created) * 10000 + EXTRACT(MONTH FROM Created) * 100 + EXTRACT(DAY FROM Created) AS INT) AS YYYYMMDD
     , COUNT(*) AS ViewCnt
FROM PUBLIC.Fact_Views_Live
WHERE Identifier = 'activities'
AND Metadata->>'Type' = 'global'
AND Created >= '2016-01-01'
GROUP BY 1
ORDER BY 1
;

-- Activity Feed View per 15 Minutes (in 2016)
DROP TABLE IF EXISTS JT.SOEP_Benchmark_ActivityFeed;
CREATE TABLE JT.SOEP_Benchmark_ActivityFeed AS
SELECT CAST(EXTRACT(YEAR FROM CHECKINS.Created) * 10000 + EXTRACT(MONTH FROM CHECKINS.Created) * 100 + EXTRACT(DAY FROM CHECKINS.Created) AS INT) AS YYYYMMDDHH
     , CAST(EXTRACT(HOUR FROM CHECKINS.Created) AS INT) AS Hour
     , CASE 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 15 THEN 0
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 15 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 30 THEN 15
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 30 AND CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) < 45 THEN 30 
         WHEN CAST(EXTRACT(MINUTE FROM CHECKINS.Created) AS INT) >= 45 THEN 45
       END AS MinuteWindow
     , COUNT(*) AS LikeCnt
FROM PUBLIC.Fact_Views_Live CHECKINS
JOIN PUBLIC.AuthDB_Applications EVENTS
ON CHECKINS.Application_Id = LOWER(EVENTS.ApplicationId)
WHERE CHECKINS.Identifier = 'activities'
AND CHECKINS.Metadata->>'Type' = 'global'
AND CHECKINS.Created >= '2016-01-01'
AND CHECKINS.Created < CURRENT_DATE
AND EVENTS.CanRegister = 'true'
GROUP BY 1,2,3
ORDER BY 1,2,3
;

-- Outlier Data
-- Posts
SELECT HourWindow
     , PostCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY PostCnt DESC) AS PostRank
           , PostCnt
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY ImagePostCnt DESC) AS ImagePostRank
           , ImagePostCnt
      FROM JT.SOEP_Benchmark_Posts
     ) A
WHERE PostRank <= 10
ORDER BY HourWindow, PostRank
;


-- Posts Images
SELECT HourWindow
     , ImagePostCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY PostCnt DESC) AS PostRank
           , PostCnt
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY ImagePostCnt DESC) AS ImagePostRank
           , ImagePostCnt
      FROM JT.SOEP_Benchmark_Posts
     ) A
WHERE ImagePostRank <= 10
ORDER BY HourWindow, ImagePostRank
;

-- Likes
SELECT HourWindow
     , LikeCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY LikeCnt DESC) AS LikeRank
           , LikeCnt
      FROM JT.SOEP_Benchmark_Likes
     ) A
WHERE LikeRank <= 10
ORDER BY HourWindow, LikeRank
;

-- Comments
SELECT HourWindow
     , LikeCnt AS CommentCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY LikeCnt DESC) AS LikeRank
           , LikeCnt
      FROM JT.SOEP_Benchmark_Comments
     ) A
WHERE LikeRank <= 10
ORDER BY HourWindow, LikeRank
;

-- Follows
SELECT HourWindow
     , LikeCnt AS FollowCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY LikeCnt DESC) AS LikeRank
           , LikeCnt
      FROM JT.SOEP_Benchmark_Follows
     ) A
WHERE LikeRank <= 10
ORDER BY HourWindow, LikeRank
;

-- Bookmarks
SELECT HourWindow
     , LikeCnt AS BookmarkCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY LikeCnt DESC) AS LikeRank
           , LikeCnt
      FROM JT.SOEP_Benchmark_Bookmarks
     ) A
WHERE LikeRank <= 10
ORDER BY HourWindow, LikeRank
;

-- Activity Feed
SELECT HourWindow
     , LikeCnt AS ViewCnt
FROM (SELECT Hour * 100 + MinuteWindow AS HourWindow
           , ROW_NUMBER() OVER (PARTITION BY Hour, MinuteWindow ORDER BY LikeCnt DESC) AS LikeRank
           , LikeCnt
      FROM JT.SOEP_Benchmark_ActivityFeed
     ) A
WHERE LikeRank <= 10
ORDER BY HourWindow, LikeRank
;
