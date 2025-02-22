{{
    config(
        materialized='table'
    )
}}

with fct_trips as (
    select * 
    from {{ref("fact_trips")}}

)
,

dim_calc as (
    select 
        tripid,
        year_quarter
    from {{ref("dim_taxi_trips_calc")}}
) 
,
revenue as (
    select 
        c.year_quarter,
        f.service_type,
        sum(total_amount) as quarterly_revenue
    from fct_trips f
    join dim_calc c
        on f.tripid=c.tripid
    group by c.year_quarter, f.service_type

)
,

prev_year_rev_lag as (
    select
        year_quarter,
        service_type,
        quarterly_revenue as curr_year_rev,
        lag(quarterly_revenue, 4) over (partition by service_type order by year_quarter asc) as prev_year_rev 

    from revenue

)


select 
    year_quarter,
    service_type,
    (case 
        when prev_year_rev=0 or prev_year_rev is null then null
        else 100 * (curr_year_rev / prev_year_rev - 1)
    end ) as quartertly_yoy_rev
from prev_year_rev_lag
