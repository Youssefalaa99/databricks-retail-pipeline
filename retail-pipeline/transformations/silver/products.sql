CREATE OR REFRESH STREAMING TABLE silver.products_silver
TBLPROPERTIES (
  'quality' = 'silver'
);


CREATE FLOW products_silver_flow AS
AUTO CDC INTO silver.products_silver
FROM STREAM bronze.products_bronze_clean
KEYS(product_id)
SEQUENCE BY updated_at
STORED AS SCD TYPE 1;