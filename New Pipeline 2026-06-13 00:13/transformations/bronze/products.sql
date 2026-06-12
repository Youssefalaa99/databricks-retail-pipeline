CREATE OR REFRESH STREAMING TABLE bronze.products_bronze
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
)