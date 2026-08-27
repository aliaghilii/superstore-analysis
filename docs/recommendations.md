# Recommendations — Superstore Analysis

Each recommendation below is tied directly to a finding from `analytical_findings.md` and `business_summary.md`. Where evidence is incomplete, the recommendation reflects that uncertainty rather than overstating it.

## Priority 1 — Immediate, high-confidence actions

**R1. Cap or review discounts above 30 percent.**
Source: Finding #6, Finding #22. Discount above 30% is associated with negative profit in the large majority of transactions, and discounting overall consumes approximately 19.8% of list-price revenue. Recommend a policy review of any discount tier above 30%, requiring explicit approval rather than default availability, since the root cause of why these high discounts exist (legitimate business reasons vs. uncontrolled practice) is not confirmed by this data.

**R2. Investigate the Texas 80% discount pattern on Binders and Appliances.**
Source: Finding #11. A single, identifiable cause (80% discount on two sub-categories) explains 78% of Texas's total loss. This is the highest-confidence, most isolated fix available — recommend auditing why this discount level was applied in this specific state/category combination before assuming it's policy-driven versus an anomaly.

## Priority 2 — Medium-confidence, structural actions

**R3. Address Furniture's compounding margin problem.**
Source: Finding #5, #19. Furniture carries both the highest average discount (17.5%) and thinner base margins than other categories. Recommend reviewing Furniture-specific discount policy separately from other categories — a uniform company-wide discount cap would not address this category's compounded weakness.

**R4. Do NOT apply a blanket "reduce Tables" strategy.**
Source: Finding #5 vs. Finding #9. Tables is aggregate-unprofitable, but profitable specifically in the West region. A company-wide decision to cut or deprioritize Tables would be incorrect based on current evidence. Recommend a region-by-region profitability breakdown for Tables before any product-line decision is made.

**R5. Reduce category-level concentration risk, not customer-level.**
Source: Finding #21 (cross-referenced with Finding #20). Technology generates 50% of total profit while Furniture contributes only 6%, despite comparable sales volume. Since customer revenue concentration is already low (#20), risk-mitigation effort is better directed at diversifying category profitability than at customer acquisition or retention programs, where risk is not currently elevated.

**R6. Investigate Central region's portfolio imbalance.**
Source: Finding #10. Central's weak margin (7.92%) is driven almost entirely by two states (Texas, Illinois) that consume nearly all the region's profit — this is a portfolio-balance issue, not uniform regional weakness. Recommend growing the profitable-state share within Central rather than treating the whole region as underperforming.

## Priority 3 — Requires further data before acting

**R7. Do not build product bundles/cross-sell promotions based on this dataset.**
Source: Finding #26. No meaningful basket association was found (max lift 1.097). Acting on assumed bundles here would have no statistical basis.

**R8. Flag "Champions" retention as a watch item, not yet an emergency.**
Source: Finding #18. Only 23.9% of revenue comes from loyal/active high-value customers vs. 48% from top-spenders overall — suggesting some high-revenue customers may not return. Recommend monitoring this cohort's repeat-purchase rate over time before designing a retention program, since root cause (one-time large buyers vs. genuine churn) is not yet confirmed.

**R9. Treat the September sales spike as a planning input, pending root-cause confirmation.**
Source: Finding #12. Whether driven by Q3 fiscal-year-end B2B spending or another cause, the pattern itself justifies inventory/staffing preparation ahead of September — but any messaging/campaign built on a specific causal story (e.g., "back-to-school") would be unsupported by current evidence.

## Explicitly NOT recommended

- **Do not use the raw BCG Matrix output for investment decisions** without cross-checking margin (Finding #16) — it misclassifies ~30% of sub-categories.
- **Do not generalize the discount-to-loss threshold (30%) as a universal retail law** — Finding #24 suggests this dataset's profit structure may be partly synthetic/formulaic, not purely organic market behavior.