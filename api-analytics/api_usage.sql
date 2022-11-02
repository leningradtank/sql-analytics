with total_calls as (
select sum(count) as api_calls, date_trunc('week', dt) as date_of
from bi_reports.correspondent_access_kind_broker
where env = 'live'
group by date_trunc('week', dt)
order by date_of
) ,

data as (
select date_of, api_calls,
/*any(api_calls) over (PARTITION BY api_calls ORDER BY date_of ASC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as prev,*/
lagInFrame(api_calls) over (ORDER BY date_of asc ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) as prev2
from total_calls
group by date_of, api_calls)

select date_of, api_calls,  (api_calls - prev2)/prev2 as "Percentage change from last week"
from data

