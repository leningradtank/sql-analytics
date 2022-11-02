select sharestraded , accounts, dollartraded, AUM,
sub.sharestraded/sub.accounts as avg_shares_peraccount, (sub.sharestraded / sub.total)*100 as percent_shares_traded, sub.dollartraded/sub.accounts as avg_dollar_traded, (sub.dollartraded / sub.dollar_total)*100 as percent_dollavalue_traded
from (

select 
    sum(filled_qty) as sharestraded, 
    count(distinct a.account_number) as accounts, 
    sum(filled_qty*
    (case when filled_avg_price_usd is not null and o.symbol not like '%/%' then filled_avg_price_usd else filled_avg_price end)
    ) as dollartraded,
CASE WHEN a.equity < 0 THEN '<0'
     WHEN a.equity >= 0 and a.equity < 5000 THEN '0-5K' 
     WHEN a.equity >= 5000 and a.equity < 10000 THEN '5-10K' 
     WHEN a.equity >= 10000 and a.equity < 15000 THEN '10-15K' 
     WHEN a.equity >= 15000 and a.equity < 20000 THEN '15-20K'
     WHEN a.equity >= 20000 and a.equity < 25000 THEN '20-25K'
     WHEN a.equity >= 25000 and a.equity < 35000 THEN '25-35K'
     WHEN a.equity >= 35000 and a.equity < 50000 THEN '35-50K'
     WHEN a.equity >= 50000 and a.equity < 75000 THEN '50-75K'
     WHEN a.equity >= 75000 and a.equity < 100000 THEN '75-100K'
     WHEN a.equity >= 100000 and a.equity < 200000 THEN '100-200K'
     WHEN a.equity >= 200000 THEN '200K+'
        END as AUM,
    subb.sum as total,
    subb2.sum as dollar_total
FROM 
    orders o
join    
    assets 
        on assets.id::uuid=o.asset_id::uuid
left join accounts a on a.account_number = o.account
cross join (select sum(filled_qty) as sum from orders left join accounts on accounts.account_number = orders.account where orders.filled_at > current_date -14 and accounts.correspondent in ('type_a', 'NULL', ''))subb
cross join (select sum(filled_qty*filled_avg_price) as sum from orders left join accounts on accounts.account_number = orders.account where orders.filled_at > current_date -14 and accounts.correspondent in ('type_a', 'NULL', ''))subb2
where ((o.asset_id = 'abc'
        OR o.asset_id = 'abc2' OR o.asset_id = 'abc3' OR o.asset_id = 'abc4')
        or exchange in ('FTX','BINANCE')
        AND o.status = 'filled')
group by 4, 5, 6 
)sub
order by 6
