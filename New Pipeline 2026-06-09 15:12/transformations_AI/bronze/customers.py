from pyspark import pipelines as dp

@dp.table(
    comment="Raw customer data ingested from landing_volume using Auto Loader"
)
def bronze_customers():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("header", "true")
        .option("cloudFiles.inferColumnTypes", "true")
        .option("pathGlobFilter", "customers.csv")
        .load("/Volumes/retail/default/landing_volume/")
    )
