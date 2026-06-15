CREATE OR REFRESH MATERIALIZED VIEW gold.orders_summary
TBLPROPERTIES ('quality' = 'gold')
AS
SELECT
    c.customer_id AS customer_id,
    c.full_name AS name,
    c.email AS email,
    c.created_at AS customer_since,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.amount), 0) AS total_revenue,
    COALESCE(AVG(o.amount), 0) AS avg_order_value,
    COUNT(DISTINCT o.product_id) AS unique_products_purchased,
    MAX(o.order_date) AS last_order_date,
    SUM(CASE WHEN o.status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM silver.customers_silver c
LEFT JOIN silver.orders_silver o
    ON o.customer_id = c.customer_id
LEFT JOIN silver.products_silver p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.full_name, c.email, c.created_at
CLUSTER BY (c.customer_id);