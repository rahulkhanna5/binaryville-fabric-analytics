# Binaryville Analytics

An end-to-end data engineering and analytics project for **Binaryville**, a multinational retail company, built on **Microsoft Fabric** with a **Medallion architecture** (bronze, silver, gold).

## What this project does

- Ingests customer, order and product data into a Fabric lakehouse using data pipelines
- Cleans and standardises it into a silver layer with PySpark / Spark SQL
- Aggregates it into gold tables for business reporting
- Exposes the gold layer through a semantic model for Power BI

## Stack

| Area | Tooling |
|:--|:--|
| Platform | Microsoft Fabric (OneLake, Lakehouse, SQL analytics endpoint) |
| Ingestion | Fabric Data Pipelines |
| Transformation | PySpark notebooks, Spark SQL, Delta Lake |
| Serving | Semantic model (Gold_Semantic) for Power BI |

## Workspace items

| Layer | Items |
|:--|:--|
| Bronze | Binaryville_Bronze lakehouse |
| Silver | Binaryville_Silver lakehouse, Silverlayer_Customer_load, Silverlayer_orders_load, Silverlayer_product_load |
| Gold | Binaryville_Gold lakehouse, Goldlayer_DailySales, Goldlayer_dailysalesby_category |
| Ingestion | Ingest_Customer_data, Ingest_Orders_data, Ingest_Products_data |
| Serving | Gold_Semantic |

More detail is added in the docs/ and notebooks/ folders.
