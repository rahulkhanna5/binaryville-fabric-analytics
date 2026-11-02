# Architecture

The project follows the **Medallion architecture** on Microsoft Fabric. Data moves through three lakehouses, each with a clear purpose.

~~~text
Source data (customers, orders, products)
        |
        |  Fabric Data Pipelines
        v
+------------------+     +------------------+     +------------------+
|  Bronze          | --> |  Silver          | --> |  Gold            |
|  raw, as landed  |     |  cleaned, typed  |     |  aggregated      |
|  + ingestion ts  |     |  Delta tables    |     |  business tables |
+------------------+     +------------------+     +------------------+
                                                          |
                                                          v
                                              Gold_Semantic (semantic model)
                                                          |
                                                          v
                                                  Power BI reporting
~~~

## Layers

**Bronze (Binaryville_Bronze).** Raw data as it lands from the ingestion pipelines. Each record carries an `ingestion_timestamp` so downstream layers can load only what is new.

**Silver (Binaryville_Silver).** Cleaned and standardised Delta tables: `silver_orders`, `silver_products` and the customer table. Handles type casting, null filtering, business-rule fixes and de-duplication through upserts.

**Gold (Binaryville_Gold).** Business-ready aggregates such as daily sales and sales by product category, read by the semantic model.

## Ingestion

One pipeline per entity keeps failures isolated and easy to re-run:

- Ingest_Customer_data
- Ingest_Orders_data
- Ingest_Products_data

## Transformation

PySpark notebooks run the silver and gold logic:

- Silverlayer_Customer_load, Silverlayer_orders_load, Silverlayer_product_load
- Goldlayer_DailySales, Goldlayer_dailysalesby_category

## Serving

The Gold_Semantic model sits on top of the gold lakehouse so reports read from curated, consistent tables instead of raw data.
