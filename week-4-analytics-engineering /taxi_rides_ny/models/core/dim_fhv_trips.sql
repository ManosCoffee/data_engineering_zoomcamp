{{
    config(
        materialized='table'
    )
}}

with fhv_trips as (
    select * from {{ref("stg_fhv")}}
)
,
zones as (
    select 
        {{ dbt.safe_cast("locationid", api.Column.translate_type("integer")) }} as locationid,
        borough, 
        zone, 
        service_zone 
    from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)


select 
    f.fhid,
    f.dispatching_base_num,
    f.pickup_locationid,
    f.dropoff_locationid,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    f.pickup_datetime,
    f.dropoff_datetime,
    extract(year from f.pickup_datetime)  as trip_year,
    extract(month from f.pickup_datetime)  as trip_month,
    f.sr_flag,
    f.affiliated_base_number

from fhv_trips f
left join zones pickup_zone
    on f.pickup_locationid = pickup_zone.locationid 
left join zones dropoff_zone
    on f.dropoff_locationid = dropoff_zone.locationid


