-- Create JT Version of globaluserdetails table
create table jt.ratings_globaluserdetails (
     globaluserid varchar
   , emailaddress varchar
   , username varchar
   , firstname varchar
   , lastname varchar
   , title varchar
   , company varchar
   , phone varchar
   , created timestamp);
   
-- Run adhoc version of globaluserdetails in robin
-- Command: java -jar DBSync-1.1.1.jar json/adhoc/jt_ratings_globaluserdetails.json

-- Ran the following sql on batman (adhoc project)
CREATE TEMPORARY TABLE survey_results_by_users as
SELECT
ud.UserId,
ui.UserIdentifierId,
gud.FirstName,
gud.LastName,
gud.EmailAddress,
gud.Title,
gud.Company,
--<concatenated string of all UserGroup.Name values tied via UserGroupMappings on UserId> AS UserGroups,
'' AS UserGroups,
sr.Created,
i.itemName AS Item,
i.ItemIdentifierId,
sq.Name AS Question,
sq.Description,
s.Name AS Survey,
i.topicname AS LIst,
'' AS FiltersList,
CASE WHEN sqo.SurveyQuestionOptionId IS NOT NULL THEN sqo.Name ELSE sr.Value end as value
--<serialized list of all Filter.Name values tied to ItemFilterMappings on ItemId> AS FiltersList
FROM ratings_SurveyResponses sr
JOIN ratings_UserDetails ud ON sr.UserId = ud.UserId
LEFT JOIN ratings_UserIdentifier ui ON sr.UserId = ui.UserId
JOIN jt.ratings_GlobalUserDetails gud ON ud.GlobalUserId = gud.GlobalUserId
LEFT JOIN (SELECT i.ItemId, i.Name as itemname, ii.ItemIdentifierId, t.Name as topicname FROM ratings_Item i JOIN ratings_ItemIdentifier ii ON i.ItemId = ii.ItemId JOIN ratings_Topic t ON i.ParentTopicId = t.TopicId) i ON sr.ItemId = i.ItemId
JOIN ratings_SurveyQuestions sq ON sr.SurveyQuestionId = sq.SurveyQuestionId
JOIN (select distinct applicationid
             , surveyid
             , name
             , itemid
       from ratings_surveys
       where applicationid = '27380D09-5EFA-428A-BADA-C0B8663ED448'
       and ispoll = false)s ON sq.SurveyId = s.SurveyId
LEFT JOIN ratings_SurveyQuestionOptions sqo ON sr.SurveyQuestionOptionId = sqo.SurveyQuestionOptionId
WHERE ud.ApplicationId = '27380D09-5EFA-428A-BADA-C0B8663ED448';

\copy survey_results_by_users to 'surveyresultsbyusers.csv' csv header;

-- Copied to Local Computer
-- Command: scp jteruya@10.223.176.157:/home/jteruya/adhoc/surveyresultsbyusers.csv ~/scp_recieve/

-- Split and compressed the file into 4 parts (10MB attachment limit in Jira)
--head -1 surveyresultsbyusers.csv > surveyresultsbyusersp1.csv
--head -1 surveyresultsbyusers.csv > surveyresultsbyusersp2.csv
--head -1 surveyresultsbyusers.csv > surveyresultsbyusersp3.csv
--head -1 surveyresultsbyusers.csv > surveyresultsbyusersp4.csv
--sed -n 2,442545p surveyresultsbyusers.csv >> surveyresultsbyusersp1.csv
--sed -n 442546,885089p surveyresultsbyusers.csv >> surveyresultsbyusersp2.csv
--sed -n 885090,1327634p surveyresultsbyusers.csv >> surveyresultsbyusersp3.csv
--sed -n 1327635,1770178p surveyresultsbyusers.csv >> surveyresultsbyusersp4.csv