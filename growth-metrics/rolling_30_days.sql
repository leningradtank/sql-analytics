with database_a as (

SELECT user_id, correspondent
FROM database_a_replica.user_account
WHERE role IN ('superuser', 'developer')

),

correspondents as (

SELECT      DISTINCT dt AS date_cd, correspondent, user_id
FROM        bi_reports.access_type_account
LEFT JOIN   database_a on database_a.correspondent = access_type_account.correspondent
            
), dates as (

select distinct
CAST(date_cd AS date) - interval '30' day as start_dt,
CAST(date_cd AS date) as end_dt
from correspondents

)
SELECT
    DATE_TRUNC('week', end_dt),
    COUNT(DISTINCT user_id) AS rolling_30_count
FROM
(

SELECT  end_dt,
        user_id
FROM    dates A

cross join correspondents B

where B.date_cd > A.start_dt
and B.date_cd <= A.end_dt

group by
end_dt,
user_id ) sub

GROUP BY DATE_TRUNC('week', end_dt)