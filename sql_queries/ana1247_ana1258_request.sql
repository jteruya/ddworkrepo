-- Create table for Unhashed GlobalUserDetail
DROP TABLE IF EXISTS jt.ratings_GlobalUserDetails;
CREATE TABLE jt.ratings_GlobalUserDetails (
     globaluserid varchar
   , emailaddress varchar
   , username varchar
   , firstname varchar
   , lastname varchar
   , title varchar
   , company varchar
   , phone varchar
   , created timestamp);
   
select count(*)
from jt.ratings_GlobalUserDetails;

select count(*)
from jt.ratings_useridentifier;
   
-- Bring in Unhashed GlobalUserDetails using db_etl
-- java -jar ProductionDatabaseETL-1.1.jar json/adhoc/jt_ratings_globaluserdetails.json


-- "Number of status updates by users" exportable report.
SELECT ud.UserId
     , gud.EmailAddress
     , gud.Created
     , gud.FirstName
     , gud.LastName
     , ud.TwitterUserName
     , gud.Title
     , gud.Company
     , gud.Phone
     , ud.GlobalUserId
     , COALESCE(uci.CNT,0) AS NoOfCheckIns
     , COALESCE(ucil.CNT,0) AS NoOfLikesReceived
FROM ratings_UserDetails ud
JOIN jt.ratings_GlobalUserDetails gud 
ON ud.GlobalUserId = upper(gud.GlobalUserId)
--Status Update Count
LEFT JOIN (SELECT UserId
                , COUNT(*) AS CNT 
           FROM (SELECT uci.UserId
                      , i.Created
                      , i.ApplicationId 
                 FROM ratings_UserCheckIns uci 
                 JOIN ratings_Item i 
                 ON uci.ItemId = i.ItemId 
                 WHERE uci.ItemId IS NOT NULL 
                 --AND i.Created >= StartDate 
                 --AND i.Created <= EndDate
                 UNION ALL
                 SELECT uci.UserId
                      , NULL AS Created
                      , NULL AS ApplicationId 
                 FROM ratings_UserCheckIns uci 
                 WHERE uci.ItemId IS NULL)  a
            GROUP BY UserId) uci 
ON ud.UserId = uci.UserId
--Status Update Like Count
LEFT JOIN (SELECT UserId
                , COUNT(*) AS CNT 
           FROM (SELECT uci.UserId
                      , i.Created
                      , i.ApplicationId 
                 FROM ratings_UserCheckIns uci 
                 JOIN ratings_Item i 
                 ON uci.ItemId = i.ItemId 
                 JOIN ratings_UserCheckInLikes ucil 
                 ON uci.CheckInId = ucil.CheckInId 
                 WHERE uci.ItemId IS NOT NULL 
                 --AND i.Created >= StartDate 
                 --AND i.Created <= EndDate
                 UNION ALL
                 SELECT uci.UserId
                      , NULL AS Created
                      , NULL AS ApplicationId 
                 FROM ratings_UserCheckIns uci 
                 JOIN ratings_UserCheckInLikes ucil 
                 ON uci.CheckInId = ucil.CheckInId 
                 WHERE uci.ItemId IS NULL) a
           GROUP BY UserId) ucil 
ON ud.UserId = ucil.UserId
WHERE ud.IsDisabled = 0
AND ud.applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'
ORDER BY ud.UserId DESC;


-- "User activities count" exportable report.

SELECT
ud.UserId,
gud.EmailAddress,
gud.Created AS UserRegisteredDate,
gud.FirstName,
gud.LastName,
ud.TwitterUserName,
gud.Title,
gud.Company,
gud.Phone,
ud.GlobalUserId,
COALESCE(uci.CNT,0) AS NoOfStatusUpdates,
COALESCE(su.CNT,0) AS NoOfCheckIns,
COALESCE(ucil.CNT,0) AS NoOfLikes,
COALESCE(ucic.CNT,0) + COALESCE(ucin.CNT,0) AS NoOfComments,
COALESCE(ir.CNT,0) AS NoOfRatings,
COALESCE(ucii.CNT,0) AS NoOfPhotos,
--<join to UserGroups via UserGroupsMappings and concatenate list of Name values from related UserGroups>,
COALESCE(s.CNT,0) AS NoOfSurveysCompleted
FROM ratings_UserDetails ud
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
LEFT JOIN (SELECT uci.UserId, COUNT(*) AS CNT FROM ratings_UserCheckIns uci WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' /*uci.Created >= StartDate AND uci.Created <= EndDate AND uci.ApplicationId = ApplicationId*/ GROUP BY uci.UserId) uci ON ud.UserId = uci.UserId
LEFT JOIN (SELECT su.UserId, COUNT(*) AS CNT FROM ratings_ShowUps su WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' AND /*su.Created >= StartDate AND su.Created <= EndDate AND su.ApplicationId = ApplicationId AND*/ su.IsDisabled <> true GROUP BY su.UserId) su ON ud.UserId = su.UserId
LEFT JOIN (SELECT ucil.UserId, COUNT(*) AS CNT FROM ratings_UserCheckInLikes ucil WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' AND /*ucil.Created >= StartDate AND ucil.Created <= EndDate AND ucil.ApplicationId = ApplicationId AND*/ ucil.IsDisabled <> true GROUP BY ucil.UserId) ucil ON ud.UserId = ucil.UserId
LEFT JOIN (SELECT ucic.UserId, COUNT(*) AS CNT FROM ratings_UserCheckInComments ucic WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'/*ucic.Created >= StartDate AND ucic.Created <= EndDate AND ucic.ApplicationId = ApplicationId*/ GROUP BY ucic.UserId) ucic ON ud.UserId = ucic.UserId
LEFT JOIN (SELECT uci.UserId, COUNT(*) AS CNT FROM ratings_UserCheckInNotes ucin JOIN ratings_UserCheckIns uci ON uci.CheckInId = ucin.CheckInId WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' /*ucin.Created >= StartDate AND ucin.Created <= EndDate AND ucin.ApplicationId = ApplicationId*/ GROUP BY uci.UserId) ucin ON ud.UserId = ucin.UserId
LEFT JOIN (SELECT ir.UserId, COUNT(*) AS CNT FROM ratings_ItemRatings ir WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' /*ir.Created >= StartDate AND ir.Created <= EndDate AND ir.ApplicationId = ApplicationId*/ GROUP BY ir.UserId) ir ON ud.UserId = ir.UserId
LEFT JOIN (SELECT uci.UserId, COUNT(*) AS CNT FROM ratings_UserCheckInImages ucii JOIN ratings_UserCheckIns uci ON uci.CheckInId = ucii.CheckInId WHERE uci.applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' /*ucii.Created >= StartDate AND ucii.Created <= EndDate AND ucii.ApplicationId = ApplicationId*/ GROUP BY uci.UserId) ucii ON ud.UserId = ucii.UserId
LEFT JOIN (SELECT sr.UserId, COUNT(DISTINCT s.SurveyId) AS CNT FROM ratings_Surveys s JOIN ratings_SurveyQuestions sq ON s.SurveyId = sq.SurveyId JOIN ratings_SurveyResponses sr ON sq.SurveyQuestionId = sr.SurveyQuestionId WHERE applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7' GROUP BY sr.UserId) s ON ud.UserId = s.UserId
WHERE ud.IsDisabled = 0
AND ud.applicationid = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'
AND (COALESCE(uci.CNT,0) > 0 OR COALESCE(su.CNT,0) > 0 OR COALESCE(ucil.CNT,0) > 0 OR COALESCE(ucic.CNT,0) > 0 OR COALESCE(ir.CNT,0) > 0 OR COALESCE(ucii.CNT,0) > 0);


-- "Status updates with associated comments, likes" exportable report.

-- The following is the interpretation query of Status Updates:

SELECT
uci.Created,
uci.CheckInId AS StatusUpdateId,
gud.FirstName AS AttendeeFirstName,
gud.LastName AS AttendeeLastName,
gud.EmailAddress AS AttendeeEmail,
'Status Update' AS ActionType,
ucin.Notes AS Text,
item.name AS ItemName,
CASE WHEN ucii.CheckInId IS NOT NULL THEN 'Y' ELSE '' END AS PhotoAttached,
CASE WHEN uci.IsDisabled = 'false' THEN 'Y' ELSE '' END AS Deleted
FROM ratings_UserCheckIns uci
JOIN ratings_UserDetails ud ON uci.UserId = ud.UserId
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
LEFT JOIN ratings_UserCheckInNotes ucin ON uci.CheckInId = ucin.CheckInId
LEFT JOIN ratings_UserCheckInImages ucii ON uci.CheckInId = ucii.CheckInId
LEFT JOIN ratings_item item ON uci.itemid = item.itemid
WHERE /*uci.Created > StartDate AND uci.Created < EndDate AND*/ uci.ApplicationId = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'
UNION

-- The following is the interpretation query of Status Updates Comments:
SELECT
ucic.Created,
ucic.CheckInId AS StatusUpdateId,
gud.FirstName AS AttendeeFirstName,
gud.LastName AS AttendeeLastName,
gud.EmailAddress AS AttendeeEmail,
'Comment' AS ActionType,
ucic.Comments AS Text,
'' AS ItemName,
'' AS PhotoAttached,
CASE WHEN ucic.IsDisabled = 'false' THEN 'Y' ELSE '' END AS Deleted
FROM ratings_UserCheckInComments ucic
JOIN ratings_UserDetails ud ON ucic.UserId = ud.UserId
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
WHERE /*ucic.Created > StartDate AND ucic.Created < EndDate AND*/ ucic.ApplicationId = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'
UNION
-- The following is the interpretation query of Status Updates Likes:
SELECT
ucil.Created,
ucil.CheckInId AS StatusUpdateId,
gud.FirstName AS AttendeeFirstName,
gud.LastName AS AttendeeLastName,
gud.EmailAddress AS AttendeeEmail,
'Like' AS ActionType,
'' AS Text,
'' AS ItemName,
'' AS PhotoAttached,
CASE WHEN ucil.IsDisabled = 'false' THEN 'Y' ELSE '' END AS Deleted
FROM ratings_UserCheckInLikes ucil
JOIN ratings_UserDetails ud ON ucil.UserId = ud.UserId
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
WHERE /*ucil.Created > StartDate AND ucil.Created < EndDate AND*/ ucil.ApplicationId = 'FBB4FD56-2B96-4773-8859-AF13AE2519F7'
ORDER BY 2,6,1;

--Those three sets are then UNION'd and ORDER BY StatusUpdateID, ActionType, Created.

drop table if exists jt.ratings_useridentifier;
create table jt.ratings_useridentifier as (
select * from ratings_useridentifier limit 0);


-- Survey Results by User

SELECT
ud.UserId,
ui.UserIdentifierId,
gud.FirstName,
gud.LastName,
gud.EmailAddress,
gud.Title,
gud.Company,
'' AS UserGroups,
sr.Created,
i.itemName AS Item,
i.ItemIdentifierId,
sq.Name AS Question,
sq.Description,
s.Name AS Survey,
i.listName AS LIst,
CASE WHEN sqo.SurveyQuestionOptionId IS NOT NULL THEN sqo.Name ELSE sr.Value END,
'' AS FiltersList
FROM ratings_SurveyResponses sr
JOIN ratings_UserDetails ud ON sr.UserId = ud.UserId
JOIN ratings_UserIdentifier ui ON sr.UserId = ui.UserId
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
LEFT JOIN (SELECT i.ItemId, i.Name as itemname, ii.ItemIdentifierId, t.Name as listname FROM ratings_Item i JOIN ratings_ItemIdentifier ii ON i.ItemId = ii.ItemId JOIN ratings_Topic t ON i.ParentTopicId = t.TopicId) i ON sr.ItemId = i.ItemId
JOIN ratings_SurveyQuestions sq ON sr.SurveyQuestionId = sq.SurveyQuestionId
JOIN ratings_Surveys s ON sq.SurveyId = s.SurveyId
LEFT JOIN ratings_SurveyQuestionOptions sqo ON sr.SurveyQuestionOptionId = sqo.SurveyQuestionOptionId
WHERE ud.ApplicationId = '4BF76576-A7EA-44FC-AD69-09173F86C7CD';


select *
from ratings_UserIdentifier
where lower(applicationid) = '4bf76576-a7ea-44fc-ad69-09173f86c7cd'


select count(*)
     , count(case when created < current_date - interval '13 months' then 1 else null end)
from authdb_is_users
where lower(applicationid) = '27380d09-5efa-428a-bada-c0b8663ed448'
and isdisabled = 0;

SELECT count(distinct sr.userid)
FROM ratings_SurveyResponses sr
JOIN ratings_UserDetails ud ON sr.UserId = ud.UserId 
JOIN ratings_UserIdentifier ui ON sr.UserId = ui.UserId
--JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
WHERE ud.ApplicationId = '27380D09-5EFA-428A-BADA-C0B8663ED448';

-- 25,148

select count(*)
from ratings_UserDetails 
WHERE ApplicationId = '27380D09-5EFA-428A-BADA-C0B8663ED448' limit 10;

-- 42,912

SELECT *
FROM ratings_UserIdentifier LIMIT 10;

SELECT *
FROM jt.ratings_globaluserdetails
WHERE globaluserid = '05B8EB7E-73A2-4FF1-AEAF-5764B11B3A8F';