CREATE OR REFRESH STREAMING TABLE bronze.customers_bronze_raw
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
);



CREATE OR REFRESH STREAMING TABLE bronze.customers_bronze_clean
(
  CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_email       EXPECT (email IS NOT NULL AND email LIKE '%@%'),
  CONSTRAINT valid_phone       EXPECT (phone IS NOT NULL)
)
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
    customer_id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    phone,
    address,
    created_at,
    ingestion_time AS updated_at
FROM STREAM bronze.customers_bronze_raw;