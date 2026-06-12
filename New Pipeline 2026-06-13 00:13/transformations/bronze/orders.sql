CREATE OR REFRESH STREAMING TABLE bronze.orders_bronze
TBLPROPERTIES (
  'quality' = 'bronze'
)
AS
SELECT
    *,
    current_timestamp() AS ingestion_time,
    _metadata.file_name AS source_file
FROM STREAM read_files(
    "${landing}/orders_*.csv",
    format => 'csv',
    header => 'true',
    schema => 'order_id INT, customer_id INT, product_id INT, quantity INT, price DOUBLE, status STRING, payment STRING, order_date TIMESTAMP'
)