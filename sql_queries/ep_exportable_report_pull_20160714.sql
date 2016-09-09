SELECT Event_Label
     , COUNT(*) AS ClickCnt
     , COUNT(DISTINCT Global_User_Id) As UserCnt
     , COUNT(DISTINCT Global_User_Id)::DECIMAL(12,4)/4636::DECIMAL(12,4) AS UserPct
FROM Google.Ep_Event_Counts
WHERE Event_Category = 'href'
AND Date >= '2015-08-01'
AND Date <= '2016-02-29'
GROUP BY 1
ORDER BY 3 DESC
;

SELECT MIN(DATE)
     , MAX(DATE)
FROM Google.Ep_Event_Counts
;
-- 2016-01-29
-- 2016-07-13

SELECT COUNT(*) FROM (
SELECT DISTINCT Global_User_Id
FROM Google.Ep_Event_Counts
WHERE Date >= '2015-08-01'
AND Date <= '2016-02-29'
UNION
SELECT DISTINCT Global_User_Id
FROM Google.Ep_PageView_Counts
WHERE Date >= '2015-08-01'
AND Date <= '2016-02-29'
) A
;
-- 4636

SELECT COUNT(DISTINCT Global_User_Id)
FROM Google.Ep_User_Device_Counts
WHERE Date >= '2015-08-01'
AND Date <= '2016-02-29'
;
-- 4636