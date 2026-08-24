# Analytical Findings — Superstore Analysis

Running log of business insights discovered during Phase 5 (SQL Analysis),
to be synthesized in Phase 7 (Business Analysis) and Phase 9 (Dashboard).

## Finding 1 — Declining Average Order Value (2014-2017)

Query: database/queries/01_revenue.sql, R3

AOV fell from $499.45 (2014) to $434.63 (2017), a ~13% decline, despite
total order volume increasing substantially over the same period (e.g.
November: 151 orders in 2014 vs 261 in 2017). Revenue growth appears
driven by order volume, not order value.

Hypothesis (untested): possible causes include increased discounting,
smaller average basket size, or customer mix shift. Requires further
investigation — see Discount Analysis (Phase 5, D1-D3) and Customer
Analysis (CU1-CU3).

## Finding 2 — Strong seasonal pattern

Query: database/queries/01_revenue.sql, R1

November and December consistently show the highest monthly sales in
every year (e.g. Nov 2017 = $118,447 vs Feb 2017 = $20,301, ~6x).
Consistent with holiday-season retail seasonality. To be formally
analyzed in Time Series Analysis (T1).

## Finding 3 — Revenue concentration lower than classic 80/20 rule

Query: database/queries/01_revenue.sql, R4

Top 20% of customers (by revenue) generate only 48.14% of total 
revenue, not ~80% as the classic Pareto principle would suggest. 
Reaching 80% of revenue requires the top ~40-50% of customers 
(cumulative: 40% of customers = 71.58%, 60% = 87.19%).

Interpretation (two competing views, not resolved):
- Positive: lower customer concentration = lower revenue risk if a 
  major customer churns. Relevant to Risk Analysis (RI1).
- Cautionary: may indicate lack of strong key-account relationships 
  typical of successful B2B operations.

Note: This uses quintile granularity (~159 customers per group), 
distinct from the Top-10-customer question (RI1), which requires a 
separate dedicated query in Risk Analysis.

## Finding 4 — Profit margin improved despite falling AOV (2014-2017)

Query: database/queries/02_profitability.sql, P1

Contrary to the expectation that a declining AOV (Finding 1) implies 
worsening profitability, profit margin actually improved from 10.24% 
(2014) to a peak of 13.43% (2016), settling at 12.74% (2017). Smaller 
average orders have not come at the cost of efficiency — possibly due 
to reduced discounting or a shift toward higher-margin products over 
time. Requires investigation in Discount Analysis (D1-D3).

## Finding 5 — Transaction-level loss rate does not equal category 
## unprofitability

Query: database/queries/02_profitability.sql, P2 vs Phase 3 findings

Furniture showed a 33.66% transaction-level loss rate (Phase 3), but 
its "Chairs" sub-category is aggregate-profitable (+8.13% margin) — 
profitable transactions outweigh frequent small losses. In contrast, 
"Tables" is aggregate-unprofitable (-8.56% margin), driven by fewer 
but much larger losses. Loss frequency and loss severity are distinct 
dimensions and should be reported separately, not conflated.

## Finding 6 — UPDATE: precise discount threshold identified

Query: database/queries/09_discount.sql, D2

Refines Decision 005: the loss-rate jump is sharp and occurs precisely 
between 20% discount (13.73% loss rate) and 30% discount (91.59% loss 
rate) — not a gradual slope. Business recommendation: 30% functions as 
a near-hard ceiling before transactions become loss-making in the vast 
majority of cases.

Minor anomaly: discount=0.15 shows a non-monotonic 32.69% loss rate, 
higher than both 0.10 (4.26%) and 0.20 (13.73%). Sample size is small 
(n=52) — likely statistical noise rather than a genuine pattern, but 
not fully investigated (possible product-mix effect at this specific 
discount tier).

## Finding 7 — Central region: high sales volume, weak profitability

Query: database/queries/06_geographic.sql, G1

Central shows the second-lowest total sales ($501,239) but by far the 
lowest profit margin (7.92%), roughly half of West's margin (14.94%) 
despite Central having higher sales than South. Suggests Central may 
sell a disproportionate share of low-margin products (e.g. Tables, 
per Finding 5) — requires category-mix breakdown by region to confirm 
(not yet tested).

## Finding 8 — West region dominated by Furniture, yet highest margin

Query: database/queries/06_geographic.sql, G3

Contrary to expectation, West's top-selling category is Furniture 
(not Technology, as in the other 3 regions), while West simultaneously 
holds the highest profit margin overall (14.94%). This appears to 
contradict the pattern where Furniture (specifically Tables) drags 
down margin elsewhere (Finding 5). Requires sub-category breakdown 
within West to resolve — see follow-up query.

## Finding 8 — REVISED: West's high margin is not driven by Furniture

Query: database/queries/06_geographic.sql, follow-up on Furniture 
sub-category breakdown

Correction to earlier framing: Furniture in West has only a 4.37% 
margin — below West's overall regional margin (14.94%) — despite 
being the top category by sales volume. West's strong overall margin 
must be driven by other categories (Technology/Office Supplies), not 
yet confirmed with a direct query.

## Finding 9 — Tables' aggregate loss (Finding 5) is not uniform 
## across regions

Within West specifically, Tables shows a small positive margin 
(+1.75%), contradicting the aggregate -8.56% margin seen in Finding 5. 
The aggregate loss is likely driven by other regions — requires a 
region × sub-category breakdown for Tables specifically to confirm.

## Finding 10 — REVISED: Central's weak margin is a portfolio-balance 
## issue, not uniform regional weakness

Query: database/queries/06_geographic.sql, state-region cross-check

Earlier hypothesis (losses concentrated in Central) was only partially 
correct. East has comparable absolute losses from its two worst states 
(Ohio + Pennsylvania = -$32,519) to Central's worst two (Texas + 
Illinois = -$38,336). The key difference: this loss represents ~97% of 
Central's total regional profit, but only ~36% of East's — because 
East has enough high-performing states to absorb the drag, while 
Central does not. This is a portfolio composition issue, not uniform 
underperformance.

## Finding 11 — RESOLVED: Texas loss driven by extreme (80%) discounting 
## on two sub-categories

Query: database/queries/10_risk.sql, RI3-followup

Texas's outlier loss (-$25,729) is explained: 78% of it comes from just 
two sub-categories — Office Supplies/Binders (-$13,922) and Appliances 
(-$6,147) — both carrying the maximum discount level in the dataset 
(80%). This is consistent with the discount>30% loss pattern (Finding 
6/D2) taken to its extreme. Root cause of why Texas received 80% 
discounts on these specific items is unknown — could reflect a 
region-specific pricing policy, a large corporate contract, or a data 
entry pattern. Not resolvable with available data.


## Finding 12 — UPDATE: September spike likely Q3-end B2B pattern, 
## not back-to-school

Query: database/queries/07_timeseries.sql, T1-followup

September sales are fairly evenly distributed across all 3 categories 
(Furniture 34.5%, Office Supplies 33.5%, Technology 30.6%). If the 
spike were driven by back-to-school demand, Office Supplies would be 
expected to dominate — it does not. The even distribution is more 
consistent with a general Q3 fiscal-year-end B2B spending pattern, 
though this remains a weak inference, not confirmed (would require 
customer-segment data not available in this dataset).

Status: Closed for Phase 5 purposes.

## Finding 13 — 2015 was an anomalous down year for Office Supplies 
## and Technology

Query: database/queries/07_timeseries.sql, T2

Contrary to the overall growth narrative (Finding 1, revenue growing 
via volume), Office Supplies (-9.68%) and Technology (-9.31%) both 
declined in 2015, while Furniture grew (+9.51%). Both categories 
rebounded sharply in 2016 (+33.03%, +40.03%). This dip was masked in 
aggregate yearly totals (R1) and only visible at category granularity. 
Root cause unknown — could reflect market/competitive factors not 
captured in this dataset.

## Finding 14 — Sales and Profit are correlated but not tightly bound

Query: database/queries/07_timeseries.sql, T3

Monthly Sales-Profit correlation = 0.716, confirming they generally 
move together but with meaningful independent variation — consistent 
with the earlier finding that discount level can decouple profit from 
sales for individual transactions (Finding 6).

## Finding 15 — Single product dominance in top profit contributors

Query: database/queries/05_product.sql, PR2

The single top profit-generating product (Canon imageCLASS 2200 
Advanced Copier, $25,199.93) contributes more than 3x the profit of 
the second-ranked product ($7,753.04). Phones — a high aggregate-
profit sub-category (Finding P2, $42,095) — do not appear in the 
Top 10 individual products at all, suggesting Phone profit comes from 
many smaller transactions rather than a few dominant products, 
opposite to the Copiers pattern.

## Finding 16 — REVISED: BCG-margin mismatch is systematic, not isolated

Query: database/queries/05_product.sql, PR1 + margin cross-check

5 of 17 sub-categories (29%) show a BCG quadrant that contradicts 
actual profit margin, in two directions:

**False reassurance (Cash Cow but unprofitable):**
- Tables: Cash Cow, margin -8.56%

**False deprioritization (Dog but highly profitable):**
- Envelopes: Dog, margin +42.27% (higher than most Stars)
- Fasteners: Dog, margin +31.40%
- Furnishings: Dog, margin +13.62%

**Risky growth signal (Question Mark but unprofitable):**
- Bookcases: Question Mark, margin -3.43% — standard QM strategy 
  (invest for growth) would mean investing in a currently 
  loss-making line

Conclusion: This adapted BCG model (internal sales share × internal 
YoY growth, no market/competitor data) systematically misrepresents 
priority for ~30% of sub-categories when profitability is ignored. 
Any strategic recommendation from this analysis MUST report margin 
alongside quadrant — BCG quadrant alone is not a reliable standalone 
decision tool for this dataset.

Recommendation for final report/dashboard: display BCG quadrant and 
margin_pct as two separate, always-paired metrics, never quadrant alone.

## Open Item — PR3 (Cross-sell / Market Basket Analysis)

Deferred. Requires Market Basket Analysis (Apriori/FP-Growth), likely 
better suited to Python (Phase 6) than raw SQL. Will revisit after 
core SQL analysis phases are complete.

## Finding 17 — RFM dimensions are strongly correlated, not independent

Query: database/queries/04_customer.sql, CU1

Customers with high Recency scores overwhelmingly also show high 
Frequency and Monetary scores (and vice versa for low scores) — visible 
as large clusters at "555"-type and "111"-type combined codes. Note: 
each individual R/F/M score is guaranteed ~20% distribution by NTILE(5) 
construction (not itself informative); the correlation between 
dimensions when combined is the genuine finding. Suggests a segment of 
consistently high-value, active customers rather than customers who 
excel on only one RFM dimension.

## Note — CU3 query was redundant with CU2

avg_clv_proxy (CU3) is mathematically identical to total_profit / 
customer_count, both already available from CU2. No new information 
was gained; flagged here as a query design oversight, not a data finding.

## Finding 18 — Revenue concentration is driven more by monetary value 
## alone than by loyal/active customer behavior

Query: database/queries/04_customer.sql, CU1-champions

Champions (customers scoring high on Recency AND Frequency AND 
Monetary simultaneously) represent only 13.1% of customers but 23.9% 
of revenue — notably lower than Finding 3's monetary-only Pareto check 
(top 20% by revenue alone = 48.14%). 

This gap suggests a meaningful share of high-revenue customers are 
NOT currently active/frequent buyers — likely large one-time or 
infrequent purchasers rather than loyal repeat customers. This is a 
business risk not visible from Finding 3 alone: a portion of revenue 
concentration relies on customers who may not return, rather than a 
stable, engaged customer base. Relevant to Risk Analysis (RI1).

## Finding 19 — Furniture carries both highest discount and lower 
## base margin — compounding effect

Query: database/queries/09_discount.sql, D3

Furniture has the highest average discount (17.5%) of all categories, 
consistent with and explaining part of Finding 5 (Tables/Bookcases 
unprofitable) — high discounting compounds with inherently thinner 
margins in this category.

## Finding 20 — Customer revenue concentration is low at every 
## granularity (final synthesis)

Query: database/queries/10_risk.sql, RI1

Top 10 customers = 6.70% of revenue, Champions (13% of customers) = 
23.9%, Top 20% by revenue = 48.14% (Finding 3). Customer concentration 
risk is consistently low across all groupings — a genuine strength, 
not a risk, for this business.

## Finding 21 — Profit concentration by Category is significant

Query: database/queries/10_risk.sql, RI2

Technology generates 50.33% of total profit despite comparable sales 
volume to other categories; Furniture generates only 6.16% of profit 
despite substantial sales share (Finding 19's high discount + Finding 
5's thin margins compound here). Category-level profit concentration 
is notably higher than customer-level concentration — the real 
concentration risk in this business is categorical, not customer-based

## Finding 22 — Discount consumes ~20% of list-price revenue

Query: database/queries/03_cost.sql, C1

Total discount cost equals 19.79% of implied list-price revenue — 
a substantial figure given that discount>30% is associated with 
near-guaranteed losses (Finding 6/D2). Suggests meaningful profit 
upside from tightening discount policy above the 30% threshold.

## Finding 23 — Ship Mode has minimal influence on cost or profitability

Query: database/queries/08_operational.sql, O2 + database/queries/03_cost.sql, C2

Profit margin varies only 1.85 percentage points across ship modes 
(12.08%-13.93%), and cost-per-order proxy varies only ~10.8% 
(Same Day highest at $426, First Class lowest at $384). Shipping 
method is not a meaningful driver of profitability in this dataset — 
category mix and discount level (Findings 6, 19) are the dominant 
factors instead.