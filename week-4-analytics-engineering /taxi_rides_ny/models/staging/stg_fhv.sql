{{
    config(
        materialized='view'
    )
}}

with fhv_data as 
(
  select *,
  from {{ source('staging','fhv_tripdata_2019_external_table') }}
  where dispatching_base_num is not null
)

select
    -- unique vehicle-hire trip identifier
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as fhid,
    dispatching_base_num,
    -- locations
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    --timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    --extras
    sr_flag,
    affiliated_base_number

    from fhv_data

-- dbt build --select stg_fhv --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}