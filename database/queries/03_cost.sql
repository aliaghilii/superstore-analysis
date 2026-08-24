-- ============================================
-- Cost Analysis (C1-C2)
-- NOTE: This dataset has no explicit COGS column.
-- "Cost" here is a derived proxy = Sales - Profit.
-- ============================================

-- C1: Discount cost as % of implied list-price revenue
-- (reconstructs pre-discount price: list_price = sales / (1 - discount))
WITH discount_cost AS (
    SELECT
        SUM(sales) AS actual_sales,
        SUM(CASE WHEN discount < 1 THEN sales * discount / (1 - discount) ELSE 0 END) AS discount_cost
    FROM order_items
)
SELECT
    ROUND(actual_sales::NUMERIC, 2) AS actual_sales,
    ROUND(discount_cost::NUMERIC, 2) AS discount_cost,
    ROUND(discount_cost * 100.0 / (actual_sales + discount_cost), 2) AS discount_cost_pct_of_list_price
FROM discount_cost;

-- C2: Average (proxy) cost per order by Ship Mode
WITH order_cost AS (
    SELECT
        oi.order_id,
        o.ship_mode,
        SUM(oi.sales) - SUM(oi.profit) AS order_cost
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.order_id, o.ship_mode
)
SELECT
    ship_mode,
    COUNT(*) AS order_count,
    ROUND(AVG(order_cost)::NUMERIC, 2) AS avg_cost_per_order
FROM order_cost
GROUP BY ship_mode
ORDER BY avg_cost_per_order DESC;