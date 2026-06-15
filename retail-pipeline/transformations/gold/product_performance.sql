CREATE OR REFRESH MATERIALIZED VIEW gold.product_performance
TBLPROPERTIES ('quality' = 'gold')
AS SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price          AS current_price,
    p.cost           AS current_cost,
    p.stock_quantity AS current_stock,
    COUNT(o.order_id)                                 AS total_orders,
    COALESCE(SUM(o.quantity), 0)                      AS units_sold,
    COALESCE(SUM(o.amount), 0)                        AS total_revenue,
    COALESCE(SUM(o.quantity * p.cost), 0)             AS total_cost,
    COALESCE(SUM(o.amount) - SUM(o.quantity * p.cost), 0) AS gross_profit,
    MAX(o.order_date)                                 AS last_sold_date
FROM silver.products_silver p
LEFT JOIN silver.orders_silver o
    ON p.product_id = o.product_id
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.`__END_AT` IS NULL
GROUP BY p.product_id, p.product_name, p.category, p.price, p.cost, p.stock_quantity;