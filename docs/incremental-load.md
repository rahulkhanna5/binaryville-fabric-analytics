# Incremental load (bronze to silver)

The silver notebooks load only new or changed records instead of reprocessing the full bronze table on every run.

## Steps

1. **Create the target table** if it does not exist (Delta format).
2. **Find the watermark.** Read MAX(last_updated) from the silver table. If the table is empty, fall back to 1900-01-01 so the first run loads everything.
3. **Select the increment.** Create a temporary view of bronze rows where ingestion_timestamp is later than the watermark.
4. **Transform.** Apply the cleaning and business rules (see data-model.md) in a second temporary view.
5. **Upsert.** MERGE the transformed rows into the silver table on the business key: update matching rows, insert new ones.
6. **Verify.** Query the silver table and check the row counts and sample rows.

## Why this design

- **Cheaper runs.** Only the new slice of data is processed.
- **Safe re-runs.** MERGE on the key means a repeated run does not create duplicates.
- **Late updates are handled.** A changed record updates the existing row instead of adding a second one.

## Data-quality rules applied in silver

- Drop rows with a null transaction date, customer or product
- Replace negative quantity and amount with 0
- Cast transaction_date to DATE
- Derive order_status from quantity and amount
- Stamp last_updated with the load time

The SQL used in the orders notebook is in notebooks/silver_orders_load.sql.
