-- ============================================
-- Profitability Analysis (P1-P3)
-- ============================================

-- P1: Overall profit margin and trend by year
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    ROUND(SUM(oi.sales)::NUMERIC, 2)   AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)  AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS profit_margin_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY year
ORDER BY year;

-- P2: Profit by Category and Sub-Category
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales)::NUMERIC, 2)   AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)  AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS profit_margin_pct
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_profit ASC;

-- P3: Top 10 loss-making products
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    COUNT(*) AS transaction_count
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category, p.sub_category
HAVING SUM(oi.profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

SELECT oi.sales, oi.quantity, oi.discount, oi.profit
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
WHERE p.product_name = 'Cisco TelePresence System EX90 Videoconferencing Unit';