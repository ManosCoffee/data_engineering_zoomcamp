

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
  on fmin.quartertly_yoy_rev = mm.min_yoy;

  
-- Q6 : Get p90, p95 & p97 percentiles per Green/Yellow taxis, for April 2020

select * from `kestra-orch.zoomcamp.fct_taxi_trips_monthly_fare_p95` 
where rev_year = 2020 
and rev_month = 4;


--  Q7:  Rank p90-duration values within each 3-dimension partition:
--  within each pickup zone for each month & year, rank the drop-off locations by p90 duration 

WITH ranked_p90_durations_per_period_and_region AS (
    SELECT 
        *,
    DENSE_RANK() OVER (PARTITION BY trip_year, trip_month, pickup_locationid
        ORDER BY p90 DESC) p90_duration_rank
    FROM  `kestra-orch.zoomcamp.fct_fhv_monthly_zone_traveltime_p90` 


)


SELECT  
  array_agg(distinct dropoff_zone) dropoff_zones
FROM ranked_p90_durations_per_period_and_region
WHERE trip_year = 2019
AND trip_month = 11
AND pickup_zone in (
    "Newark Airport",
    "SoHo",
    "Yorkville East"
)
AND p90_duration_rank = 2
group by trip_year, trip_month, pickup_zone






