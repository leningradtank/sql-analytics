select created_at
    , sum(wallets_opened) over (order by created_at) as rolling_sum
from
    (
        Select created_at
        , sum(daily_wallets) as wallets_opened
    from
        (
            SELECT created_at::date
                    , count(*) as daily_wallets
        FROM wallets
        WHERE wallet_status = 'APPROVED'
            AND type_account not in ('', 'NULL', '12345')
            and trades_defi_options = 'false'
            GROUP BY created_at::date
            ORDER BY 1 desc,2 desc
        ) as a 
        group by 1
        order by 1 desc 
    ) as b
    order by created_at desc