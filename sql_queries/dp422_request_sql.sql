
select *
from authdb.dbo.applications
where ApplicationId = '170D682C-39B6-49A5-8C62-679B9FE4DE70';

--Overall counts
SELECT COUNT(DISTINCT ToUserId) AS "Users Receiving Messages", COUNT(DISTINCT FromUserId) AS "Users Sending Messages", COUNT(*) AS "Messages Sent"
FROM Ratings.dbo.UserMessages
WHERE ApplicationId = '170D682C-39B6-49A5-8C62-679B9FE4DE70';


select COUNT(DISTINCT ToUserId) AS "Users Receiving Messages"
     , COUNT(DISTINCT FromUserId) AS "Users Sending Messages"
     , COUNT(*) AS "Messages Sent"
from ratings.dbo.usermessages a
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) b
on a.touserid = b.userid
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) c
on a.fromuserid = c.userid;

-- 3622
-- 480
-- 7256

-- Users Receiving Messages: 3620
-- Users Sending Messages: 476
-- Messages Sent: 7,241


--Users that sent and were sent at least one message
SELECT COUNT(*) FROM (
SELECT DISTINCT ToUserId
from ratings.dbo.usermessages a
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) b
on a.touserid = b.userid
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) c
on a.fromuserid = c.userid
INTERSECT 
SELECT DISTINCT FromUserId
from ratings.dbo.usermessages a
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) b
on a.touserid = b.userid
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) c
on a.fromuserid = c.userid
) t; 

-- Users Sent at least one message and recieved at least one message: 266

select count(*)
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0;

-- 11,281 Total Non-Disabled Users      


-- Max number of messages sent by one user
select count(*) as userSentMsgCnt
     , max(msgToUserCnt) as maxMsgToUserCnt
     , max(msgSentCnt) as maxMsgSentCnt
     , avg(msgToUserCnt) as avgMsgToUserCnt
     , avg(msgSentCnt) as avgMsgSentCnt
FROM (
SELECT FromUserId
     , count(*) as msgToUserCnt
     , sum(msgSentCnt) as msgSentCnt 
from (
SELECT FromUserId, ToUserId, count(*) as msgSentCnt
from ratings.dbo.usermessages a
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) b
on a.touserid = b.userid
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) c
on a.fromuserid = c.userid
GROUP BY FromUserId, ToUserId) A
GROUP BY FromUserId 
--ORDER BY msgSentCnt desc
) B;

-- User Count that sent at least one message: 476 users (4.22% of all non-disabled app users)
-- Max Number of Recipients a User Sent Messages to: 1,028 people 
-- Max Number of Messages Sent by One User: 1,118 messages
-- Avg Number of Recipients a User Sends Messages To per User: 13 people
-- Avg Number of Messages Sent per User: 15 messages

--Max number of messages sent to one user
select count(*) as userRecievedMsgCnt
     , max(msgFromUserCnt) as maxMsgFromUserCnt
     , max(msgRecievedCnt) as maxMsgRecievedCnt
     , avg(msgFromUserCnt) as avgMsgFromUserCnt
     , avg(msgRecievedCnt) as avgMsgRecievedCnt
FROM (
SELECT ToUserId
     , count(*) as msgFromUserCnt
     , sum(msgRecievedCnt) as msgRecievedCnt 
from (
SELECT ToUserId, FromUserId, count(*) as msgRecievedCnt
from ratings.dbo.usermessages a
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) b
on a.touserid = b.userid
join (select userid
      from authdb.dbo.is_users
      where applicationid = '170D682C-39B6-49A5-8C62-679B9FE4DE70'
      and isdisabled = 0) c
on a.fromuserid = c.userid
GROUP BY ToUserId, FromUserId) A
GROUP BY ToUserId 
--ORDER BY msgFromUserCnt desc
) B;

-- User Count recieved at least one message: 3,620 users (32.09% of all non-disabled app users)
-- Max Number of Senders a User Recieves Messages From: 14 people
-- Max Number of Messages Recieved by a User: 16 messages
-- Avg Number of Senders a User Recieves Messages From per User: 1
-- Avg Number of Messages Recieved per User: 2
