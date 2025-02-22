{{
    config(
        materialized='table'
    )
}}

with (
    select * 
    from {{ref("dim_taxi_trips_calc")}}
) as dim_calc 

select *,
from dim_calc

