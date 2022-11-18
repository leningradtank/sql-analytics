WITH first_funded AS (
    
    SELECT      A.id AS account_id, MIN(B.created_at) AS funding_date
    FROM        wallets A
    JOIN        activity B
        ON      B.account_number = A.account_number
    WHERE       account IN ('TypeA', '')
    AND         B.action_like IN ('deposit', 'withdraw')
    AND         B.status = 'executed'
    AND         A.created_at >= '2022-01-01'
    GROUP BY    A.id
    
    
), last_approved AS (

    SELECT      account_id, MIN(at) AS approved_date 
    FROM        account_status 
    WHERE       status_to = 'APPROVED'
    GROUP BY    account_id 
    
), first_order AS (

    SELECT      A.id AS account_id, MIN(B.created_at) AS order_date
    FROM        wallets A
    JOIN        orders B
        ON      B.account = A.account_number
    WHERE       account IN ('TypeA', '')
    AND         B.filled_at IS NOT NULL
    AND         A.created_at >= '2022-01-01'
    GROUP BY    A.id

), time_difference AS (

    SELECT      first_funded.account_id, approved_date, funding_date, order_date, funding_date - approved_date AS app_to_funding, order_date - funding_date AS fund_to_order
    FROM        first_funded
    JOIN        last_approved
        ON      first_funded.account_id = last_approved.account_id
    LEFT JOIN   first_order
        ON      first_order.account_id = first_funded.account_id

), days AS (

    SELECT DATE_TRUNC('day', d)::date AS day
    FROM GENERATE_SERIES(CURRENT_DATE-31, CURRENT_DATE-1, '1 day'::interval) d  -- CTE to capture days with no data

), n AS (
    
    SELECT      days.day,
                COUNT(DISTINCT account_id) AS n_wallets_deposit_after_app,
                COUNT(DISTINCT CASE WHEN funding_date::date >= approved_date::date AND funding_date::date < approved_date::date + INTERVAL '3 day' THEN account_id END) AS n_wallets_deposit_3_days_after_app,
                COUNT(DISTINCT CASE WHEN funding_date::date >= approved_date::date AND funding_date::date < approved_date::date + INTERVAL '3 day' AND order_date IS NOT NULL THEN account_id END) AS n_wallets_trade_after_dep_3_days_after_app
    FROM        days
    LEFT JOIN   time_difference ON days.day = time_difference.approved_date::date
    GROUP BY    days.day

)

SELECT  day,
        SUM(n_wallets_deposit_after_app) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS "wallets that Deposit on/after Approval",
        1.0*SUM(n_wallets_deposit_3_days_after_app) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(n_wallets_deposit_after_app) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS "% of Users that Deposit w/in 3 Days",
        1.0*SUM(n_wallets_trade_after_dep_3_days_after_app) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(n_wallets_deposit_3_days_after_app) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS "% of Users that Traded after Deposit made w/in 3 Days"
FROM    n