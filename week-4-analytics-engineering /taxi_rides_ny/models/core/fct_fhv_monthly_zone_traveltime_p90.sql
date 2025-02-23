{{
    config(
        materialized='table'
    )
    }}

with fhv_trips_with_durations as (
    select 
        fhid,
        pickup_locationid,
        dropoff_locationid,
        pickup_borough,
        pickup_zone,
        dropoff_borough,
        dropoff_zone,
        pickup_datetime,
        dropoff_datetime,
        {{dbt.datediff("pickup_datetime","dropoff_datetime","second")}} as trip_duration,
        trip_year,
        trip_month

    from {{ref("dim_fhv_trips")}}
    where pickup_locationid is not null
    and dropoff_locationid is not null
    and pickup_borough is not  null
    and pickup_zone is not null
    and dropoff_borough is not null
    and dropoff_zone is not null

)
,

percentiles_enrichment as (
    select 
        * ,
        percentile_cont(trip_duration , 0.90) 
            over (partition by trip_year, trip_month, pickup_locationid, dropoff_locationid) p90,
    from fhv_trips_with_durations
)

select * from percentiles_enrichment
