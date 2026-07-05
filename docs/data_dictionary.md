# Data Dictionary — Superstore Analysis
## Data Source
This dataset is a copy of the widely-distributed "Sample Superstore" 
dataset originally published by Tableau for training purposes. No 
formal license was located for this specific dataset variant; it is 
included here for portfolio/educational reproducibility, consistent 
with its common distribution across public Kaggle mirrors and GitHub 
repositories.

## Dataset Overview

| Item | Value |
|------|-------|
| Source | Superstore Sample Dataset |
| Time period | 2014 - 2017 |
| Country | United States |
| Total records (order_items) | 9,994 |
| Number of tables | 4 |

---

## Table 1 — customers

Unique customer records. Contains only attributes verified to be stable
per `customer_id` (zero inconsistencies found across all 793 customers).

| Column | Data Type | Description |
|--------|-----------|--------------|
| customer_id | VARCHAR(20) | Primary Key |
| customer_name | VARCHAR(100) | Full customer name |
| segment | VARCHAR(20) | Consumer, Corporate, Home Office |

**Row count:** 793

**Data Quality Note:** City, State, Region, Postal Code, and Country
were originally assumed to be customer-level attributes. Testing showed
780 of 793 customers (98.4%) had orders shipped to more than one city,
proving these are order-level (shipping) attributes, not customer
attributes. They were moved to the `orders` table. Full rationale in
`docs/decisions.md` (Decision 001).

---

## Table 2 — products

Unique product records.

| Column | Data Type | Description |
|--------|-----------|--------------|
| product_id | VARCHAR(20) | Primary Key |
| category | VARCHAR(50) | Furniture, Office Supplies, Technology |
| sub_category | VARCHAR(50) | 17 sub-categories |
| product_name | VARCHAR(200) | Full product name |
| name_conflict | BOOLEAN | TRUE if this product_id mapped to more than one distinct product_name in the raw source data (see Data Quality Note below) |

**Row count:** 1,862 (32 flagged as name_conflict = TRUE)

**Data Quality Note:** 1,862 unique Product IDs exist against only 1,850
unique Product Names in the raw dataset — 32 Product IDs (1.7%) map to
two distinct, often unrelated product names (e.g. a chair ID paired with
a wall clock name). Root cause unconfirmed (hypothesis: sequence-number
collision within the same sub-category in the source dataset, not a
data-entry typo — pattern-based inference, not verified against an
official source). Rather than silently discarding one name during
deduplication, affected rows are flagged via `name_conflict = TRUE` so
downstream analysis can filter them out or treat their names as
low-confidence. Full list: `docs/data_quality/product_id_name_conflicts.csv`.

---

## Table 3 — orders

Unique order records, including shipping destination fields.

| Column | Data Type | Description |
|--------|-----------|--------------|
| order_id | VARCHAR(20) | Primary Key |
| order_date | DATE | Range: 2014-01-01 to 2017-12-31 |
| ship_date | DATE | Always >= order_date |
| ship_mode | VARCHAR(20) | Same Day, First Class, Second Class, Standard Class |
| ship_city | VARCHAR(50) | Destination city — verified stable per order_id |
| ship_state | VARCHAR(50) | Destination state |
| ship_region | VARCHAR(20) | East, West, Central, South |
| ship_country | VARCHAR(20) | Always "United States" in this dataset |
| ship_postal_code | VARCHAR(10) | Nullable — see data quality note below |

**Row count:** 5,009

**Data Quality Note:** 449 postal codes have fewer than 5 digits (e.g.
Massachusetts `2038` instead of `02038`). Cause: the source CSV stores
this column as an integer, which strips leading zeros. This is a source
data limitation and is not recoverable without an external ZIP code
reference table.

**Design Note:** The `ship_` prefix reflects an inference from data
behavior (these fields are constant within a given order_id, consistent
with a shipping destination), not an official definition documented by
the dataset source.

---

## Table 4 — order_items

Central fact table — one row per product line within an order.

| Column | Data Type | Description |
|--------|-----------|--------------|
| row_id | INTEGER | Primary Key |
| order_id | VARCHAR(20) | Foreign Key → orders |
| customer_id | VARCHAR(20) | Foreign Key → customers |
| product_id | VARCHAR(20) | Foreign Key → products |
| sales | NUMERIC(10,4) | Range: 0.44 to 22,638.48 |
| quantity | INTEGER | Range: 1 to 14 |
| discount | NUMERIC(4,2) | Range: 0.00 to 0.80 |
| profit | NUMERIC(10,4) | Range: -6,599.98 to 8,399.98 (can be negative) |

**Row count:** 9,994

---

## Schema Version History

| Version | Change | Reason |
|---------|--------|--------|
| v1 | Initial design — address fields in customers | Untested assumption |
| v2 | Address fields (city/state/region/country/postal_code) moved to orders | 98.4% of customers had orders shipped to multiple cities; verified via query. Full rationale: `docs/decisions.md`, Decision 001 |

---

## Entity Relationship Summary

```
customers (793)          orders (5,009)
customer_id PK            order_id PK
     |                         |
     └──────────┐   ┌──────────┘
                ▼   ▼
           order_items (9,994)
           row_id PK
           order_id FK
           customer_id FK
           product_id FK  ◄──── products (1,862)
                                 product_id PK
```