with total_calls_sandbox as (
select sum(count) as api_calls, access_kind as access_kind
from bi_reports.correspondent_access_kind_broker
where env = 'sandbox'
group by access_kind

) ,

total_calls_live as (
select sum(count) as api_calls, access_kind as access_kind
from bi_reports.correspondent_access_kind_broker
where env = 'live'
group by access_kind
) 

select tsand.access_kind as access_kind, tsand.api_calls as sandbox_api, tlive.api_calls as live_api
-- ((api_calls - neighbor(api_calls, -1))/neighbor(api_calls, -1)) over (Partition by api_calls order by date_of asc) as percentage_change
from total_calls_sandbox tsand
right outer join total_calls_live tlive on tlive.access_kind = tsand.access_kind
order by sandbox_api desc 

