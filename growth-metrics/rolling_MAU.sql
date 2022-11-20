select cal.cal as dt,
       count(distinct account_number)
from generate_series(current_date - 1095, current_date, interval '1day') cal
inner join (
                select date_trunc('day', filled_at), account_number
                from(
                        select sub_1.filled_at,
                               sub_1.account,
                               concat(sub_1.account, extract('month' from sub_1.filled_at), extract('day' from sub_1.filled_at), extract('year' from sub_1.filled_at)) as new_unique
                        from (
                                select orders.filled_at,
                                orders.account,
                                ROW_NUMBER() OVER(PARTITION BY orders.account, date_trunc('day', orders.filled_at)
                                                  ORDER BY orders.filled_at
                                                  ) AS row_num
                                from orders
                                where filled_at is not null and filled_qty > 0) as sub_1
                        where sub_1.row_num = 1) as sub_2
                inner join (
                                select  concat(accounts.account_number, extract('month' from daily_balances.asof), extract('day' from daily_balances.asof), extract('year' from daily_balances.asof)) as new_unique, 
                                accounts.account_number,
                                daily_balances.asof,
                                daily_balances.equity
                                from daily_balances
                                left join accounts
                                on daily_balances.account_id = accounts.id
                                where daily_balances.equity > 25000
                                order by asof asc
                            ) as sub_3
                on sub_2.new_unique = sub_3.new_unique
                order by date_trunc('day', filled_at)
 )s on s.date_trunc between cal.cal::date - 30 and cal.cal::date
group by cal.cal
order by dt