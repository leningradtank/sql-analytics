
                SELECT
                end_dt,
                count(distinct user_id) as unique_users
                FROM
                (
                    SELECT distinct
                    product_use.user_id,
                    product_use.dt
                    FROM
                    (


                    SELECT distinct
                    user_id,
                    min(dt) as first_api_call
                    FROM
                    (
                    
                    SELECT  user_id, 
                        dt,
                        --COUNT(CASE WHEN accesskind in ('internal', 'tradingview') THEN 1 END) as internal_count,
                        COUNT(CASE WHEN accesskind in ('live_v1', 'live_v2', 'paper_v1', 'paper_v2') THEN 1 END) as non_internal_count
                        FROM activity_type_2021
                        WHERE user_id not in ('null', '')
                        GROUP BY user_id, dt
                        ) as aaa
                        
                        group by user_id
                        ) as api_call
                        
                        inner join
                        
                        (   
                        SELECT  user_id, 
                        dt,
                        COUNT(CASE WHEN accesskind in ('internal', 'paper_dash') THEN 1 END) as internal_count
                        --COUNT(CASE WHEN accesskind not in ('internal', 'tradingview') THEN 1 END) as non_internal_count
                        FROM activity_type_2021
                        WHERE user_id not in ('null', '')
                        
                        GROUP BY user_id, dt
                        
                        ) as product_use
                        
                        on api_call.user_id = product_use.user_id
                        and product_use.dt > api_call.first_api_call
                        
                        where internal_count > 0
                        ) as aaa
                        
                        join dt_windows win
                        on aaa.dt > win.strt_dt
                        and aaa.dt <= end_dt
                        
                        group by end_dt
)