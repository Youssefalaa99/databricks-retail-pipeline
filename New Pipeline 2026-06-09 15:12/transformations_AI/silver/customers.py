from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.table(
    name="retail.silver.silver_customers",
    comment="Cleaned and validated customer data with deduplication",
    cluster_by=["customer_id"]
)
@dp.expect_or_drop("valid_email", "email IS NOT NULL AND email LIKE '%@%'")
@dp.expect_or_drop("valid_customer_id", "customer_id IS NOT NULL")
@dp.expect("valid_phone", "phone IS NOT NULL")
def silver_customers():
    return (
        spark.readStream.table("bronze_customers")
        .filter("_rescued_data IS NULL")
        .withWatermark("updated_at", "1 hour")
        .dropDuplicatesWithinWatermark(["customer_id"])
        .select(
            "customer_id",
            "first_name",
            "last_name",
            "email",
            "phone",
            "address",
            "created_at",
            "updated_at"
        )
    )
