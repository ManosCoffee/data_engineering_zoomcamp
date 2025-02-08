-- Create external table for 2024 Yellow Trips 
CREATE EXTERNAL TABLE `kestra-orch.zoomcamp.yellow_tripdata_2024_external_table`
  OPTIONS (
    format ="PARQUET",
    uris = ['gs://kestra-de-zoomcamp-manos/yellow_tripdata_2024-*']
    );

  -- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `kestra-orch.zoomcamp.yellow_tripdata_2024_non_partitioned` AS
SELECT * FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_external_table`;

-- Queries (never actually ran) to determine byte-scanning estimation  
-- SELECT COUNT(DISTINCT PULocationID)
-- FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_external_table`;
-- -O : 0 bytes !

-- SELECT COUNT(DISTINCT PULocationID)
-- FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_non_partitioned`;
-- -O: 155,12 bytes!

-- SELECT PULocationID , DOLocationID  
-- FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_non_partitioned`; 

SELECT COUNT(*) AS ZERO_FARE
FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_non_partitioned`
GROUP BY fare_amount
HAVING fare_amount=0;

-- Data distribution exploration before creating partitions/clusters (!)
SELECT 
  DATE(tpep_dropoff_datetime) AS dropoff_date,
  VendorID,
  COUNT(*) AS trips
FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_non_partitioned`
GROUP BY dropoff_date, VendorID
ORDER BY dropoff_date, VendorID;

-- Partitioning & Clustering
CREATE OR REPLACE TABLE `kestra-orch.zoomcamp.yellow_tripdata_2024_partitioned_clustered`   
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_external_table`;

-- Comparing initial materialized table and the new partioned-clustered table
SELECT DISTINCT VendorID
FROM `kestra-orch.zoomcamp.yellow_tripdata_2024_partitioned_clustered`
WHERE DATE(tpep_dropoff_datetime) BETWEEN "2024-03-01" AND "2024-03-15" 
--  310,24 bytes --> 28,83 bytes
