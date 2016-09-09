-- Check to see MailgunCube is still working
SELECT MAX(First_Accepted_Timestamp)
FROM Mailgun.MailGunCube LIMIT 10
;
-- 2016-08-11 12:04:02
-- Looks good!


-- DOY Granular Table
DROP TABLE IF EXISTS JT.DOYEmails;
CREATE TABLE JT.DOYEmails AS
SELECT CAST(First_Accepted_Timestamp AS DATE) AS YYYYMMDD
     , EXTRACT(DOY FROM First_Accepted_Timestamp) AS DOY
     , COUNT(*) AS AcceptedCnt
     , COUNT(CASE WHEN Rejected_Flag = TRUE THEN 1 ELSE NULL END) AS RejectedCnt
     , COUNT(CASE WHEN Delivered_Flag = TRUE THEN 1 ELSE NULL END) AS DeliveredCnt
     , COUNT(CASE WHEN Failed_Flag = TRUE AND Delivered_Flag = FALSE THEN 1 ELSE NULL END) AS FailedCnt
     , COUNT(CASE WHEN Opened_Flag = TRUE THEN 1 ELSE NULL END) AS OpenedCnt
     , COUNT(CASE WHEN Clicked_Flag = TRUE THEN 1 ELSE NULL END) AS ClickedCnt
     , COUNT(CASE WHEN Unsubscribed_Flag = TRUE THEN 1 ELSE NULL END) AS UnsubscribedCnt
     , COUNT(CASE WHEN Complained_Flag = TRUE THEN 1 ELSE NULL END) AS ComplainedCnt
     , COUNT(CASE WHEN Stored_Flag = TRUE THEN 1 ELSE NULL END) AS StoredCnt
     , COUNT(CASE WHEN Opened_Flag = TRUE OR Clicked_Flag = TRUE OR Unsubscribed_Flag = TRUE OR Complained_Flag = TRUE OR Stored_Flag = TRUE THEN 1 ELSE NULL END) AS ResponseCnt
FROM Mailgun.MailgunCube MC
JOIN EventCube.EventCubeSummary ECS
ON MC.ApplicationId = ECS.ApplicationId::UUID
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE First_Accepted_Timestamp >= '2015-09-01'
AND Accepted_Flag = TRUE
AND RecipientEmailDomain NOT ILIKE '%doubledutch%'
AND TE.ApplicationId IS NULL
GROUP BY 1,2
;


DROP TABLE IF EXISTS JT.DOYPREmails;
CREATE TABLE JT.DOYPREmails AS
SELECT CAST(First_Accepted_Timestamp AS DATE) AS YYYYMMDD
     , EXTRACT(DOY FROM First_Accepted_Timestamp) AS DOY
     , COUNT(*) AS AcceptedCnt
     , COUNT(CASE WHEN Rejected_Flag = TRUE THEN 1 ELSE NULL END) AS RejectedCnt
     , COUNT(CASE WHEN Delivered_Flag = TRUE THEN 1 ELSE NULL END) AS DeliveredCnt
     , COUNT(CASE WHEN Failed_Flag = TRUE AND Delivered_Flag = FALSE THEN 1 ELSE NULL END) AS FailedCnt
     , COUNT(CASE WHEN Opened_Flag = TRUE THEN 1 ELSE NULL END) AS OpenedCnt
     , COUNT(CASE WHEN Clicked_Flag = TRUE THEN 1 ELSE NULL END) AS ClickedCnt
     , COUNT(CASE WHEN Unsubscribed_Flag = TRUE THEN 1 ELSE NULL END) AS UnsubscribedCnt
     , COUNT(CASE WHEN Complained_Flag = TRUE THEN 1 ELSE NULL END) AS ComplainedCnt
     , COUNT(CASE WHEN Stored_Flag = TRUE THEN 1 ELSE NULL END) AS StoredCnt
     , COUNT(CASE WHEN Opened_Flag = TRUE OR Clicked_Flag = TRUE OR Unsubscribed_Flag = TRUE OR Complained_Flag = TRUE OR Stored_Flag = TRUE THEN 1 ELSE NULL END) AS ResponseCnt
FROM Mailgun.MailgunCube MC
JOIN EventCube.EventCubeSummary ECS
ON MC.ApplicationId = ECS.ApplicationId::UUID
LEFT JOIN EventCube.TestEvents TE
ON ECS.ApplicationId = TE.ApplicationId
WHERE /*First_Accepted_Timestamp >= '2015-09-01'
AND*/ Accepted_Flag = TRUE
AND RecipientEmailDomain NOT ILIKE '%doubledutch%'
AND Subject ILIKE '%password%reset%'
AND TE.ApplicationId IS NULL
GROUP BY 1,2
;

SELECT COUNT(*)
     , AVG(AcceptedCnt)
     , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY AcceptedCnt)
FROM JT.DOYEmails
;

-- 224 Days
-- Average: 24,458.92 Messages/Day
-- Median: 22,847.5 Messages/Day

-- All Time
SELECT SUM(AcceptedCnt) AS AcceptedCnt
     , SUM(RejectedCnt) AS RejectedCnt
     , SUM(DeliveredCnt) AS DeliveredCnt
     , SUM(FailedCnt) AS FailedCnt
     , SUM(OpenedCnt) AS OpenedCnt
     , SUM(ClickedCnt) AS ClickedCnt
     , SUM(UnsubscribedCnt) AS UnsubscribedCnt
     , SUM(ComplainedCnt) AS ComplainedCnt
     , SUM(ResponseCnt) AS ResponseCnt
     , SUM(StoredCnt) AS StoredCnt
FROM DOYEmails
;


-- By Day
SELECT CAST(EXTRACT(YEAR FROM YYYYMMDD) * 100 + EXTRACT(MONTH FROM YYYYMMDD) AS INT) AS MONTH
     , SUM(AcceptedCnt) AS AcceptedCnt
     --, SUM(RejectedCnt) AS RejectedCnt
     , SUM(DeliveredCnt) AS DeliveredCnt
     , SUM(FailedCnt) AS FailedCnt
     --, SUM(OpenedCnt) AS OpenedCnt
     --, SUM(ClickedCnt) AS ClickedCnt
     --, SUM(UnsubscribedCnt) AS UnsubscribedCnt
     --, SUM(ComplainedCnt) AS ComplainedCnt
     , SUM(ResponseCnt) AS ResponseCnt
     --, SUM(StoredCnt) AS StoredCnt
FROM JT.DOYEmails
WHERE YYYYMMDD >= '2015-10-01'
GROUP BY 1
ORDER BY 1
;



SELECT CAST(EXTRACT(YEAR FROM YYYYMMDD) * 100 + EXTRACT(MONTH FROM YYYYMMDD) AS INT) AS MONTH
     , SUM(AcceptedCnt) AS AcceptedCnt
     --, SUM(RejectedCnt) AS RejectedCnt
     , SUM(DeliveredCnt) AS DeliveredCnt
     , SUM(FailedCnt) AS FailedCnt
     --, SUM(OpenedCnt) AS OpenedCnt
     --, SUM(ClickedCnt) AS ClickedCnt
     --, SUM(UnsubscribedCnt) AS UnsubscribedCnt
     --, SUM(ComplainedCnt) AS ComplainedCnt
     , SUM(ResponseCnt) AS ResponseCnt
     --, SUM(StoredCnt) AS StoredCnt
FROM JT.DOYPREmails
WHERE YYYYMMDD >= '2015-05-01'
GROUP BY 1
ORDER BY 1
;



SELECT YYYYMMDD
     , SUM(AcceptedCnt) AS AcceptedCnt
     --, SUM(RejectedCnt) AS RejectedCnt
     , SUM(DeliveredCnt) AS DeliveredCnt
     , SUM(FailedCnt) AS FailedCnt
     --, SUM(OpenedCnt) AS OpenedCnt
     --, SUM(ClickedCnt) AS ClickedCnt
     --, SUM(UnsubscribedCnt) AS UnsubscribedCnt
     --, SUM(ComplainedCnt) AS ComplainedCnt
     , SUM(ResponseCnt) AS ResponseCnt
     --, SUM(StoredCnt) AS StoredCnt
FROM JT.DOYPREmails
WHERE YYYYMMDD >= '2015-05-01'
GROUP BY 1
ORDER BY 1
;