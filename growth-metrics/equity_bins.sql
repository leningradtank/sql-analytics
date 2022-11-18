select sharestraded , users, dollartraded, AUM,
sub.sharestraded/sub.users as avg_shares_perid, (sub.sharestraded / sub.total)*100 as percent_shares_traded, sub.dollartraded/sub.users as avg_dollar_traded, (sub.dollartraded / sub.dollar_total)*100 as percent_dollavalue_traded
from (

select 
    sum(filled_qty) as sharestraded, 
    count(distinct a.user_id) as users, 
    sum(filled_qty*
    (case when filled_avg_price_usd is not null and o.symbol not like '%/%' then filled_avg_price_usd else filled_avg_price end)
    ) as dollartraded,
CASE WHEN a.liquidity < 0 THEN '<0'
     WHEN a.liquidity >= 0 and a.liquidity < 5000 THEN '0-5K' 
     WHEN a.liquidity >= 5000 and a.liquidity < 10000 THEN '5-10K' 
     WHEN a.liquidity >= 10000 and a.liquidity < 15000 THEN '10-15K' 
     WHEN a.liquidity >= 15000 and a.liquidity < 20000 THEN '15-20K'
     WHEN a.liquidity >= 20000 and a.liquidity < 25000 THEN '20-25K'
     WHEN a.liquidity >= 25000 and a.liquidity < 35000 THEN '25-35K'
     WHEN a.liquidity >= 35000 and a.liquidity < 50000 THEN '35-50K'
     WHEN a.liquidity >= 50000 and a.liquidity < 75000 THEN '50-75K'
     WHEN a.liquidity >= 75000 and a.liquidity < 100000 THEN '75-100K'
     WHEN a.liquidity >= 100000 and a.liquidity < 200000 THEN '100-200K'
     WHEN a.liquidity >= 200000 THEN '200K+'
        END as AUM,
    subb.sum as total,
    subb2.sum as dollar_total
FROM 
    orders o
join    
    assets 
        on assets.id::uuid=o.asset_id::uuid
left join users a on a.user_id = o.id
cross join (select sum(filled_qty) as sum from orders left join users on users.user_id = orders.id where orders.filled_at > current_date -14 and users.correspondent in ('type_a', 'NULL', ''))subb
cross join (select sum(filled_qty*filled_avg_price) as sum from orders left join users on users.user_id = orders.id where orders.filled_at > current_date -14 and users.correspondent in ('type_a', 'NULL', ''))subb2
where ((o.asset_id = 'abc'
        OR o.asset_id = 'abc2' OR o.asset_id = 'abc3' OR o.asset_id = 'abc4')
        or exchange in ('SUSHI','UNI')
        AND o.status = 'filled')
group by 4, 5, 6 
)sub
order by 6
