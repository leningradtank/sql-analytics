with logs as (
select * , toStartOfMonth(timestamp) as time_month, toHour(timestamp) as time_hour 
from bi_reports.categorized_brokerlog
where toDate(timestamp) between '2022-05-01' and '2022-06-01'
and env = 'live'
and correspondent not in ('', 'LPCA')
),

gobroker_data as (
select count(account_number) as total_accounts, correspondent
from gobroker.accounts 
where status = 'ACTIVE'
and created_at < '2022-06-01'
group by correspondent
),

data as (
select count(*) as api_calls_hour, count(*)/60 as rpm, correspondent, time_hour, time_month
from logs
group by correspondent, time_hour, time_month
),

data2 as (
select sum(rpm) total_rpm, count(time_hour) as total_hours, sum(rpm)/count(time_hour) as avg_rpm, correspondent, time_month
from data 
group by time_month,  correspondent
),

data3 as (
select correspondent, quantile(avg_rpm) as median_rpm
from data2
group by correspondent
)

select correspondent, quantile(median_rpm/ gd.total_accounts) as median_rpm_account
from data3
left join gobroker_data gd on gd.correspondent = data3.correspondent
where gd.correspondent not in ('','NULL')
group by correspondent
order by median_rpm_account desc 
limit {{TOP}}



