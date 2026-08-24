-- ============================================
-- Time Series Analysis (T1-T3)
-- ============================================

-- T1: Seasonality — sales per month normalized against that year's
-- monthly average, to separate seasonal effect from overall YoY growth
WITH monthly AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date)  AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(oi.sales) AS monthly_sales
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY year, month
),
yearly_avg AS (
    SELECT year, AVG(monthly_sales) AS avg_monthly_sales
    FROM monthly
    GROUP BY year
)
SELECT
    m.month,
    ROUND(AVG(m.monthly_sales / y.avg_monthly_sales)::NUMERIC, 2) AS seasonal_index
FROM monthly m
JOIN yearly_avg y ON m.year = y.year
GROUP BY m.month
ORDER BY m.month;

-- Which Category drives the September spike? 
-- Office Supplies dominance would support "back-to-school"; 
-- a broad spike across all categories would support "Q3 fiscal year-end"
SELECT
    p.category,
    SUM(oi.sales) AS september_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products_clean p ON oi.product_id = p.product_id
WHERE EXTRACT(MONTH FROM o.order_date) = 9
GROUP BY p.category
ORDER BY september_sales DESC;

-- T2: Year-over-Year growth rate per Category
WITH yearly_cat AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        p.category,
        SUM(oi.sales) AS total_sales
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products_clean p ON oi.product_id = p.product_id
    GROUP BY year, p.category
)
SELECT
    year,
    category,
    ROUND(total_sales::NUMERIC, 2) AS total_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY year))
        * 100.0 / LAG(total_sales) OVER (PARTITION BY category ORDER BY year), 2
    ) AS yoy_growth_pct
FROM yearly_cat
ORDER BY category, year;

-- T3: Do Sales and Profit grow together month-over-month?
WITH monthly_totals AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date)  AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(oi.sales)  AS total_sales,
        SUM(oi.profit) AS total_profit
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY year, month
)
SELECT ROUND(CORR(total_sales, total_profit)::NUMERIC, 3) AS sales_profit_correlation
FROM monthly_totals;