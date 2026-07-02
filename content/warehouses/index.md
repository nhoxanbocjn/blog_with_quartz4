---
title: Data Warehouses
tags:
  - warehouse
  - data-engineering
  - analytics
  - olap
---

## What is a Data Warehouse?

A **data warehouse** is a centralized repository designed for analytical querying and reporting. It stores large volumes of historical data from multiple sources, optimized for read-heavy, complex queries (OLAP) rather than transactional processing (OLTP).

Key characteristics:
- **Subject-oriented** — organized around business subjects (sales, inventory, customers)
- **Integrated** — data from disparate sources is cleaned, transformed, and consolidated
- **Time-variant** — maintains historical data for trend analysis (typically 1–10 years)
- **Non-volatile** — data is append-only; once written, it is not modified

## Architecture Layers

| Layer | Purpose | Tools/Technologies |
|---|---|---|
| **Staging** | Raw data ingestion, minimal transformation | S3, Kafka, Airbyte |
| **ODS (Operational Data Store)** | Near-real-time operational reporting | PostgreSQL, MySQL |
| **DWH Core** | Dimensional modeling (star/snowflake) | Snowflake, Redshift, BigQuery |
| **Data Marts** | Department-specific aggregates | Subset of DWH, BI-tuned |
| **Semantic Layer** | Business view for analytics tools | dbt, LookML, Power BI |

## Dimensional Modeling (Kimball)

The most common approach for data warehouse design:

- **Fact tables** — quantitative measurements (sales amount, order count), foreign keys to dimensions
  - Transaction facts (one row per event)
  - Periodic snapshot facts (one row per time period)
  - Accumulating snapshot facts (one row per process lifecycle)
- **Dimension tables** — descriptive attributes (customer name, product category, date)
  - Conformed dimensions — shared across fact tables (e.g., `Date`, `Customer`)
  - Slowly Changing Dimensions (SCD Type 1/2/3) — track historical changes

## Warehouse vs Lakehouse vs Data Lake

| | Data Lake | Data Warehouse | Lakehouse |
|---|---|---|---|
| **Data format** | Raw files (Parquet, JSON) | Structured, schema-on-write | Structured + semi-structured |
| **Schema** | Schema-on-read | Schema-on-write | Flexible |
| **ACID** | Limited | Full | Full (via Delta/Iceberg) |
| **Use case** | ML, exploratory | BI, reporting | Both |
| **Examples** | S3, ADLS | Snowflake, Redshift | Databricks, Iceberg |

## ETL/ELT for Warehousing

- **ETL** — Extract, Transform, Load (transform before loading)
  - Traditional approach, used when warehouse had limited compute
- **ELT** — Extract, Load, Transform (transform inside warehouse)
  - Modern approach, leveraging cloud warehouse scalability (Snowflake, BigQuery)
  - Tools: dbt, SQLMesh, Dataform

## Best Practices

1. Use **surrogate keys** for dimension tables instead of natural keys
2. Store grain of fact table clearly — document what each row represents
3. Pre-aggregate for common queries (materialized views, rollup tables)
4. Partition large tables by date for query pruning
5. Use columnar storage (Parquet, ORC) and compression (ZSTD, Snappy)
6. Implement data quality tests at every stage (dbt tests, Great Expectations)

## Files in this Section

- **Snowflake** — cloud data warehouse with separate compute/storage
- **Databricks** — lakehouse platform built on Apache Spark
- **Hive** — SQL-on-Hadoop warehouse for batch processing
