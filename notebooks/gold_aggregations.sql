-- Gold layer: business aggregates
-- From the Goldlayer_DailySales and Goldlayer_dailysalesby_category Fabric notebooks.

-- Daily sales
CREATE OR REPLACE TABLE gold_daily_sales AS
SELECT
    transaction_date,
    SUM(total_amount) AS daily_total_sales
FROM Binaryville_Silver.dbo.silver_orders
GROUP BY transaction_date;

SELECT * FROM gold_daily_sales LIMIT 10;

-- Sales by product category
CREATE OR REPLACE TABLE gold_category_sales AS
SELECT
    p.category AS product_category,
    SUM(o.total_amount) AS category_total_sales
FROM Binaryville_Silver.dbo.silver_orders o
JOIN Binaryville_Silver.dbo.silver_products p
    ON o.product_id = p.product_id
GROUP BY p.category;

SELECT * FROM gold_category_sales LIMIT 10;
