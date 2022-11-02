WITH range_values AS (
  SELECT date_trunc('month', min(orders.filled_at)) as minval,
         date_trunc('month', max(orders.filled_at)) as maxval
  FROM gobroker_temp.orders),
   
month_range as (
SELECT generate_series(minval, maxval, '1 month'::interval) as month
from range_values
),


signup_count as (
SELECT date_trunc('month', CAST("intercom"."users"."created_at" AS timestamp)) AS "created_at", count(distinct "intercom"."users"."id") AS "total_signups"
FROM "intercom"."users"
where referrercampaignmedium = 'cpc' or referrercampaignmedium = 'ppc'
GROUP BY date_trunc('month', CAST("intercom"."users"."created_at" AS timestamp))
),


monthly_orders as (
select date_trunc('month', a.created_at) as month,
       

        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at ) ) then filled_qty*0.0019 end  ) as M1,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '1 Month')  ) then filled_qty*0.0019 end  ) as M2,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '2 Month')  ) then filled_qty*0.0019 end  ) as M3,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '3 Month')  ) then filled_qty*0.0019 end  ) as M4,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '4 Month')  ) then filled_qty*0.0019 end  ) as M5,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '5 Month')  ) then filled_qty*0.0019 end  ) as M6,
        
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '6 Month')  ) then filled_qty*0.0019 end  ) as M7,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '7 Month')  ) then filled_qty*0.0019 end  ) as M8,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '8 Month')  ) then filled_qty*0.0019 end  ) as M9,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '9 Month')  ) then filled_qty*0.0019 end  ) as M10,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '10 Month')  ) then filled_qty*0.0019 end  ) as M11,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '11 Month')  ) then filled_qty*0.0019 end  ) as M12,
        
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '12 Month')  ) then filled_qty*0.0019 end  ) as M13,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '13 Month')  ) then filled_qty*0.0019 end  ) as M14,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '14 Month')  ) then filled_qty*0.0019 end  ) as M15,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '15 Month')  ) then filled_qty*0.0019 end  ) as M16,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '16 Month')  ) then filled_qty*0.0019 end  ) as M17,
        
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '17 Month')  ) then filled_qty*0.0019 end  ) as M18,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '18 Month')  ) then filled_qty*0.0019 end  ) as M19,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '19 Month')  ) then filled_qty*0.0019 end  ) as M20,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '20 Month')  ) then filled_qty*0.0019 end  ) as M21,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '21 Month')  ) then filled_qty*0.0019 end  ) as M22,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '22 Month')  ) then filled_qty*0.0019 end  ) as M23,
        
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '23 Month')  ) then filled_qty*0.0019 end  ) as M24,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '24 Month')  ) then filled_qty*0.0019 end  ) as M25,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '25 Month')  ) then filled_qty*0.0019 end  ) as M26,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '26 Month')  ) then filled_qty*0.0019 end  ) as M27,
        
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '27 Month')  ) then filled_qty*0.0019 end  ) as M28,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '28 Month')  ) then filled_qty*0.0019 end  ) as M29,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '29 Month')  ) then filled_qty*0.0019 end  ) as M30,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '30 Month')  ) then filled_qty*0.0019 end  ) as M31,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '31 Month')  ) then filled_qty*0.0019 end  ) as M32,
        sum(case when (date_trunc('month', orders.filled_at) = date_trunc('month', a.created_at + interval '32 Month')  ) then filled_qty*0.0019 end  ) as M33
        
        
from gobroker_temp.orders
left join gobroker_temp.accounts a 
on a.account_number = gobroker_temp.orders.account
left join gobroker_temp.account_owners 
on gobroker_temp.account_owners.account_id = a.id
left join intercom.users
on intercom.users.ownerid::uuid = gobroker_temp.account_owners.owner_id::uuid
where referrercampaignmedium = 'cpc'
or referrercampaignmedium = 'ppc'
group by 1
)

select month_range.month,
       signup_count.total_signups,
       monthly_orders.M1,
       monthly_orders.M2,
       monthly_orders.M3,
       monthly_orders.M4,
       monthly_orders.M5,
       monthly_orders.M6,
       
       monthly_orders.M7,
       monthly_orders.M8,
       monthly_orders.M9,
       monthly_orders.M10,
       monthly_orders.M11,
       monthly_orders.M12,
       
       monthly_orders.M13,
       monthly_orders.M14,
       monthly_orders.M15,
       monthly_orders.M16,
       
       monthly_orders.M17,
       monthly_orders.M18,
       monthly_orders.M19,
       monthly_orders.M20,
       monthly_orders.M21,
       monthly_orders.M22,
     
       monthly_orders.M23,
       monthly_orders.M24,
       monthly_orders.M25,
       monthly_orders.M26,
       
       monthly_orders.M27,
       monthly_orders.M28,
       monthly_orders.M29,
       monthly_orders.M30,
       monthly_orders.M31,
       monthly_orders.M32,
       monthly_orders.M33
       
       
from month_range
left outer join monthly_orders on month_range.month = monthly_orders.month
left outer join signup_count on month_range.month = signup_count.created_at
order by 1 ASC