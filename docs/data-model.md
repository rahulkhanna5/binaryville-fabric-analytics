# Data model

## Bronze: orders (raw)

| Column | Notes |
|:--|:--|
| transaction_id | Source transaction identifier, e.g. TRX000063 |
| customer_id | Customer reference |
| product_id | Product reference |
| quantity | Units purchased |
| total_amount | Order value |
| transaction_date | Date of the transaction |
| payment_method | e.g. Bank Transfer |
| store_type | e.g. Online |
| ingestion_timestamp | Added at load time, used as the incremental watermark |

## Silver: silver_orders (Delta)

| Column | Type | Notes |
|:--|:--|:--|
| order_id | STRING | Mapped from transaction_id, merge key |
| customer_id | STRING | |
| product_id | STRING | |
| quantity | INT | Negative values set to 0 |
| total_amount | DOUBLE | Negative values set to 0 |
| transaction_date | DATE | Cast to DATE |
| order_status | STRING | Derived: Completed, Cancelled or In Progress |
| last_updated | TIMESTAMP | Set when the row is written to silver |

Rows with a null transaction_date, customer_id or product_id are dropped before loading.

### order_status rules

| Condition | Status |
|:--|:--|
| quantity = 0 and total_amount = 0 | Cancelled |
| quantity > 0 and total_amount > 0 | Completed |
| anything else | In Progress |

## Gold

| Table | Grain | Measures |
|:--|:--|:--|
| gold_daily_sales | One row per transaction_date | daily_total_sales = SUM(total_amount) |
| gold_category_sales | One row per product_category | category_total_sales = SUM(total_amount) |

gold_category_sales is built by joining silver_orders to silver_products on product_id.

## Serving

Gold_Semantic is the semantic model over the gold lakehouse and is the layer reports connect to.
