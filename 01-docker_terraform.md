

## Export and save Green Trips CSV file - use head to preview file
```
gunzip -c green_tripdata_2019-10.csv.gz > green_trips.csv | head
```

## Different column names found for timestamps
Minor code refactoring to include different datetime column names.
Required a new image build: 
```
docker build -t taxi_ingest:v002 .
```

## Run the dockerized script (v2) for Green Trips
(Containers on the same network can communicate using their service names as hostnames. That would be: "pgdatabase"!)

### Setting Url for Green Trips
```
URL_GREEN="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
```
### Running by passing required arguments
```
docker run -it \
  --network=2_docker_sql_default \
  taxi_ingest:v002 \
    --user=root \
    --password=root \
    --host=pgdatabase \ 
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_taxi_trips \
    --url=${URL_GREEN} \
    --pickup_col_name=lpep_pickup_datetime \
    --dropoff_col_name=lpep_dropoff_datetime
```

## Downloading Taxi Zones Lookup table and running dockerized script for this dataset
### Setting Url for Zones table
```
URL_ZONES="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"
```

### Running by passing required arguments
```
docker run -it \
  --network=2_docker_sql_default \
  taxi_ingest:v002 \
    --user=root \
    --password=root \
    --host=pgdatabase \
    --port=5432 \
    --db=ny_taxi \
    --table_name=zone_lookup \
    --url=${URL_ZONES}
```

# ANALYTICS (lets-just-say)

##  3. Trip Segmentation Count

```sql
  SELECT
      CASE
          WHEN trip_distance <= 1 THEN '<1'
          WHEN trip_distance > 1 AND trip_distance <= 3 THEN '1-3'
          WHEN trip_distance > 3 AND trip_distance <= 7 THEN '3-7'
          WHEN trip_distance > 7 AND trip_distance <= 10 THEN '7-10'
          WHEN trip_distance > 10 THEN '>10'
      END AS distance_category,
      COUNT(*) AS trip_count
  FROM
      green_taxi_trips
  WHERE
      lpep_pickup_datetime >= '2019-10-01' AND lpep_dropoff_datetime < '2019-11-01'
  GROUP BY
      distance_category
```



## 4. Longest trip for each day

```sql
  WITH max_distances AS (
      SELECT
          DATE(lpep_pickup_datetime) AS pickup_day,
          MAX(trip_distance) AS max_distance
      FROM
          green_taxi_trips
      GROUP BY
          pickup_day
  )
  SELECT
      pickup_day,
      max_distance
  FROM
      max_distances
  ORDER BY max_distance DESC
  LIMIT 1;
```

## 5. Three biggest pickup zones

### Explore lookup table with zones

```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'zone_lookup';
```

### Table with top 3 zones 
```sql
WITH top_pickups AS (
	SELECT
	    "PULocationID" as pickup_locations,
	    SUM(total_amount) AS total_amount
	FROM
	    green_taxi_trips
	WHERE
	    DATE(lpep_pickup_datetime) = '2019-10-18'
	GROUP BY
	    pickup_locations
	HAVING
	    SUM(total_amount) > 13000
	ORDER BY
	    total_amount DESC
	LIMIT 3
)

SELECT 
	tp.pickup_locations,
	tp.total_amount,
	zl."Zone" 
FROM top_pickups tp
LEFT JOIN zone_lookup zl
	ON tp.pickup_locations=zl."LocationID";
```

## 6. Largest tip


```sql
SELECT 
	MAX(gt.tip_amount) as max_tip,
	zl_do."Zone" as dropoff_zone
	
	FROM green_taxi_trips gt
	INNER JOIN zone_lookup zl_do
		ON gt."DOLocationID" = zl_do."LocationID"
		
	INNER JOIN zone_lookup zl_pu
		ON gt."PULocationID" = zl_pu."LocationID"
		AND  zl_pu."Zone" = 'East Harlem North'
	WHERE gt.lpep_pickup_datetime BETWEEN '2019-10-01' AND '2019-10-31'
	-- WHERE TO_CHAR(gt.lpep_pickup_datetime, 'Month YYYY') ='October 2019'
	GROUP BY dropoff_zone
	ORDER BY max_tip DESC
```








