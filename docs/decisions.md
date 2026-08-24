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

-UPDATE (Phase 4 resolution)
Action taken: Deleted Row ID 3406 (exact duplicate of Row ID 3407).
Result: order_items reduced from 9,994 to 9,993 rows.
Validation: duplicate check query returned 0 rows after deletion.
Script: database/schema/clean_data.sql

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

## Decision 005 — Outlier detection concluded: no data errors found

Method: Per-category IQR (1.5×IQR) applied separately to Sales and 
Profit, since raw skewness (Sales=12.97, Profit=7.56) made whole-
dataset IQR unreliable. Discount excluded from IQR analysis — value 
counts showed only 12 discrete policy-driven levels (0%, 10%, 20%...), 
not a continuous variable.

Findings:
- Profit "outliers" (13-19% per category): strongly explained by 
  Discount > 30%, which correlates with negative profit 97.77% of 
  the time. This is a real business pattern, not a data error — 
  directly relevant to business question D2 (discount/profit 
  threshold). No cleaning action needed.
- Sales "outliers" (7.7-13.5% per category): driven primarily by 
  higher unit price (ratio 3.78x-13.63x across categories), not 
  bulk quantity (ratio only 1.29x-1.74x) — hypothesis about bulk 
  purchases was largely incorrect. Sanity-checked against the 
  single highest sale ($22,638.48, Cisco TelePresence System, 
  qty=6) — a plausible legitimate B2B transaction, not an error.

Conclusion: No row-level removal recommended for Sales/Profit 
outliers in Phase 4. These represent genuine business variation, 
not data quality issues.

## Decision 006 — Phase 6 scope reduced from original roadmap

The original roadmap listed 12 items for Phase 6 (Python EDA). 8 of 
these were already completed with more depth during Phase 3 (skewness, 
distribution checks) and Phase 5 (Category/Region/Customer/Time 
analysis via SQL — 23 findings documented in analytical_findings.md).

Decision: Phase 6 scope narrowed to the 3 items that provide genuine 
new value beyond what SQL already delivered:
1. Visualizations (histograms, boxplots, trend charts) — for direct 
   use in final report/dashboard
2. Multivariate correlation matrix (Sales, Profit, Quantity, Discount) 
   — SQL only supports pairwise CORR()
3. Market Basket Analysis (PR3, deferred from Phase 5) — requires 
   Apriori/FP-Growth, impractical in raw SQL

Rationale: avoids redundant work (same anti-pattern caught earlier 
with CU3 and O1 query redundancy).

## Finding 24 — REVISED & CONFIRMED: Profit follows a structured, 
## near-linear discount-based pattern per Category

Query: notebooks/03_visualization_correlation.ipynb, Category×Discount 
groupby

Mean margin decreases in a fairly linear, predictable pattern as 
discount increases, with a consistent base margin (~29-37%) at 0% 
discount for all three categories, declining toward strongly negative 
values at high discount tiers (e.g. Office Supplies: 36.7% → -182.5% 
from 0% to 80% discount). Standard deviations within each 
(Category, Discount) group are non-trivial (5-40), ruling out an exact 
deterministic formula, but the strength and regularity of the pattern 
across all three categories suggests this dataset's Profit values were 
likely generated with a structured discount-based rule plus random 
noise, rather than reflecting fully organic/independent transactions.

Implication: explains why the discount>30% loss threshold (Decision 
005, Finding 6, D2) is so sharp and consistent — this is very likely 
a designed characteristic of the synthetic/training dataset, not an 
emergent real-world business pattern. Should be disclosed as a dataset 
limitation in the final report, alongside the earlier note on 
Product ID/Name generation issues (Finding 24 in Decision 002).

## Finding 25 — Transaction-level Sales-Profit correlation weaker than 
## monthly-aggregate correlation

Sales-Profit correlation at the transaction level (0.48) is notably 
weaker than at the monthly-aggregate level (Finding 14, T3: 0.716). 
Aggregation smooths individual-transaction noise (e.g. discount 
variation, product mix), producing a stronger apparent relationship. 
Both figures are valid — they answer different questions (transaction- 
level vs. time-period-level relationship).

## Observation (unconfirmed) — Possible discrete clustering in margin values

The boxplot of margin by category shows whisker boundaries suspiciously 
aligned near round numbers (~50%, ~-25%) across categories, hinting 
that Profit may be formulaically generated in this dataset rather than 
organic. Not confirmed — would require checking margin value frequency 
distribution directly.

## Finding 26 — PR3: No meaningful cross-sell pattern found

Query: notebooks/03_visualization_correlation.ipynb, Market Basket Analysis

Method: Apriori algorithm at Sub-Category granularity (Product-level 
analysis was ruled out — Finding: 50.7% of orders contain only 1 
distinct product, making product-level basket analysis too sparse).

Result: The strongest association found (Binders → Appliances) has 
lift = 1.097 — only 9.7% above random chance, well below the 
lift > 2-3 threshold typically considered meaningful in retail cross-
sell analysis. Of 44 rules generated, 77% had lift < 1.0 (weak negative 
association). 

Conclusion: This dataset shows no strong product/sub-category cross-
sell pattern. Customers appear to purchase items largely independently 
of each other, rather than in predictable combinations. This is a 
valid negative finding, not an analysis failure — recommend NOT 
building product bundles/recommendations based on this dataset, as no 
statistically meaningful basis exists.

Limitation: Analysis conducted at Sub-Category level (17 categories) 
due to sparsity at Product level (1,862 products). A genuine product-
level pattern could theoretically exist but be undetectable with this 
order volume (5,009 orders) and granularity.