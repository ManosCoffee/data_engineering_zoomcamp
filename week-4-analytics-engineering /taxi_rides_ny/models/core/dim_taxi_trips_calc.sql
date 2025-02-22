{{
    config(
        materialized='view'
    )
}}

with fct_trips as (
    select 
        tripid,
        extract(year from pickup_datetime)  as rev_year,
        extract(month from pickup_datetime)  as rev_month,
        extract(quarter from pickup_datetime) as rev_quarter,
    from {{ref("fact_trips")}}
)

select *,    
    {{ dbt.safe_cast("rev_year", api.Column.translate_type("string")) }} || "-Q" || {{ dbt.safe_cast("rev_quarter", api.Column.translate_type("string")) }} as year_quarter
    from fct_trips




