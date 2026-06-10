from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.table(
    name="retail.silver.silver_products",
    comment="Validated product data with pricing checks",
    cluster_by=["category", "product_id"]
)
@dp.expect_or_drop("valid_product_id", "product_id IS NOT NULL")
@dp.expect_or_drop("valid_name", "name IS NOT NULL")
@dp.expect_or_drop("valid_pricing", "price > 0 AND cost > 0 AND price >= cost")
@dp.expect_or_drop("valid_stock", "stock_quantity >= 0")
@dp.expect("valid_category", "category IS NOT NULL")
def silver_products():
    return (
        spark.readStream.table("bronze_products")
        .filter("_rescued_data IS NULL")
        .withWatermark("updated_at", "1 hour")
        .dropDuplicatesWithinWatermark(["product_id"])
        .withColumn("profit_margin", 
            F.round((F.col("price") - F.col("cost")) / F.col("price") * 100, 2)
        )
        .select(
            "product_id",
            "name",
            "category",
            "price",
            "cost",
            "profit_margin",
            "stock_quantity",
            "created_at",
            "updated_at"
        )
    )
