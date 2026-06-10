from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.materialized_view(
    name="retail.gold.gold_revenue_analysis",
    comment="Revenue trends and KPIs by product category and time period",
    cluster_by=["category"]
)
def gold_revenue_analysis():
    orders = spark.read.table("retail.silver.silver_orders")
    products = spark.read.table("retail.silver.silver_products")
    
    return (
        orders
        .join(products, "product_id", "left")
        .withColumn("order_year", F.year("order_date"))
        .withColumn("order_month", F.month("order_date"))
        .withColumn("order_quarter", F.quarter("order_date"))
        .groupBy(
            "category",
            "order_year",
            "order_quarter",
            "order_month"
        )
        .agg(
            F.count("order_id").alias("total_orders"),
            F.sum("amount").alias("total_revenue"),
            F.sum("quantity").alias("total_quantity_sold"),
            F.countDistinct("customer_id").alias("unique_customers"),
            F.avg("amount").alias("avg_order_value"),
            F.sum(
                F.when(F.col("status") == "delivered", F.col("amount")).otherwise(0)
            ).alias("delivered_revenue"),
            F.sum(
                F.when(F.col("status") == "cancelled", F.col("amount")).otherwise(0)
            ).alias("cancelled_revenue")
        )
        .withColumn(
            "revenue_fulfillment_rate",
            F.round(F.col("delivered_revenue") / F.col("total_revenue") * 100, 2)
        )
        .orderBy("order_year", "order_quarter", "order_month", "category")
    )
