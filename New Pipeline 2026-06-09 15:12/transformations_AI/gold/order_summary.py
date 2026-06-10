from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.materialized_view(
    name="retail.gold.gold_order_summary",
    comment="Aggregated order metrics by customer and product",
    cluster_by=["customer_id"]
)
def gold_order_summary():
    orders = spark.read.table("retail.silver.silver_orders")
    customers = spark.read.table("retail.silver.silver_customers")
    products = spark.read.table("retail.silver.silver_products")
    
    return (
        orders
        .join(customers, "customer_id", "left")
        .join(products, "product_id", "left")
        .groupBy(
            "customer_id",
            "first_name",
            "last_name",
            "email"
        )
        .agg(
            F.count("order_id").alias("total_orders"),
            F.sum("amount").alias("total_revenue"),
            F.avg("amount").alias("avg_order_value"),
            F.countDistinct("product_id").alias("unique_products_purchased"),
            F.max("order_date").alias("last_order_date"),
            F.sum(
                F.when(F.col("status") == "delivered", 1).otherwise(0)
            ).alias("delivered_orders"),
            F.sum(
                F.when(F.col("status") == "cancelled", 1).otherwise(0)
            ).alias("cancelled_orders")
        )
        .withColumn(
            "delivery_rate",
            F.round(F.col("delivered_orders") / F.col("total_orders") * 100, 2)
        )
    )
