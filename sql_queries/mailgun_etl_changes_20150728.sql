create table jt.mailgun_accepted_events (
     applicationid uuid
   , name varchar
   , eventtype varchar
   , messageid varchar
   , subject varchar
   , emailsubjectcatg varchar
   , recipientemail varchar
   , senderemail varchar
   , eventstatus varchar
   , clickurl varchar
   , id varchar
   , eventtimestamp bigint);
   
create table jt.mailgun_delivered_events (
     applicationid uuid
   , name varchar
   , eventtype varchar
   , messageid varchar
   , subject varchar
   , emailsubjectcatg varchar
   , recipientemail varchar
   , senderemail varchar
   , eventstatus varchar
   , clickurl varchar
   , id varchar
   , eventtimestamp bigint);
   
   
--- 

insert into jt.mailgun_accepted_events (
   select a.applicationid
        , b.name
        , case
            when b.eventtype = '_Unknown' then 'Unknown'
            when b.eventtype = '' then 'No Event Type'
            else b.eventtype
          end as eventtype
        , a.messageid
        , a.subject
        , case
            when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'passwordresetemail'
            when a.subject like '%sent you a message%' then 'messagealertemail'
            when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'welcomeemail'
            when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'dailydigestemail'
            when a.subject like 'Your Session Notes' then 'sessionnotealertemail'
            when a.subject like 'Your Beacon Message Info' then 'beaconmessageinfoemail'
            when a.subject like 'Exhibitor Opportunity %' then 'exhibitoropportunityemail'
            when a.subject like 'Your Leads Report %' then 'leadsreportemailemail'
            when a.subject like 'Set Up Lead Scanning For %' then 'setupleadscanningcalltoactionemail'
            when a.subject like 'Activity Flagged %' then 'activityflaggedemail'
            when a.subject like '% has requested a meeting' then 'meetingrequestemail'
            when a.subject is null then 'nullsubjectemail'
            else 'unknownemail'
          end as emailsubjectcatg
        , a.recipientemail
        , a.senderemail
        , a.eventstatus
        , a.clickurl
        , a.id
        , a.eventtimestamp
   from (select * from public.mailgun_events where eventstatus = 'accepted' and eventtimestamp >= ) a
   join eventcube.eventcubesummary b
   on a.applicationid = b.applicationid::uuid);
   
