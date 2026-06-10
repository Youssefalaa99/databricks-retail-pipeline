from pyspark import pipelines as dp

@dp.table(
    comment="Raw product data ingested from landing_volume using Auto Loader"
)
def bronze_products():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("header", "true")
        .option("cloudFiles.inferColumnTypes", "true")
        .option("pathGlobFilter", "products.csv")
        .load("/Volumes/retail/default/landing_volume/")
    )
