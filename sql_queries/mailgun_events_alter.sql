drop table if exists jt.mailgun_events_new;

create table jt.mailgun_events_new as
select *
     , cast(to_timestamp(eventtimestamp/1000) as date) as eventdate
     , substring(cast(to_timestamp(eventtimestamp/1000) as varchar) from 12 for 8) as eventtime
     , eventtimestamp%1000 as eventmillisec
     , 1 as batch_id
from mailgun_events;



select count(*)
from jt.mailgun_events_new;

select count(*)
from public.mailgun_events;





