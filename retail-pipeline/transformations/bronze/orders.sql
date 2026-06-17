CREATE OR REFRESH STREAMING TABLE bronze.orders_bronze_raw
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
);


CREATE OR REFRESH STREAMING TABLE bronze.orders_bronze_clean
(
    CONSTRAINT valid_order_id    EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW,
    CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION DROP ROW,
    CONSTRAINT valid_product_id  EXPECT (product_id IS NOT NULL) ON VIOLATION DROP ROW,
    CONSTRAINT valid_quantity    EXPECT (quantity > 0) ON VIOLATION DROP ROW,
    CONSTRAINT valid_price       EXPECT (unit_price > 0) ON VIOLATION DROP ROW,
    CONSTRAINT valid_status      EXPECT (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_payment     EXPECT (payment_method IN ('credit_card', 'debit_card', 'paypal', 'apple_pay', 'google_pay', 'bank_transfer', 'cash_on_delivery'))
)
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
    order_id,
    customer_id,
    product_id,
    quantity,
    price AS unit_price,
    ROUND(quantity * price, 2) AS amount,
    status,
    payment AS payment_method,
    order_date,
    ingestion_time AS updated_at
FROM STREAM bronze.orders_bronze_raw;