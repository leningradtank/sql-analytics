WITH custs AS (

SELECT      customers.id AS unique_id,
            MAX(_airbyte_emitted_at) AS max_airbyte_emitted_at
FROM        stripe.customers
GROUP BY    customers.id

),

chgs as (

SELECT      stripe.charges.id,
            MAX(_airbyte_emitted_at) AS max_airbyte_emitted_at
FROM        stripe.charges
GROUP BY    stripe.charges.id

) 


SELECT  customer_email,
        (SUM(charge_amount) - COALESCE(SUM(refunded_amount), 0))/count(DATE_TRUNC('month', toDate(charge_date))) as avg_monthly_revenue

FROM 

(
    
    SELECT      DISTINCT 
                stripe.charges.id AS charge_id,
                FROM_UNIXTIME(stripe.charges.created) AS charge_date,
                stripe.charges.status AS charge_status,
                stripe.charges.amount / 100 AS charge_amount,
                toInt64(JSON_VALUE(refunds, '$.data[0].amount')) / 100 AS refunded_amount,
                stripe.charges.customer AS customer_id,
                stripe.customers.email AS customer_email
    FROM        chgs 
    JOIN        stripe.charges ON chgs.id = stripe.charges.id AND chgs.max_airbyte_emitted_at = stripe.charges._airbyte_emitted_at
    LEFT JOIN   stripe.customers ON stripe.customers.id =  stripe.charges.customer
    JOIN        custs ON stripe.customers.id = custs.unique_id AND stripe.customers.id._airbyte_emitted_at = custs.max_airbyte_emitted_at
    WHERE       stripe.charges.status = 'succeeded'
    AND         CAST(charge_date AS date) >= '2022-01-01' AND CAST(charge_date AS date) < '2022-08-01'

) sub 

GROUP BY customer_email