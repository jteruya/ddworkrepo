drop function jt.fn_emaildeliveredpct(int);

create function jt.fn_emaildeliveredpct(int) 
returns table (metric_date date, metric_desc varchar(200), metric_val decimal(15,4)) as $$
        select cast(now() + interval '1' day * $1 as date) as metric_date
             , cast('% of Accepted Email Delivered' as varchar) as metric_desc
             , cast(cast(sum(case when eventstatus = 'delivered' then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'accepted' then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100 as metric_val
        from jt.mailgun_events_aggregate
        where mailgundate < cast(now() + interval '1' day * $1 as date)    
$$ language sql;









      

