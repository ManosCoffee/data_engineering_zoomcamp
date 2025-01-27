

### Export and save Green Trips csv file - use head to preview file
```
gunzip -c green_tripdata_2019-10.csv.gz > green_trips.csv | head
```

### Different column names found for timestamps
Minor code refactoring to include different datetime column names.
Required a new image build: 
```
docker build -t taxi_ingest:v002 .
```

### Run the dockerized script (v2)
(Containers on the same network can communicate using their service names as hostnames. That would be: "pgdatabase"!)
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




