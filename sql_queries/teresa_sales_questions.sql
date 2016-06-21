

select count(*)
from mailgun.mailguncube
where applicationid is not null 
and recipientemaildomain <> 'doubledutch.me'
and lower(subject) not like '%welcome%'
and lower(subject) not like '%today at%'
and lower(subject) not like '%password reset%'
and lower(subject) not like '%sent you a message%'
and lower(subject) not like '%bienvenido%'
and lower(subject) not like '%engagement report%'
and lower(subject) not like '%activity flagged%'
and lower(subject) not like '%bienvenido%'
and lower(subject) not like '%session notes%'
and lower(subject) not like '%beacon message%'
and lower(subject) not like '%exhibitor opportunity%'
and lower(subject) not like '%lead scanning%'
and lower(subject) not like '%people are viewing your profile%'
and lower(subject) not like '%mid-day%'
and lower(subject) not like '%leads report%'
and lower(subject) not like '%midday digest%'
and lower(subject) not like '%end of day digest%'
and lower(subject) not like '%cms%'
and lower(subject) not like '%requested a meeting%'
and lower(subject) not like '%make sure your profile is complete%'
and lower(subject) not like '%daily update%'
and lower(subject) not like '%restablecer%'
and lower(subject) not like '%update%'

and lower(subject) not like '%today''s highlights%'
and lower(subject) not like '%here''s what happened%'
and lower(subject) not like '%good afternoon%'
and lower(subject) not like '%day in review%'
and lower(subject) not like '%midday summary%'
and lower(subject) not like '%day end digest%'
and lower(subject) not like '%thank you for joining%'
and lower(subject) not like '%so far today..%'
and lower(subject) not like '%review%'
and lower(subject) not like '%end-of-day recap%'
and lower(subject) not like '%digest%'
and lower(subject) not like '%highlightes from today''s meeting activity%'
and lower(subject) not like '%trending%'
and lower(subject) not like '%end of day wrap-up%'
and trim(subject) <> 'We are halfway the day.... What''s happening'
and lower(subject) not like '%check out%'
and lower(subject) not like '%attendees are saying%'
and lower(subject) not like '%what''s happening%'
and lower(subject) not like '%what''s been happening%'
and lower(subject) not like '%going on%'
and lower(subject) not like '%happening%'
and lower(subject) not like '%recap%'
and lower(subject) not like '%crashed in your hotel%'
and lower(subject) not like '%happened%'
and lower(subject) not like '%summary%'
and lower(subject) not like '%popular%'
and lower(subject) not like '%that was the day%'
and lower(subject) not like '%what up%'
and lower(subject) not like '%highlight%'
and lower(subject) not like '%today%'


and lower(subject) not like '%request collateral%'
and lower(subject) not like '%requested collateral%'
and lower(subject) not like '%handoff file%'
and lower(subject) not like '%want to meet%'
and lower(subject) not like '%wants to meet%'
and lower(subject) not like '%meet%'
and lower(subject) not like '%rate%'
and lower(subject) not like '%direct message%'
and lower(subject) not like '%exhibitor portal%'
and lower(subject) not like '%failed%'
and lower(subject) not like '%results%'
and trim(subject) <> '=?utf-8?B?gYTjgZfjgojjgYY=?='
and trim(subject) <> 'Please tell us how we''re doing!'
and trim(subject) <> 'fafksdfhkas'
and lower(subject) not like '%challenges%'
and lower(subject) not like '%email verification%'
and lower(subject) not like '%event going%'
and lower(subject) not like '%top content%'
and lower(subject) not like '%dashboard%'
and trim(subject) <> 'fdsgdgfdg^%$^%&^%&^&^%&^%7'
and trim(subject) <> '=?utf-8?B?k+KJoMKr4oCY4oCcwrTiiJHFk8Olw5/iiILGksKpy5niiIbLmsKs4oCm?= =?utf-8?B?wqDDpsO34oml4omkwrXLnOKIq+KImsOn4omI4omIw6XigJPigJMgUmVz?= =?utf-8?B?dWx0cw==?='
and trim(subject) <> '=?utf-8?B?rrblhbfnlJ/kuqforr7lpIflj4rljp/ovoXmnZDmlpnlsZXop4jkvJo=?='
and trim(subject) <> '=?utf-8?B?nMK04oiRxZPDpcOf4oiCxpLCqcuZ4oiGy5rCrOKApsKgw6bDt+KJpeKJ?= =?utf-8?B?pMK1y5ziiKviiJrDp+KJiOKJiMOl4oCT4oCTIFJlc3VsdHM=?='
and trim(subject) <> 'Test new'
and trim(subject) <> 'Heutige Aktivität / Activité aujourd''hui'
;



create temporary table daily_digest_funnel as
select count(distinct mgc.applicationid) as eventcnt
     , count(distinct mgc.recipientemail) as uniquerecipientcnt
     , count(*) as msgcnt
     , count(case when accepted_flag = true then 1 else null end) as acceptedcnt
     , count(case when delivered_flag = true then 1 else null end) as deliveredcnt
     , count(case when opened_flag = true then 1 else null end) as openedcnt    
     , count(case when clicked_flag = true then 1 else null end) as clickedcnt       
from mailgun.mailguncube mgc
join eventcube.eventcubesummary ecs
on mgc.applicationid = ecs.applicationid::uuid
left join eventcube.testevents tc
on ecs.applicationid = tc.applicationid
where ecs.startdate >= '2016-01-01'
and tc.applicationid is null
-- Daily Digest Subject Line
and (lower(subject) like '%today at%'
or lower(subject) like '%today''s highlights%'
or lower(subject) like '%here''s what happened%'
or lower(subject) like '%good afternoon%'
or lower(subject) like '%day in review%'
or lower(subject) like '%midday summary%'
or lower(subject) like '%day end digest%'
or lower(subject) like '%thank you for joining%'
or lower(subject) like '%so far today..%'
or lower(subject) like '%review%'
or lower(subject) like '%end-of-day recap%'
or lower(subject) like '%digest%'
or lower(subject) like '%highlightes from today''s meeting activity%'
or lower(subject) like '%trending%'
or lower(subject) like '%end of day wrap-up%'
or trim(subject) = 'We are halfway the day.... What''s happening'
or lower(subject) like '%check out%'
or lower(subject) like '%attendees are saying%'
or lower(subject) like '%what''s happening%'
or lower(subject) like '%what''s been happening%'
or lower(subject) like '%going on%'
or lower(subject) like '%happening%'
or lower(subject) like '%recap%'
or lower(subject) like '%crashed in your hotel%'
or lower(subject) like '%happened%'
or lower(subject) like '%summary%'
or lower(subject) like '%popular%'
or lower(subject) like '%that was the day%'
or lower(subject) like '%what up%'
or lower(subject) like '%highlight%'
or lower(subject) like '%today%'
or lower(subject) like '%mid-day%'
or lower(subject) like '%midday digest%'
or lower(subject) like '%end of day digest%'
or lower(subject) like '%daily update%'
or lower(subject) like '%update%')
;


select *
from daily_digest_funnel
;



select count(distinct applicationid) as eventcnt
     , count(distinct userid) as usercnt
     , avg(diff) as avgdaysbefore
     , percentile_cont(0.5) within group (order by diff) as mediandaysbefore
from (select ecs.applicationid
           , aspa.userid
           , ecs.startdate
           , aspa.firsttimestamp
           , ecs.startdate - aspa.firsttimestamp::date as diff
      from EventCube.Agg_Session_per_AppUser aspa
      join eventcube.eventcubesummary ecs
      on aspa.applicationid = ecs.applicationid
      left join eventcube.testevents tc
      on ecs.applicationid = tc.applicationid
      where ecs.startdate >= '2016-01-01') a
where diff > 0
;

