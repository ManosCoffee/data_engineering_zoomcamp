-- Final level analytical queries on materialized tables of BigQuery transformed with DBT

-- Q5 : MAX and MIN YoY for Green & Yellow taxis --

with max_min_q_yoy as (
  select  
    service_type,
    max(quartertly_yoy_rev) max_yoy,
    min(quartertly_yoy_rev) min_yoy
  FROM `kestra-orch.zoomcamp.fct_taxi_trips_quarterly_revenue` 
  where year_quarter like '2020-%'
  group by service_type

)

select 
  mm.*,
  fmax.year_quarter as yq_max,
  fmin.year_quarter as yq_min

from max_min_q_yoy mm
left join `kestra-orch.zoomcamp.fct_taxi_trips_quarterly_revenue` fmax                   
  on fmax.quartertly_yoy_rev = mm.max_yoy
left join `kestra-orch.zoomcamp.fct_taxi_trips_quarterly_revenue` fmin                   
  on fmin.quartertly_yoy_rev = mm.min_yoy
