# Superstore Sales Performance Analysis

End-to-end data analysis project on the Sample Superstore dataset, 
covering database design, data quality auditing, SQL analysis across 
10 business categories, Python-based exploratory analysis, and an 
interactive Power BI dashboard.

## Project Goal

Analyze sales and profitability performance across products, customers, 
regions, and time to identify strengths, weaknesses, and deliver 
actionable business recommendations.

## Tech Stack

PostgreSQL · Python (pandas, numpy, seaborn) · Power BI

## Project Architecture

data/raw/ → Original source CSV
data/processed/ → Generated CSVs (excluded from git, regenerate via prepare_import.py)
database/schema/ → Table definitions, import scripts, cleaning scripts
database/queries/ → SQL analysis by business category (01-10) + data quality checks
database/views/ → Power BI-facing views (e.g. products_clean)
notebooks/ → Python EDA, data quality checks, visualizations
docs/ → Data dictionary, decision log, findings, business summary, recommendations
dashboard/ → Power BI file and screenshots


### Key design decisions
The dataset went through a 4-table normalization (customers, products, 
orders, order_items). Along the way, several assumptions were tested 
and corrected — most notably, address fields were moved from customers 
to orders after discovering 98.4% of customers had shipped to multiple 
cities. Full decision log with evidence: [`docs/decisions.md`](docs/decisions.md).

## Data

Sample Superstore dataset (2014-2017, United States). Details: 
[`docs/data_dictionary.md`](docs/data_dictionary.md).

## Analysis Summary

- **SQL Analysis** (`database/queries/`): 23 findings across Revenue, 
  Profitability, Cost, Customer/RFM, Product/BCG, Geographic, Time 
  Series, Operational, Discount, and Risk analysis.
- **Python EDA** (`notebooks/`): distribution analysis, correlation 
  matrix, and Market Basket Analysis (no significant cross-sell 
  pattern found).

Full findings log (26 total, each with evidence and confidence level): 
[`docs/analytical_findings.md`](docs/analytical_findings.md).

## Business Summary & Recommendations

Strengths, weaknesses, and open questions synthesized from all 
findings: [`docs/business_summary.md`](docs/business_summary.md).

Actionable recommendations, each traced to a specific finding: 
[`docs/recommendations.md`](docs/recommendations.md).

## Dashboard

Interactive Power BI dashboard with 4 pages:
1. Executive Dashboard — KPIs, revenue/profit trends, regional overview
2. Product Analysis — category performance, BCG-style analysis with margin overlay, top/loss-making products
3. Customer Analysis — top customers, revenue contribution, segments
4. Geographic Analysis — regional and state-level sales/profit

Screenshots: [`dashboard/screenshots/`](dashboard/screenshots/)  
File: [`dashboard/superstore_dashboard.pbix`](dashboard/superstore_dashboard.pbix)

## Key Findings (highlights)

- Discount above 30% is associated with negative profit in the large 
  majority of transactions — a sharp threshold, not a gradual slope.
- Customer revenue concentration is low at every granularity (top 10 
  customers = 6.7% of revenue), but category-level profit concentration 
  is high (Technology = 50% of profit).
- A single root cause (80% discount on two sub-categories) explains 78% 
  of Texas's total loss.

Full list: see `docs/analytical_findings.md` and `docs/recommendations.md`.

## Data Quality Notes

This dataset appears to have some synthetic/training-data characteristics 
(e.g. 32 Product IDs map to conflicting names; Profit follows an 
unusually structured discount-based pattern). These are disclosed as 
limitations in `docs/business_summary.md`.

## How to Reproduce

1. Run `database/schema/create_tables.sql` in PostgreSQL
2. Run `python database/schema/prepare_import.py` to generate processed CSVs
3. Run `database/schema/import_data.sql` to load data
4. Run `database/schema/clean_data.sql` for Phase 4 cleaning
5. Run queries in `database/queries/` for the full analysis
