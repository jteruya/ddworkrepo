drop table reportingdb.dbo.jt_event_lead_source;

select e.applicationid
     , e.name as eventname
     , case
        when e.eventtype = '' then 'No Event Type'
        when e.eventtype = '_Unknown' then 'Unknown'
        else e.eventtype
       end as eventtype
     , e.leadscanning
     , e.startdate
     , count(*) as total_leads
     , count(case when l.source = 1 then 1 else null end) as scanned_lead
     , cast(cast(count(case when l.source = 1 then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_scanned_lead
     , count(case when l.source = 2 then 1 else null end) as requested_lead
     , cast(cast(count(case when l.source = 2 then 1 else null end) as decimal(12,4))/cast(count(*) as decimal(12,4)) as decimal(12,4)) as pct_requested_lead
into reportingdb.dbo.jt_event_lead_source
from ratings.dbo.leads l
join authdb.dbo.is_users u
on u.userid = l.userid
join reportingdb.dbo.eventcubesummary e
on u.applicationid = e.applicationid
where u.isdisabled = 0
group by e.applicationid, e.name, e.eventtype, e.leadscanning, e.startdate;




-- Across all Events
select count(*) as total_events
     , avg(total_leads) as avg_total_leads_per_event
     , avg(scanned_lead) as avg_scanned_leads_per_event
     , avg(pct_scanned_lead) as avg_pct_scanned_lead_per_event
     , avg(requested_lead) as avg_requested_lead_per_event
     , avg(pct_requested_lead) as avg_requested_lead_per_event
from reportingdb.dbo.jt_event_lead_source
where total_leads >= 100
and leadscanning = 1;

-- Across all Events by Eventtype
select eventtype
     , count(*) as total_events
     , avg(total_leads) as avg_total_leads_per_event
     , avg(scanned_lead) as avg_scanned_leads_per_event
     , avg(pct_scanned_lead) as avg_pct_scanned_lead_per_event
     , avg(requested_lead) as avg_requested_lead_per_event
     , avg(pct_requested_lead) as avg_requested_lead_per_event
from reportingdb.dbo.jt_event_lead_source
where total_leads >= 100
and leadscanning = 1
group by eventtype;



