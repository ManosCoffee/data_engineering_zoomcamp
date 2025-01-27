

### Export and save Green Trips CSV file - use head to preview file
```
gunzip -c green_tripdata_2019-10.csv.gz > green_trips.csv | head
```

### Different column names found for timestamps
Minor code refactoring to include different datetime column names.
Required a new image build: 
```
docker build -t taxi_ingest:v002 .
```

### Run the dockerized script (v2) for Green Trips
(Containers on the same network can communicate using their service names as hostnames. That would be: "pgdatabase"!)

## Setting Url for Green Trips
```
URL_GREEN="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
```
## Running by passing required arguments
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

### Downloading Taxi Zones Lookup table and running dockerized script for this dataset
## Setting Url for Zones table
```
URL_ZONES="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"
```

## Running by passing required arguments
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

### ANALYTICS (lets-just-say)

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








