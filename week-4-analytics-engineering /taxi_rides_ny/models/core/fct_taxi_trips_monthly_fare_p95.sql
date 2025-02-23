{{
    config(
        materialized='table'
    )
}}

with fct_trips_filtered as (
    select 
        f.fare_amount,
        f.service_type,
        c.rev_year,
        c.rev_month
    from {{ref("fact_trips")}} f
    left join {{ref("dim_taxi_trips_calc")}} c 
        on f.tripid=c.tripid
    where fare_amount > 0
    and trip_distance > 0
    and payment_type_description in ('Cash', 'Credit card')
)
,
percentiles as(
    select 
        service_type,
        rev_year,
        rev_month,
        percentile_cont(fare_amount , 0.90) 
            over (partition by service_type,rev_year,rev_month) p90,
        percentile_cont(fare_amount , 0.95) 
            over (partition by service_type,rev_year,rev_month) p95,
        percentile_cont(fare_amount , 0.97) 
            over (partition by service_type,rev_year,rev_month) p97,
    from fct_trips_filtered
)

select 
    service_type,
    rev_year,
    rev_month,
    max (p90) p90,
    max (p95) p95,
    max (p97) p97
from percentiles
group by 1, 2, 3


