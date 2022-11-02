with logs as (
select * , toStartOfMonth(timestamp) as time_month, toHour(timestamp) as time_hour 
from bi_reports.categorized_brokerlog
where toDate(timestamp) between '2022-05-01' and '2022-06-01'
and env = 'live'
and correspondent not in ('', 'LPCA')
),

data as (
select count(*) as api_calls_hour,  count(*)/60 as rpm, correspondent, time_hour, time_month
from logs
group by correspondent, time_hour, time_month
),

data2 as (
select sum(rpm) total_rpm, count(time_hour) as total_hours, sum(rpm)/count(time_hour) as avg_rpm, correspondent, time_month
from data 
group by time_month,  correspondent
)

select correspondent, quantile(avg_rpm) as median_rpm
from data2
group by correspondent
order by median_rpm desc 
limit {{TOP}}



