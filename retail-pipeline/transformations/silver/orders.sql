CREATE OR REFRESH STREAMING TABLE silver.orders_silver
TBLPROPERTIES (
  'quality' = 'silver'
) CLUSTER BY (customer_id, order_date);


CREATE FLOW orders_silver_flow AS
AUTO CDC INTO silver.orders_silver
FROM STREAM bronze.orders_bronze_clean
KEYS(order_id)
SEQUENCE BY updated_at
STORED AS SCD TYPE 2;