-- ============================================
-- Revenue Analysis (R1-R4)
-- ============================================

-- R1: Annual and monthly sales trend
SELECT
    EXTRACT(YEAR FROM o.order_date)  AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    ROUND(SUM(oi.sales)::NUMERIC, 2) AS total_sales,
    COUNT(DISTINCT oi.order_id)      AS total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY year, month
ORDER BY year, month;

-- R2: Sales by Category and Sub-Category
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales)::NUMERIC, 2)   AS total_sales,
    ROUND(SUM(oi.sales) * 100.0 /
          SUM(SUM(oi.sales)) OVER ()::NUMERIC, 2) AS pct_of_total
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_sales DESC;

-- R3: Average Order Value (AOV) trend by year
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    ROUND(SUM(oi.sales) /
          COUNT(DISTINCT oi.order_id)::NUMERIC, 2) AS avg_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY year
ORDER BY year;

-- R4: Pareto check — do top 20% customers generate 80% of revenue?
WITH customer_revenue AS (
    SELECT
        oi.customer_id,
        SUM(oi.sales) AS total_sales
    FROM order_items oi
    GROUP BY oi.customer_id
),
ranked AS (
    SELECT
        customer_id,
        total_sales,
        NTILE(5) OVER (ORDER BY total_sales DESC) AS quintile
    FROM customer_revenue
)
SELECT
    quintile,
    COUNT(*)                                          AS customer_count,
    ROUND(SUM(total_sales)::NUMERIC, 2)               AS quintile_sales,
    ROUND(SUM(total_sales) * 100.0 /
          SUM(SUM(total_sales)) OVER ()::NUMERIC, 2)  AS pct_of_total
FROM ranked
GROUP BY quintile
ORDER BY quintile;