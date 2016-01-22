-- Written for use on ROBIN --
--Identified ApplicationId = 'DAFEB5B3-0476-467E-937F-E1FC011BD131' (2015 EBS RTTW)
SELECT * FROM AuthDB_Applications WHERE ApplicationId = UPPER('dafeb5b3-0476-467e-937f-e1fc011bd131');
SELECT * FROM Ratings_Timezones WHERE TimezoneId = 7; --PST

--Only NewMetrics

--Check on the breakdown of beacon pings across hours
SELECT CAST(Created AS DATE) AS DT, EXTRACT('hour' FROM Created) AS HR, COUNT(*) FROM PUBLIC.Fact_States_Live
WHERE Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131' AND Identifier = 'beacons' GROUP BY 1,2 ORDER BY 1,2;

--Build out a view of our dataset
DROP VIEW IF EXISTS jt.V_Metrics_States_Adhoc;
CREATE VIEW jt.V_Metrics_States_Adhoc AS
SELECT * FROM PUBLIC.Fact_States_Live
WHERE Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131' AND Identifier = 'beacons'
AND (Created >= '2015-12-13 08:00:00' AND Created <= '2015-12-16 08:00:00'); --Adjusted for UTC to PST

--View of Beacon States for all time in the past (should be queried with a filter on ApplicationId)
DROP VIEW IF EXISTS jt.V_Metrics_States_Adhoc_Clean;
CREATE VIEW jt.V_Metrics_States_Adhoc_Clean AS
SELECT
base.*, bm.Name, bm.Title, bm.Body, bm.ActionButtonText
FROM (
--=============--
--iOS - States --
--=============--
SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'UUID' AS UUID,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Major' AS Major,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Minor' AS Minor,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'RSSI' AS RSSI,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Distance' AS Distance
FROM    jt.V_Metrics_States_Adhoc f
WHERE   Device_Type = 'ios'
        AND Identifier = 'beacons'
        
UNION ALL

--=================--
--Android - States --
--=================--
SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'UUID' AS UUID,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Major' AS Major,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Minor' AS Minor,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'RSSI' AS RSSI,
        JSONB_ARRAY_ELEMENTS(CAST(Metadata ->> 'Beacons' AS JSONB)) ->> 'Distance' AS Distance
FROM    jt.V_Metrics_States_Adhoc f
WHERE   Device_Type = 'android'
        AND Identifier = 'beacons'
) base
LEFT JOIN (
SELECT ApplicationId, MinorId, Name, Title, Body, ActionButtonText, Created AS Start, COALESCE(MAX(Created) OVER (PARTITION BY ApplicationId, MinorId ORDER BY Created ASC ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING),'9999-12-31 23:59:59') AS End
FROM PUBLIC.Ratings_BeaconMessages 
WHERE ApplicationId = 'DAFEB5B3-0476-467E-937F-E1FC011BD131'
) bm ON UPPER(base.ApplicationId) = bm.ApplicationId AND CAST(base.Minor AS INT) = bm.MinorId AND base.Timestamp BETWEEN bm.Start AND bm.End
;

--Identify set of all Beacon Minors for the Adhoc Set
DROP TABLE IF EXISTS jt.Metrics_States_Minor_Distinct_Adhoc;
CREATE TABLE jt.Metrics_States_Minor_Distinct_Adhoc AS
SELECT DISTINCT ApplicationId AS ApplicationId, GlobalUserId AS GlobalUserId, Minor, Name, Title, Body, ActionButtonText FROM jt.V_Metrics_States_Adhoc_Clean; 
        
--======================================================================================================================================================

DROP TABLE IF EXISTS jt.Metrics_Notifications_Adhoc;
CREATE TABLE jt.Metrics_Notifications_Adhoc AS
SELECT base.*, bm.Name, bm.Title, bm.Body, bm.ActionButtonText
FROM (
--====================--
--iOS - Notifications --
--====================--
SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'UUID' AS UUID,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Major' AS Major,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Minor' AS Minor,
        LOWER(Metadata ->> 'State') AS State,
        LOWER(Metadata ->> 'Type') AS MessageType,
        Metadata ->> 'MessageId' AS MessageId
FROM    PUBLIC.Fact_Notifications_Live f
WHERE   Device_Type = 'ios'
        AND Identifier = 'beacon'        
        AND (Created >= '2015-12-13 08:00:00' AND Created <= '2015-12-16 08:00:00') --Adjusted for UTC to PST
        AND f.Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131'

UNION ALL

--========================--
--Android - Notifications --
--========================--
SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'UUID' AS UUID,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Major' AS Major,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Minor' AS Minor,
        LOWER(Metadata ->> 'State') AS State,
        LOWER(Metadata ->> 'Type') AS MessageType,
        Metadata ->> 'MessageId' AS MessageId
FROM    PUBLIC.Fact_Notifications_Live f
WHERE   Device_Type = 'android'
        AND Identifier = 'beacon'
        AND (Created >= '2015-12-13 08:00:00' AND Created <= '2015-12-16 08:00:00') --Adjusted for UTC to PST
        AND f.Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131'
) base
LEFT JOIN (
SELECT ApplicationId, MinorId, Name, Title, Body, ActionButtonText, Created AS Start, COALESCE(MAX(Created) OVER (PARTITION BY ApplicationId, MinorId ORDER BY Created ASC ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING),'9999-12-31 23:59:59') AS End
FROM PUBLIC.Ratings_BeaconMessages 
WHERE ApplicationId = 'DAFEB5B3-0476-467E-937F-E1FC011BD131'
) bm ON UPPER(base.ApplicationId) = bm.ApplicationId AND CAST(base.Minor AS INT) = bm.MinorId AND base.Timestamp BETWEEN bm.Start AND bm.End
;

-- Pre-Aggregate for Last Value per Notification
DROP TABLE IF EXISTS jt.Metrics_Notifications_LastValue_Adhoc;
CREATE TABLE jt.Metrics_Notifications_LastValue_Adhoc AS
SELECT DISTINCT ApplicationId, GlobalUserId, Minor, Name, Title, Body, ActionButtonText,
LAST_VALUE(State) OVER (PARTITION BY ApplicationId, GlobalUserId, Minor, Name, Title, Body, ActionButtonText ORDER BY Timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS State
FROM jt.Metrics_Notifications_Adhoc;

--======================================================================================================================================================

DROP TABLE IF EXISTS jt.Metrics_Actions_Adhoc;
CREATE TABLE jt.Metrics_Actions_Adhoc AS
SELECT base.*, bm.Name, bm.Title, bm.Body, bm.ActionButtonText
FROM (
--==============--
--iOS - Actions --
--==============--
SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'UUID' AS UUID,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Major' AS Major,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Minor' AS Minor,
        LOWER(Metadata ->> 'Type') AS MessageType,
        Metadata ->> 'MessageId' AS MessageId
FROM    PUBLIC.Fact_Actions_Live f
WHERE   Device_Type = 'ios'
        AND Identifier = 'beaconNotification'
        AND (Created >= '2015-12-13 08:00:00' AND Created <= '2015-12-16 08:00:00') --Adjusted for UTC to PST
        AND f.Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131'

UNION ALL

SELECT
        Created AS Timestamp,
        f.Application_Id AS ApplicationId,
        Global_User_Id AS GlobalUserId,
        Binary_Version AS BinaryVersion,
        CASE WHEN Device_Type = 'ios' THEN 1 WHEN Device_Type = 'android' THEN 3 END AS AppTypeId,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'UUID' AS UUID,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Major' AS Major,
        CAST(Metadata ->> 'Beacon' AS JSONB) ->> 'Minor' AS Minor,
        LOWER(Metadata ->> 'Type') AS MessageType,
        Metadata ->> 'MessageId' AS MessageId
FROM    PUBLIC.Fact_Actions_Live f
WHERE   Device_Type = 'android'
        AND Identifier IN ('beaconNotification')
        AND (Created >= '2015-12-13 08:00:00' AND Created <= '2015-12-16 08:00:00') --Adjusted for UTC to PST
        AND f.Application_Id = 'dafeb5b3-0476-467e-937f-e1fc011bd131'
) base
LEFT JOIN (
SELECT ApplicationId, MinorId, Name, Title, Body, ActionButtonText, Created AS Start, COALESCE(MAX(Created) OVER (PARTITION BY ApplicationId, MinorId ORDER BY Created ASC ROWS BETWEEN 1 FOLLOWING and 1 FOLLOWING),'9999-12-31 23:59:59') AS End
FROM PUBLIC.Ratings_BeaconMessages 
WHERE ApplicationId = 'DAFEB5B3-0476-467E-937F-E1FC011BD131'
) bm ON UPPER(base.ApplicationId) = bm.ApplicationId AND CAST(base.Minor AS INT) = bm.MinorId AND base.Timestamp BETWEEN bm.Start AND bm.End
;

--======================================================================================================================================================

DROP TABLE IF EXISTS jt.Report_Summary_Adhoc;
CREATE TABLE jt.Report_Summary_Adhoc AS
--=========================--
-- Beacon Report Summaries --
--=========================--
SELECT 
        d.ApplicationId, 
        m.MessageType,
        d.Minor,
        d.Name, d.Title, d.Body, d.ActionButtonText,
        CASE 
          WHEN COUNT(DISTINCT d.GlobalUserId) = 0 THEN 0.0
          ELSE ROUND(100 * COUNT(DISTINCT n.GlobalUserId) / COUNT(DISTINCT d.GlobalUserId),2)
        END AS "% of detected users notified",
        CASE
          WHEN COUNT(DISTINCT n.GlobalUserId) = 0 THEN 0.0
          ELSE ROUND(100 * COUNT(DISTINCT a1.GlobalUserId) / COUNT(DISTINCT n.GlobalUserId),2)
        END AS "% of notified users that tapped",
        COUNT(DISTINCT d.GlobalUserId) AS "Detected Users",
        COUNT(DISTINCT n.GlobalUserId) AS "Notified Users",
        COUNT(DISTINCT a1.GlobalUserId) AS "Users that Tapped"   
FROM jt.Metrics_States_Minor_Distinct_Adhoc d
LEFT JOIN (
        SELECT DISTINCT ApplicationId, GlobalUserId, Minor, Name, Title, Body, ActionButtonText
        FROM jt.Metrics_Notifications_LastValue_Adhoc n
        WHERE State = 'scheduled'
        ) n ON 1=1
        AND d.ApplicationId = n.ApplicationId
        AND d.GlobalUserId = n.GlobalUserId
        AND d.Minor = n.Minor
        AND d.Name = n.Name AND d.Title = n.Title AND d.Body = n.Body AND d.ActionButtonText = n.ActionButtonText
LEFT JOIN (
        SELECT DISTINCT ApplicationId, GlobalUserId, Minor, Name, Title, Body, ActionButtonText
        FROM jt.Metrics_Actions_Adhoc
        ) a1 ON 1=1
        AND d.ApplicationId = a1.ApplicationId
        AND d.GlobalUserId = a1.GlobalUserId
        AND d.Minor = a1.Minor
        AND d.Name = a1.Name AND d.Title = a1.Title AND d.Body = a1.Body AND d.ActionButtonText = a1.ActionButtonText
LEFT JOIN (
        SELECT DISTINCT ApplicationId, Minor, MessageType, Name, Title, Body, ActionButtonText FROM jt.Metrics_Notifications_Adhoc
        ) m ON 1=1
        AND d.ApplicationId = m.ApplicationId
        AND d.Minor = m.Minor
        AND d.Name = m.Name AND d.Title = m.Title AND d.Body = m.Body AND d.ActionButtonText = m.ActionButtonText
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1, "Detected Users" DESC;
;

--Basic Aggregate Report Pull
SELECT 
CAST(Minor AS INT) AS Minor,
a.Name AS "Beacon - Name", 
a.Title AS "Beacon - Title", 
a.Body AS "Beacon - Body",
a.ActionButtonText AS "Beacon - Action Button",
"% of detected users notified",
"% of notified users that tapped",
"Detected Users",
"Notified Users",
"Users that Tapped"
FROM jt.Report_Summary_Adhoc a
ORDER BY CAST(Minor AS INT);
