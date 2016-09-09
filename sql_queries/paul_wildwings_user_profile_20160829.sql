-- One Example
SELECT *
FROM Kevin.Ratings_GlobalUserDetails
WHERE ApplicationId = '6C45CA53-19C2-46E1-9405-E66B3ACD128E'
AND emailaddress = 'joken_z@msn.com'
;

-- 41D13BF6-5110-421A-BEA1-843A9C3F8FEA

SELECT COUNT(DISTINCT Session_Id)
FROM PUBLIC.Fact_Sessions_Live
WHERE Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e'
AND Global_User_Id = '41d13bf6-5110-421a-bea1-843a9c3f8fea'
;

-- 2 Sessions

SELECT DISTINCT Device_Id
FROM PUBLIC.Fact_Sessions_Live
WHERE Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e'
AND Global_User_Id = '41d13bf6-5110-421a-bea1-843a9c3f8fea'
;

-- DEVICE_ID: d53f9056-24ec-42c1-9de2-8416efd23010

SELECT *
FROM PUBLIC.Fact_Sessions_Live
WHERE Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e'
AND Global_User_Id = '41d13bf6-5110-421a-bea1-843a9c3f8fea'
;

-- 6.0.1, 6.24.0.0, trltevzw,SM-N910V,samsung


------------
SELECT GlobalUserId
     , FirstName
     , LastName
     , Company
     , Title
FROM Kevin.Ratings_GlobalUserDetails
WHERE ApplicationId = '6C45CA53-19C2-46E1-9405-E66B3ACD128E'
AND (LastName IS NULL OR TRIM(LastName) = '')
;



SELECT USERS.GlobalUserId
     , IS_USERS.UserId
     , USERS.EmailAddress
     , USERS.UserName
     , USERS.FirstName
     , USERS.LastName
     , USERS.Company
     , USERS.Title
     --, SESSIONS.Binary_Version
     , SESSIONS.Device_Type
     , SESSIONS.MMM_Info
     , COUNT(DISTINCT SESSIONS.Session_Id) AS SessionCnt
     , MIN(SESSIONS.Created) AS SessionCreated
     , IS_USERS.UserCreated
     , CASE WHEN A_FEED.Global_User_Id IS NOT NULL THEN 1 ELSE NULL END AS ActivityFeedFlag
FROM (SELECT GlobalUserId
           , FirstName
           , LastName
           , Company
           , Title
           , EmailAddress
           , UserName
      FROM Kevin.Ratings_GlobalUserDetails
      WHERE ApplicationId = '6C45CA53-19C2-46E1-9405-E66B3ACD128E'
      AND (LastName IS NULL OR TRIM(LastName) = '')) USERS
LEFT JOIN (SELECT GlobalUserId
                , UserId
                , MIN(Created) AS UserCreated
           FROM PUBLIC.AuthDB_IS_Users
           WHERE ApplicationId = '6C45CA53-19C2-46E1-9405-E66B3ACD128E'
           GROUP BY 1,2) IS_USERS
ON USERS.GlobalUserId = IS_USERS.GlobalUserId           
LEFT JOIN (SELECT *
           FROM PUBLIC.Fact_Sessions_Live 
           WHERE Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e') SESSIONS
ON LOWER(USERS.GlobalUserId) = SESSIONS.Global_User_Id
LEFT JOIN (SELECT DISTINCT Global_User_Id
           FROM PUBLIC.Fact_Views_Live
           WHERE Identifier = 'activities'
           AND Metadata->>'Type' = 'global'
           AND Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e') A_FEED
ON LOWER(USERS.GlobalUserId) = A_FEED.Global_User_Id           
GROUP BY 1,2,3,4,5,6,7,8,9,10,13,14
ORDER BY 11 DESC
;


           
SELECT *
FROM PUBLIC.Ratings_UserCheckIns CHECK_INS
JOIN PUBLIC.Ratings_UserCheckInNotes NOTES
ON CHECK_INS.CheckInId = NOTES.CheckInId
WHERE CHECK_INS.ApplicationId = '6C45CA53-19C2-46E1-9405-E66B3ACD128E'
;
           
   
           
SELECT DISTINCT Identifier
FROM PUBLIC.Fact_Views_Live
WHERE Application_Id = '6c45ca53-19c2-46e1-9405-e66b3acd128e'
AND Global_User_Id IN (
'666bfe43-c713-4fcb-a074-6af3a6f4132c',
'f2a97ac3-b521-4101-93b7-24c58d80266b',
'21e6f7f2-4eb8-46da-aaf3-1cf73e475bbe',
'06277967-1c0e-4df8-ae11-eb8bc975bf69',
'0e251eef-6b51-41a6-9815-4f56e8f021c9',
'd86140ee-73d3-43b9-a1d3-5e3085b125d2',
'18d4c839-fb18-4d8e-b43a-f5bdc8341cde',
'40f40c57-6df3-4661-9077-b99485a3891f',
'cbcb435e-0746-4d55-bf44-4ba030124146',
'13c560a2-dc1c-4bef-aece-ca9ca8eb8cd5',
'18657df2-ec1b-4ef4-98e1-fdd1ca0eee03',
'2c506d78-33bf-4bec-957c-356d1935e05b',
'6d1986a8-03ec-43b8-b0d3-37e5833dc103',
'70010f36-cd40-4c21-909d-7be226137e7f',
'71343d91-1104-411f-9352-693b692e4fa2',
'ae81cd5e-9e7a-450a-9792-87d791c3845c',
'd7518f25-f8a4-42d3-b090-e9ae659763f5',
'f0d48a65-28c5-4531-b60b-fa944deaadf6',
'4f000b25-1f12-4295-bc91-295a0f2b4eb1',
'c68039e5-f3b2-4ace-9304-f6a4829a3999',
'cb1701cf-6231-4ec4-b3c8-617831872e7a',
'a21ecd8e-cfad-4742-bebf-7361f15fb51d',
'2c629e9e-f925-45c2-8755-f8cfc31a42b1',
'd96bb825-44df-4deb-a111-d31645f91561',
'9e83c5b8-1f80-4160-975c-0e946ce7aa12',
'15ef471e-f43b-402b-93ae-1b4e5f49efb2',
'64a8b02a-3016-45ae-ad27-5ff76dffa41e',
'f711e536-6256-44dc-893f-507b6b8a1179',
'f9396187-ab55-43ce-9e8e-d9c83476af33',
'f9a71ea2-a617-42c8-bf7e-c9aee90c365d',
'cbaf0a3a-39e7-493e-956d-5ff169bda85c',
'9e921025-84cf-4b51-aa35-115b83c24d51',
'f48392b9-d7e9-455f-a2fd-5876fd76a813')
;
