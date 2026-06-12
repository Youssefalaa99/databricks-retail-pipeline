CREATE OR REFRESH STREAMING TABLE bronze.customers_bronze
TBLPROPERTIES (
  'quality' = 'bronze'
)
AS
SELECT
    *,
    current_timestamp() AS ingestion_time,
    _metadata.file_name AS source_file
FROM STREAM read_files(
    "${landing}/customers_*.csv",
    format => 'csv',
    header => 'true',
    schema => 'customer_id INT, first_name STRING, last_name STRING, email STRING, phone STRING, address STRING, created_at TIMESTAMP'
)