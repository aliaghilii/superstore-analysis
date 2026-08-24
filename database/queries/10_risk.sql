-- ============================================
-- Risk Analysis (RI1-RI3)
-- ============================================

-- RI1: Revenue concentration in Top 10 customers
-- (distinct from Finding 3's quintile-based check — this is the
-- exact metric the business question asks for)
WITH customer_revenue AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM order_items
    GROUP BY customer_id
),
ranked AS (
    SELECT *, RANK() OVER (ORDER BY total_sales DESC) AS rnk
    FROM customer_revenue
)
SELECT
    SUM(total_sales) FILTER (WHERE rnk <= 10) AS top10_revenue,
    SUM(total_sales) AS total_revenue,
    ROUND(SUM(total_sales) FILTER (WHERE rnk <= 10) * 100.0 / SUM(total_sales), 2) AS pct_from_top10
FROM ranked;

-- RI2: Revenue/Profit concentration in a single Category
SELECT
    p.category,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(SUM(oi.profit)) OVER (), 2) AS pct_of_total_profit
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- RI3: State/Region loss risk ranking (formalizes G2 for Risk section)
SELECT
    o.ship_state,
    o.ship_region,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit,
    COUNT(DISTINCT oi.order_id) AS order_count,
    ROUND(SUM(oi.profit) / COUNT(DISTINCT oi.order_id)::NUMERIC, 2) AS avg_profit_per_order
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_state, o.ship_region
HAVING SUM(oi.profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

-- RI3-followup: Texas root cause (deferred finding, now investigated)
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales)::NUMERIC, 2)   AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)  AS total_profit,
    ROUND(AVG(oi.discount)::NUMERIC, 3) AS avg_discount,
    COUNT(*) AS transaction_count
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products_clean p ON oi.product_id = p.product_id
WHERE o.ship_state = 'Texas'
GROUP BY p.category, p.sub_category
ORDER BY total_profit ASC
LIMIT 5;