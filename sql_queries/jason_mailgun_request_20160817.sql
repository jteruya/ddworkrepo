DROP TABLE IF EXISTS NonTestEvents;
CREATE TEMPORARY TABLE NonTestEvents AS
SELECT LOWER(ECS.ApplicationId)::UUID AS ApplicationId
FROM EventCube.EventCubeSummary ECS
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE TE.ApplicationId IS NULL
;



SELECT COUNT(*) -- Total: 10,608,714
/*
     -- NULL Subject
     , COUNT(CASE WHEN Subject IS NULL THEN 1 ELSE NULL END)
     
     -- Welcome Email
     , COUNT(CASE WHEN Subject ILIKE 'Welcome to%' OR Subject ILIKE 'Bienvenido%' THEN 1 ELSE NULL END) -- 'Welcome to...' Emails: 1,461,329
     
     -- Password Reset
     , COUNT(CASE WHEN Subject ILIKE 'Password Reset%' OR Subject ILIKE 'Restablecer%' THEN 1 ELSE NULL END) -- 'Password Reset...' Emails: 390,771
     
     -- Message Sent
     , COUNT(CASE WHEN Subject ILIKE '%sent you a message%' THEN 1 ELSE NULL END) -- '...sent you a message...' Emails: 363,542
     
     -- Session Notes
     , COUNT(CASE WHEN Subject ILIKE 'Your Session Notes' THEN 1 ELSE NULL END) -- 'Your Session Notes' Emails: 12,040
     
     -- Direct Message
     , COUNT(CASE WHEN Subject ILIKE 'New Direct Message' THEN 1 ELSE NULL END) -- 41,339
     
     -- Daily Digest
     , COUNT(CASE WHEN Subject ILIKE 'Today at%' THEN 1 ELSE NULL END) -- 'Today at...' Emails: 7,858,495
     , COUNT(CASE WHEN Subject ILIKE 'Your%Midday Digest' OR Subject ILIKE '%Midday digest' OR Subject ILIKE '%Mid-Day Digest' THEN 1 ELSE NULL END) -- 43,881
     , COUNT(CASE WHEN Subject ILIKE 'Your%End of Day Digest' OR Subject ILIKE '%End of Day Digest' THEN 1 ELSE NULL END) -- 11,610
     , COUNT(CASE WHEN Subject ILIKE 'Highlights from%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%- Update' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'Daily Digest -%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%Daily Update' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%End-of-Day Recap' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%Day in Review' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%Mid-Day Recap' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%Day end digest' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'Today''s Highlights from %' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'What''s happening today at%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'What''s been happening at%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'Here''s what happened at%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE 'Today''s%Review' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%Day In Review%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%midday summary%' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Subject ILIKE '%summary for today%' THEN 1 ELSE NULL END)
     
     -- Beacon Report
     , COUNT(CASE WHEN Subject ILIKE 'Your Beacon Message Info' THEN 1 ELSE NULL END) -- 136
     -- Exhibitor Opportunity
     , COUNT(CASE WHEN Subject ILIKE 'Exhibitor Opportunity at%' THEN 1 ELSE NULL END) -- 691
     -- Set up Lead Scanning
     , COUNT(CASE WHEN Subject ILIKE 'Set Up Lead Scanning For%' THEN 1 ELSE NULL END) -- 113
     -- PV
     , COUNT(CASE WHEN Subject ILIKE 'People are viewing your profile%' THEN 1 ELSE NULL END) -- 4,345
     -- Leads Report
     , COUNT(CASE WHEN Subject ILIKE 'Your Leads Report for%' THEN 1 ELSE NULL END) -- 1,527
     -- Profile Complete CTA
     , COUNT(CASE WHEN Subject ILIKE 'Make sure your profile is complete%' THEN 1 ELSE NULL END) -- 4,808
     -- Trending
     , COUNT(CASE WHEN Subject ILIKE 'What''s trending at%' THEN 1 ELSE NULL END)
     -- Exhibitor Portal
     , COUNT(CASE WHEN Subject ILIKE 'Your Exhibitor Portal Account at%' THEN 1 ELSE NULL END)
     -- Junk
     , COUNT(CASE WHEN Subject ILIKE ' =?utf-8?B?gYTjgZfjgojjgYY=?=' THEN 1 ELSE NULL END) -- 93,232
*/
FROM Mailgun.MailgunCube MGC
/*JOIN NonTestEvents NTE
ON MGC.ApplicationId = NTE.ApplicationId*/
WHERE /*Subject IS NOT NULL
AND*/ RecipientEmailDomain <> 'doubledutch.me'
;

-- 14,906,178


-- Find Subjects not included in counts above
SELECT MGC.Subject
FROM Mailgun.MailgunCube MGC
JOIN NonTestEvents NTE
ON MGC.ApplicationId = NTE.ApplicationId
WHERE Subject IS NOT NULL
AND RecipientEmailDomain <> 'doubledutch.me'
AND Subject NOT ILIKE 'Welcome to%' AND Subject NOT ILIKE 'Bienvenido%'
AND Subject NOT ILIKE 'Today at%'
AND Subject NOT ILIKE 'Password Reset%' AND Subject NOT ILIKE 'Restablecer%'
AND Subject NOT ILIKE '%sent you a message%'
AND Subject NOT ILIKE 'Your Session Notes'
AND Subject NOT ILIKE 'New Direct Message'
AND Subject NOT ILIKE 'Your%Midday Digest' AND Subject NOT ILIKE '%Midday digest' AND Subject NOT ILIKE '%Mid-Day Digest'
AND Subject NOT ILIKE 'Your%End of Day Digest' AND Subject NOT ILIKE '%End of Day Digest'
AND Subject NOT ILIKE 'Highlights from%'
AND Subject NOT ILIKE '%- Update'
AND Subject NOT ILIKE 'Daily Digest -%'
AND Subject NOT ILIKE '%Daily Update'
AND Subject NOT ILIKE '%End-of-Day Recap'
AND Subject NOT ILIKE '%Day in Review'
AND Subject NOT ILIKE '%Mid-Day Recap'
AND Subject NOT ILIKE '%Day end digest'
AND Subject NOT ILIKE 'Today''s Highlights from %'
AND Subject NOT ILIKE 'What''s happening today at%'
AND Subject NOT ILIKE 'Today''s%Review'
AND Subject NOT ILIKE 'What''s been happening at%'
AND Subject NOT ILIKE 'Here''s what happened at%'
AND Subject NOT ILIKE '%Day In Review%'
AND Subject NOT ILIKE '%midday summary%'
AND Subject NOT ILIKE '%summary for today%'

AND Subject NOT ILIKE 'Your Beacon Message Info'
AND Subject NOT ILIKE 'Exhibitor Opportunity at%'
AND Subject NOT ILIKE 'Set Up Lead Scanning For%'
AND Subject NOT ILIKE 'People are viewing your profile%'
AND Subject NOT ILIKE 'Your Leads Report for%'
AND Subject NOT ILIKE 'Make sure your profile is complete%'
AND Subject NOT ILIKE 'What''s trending at%'
AND Subject NOT ILIKE 'Your Exhibitor Portal Account at%'
AND Subject NOT ILIKE ' =?utf-8?B?gYTjgZfjgojjgYY=?='
LIMIT 1000
;

-- Meeting Request Emails
SELECT COUNT(*)
FROM Mailgun.MailgunCube
WHERE Subject ILIKE '%has requested a meeting%'
AND RecipientEmailDomain <> 'doubledutch.me'
;

-- 1013 (0.0068%)


SELECT COUNT(*)
FROM PUBLIC.Ratings_ApplicationConfigSettings
WHERE Name = 'ExhibitorMessagingEnabled'
AND SettingValue = 'True'
;

-- 2345

