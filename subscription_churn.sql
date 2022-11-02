WITH signedup_at AS (
SELECT customer_email, owner_id, MIN(created_at) AS signup_date
FROM (
        SELECT DISTINCT stripe_payments.id, sub.id AS owner_id, stripe_payments.*
        FROM stripe_payments 
        LEFT JOIN gobroker_temp.owners sub ON sub.email = stripe_payments.customer_email
        WHERE status = 'Paid'
) subb
GROUP BY 1, 2) 
SELECT AVG(final.churn_rate) AS "Average Churn Rate", 
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY final.churn_rate) AS "Median Churn Rate"
FROM (
        SELECT DATE_TRUNC('month', signup_date),
           COUNT(DISTINCT CASE WHEN status_subscription = 'Canceled' THEN customer_email END) / COUNT(DISTINCT customer_email)::float AS churn_rate
        FROM (
                SELECT *, 
                       CASE WHEN last_payment_date = signup_date AND last_payment_date::date + 28 < current_date AND user_rev / 9 != 11 THEN 'Canceled'
                            WHEN last_payment_date > signup_date AND last_payment_date::date + 28 < current_date THEN 'Canceled'
                            WHEN last_payment_date = signup_date AND last_payment_date::date + 28 < current_date AND user_rev / 9 = 11 THEN 'Active' -- Account for Anual Subscriptions
                            ELSE 'Active'
                       END AS status_subscription
                FROM    (
                
                        SELECT DISTINCT signedup_at.owner_id, 
                               stripe_payments.customer_email, 
                               signedup_at.signup_date, 
                               MAX(stripe_payments.created_at) AS last_payment_date,
                               SUM(stripe_payments.amount) AS user_rev
                        FROM stripe_payments
                        JOIN signedup_at ON signedup_at.customer_email = stripe_payments.customer_email
                        WHERE status = 'Paid'
                        GROUP BY 1, 2, 3
                        
                        ) sub
            ) subb
        GROUP BY 1
) final
;