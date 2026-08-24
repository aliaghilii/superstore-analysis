-- ============================================
-- Discount & Pricing Analysis (D1-D3)
-- ============================================

-- D1: Discount vs Profit relationship (already partially known from
-- Phase 3, Decision 005 — this formalizes it as a business-facing query)
SELECT
    CASE
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.2 THEN '1-20%'
        WHEN discount <= 0.3 THEN '21-30%'
        WHEN discount <= 0.5 THEN '31-50%'
        ELSE '50%+'
    END AS discount_bracket,
    COUNT(*) AS transaction_count,
    ROUND(AVG(profit)::NUMERIC, 2) AS avg_profit,
    ROUND((COUNT(*) FILTER (WHERE profit < 0)) * 100.0 / COUNT(*), 2) AS pct_lossmaking
FROM order_items
GROUP BY discount_bracket
ORDER BY MIN(discount);

-- D2: Precise loss threshold — find the exact discount level where
-- majority of transactions flip to negative profit
SELECT
    discount,
    COUNT(*) AS transaction_count,
    ROUND((COUNT(*) FILTER (WHERE profit < 0)) * 100.0 / COUNT(*), 2) AS pct_lossmaking
FROM order_items
GROUP BY discount
ORDER BY discount;

-- D3: Which Category receives the highest average discount?
SELECT
    p.category,
    ROUND(AVG(oi.discount)::NUMERIC, 3) AS avg_discount,
    ROUND(SUM(oi.sales)::NUMERIC, 2) AS total_sales
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;