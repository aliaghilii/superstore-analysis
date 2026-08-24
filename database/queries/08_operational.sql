-- ============================================
-- Operational Analysis (O1-O2)
-- O1 (avg ship duration by mode) already answered during Phase 3/5
-- Same Day investigation — not repeated here. See analytical_findings.md.
-- ============================================

-- O2: Relationship between Ship Mode and profitability
SELECT
    o.ship_mode,
    ROUND(SUM(oi.sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS margin_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_mode
ORDER BY margin_pct DESC;