-- Silver layer: orders incremental load
-- Condensed from the Silverlayer_orders_load Fabric notebook (Spark SQL, run via PySpark).

-- 1. Target table
CREATE TABLE IF NOT EXISTS silver_orders (
    order_id         STRING,
    customer_id      STRING,
    product_id       STRING,
    quantity         INT,
    total_amount     DOUBLE,
    transaction_date DATE,
    order_status     STRING,
    last_updated     TIMESTAMP
)
USING DELTA;

-- 2. Watermark: latest load time already in silver (the notebook falls back to 1900-01-01 when empty)
SELECT MAX(last_updated) AS last_processed FROM silver_orders;

-- 3. New bronze rows since the watermark
CREATE OR REPLACE TEMPORARY VIEW bronze_incremental_orders AS
SELECT *
FROM orders
WHERE ingestion_timestamp > '<last_processed_timestamp>';

-- 4. Clean and standardise
CREATE OR REPLACE TEMPORARY VIEW silver_incremental_orders AS
SELECT
    transaction_id AS order_id,
    customer_id,
    product_id,
    CASE WHEN quantity < 0 THEN 0 ELSE quantity END AS quantity,
    CASE WHEN total_amount < 0 THEN 0 ELSE total_amount END AS total_amount,
    CAST(transaction_date AS DATE) AS transaction_date,
    CASE
        WHEN quantity = 0 AND total_amount = 0 THEN 'Cancelled'
        WHEN quantity > 0 AND total_amount > 0 THEN 'Completed'
        ELSE 'In Progress'
    END AS order_status,
    CURRENT_TIMESTAMP() AS last_updated
FROM bronze_incremental_orders
WHERE transaction_date IS NOT NULL
  AND customer_id IS NOT NULL
  AND product_id IS NOT NULL;

-- 5. Upsert into silver
MERGE INTO Binaryville_Silver.dbo.silver_orders target
USING silver_incremental_orders source
ON target.order_id = source.order_id
WHEN MATCHED THEN
    UPDATE SET *
WHEN NOT MATCHED THEN
    INSERT *;

-- 6. Check
SELECT * FROM Binaryville_Silver.dbo.silver_orders LIMIT 10;
