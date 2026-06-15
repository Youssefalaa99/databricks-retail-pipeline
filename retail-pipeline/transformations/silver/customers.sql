CREATE OR REFRESH STREAMING TABLE silver.customers_silver
TBLPROPERTIES (
  'quality' = 'silver'
);


CREATE FLOW customers_silver_flow AS
AUTO CDC INTO silver.customers_silver
FROM STREAM bronze.customers_bronze_clean
KEYS(customer_id)
SEQUENCE BY updated_at
STORED AS SCD TYPE 1;