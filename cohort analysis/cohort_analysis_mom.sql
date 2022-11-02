with cohort_items as (
SELECT cohort_month, account as user_id
FROM
(
SELECT orders.account, date_trunc('month',orders.filled_at) cohort_month, row_number() over (partition by orders.account order by date_trunc('month',orders.filled_at)) as rn
    
FROM orders
join assets 
on assets.id::uuid=orders.asset_id::uuid
left join accounts 
on accounts.account_number = orders.account

where orders.filled_at IS NOT NULL
and orders.status like '%filled%'
and orders.account not in ('xyz', '123456789')
        and orders.id not in ('2385278f-cf12-4332-b562-ad7b56158b36' -- 4m error on 5/26
        )
and correspondent in ('ALPACA','')

group by orders.account, date_trunc('month',orders.filled_at)
) sub
where rn = 1

)
,

user_activities as 
(


SELECT sub.user_id, order_placed_date, C.cohort_month, 
abs(EXTRACT(year FROM age(order_placed_date, C.cohort_month))*12 + EXTRACT(month FROM age(order_placed_date, C.cohort_month))) as month_number

FROM
(
SELECT  distinct A.account as user_id, date_trunc('month',A.filled_at) order_placed_date, row_number() over (partition by A.account order by date_trunc('month',A.filled_at)) as rn
    
FROM orders A
join assets B
on B.id::uuid= A.asset_id::uuid
left join accounts 
on accounts.account_number = A.account

where A.filled_at IS NOT NULL
and A.status like '%filled%'
and correspondent in ('ALPACA','')

group by A.account, date_trunc('month',A.filled_at)
) sub

left join cohort_items C 
ON sub.user_id = C.user_id

where rn <> 1
group by 1,2,3,4
)
,

cohort_size as (
  select cohort_month, count(1) as num_users
  from cohort_items
  group by 1
),

retention_table as (
  select
    C.cohort_month,
    A.month_number,
    count(1) as num_users
  from user_activities A
  left join cohort_items C ON A.user_id = C.user_id
  group by 1, 2
)

select
  B.cohort_month,
  B.month_number,
  B.num_users::float / S.num_users as percentage
from retention_table B
left join cohort_size S ON B.cohort_month = S.cohort_month
where B.cohort_month IS NOT NULL
and B.cohort_month >= date_trunc('month',{{date_from}})
order by 1, 2