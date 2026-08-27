-- ============================================
-- Phase 7: Core Business KPIs
-- ============================================
SELECT
    ROUND(SUM(oi.sales)::NUMERIC, 2)                          AS total_revenue,
    ROUND(SUM(oi.profit)::NUMERIC, 2)                         AS total_profit,
    COUNT(DISTINCT oi.order_id)                                AS total_orders,
    COUNT(DISTINCT oi.customer_id)                             AS total_customers,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT oi.order_id)::NUMERIC, 2) AS avg_order_value,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2)          AS overall_profit_margin_pct
FROM order_items oi;