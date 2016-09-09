-- Get a breakdown of the counts of the binary versions, device types for view metrics that have "chat" in the identifier.
CREATE TEMPORARY TABLE chat_device_version_breakdown AS
SELECT Device_Type
     , Binary_Version
     , fn_parent_binaryversion(binary_version)
     , Identifier
     , COUNT(*)
FROM Fact_Views_Live
Where Identifier ILIKE '%chat%'
GROUP BY 1,2,3,4
;

-- Establish which view identifiers have "chat" in their name.
SELECT DISTINCT Identifier
FROM chat_device_version_breakdown
;
-- Only the identifier 'chat'

-- Get a breakdown of the binary versions, device types.
SELECT device_type
     , fn_parent_binaryversion
     , sum(count)
FROM chat_device_version_breakdown
group by 1,2
order by 1,2
;

-- Compare the two (done in excel).

-- Across 16 different binary versions (6.08 - 6.23), the general breakdown is...
-- Android: 4,016 chat views (1.18%)
-- iOS: 336,145 chat views (98.82%)
-- This looks off based on the fact that generally we would want to see a proportion of 30/70 between Android/iOS assuming users access the chat view at similar rates.

-- Break down of room types associate with chat identifier for android devices.
CREATE TEMPORARY TABLE chat_android_device_version_breakdown AS
SELECT fn_parent_binaryversion(binary_version)
     , binary_version
     , metadata->>'ChannelId'
     , count(*)
FROM Fact_Views_Live
WHERE Identifier = 'chat'
AND Device_Type = 'android'
GROUP BY 1,2,3
;

-- get the room type of the android chat views
select a.roomtype
     , count(*)
from (
select *
     , cast("?column?" as bigint)
     , b.type as roomtype
from chat_android_device_version_breakdown a
left join channels.rooms b
on cast("?column?" as bigint) = b.id
--where b.id is null
) a
group by 1
;

-- all but one are session rooms (the other is null).  looks like the dm/tc chat views are not working.

