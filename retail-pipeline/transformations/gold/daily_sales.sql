CREATE OR REFRESH MATERIALIZED VIEW gold.daily_sales
TBLPROPERTIES ('quality' = 'gold')
AS SELECT
    CAST(order_date AS DATE)                          AS sales_date,
    COUNT(order_id)                                   AS total_orders,
    COUNT(DISTINCT customer_id)                       AS unique_customers,
    SUM(CASE WHEN status = 'cancelled' OR status='refunded' THEN 0 ELSE quantity END)    AS total_units_sold,
    ROUND(SUM(CASE WHEN status = 'cancelled' OR status='refunded' THEN 0 ELSE amount END), 2)     AS total_revenue,
    ROUND(AVG(CASE WHEN status = 'cancelled' OR status='refunded' THEN 0 ELSE amount END), 2)     AS avg_order_value,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN status = 'refunded' THEN 1 ELSE 0 END)  AS refunded_orders
FROM silver.orders_silver
GROUP BY CAST(order_date AS DATE);