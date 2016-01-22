--Get the set of Sessions that we'd look at
DROP TABLE IF EXISTS jt.linkedinimport_sessions;
CREATE TABLE jt.linkedinimport_sessions AS
SELECT
UPPER(Application_Id) AS ApplicationId,
User_Id AS UserId,
Binary_Version,
Start_Date
FROM PUBLIC.Fact_Sessions
WHERE Start_Date >= '2015-07-01 00:00:00'
AND Application_Id IN (SELECT LOWER(ApplicationId) AS ApplicationId FROM AuthDB_Applications WHERE StartDate >= '2015-07-01 00:00:00');

--Identify just users for which their first session was 5.18+
DROP TABLE IF EXISTS jt.linkedinimport_users_beginning_518;
CREATE TABLE jt.linkedinimport_users_beginning_518 AS
SELECT DISTINCT ApplicationId, UserId, Binary_Version, Start_Date AS StartDate FROM (
SELECT
ApplicationId, UserId, Binary_Version, Start_Date,
RANK() OVER (PARTITION BY ApplicationId, UserId ORDER BY Start_Date ASC) AS RNK
FROM jt.linkedinimport_sessions
) t WHERE RNK = 1
AND (Binary_Version like '5.18%' OR Binary_Version like '5.19%' OR Binary_Version like '5.2%');

--For these users beginning with 5.18, from those events, get the set of CreateProfileButton actions
DROP TABLE IF EXISTS jt.linkedinimport_createprofilebutton_taps;
CREATE TABLE jt.linkedinimport_createprofilebutton_taps AS
SELECT UPPER(Application_Id) AS ApplicationId
     , UPPER(Global_User_Id) AS GlobalUserId
     , Created
     , Metadata ->> 'view' AS ViewType
     , Metadata ->> 'type' AS ButtonType
FROM PUBLIC.Fact_Actions 
WHERE Identifier = 'createprofilebutton'
AND UPPER(Application_Id) IN (SELECT DISTINCT ApplicationId FROM jt.linkedinimport_users_beginning_518);

--For these users beginning with 5.18, from those events, get the set of AddSocialNetworkProfileButton actions
DROP TABLE IF EXISTS jt.linkedinimport_createprofilebutton_profile_taps;
CREATE TABLE jt.linkedinimport_createprofilebutton_profile_taps AS
SELECT UPPER(Application_Id) AS ApplicationId
     , UPPER(Global_User_Id) AS GlobalUserId
     , Created
FROM PUBLIC.Fact_Actions 
WHERE Identifier = 'addsocialnetworktoprofilebutton'
AND metadata->>'view' = 'profile'
AND metadata->>'network' = 'linkedin'
AND UPPER(Application_Id) IN (SELECT DISTINCT ApplicationId FROM jt.linkedinimport_users_beginning_518);

--Per user beginning with 5.18, how many taps were performed on the CreateProfileButton actions possible?
DROP TABLE IF EXISTS jt.linkedinimport_createprofilebutton_taps_agg;
CREATE TABLE jt.linkedinimport_createprofilebutton_taps_agg AS
SELECT a.ApplicationId
     , iu.UserId
     , SUM(CASE WHEN a.ButtonType = 'linkedin' AND a.ViewType = 'eventprofilechoice' THEN 1 ELSE 0 END) AS LinkedIn_EPC_Taps
     , MIN(CASE WHEN a.ButtonType = 'linkedin' AND a.ViewType = 'eventprofilechoice' THEN a.created ELSE null END) As LinkedIn_EPC_First_Tap
     , SUM(CASE WHEN a.ButtonType = 'linkedin' AND a.ViewType = 'profilefiller' THEN 1 ELSE 0 END) AS LinkedIn_PF_Taps
     , MIN(CASE WHEN a.ButtonType = 'linkedin' AND a.ViewType = 'profilefiller' THEN a.created ELSE null END) AS LinkedIn_PF_First_Tap
     , SUM(CASE WHEN a.ButtonType = 'manual' THEN 1 ELSE 0 END) AS ManualTaps
     , MIN(CASE WHEN a.ButtonType = 'manual' THEN a.created ELSE null END) As First_Manual_Tap
     , SUM(CASE WHEN c.ApplicationId IS NOT NULL THEN 1 ELSE NULL END) As LinkedIn_SocialNetwork_Taps
     , MIN(CASE WHEN c.ApplicationId IS NOT NULL THEN c.created ELSE NULL END) As LinkedIn_SocialNetwork_First_Tap
FROM jt.linkedinimport_createprofilebutton_taps a 
JOIN AuthDB_IS_Users iu 
ON a.GlobalUserId = iu.GlobalUserId 
AND a.ApplicationId = iu.ApplicationId 
LEFT JOIN jt.linkedinimport_createprofilebutton_profile_taps c
ON a.GlobalUserId = c.GlobalUserId 
AND a.ApplicationId = c.ApplicationId
GROUP BY 1,2;


--Per user beginning with 5.18, classify each user based on their tap?
DROP TABLE IF EXISTS jt.linkedinimport_createprofilebutton_taps_classify;
CREATE TABLE jt.linkedinimport_createprofilebutton_taps_classify AS
SELECT
CASE 
  WHEN Issue_Ind IS NOT NULL THEN 'Never experienced Event Profile Choice'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps > 0 AND LinkedIn_PF_Taps > 0 AND ManualTaps > 0 THEN 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps > 0 AND LinkedIn_PF_Taps > 0 AND ManualTaps = 0 THEN 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps > 0 AND LinkedIn_PF_Taps = 0 AND ManualTaps = 0 THEN 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps = 0 AND LinkedIn_PF_Taps > 0 AND ManualTaps = 0 THEN 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps > 0 AND LinkedIn_PF_Taps = 0 AND ManualTaps > 0 THEN 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps = 0 AND LinkedIn_PF_Taps > 0 AND ManualTaps > 0 THEN 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual'
  WHEN Issue_Ind IS NULL AND LinkedIn_EPC_Taps = 0 AND LinkedIn_PF_Taps = 0 AND ManualTaps > 0 THEN 'Tapped manual option only'
END AS EventProfileChoice_Case,
*
FROM (
SELECT distinct base.ApplicationId
     , base.UserId
     --, base.Binary_Version
     , CASE 
          WHEN agg.LinkedIn_EPC_Taps IS NULL AND LinkedIn_PF_Taps IS NULL AND agg.ManualTaps IS NULL THEN 'Never experienced Event Profile Choice' ELSE NULL 
       END AS Issue_Ind
     , agg.LinkedIn_EPC_Taps
     , LinkedIn_PF_Taps
     , agg.ManualTaps
FROM jt.linkedinimport_users_beginning_518 base
LEFT JOIN jt.linkedinimport_createprofilebutton_taps_agg agg 
ON base.ApplicationId = agg.ApplicationId AND base.UserId = agg.UserId
) t;





SELECT 
  CASE 
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped All Options - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped All Options - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NOT NULL THEN 'Never saw Event Profile Choice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NULL THEN 'Never saw Event Profile Choice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NOT NULL THEN 'Tapped manual option only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NULL THEN 'Tapped manual option only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped both LinkedIn options only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped both LinkedIn options only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn NOT connected'
    
  END AS ClickGroupType,
  COUNT(*) AS CNT
FROM jt.linkedinimport_createprofilebutton_taps_classify a
LEFT JOIN jt.ratings_userdetails lu ON a.ApplicationId = lu.ApplicationId AND a.UserId = lu.UserId
GROUP BY 1 ORDER BY 1;

SELECT 
  CASE 
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped All Options - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped All Options - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NOT NULL THEN 'Never saw Event Profile Choice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NULL THEN 'Never saw Event Profile Choice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NOT NULL THEN 'Tapped manual option only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NULL THEN 'Tapped manual option only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped both LinkedIn options only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped both LinkedIn options only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn NOT connected'
    
  END AS ClickGroupType,
  COUNT(*) AS CNT
FROM kevin.linkedinimport_createprofilebutton_taps_classify a
LEFT JOIN kevin.LinkedIn_Users lu ON a.ApplicationId = lu.ApplicationId AND a.UserId = lu.UserId
GROUP BY 1 ORDER BY 1;

select applicationid
     , startdate
     , enddate
     , sum(case when ClickGroupType like '%LinkedIn connected%' then CNT else 0 end)
     , sum(cnt)
     , sum(case when ClickGroupType like '%LinkedIn connected%' then CNT else 0 end)::decimal(12,4)/sum(cnt)::decimal(12,4)
             
from (
SELECT
  a.applicationid, 
  c.startdate,
  c.enddate,
  CASE 
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped All Options - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped all options - LinkedIn/Manual on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped All Options - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NOT NULL THEN 'Never saw Event Profile Choice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Never experienced Event Profile Choice' AND lu.UserId IS NULL THEN 'Never saw Event Profile Choice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NOT NULL THEN 'Tapped manual option only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped manual option only' AND lu.UserId IS NULL THEN 'Tapped manual option only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped both LinkedIn options only - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped both LinkedIn options only - LinkedIn on EventProfileChoice and LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped both LinkedIn options only - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on ProfileFiller' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on ProfileFiller - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NOT NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option only - LinkedIn on EventProfileChoice' AND lu.UserId IS NULL THEN 'Tapped only LinkedIn on EventProfileChoice - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on ProfileFiller and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(ProfileFiller) and manula option - LinkedIn NOT connected'
    
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NOT NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn connected'
    WHEN EventProfileChoice_Case = 'Tapped one LinkedIn option and manual option - LinkedIn on EventProfileChoice and manual' AND lu.UserId IS NULL THEN 'Tapped LinkedIn(EventProfileChoice) and manula option - LinkedIn NOT connected'
    
  END AS ClickGroupType,
  COUNT(*) AS CNT
FROM jt.linkedinimport_createprofilebutton_taps_classify a
LEFT JOIN jt.ratings_userdetails lu ON a.ApplicationId = lu.ApplicationId AND a.UserId = lu.UserId
join authdb_applications c
on a.applicationid = c.applicationid
GROUP BY 1,2,3,4) a
group by 1,2,3
order by 2,3;





select applicationid
     , update

select a.applicationid
     , a.userid
     , b.globaluserid
     , a.linkedin_epc_first_tap
     , a.linkedin_pf_first_tap
     , a.first_manual_tap
     , a.linkedin_socialnetwork_first_tap
     , c.update
from jt.linkedinimport_createprofilebutton_taps_agg a
join authdb_is_users b
on a.applicationid = b.applicationid and a.userid = b.userid
join jt.ratings_userdetails c
on b.globaluserid = c.globaluserid and a.applicationid = c.applicationid;




drop table if exists jt.linkedinimport_times;
create table jt.linkedinimport_times as
select a.applicationid
     , a.userid
     , b.startdate
     , b.enddate
     , a.update
from jt.linkedinimport_createprofilebutton_taps_classify d
join jt.ratings_userdetails a
ON a.ApplicationId = d.ApplicationId AND a.UserId = d.UserId
join authdb_applications b
on a.applicationid = b.applicationid;



select count(*)
from jt.linkedinimport_times
where update between startdate and enddate;


select count(*)
from jt.linkedinimport_times
where cast(update as date) <= enddate;

select count(*)
from jt.linkedinimport_times
where extract(month from update) between 7 and 9;

-- per event per day

select startdate
     , avg(count)
     , percentile_cont(0.5) within group (order by count)
from (
select applicationid
     , cast(startdate as date) as startdate
     , count(*) as count
from jt.linkedinimport_times
where extract(month from update) between 7 and 9
group by 1,2) a
group by 1;

select startdate
     , count(*)
from (
select distinct applicationid
     , cast(startdate as date) as startdate
from jt.linkedinimport_times
where extract(month from update) between 7 and 9) a
group by 1;




-- per day across all events
select avg(count)
     , percentile_cont(0.5) within group (order by count)
     , avg(case when eventdateflag = 0 then count else null end)
     , avg(case when eventdateflag = 1 then count else null end)
from (
select cast(update as date)
     , case 
         when cast(update as date) between startdate and enddate then 1
         else 0
       end as eventdateflag
     , count(*) as count
from jt.linkedinimport_times
where extract(month from update) between 7 and 9
group by 1,2) a;




select avg(count)
     , percentile_cont(0.5) within group (order by count)
from (
select extract(month from update)
     , count(*) as count
from jt.linkedinimport_times
where extract(month from update) between 7 and 9
group by 1) a;


