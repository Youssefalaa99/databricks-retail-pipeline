# databricks-retail-pipeline

This project demonstrates a retail data pipeline using Databricks, showcasing its key features and best practices for building scalable data solutions. The **Medallion** Architecture pattern was used, organizing data into Bronze, Silver, and Gold layers to ensure scalable, reliable, and maintainable data processing.


## Pipeline Architecture

<img width="985" height="358" alt="image" src="https://github.com/user-attachments/assets/d0655c88-f40e-4444-86b0-ed06ff1fcda6" />

## Project Structure

The pipeline consists of three main components:

1. **Data Generator**
   - Simulates retail data (e.g., customers, products, orders) for use in the pipeline.
   - Generates realistic datasets for testing and demonstration purposes.

2. **Delta Live Tables Pipeline**
   - Implements a multi-layer architecture:
     - **Bronze Tables:** Raw ingested data . 
     - **Silver Tables:** Cleaned and transformed data using CDC and SCD type 1,2.
     - **Gold Tables:** Aggregated and business-ready data.
   - Utilizes Databricks Delta Live Tables for orchestration and data quality.

3. **Dashboard**
   - Interactive dashboards built on top of the gold tables.
   - Provides insights into retail metrics such as retail performance summary, top products, and top customers.


## Features explored

- **Databricks Notebook-based data generation**
  - Built a reusable notebook to generate synthetic retail data.
  - Uses `dbutils.widgets` to accept parameters from Databricks Jobs (e.g., volume paths, record counts).
  - Writes generated data directly to Unity Catalog volumes and supports downstream querying for validation.
  - Query delta tables and explore its features (time travel, clustering, ACID operations).

- **Incremental ingestion with Auto Loader**
  - Implements `read_files()` for incremental file ingestion.
  - Leverages Auto Loader in the background to efficiently process new files into Bronze tables with scalable, metadata-driven ingestion.

- **Data quality enforcement with Delta Live Tables (DLT)**
  - Applies data quality constraints using expectations to validate incoming data.
  - Ensures only clean and reliable data is propagated through Silver and Gold layers.

- **Change Data Capture (CDC) and Slowly Changing Dimensions (SCD)**
  - Uses Auto CDC patterns to handle upserts efficiently.
  - Implements:
    - **SCD Type 1** for dimension tables (customers, products) to overwrite current state.
    - **SCD Type 2** for orders to preserve historical changes over time.

- **Gold layer analytics using materialized views**
  - Builds aggregated materialized views to support business-ready metrics.
  - Enables fast, pre-computed analytics for reporting and dashboarding.

- **Business insights through Databricks dashboards**
  - Creates dashboards to monitor pipeline performance and explore retail KPIs.
  - Supports decision-making through near real-time insights.

- **End-to-end orchestration with Lakeflow Jobs**
  - Orchestrates the full pipeline using Databricks Jobs (Lakeflow).
  - Coordinates ingestion, transformation, and aggregation steps into a single automated workflow.

## Dashboards
<img width="1875" height="836" alt="image" src="https://github.com/user-attachments/assets/09722430-4187-439d-9687-3d85057fdd2e" />
<img width="1877" height="559" alt="image" src="https://github.com/user-attachments/assets/da8c726a-2c07-4d92-b674-2ca3d1fe582a" />
<img width="1871" height="852" alt="image" src="https://github.com/user-attachments/assets/96c6cf36-314f-4711-8da3-cbfe1a176720" />

## Getting Started

1. Clone the repository.
2. Run the pre_ddls.sql to create schemas and volume (use this volume path in the job parameter)
3. Create a Lakeflow Job which consists of 3 consecutive tasks.
    - First task: Data generator
    - Second task: Pipeline
    - Third task: Dashboard refresh
4. Add configurations to the job like:
    - Create a parameter for a volume which acts as the default landing zone for raw files generated.
    - Notification incase of failures
    - Set a schedule trigger
    - Edit permissions and choose compute type
5. Explore the dashboards for actionable insights.

## Requirements

- Databricks workspace
- Delta Live Tables enabled
