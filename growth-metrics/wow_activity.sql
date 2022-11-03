with sales as (
SELECT 
    date_trunc('week',filled_at::date) as timeframe,
    count(distinct orders_table.account)  as metric
FROM 
    account_details
join    
    orders_table 
        on orders_table.account=account_details.account_number
where account_details.status = 'PRODUCTION'
    and orders_table.status like '%sold%'
group by 1
)


SELECT
    timeframe,
    metric number_traders,
    ((sum(metric)-lag(sum(metric)) over (order by timeframe))/lag(nullif((sum(metric)),0)) over (order by timeframe)) as "Percent Change from Previous Week"
FROM    
    sales
group by 1,2
offset 104













