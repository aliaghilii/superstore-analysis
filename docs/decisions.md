## Decision 001 — Move address fields from customers to orders
Problem: Initial schema assumed city/state/region were stable 
         customer attributes.
Evidence: 780/793 (98.4%) customers appeared with multiple cities.
          Order-level consistency confirmed (0/5,009 inconsistent).
Decision: Move ship_city, ship_state, ship_region, ship_postal_code 
          to orders table.
Alternatives considered: Keep in customers (rejected — data proves 
          it's wrong); separate addresses table (rejected — 
          overengineering for this dataset's needs).

"Verified: no NULLs in columns constrained as NOT NULL by schema 
    (expected, enforced at import time) and in the one nullable column 
    (ship_postal_code). This does NOT cover duplicates, business-rule 
    validity, or logical consistency — deferred to Phase 3."


## Decision 002 — Flag Product ID / Name conflicts instead of silent dedup
Problem: The initial products table was built via
`drop_duplicates(subset=['Product ID'])`, which silently kept only the
first product_name seen for each ID and discarded any alternates —
without recording that a conflict existed.

Evidence: Raw data check (`df.groupby('Product ID')['Product Name'].nunique()`)
found 32 Product IDs (1.7% of 1,862) mapped to two distinct names.
Manual inspection showed these are often unrelated products (e.g. a
chair paired with a wall clock name), not minor spelling variants —
suggesting a data quality issue in the source dataset rather than a
naming inconsistency.

Method note: This check is only valid on raw, non-deduplicated data.
Running it on the already-deduplicated `products` table would be
tautological, since `drop_duplicates(subset=['Product ID'])` guarantees
exactly one name per ID by construction — the conflict is destroyed
before it can be observed.

Decision: Added a `name_conflict BOOLEAN NOT NULL DEFAULT FALSE` column
to the `products` table, computed in `prepare_import.py` before
deduplication. Chose this over (a) pure documentation with no schema
change — rejected because it leaves downstream query results (e.g. Top
Products reports) with no visible warning; and (b) a separate
name-variants table — rejected as overengineering for a dataset where
only 1.7% of rows are affected.

Full conflict list: `docs/data_quality/product_id_name_conflicts.csv`


## Decision 003 — Duplicate transaction found, disposition deferred to Phase 4

Finding: One exact duplicate found in `order_items` — same order_id,
customer_id, product_id, and all financial fields (sales, quantity,
discount, profit) appear twice (Row ID 3406 and 3407 in the raw
source CSV).

Details: order_id = US-2014-150119, customer_id = LB-16795,
product_id = FUR-CH-10002965, sales = 281.372, quantity = 2,
discount = 0.30, profit = -12.0588.

Verification: Confirmed present in raw source data (both row IDs
exist independently in `data/raw/superstore.csv`) — not an artifact
of our import pipeline.

Query: See `database/queries/data_quality_checks.sql`, Check 2.

Assessment (hypothesis, not proven): Given all 7 numeric/categorical
fields match exactly, this is most likely a duplicate data-entry
error inherited from the source dataset, not two genuinely distinct
transactions. Confidence: high, but not certain — no way to verify
against an external source of truth.

Decision: Do not resolve now. Documented here for traceability;
disposition (keep, remove, or flag) deferred to Phase 4 (Data
Cleaning), consistent with the roadmap's separation of Discovery
(Phase 3) from remediation (Phase 4).

## Decision 004 — Same Day shipping duration anomaly (12 orders)

Finding: Of 264 orders with ship_mode = 'Same Day', 252 (95.5%) show
0 days between order_date and ship_date as expected. 12 orders (4.5%)
show a 1-day gap instead.

Cross-check: General hypothesis that shipping duration scales with
ship_mode was confirmed (First Class ~2.2 days avg, Second Class
~3.2 days, Standard Class ~5.0 days) — this anomaly is isolated to a
minority of Same Day orders, not a systemic labeling issue.

Limitation: Dataset only records dates, not timestamps. Cannot verify
whether these 12 orders were placed late at night and processed on
the next calendar day (a legitimate business edge case) versus a
genuine data entry error. Insufficient granularity to resolve.

Decision: Documented, not resolved. Disposition deferred to Phase 4.
Query: `database/queries/data_quality_checks.sql`