CREATE OR REFRESH STREAMING TABLE bronze.products_bronze_raw
TBLPROPERTIES (
  'quality' = 'bronze'
)
AS
SELECT
    *,
    current_timestamp() AS ingestion_time,
    _metadata.file_name AS source_file
FROM STREAM read_files(
    "${landing}/products_*.csv",
    format => 'csv',
    header => 'true',
    inferSchema => 'true'
);


CREATE OR REFRESH STREAMING TABLE bronze.products_bronze_clean
(
  CONSTRAINT valid_product_id EXPECT (product_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_name       EXPECT (product_name IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_pricing    EXPECT (price > 0 AND cost > 0 AND price >= cost) ON VIOLATION DROP ROW,
  CONSTRAINT valid_category   EXPECT (category IS NOT NULL)
)
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
    product_id,
    name AS product_name,
    category,
    price,
    cost,
    stock_quantity,
    created_at,
    ingestion_time AS updated_at
FROM STREAM bronze.products_bronze_raw;