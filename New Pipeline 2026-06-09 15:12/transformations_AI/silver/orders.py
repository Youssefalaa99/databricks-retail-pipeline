from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.table(
    name="retail.silver.silver_orders",
    comment="Validated order data with business rules applied",
    cluster_by=["customer_id", "product_id"]
)
@dp.expect_or_drop("valid_order_id", "order_id IS NOT NULL")
@dp.expect_or_drop("valid_customer_id", "customer_id IS NOT NULL")
@dp.expect_or_drop("valid_product_id", "product_id IS NOT NULL")
@dp.expect_or_drop("valid_quantity", "quantity > 0")
@dp.expect_or_drop("valid_amount", "amount > 0 AND amount = price * quantity")
@dp.expect("valid_status", "status IN ('pending', 'delivered', 'cancelled')")
@dp.expect("valid_payment", "payment_method IN ('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'google_pay')")
def silver_orders():
    return (
        spark.readStream.table("bronze_orders")
        .filter("_rescued_data IS NULL")
        .select(
            "order_id",
            "customer_id",
            "product_id",
            "quantity",
            "price",
            "amount",
            "status",
            "payment_method",
            "order_date"
        )
    )
