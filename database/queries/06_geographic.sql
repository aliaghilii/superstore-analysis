-- ============================================
-- Geographic Analysis (G1-G3)
-- ============================================

-- G1: Most profitable Region
SELECT
    o.ship_region,
    ROUND(SUM(oi.sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS profit_margin_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_region
ORDER BY total_profit DESC;

-- G2: Unprofitable States
SELECT
    o.ship_state,
    ROUND(SUM(oi.sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    COUNT(DISTINCT oi.order_id)       AS order_count
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_state
HAVING SUM(oi.profit) < 0
ORDER BY total_profit ASC;

-- G3: Best-selling Category per Region
WITH region_category AS (
    SELECT
        o.ship_region,
        p.category,
        SUM(oi.sales) AS total_sales,
        RANK() OVER (PARTITION BY o.ship_region ORDER BY SUM(oi.sales) DESC) AS rnk
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products_clean p ON oi.product_id = p.product_id
    GROUP BY o.ship_region, p.category
)
SELECT ship_region, category, ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM region_category
WHERE rnk = 1;


-- Why is West both high-margin AND Furniture-dominant?
-- Check Furniture sub-category mix specifically within West region
SELECT
    p.sub_category,
    ROUND(SUM(oi.sales)::NUMERIC, 2)  AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS margin_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products_clean p ON oi.product_id = p.product_id
WHERE o.ship_region = 'West' AND p.category = 'Furniture'
GROUP BY p.sub_category
ORDER BY total_sales DESC;

-- Cross-check: are the top loss-making states concentrated in Central?
SELECT
    o.ship_state,
    o.ship_region,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_state, o.ship_region
HAVING SUM(oi.profit) < 0
ORDER BY total_profit ASC
LIMIT 10;