-- ============================================
-- Product Analysis + BCG Matrix (PR1-PR3)
-- NOTE: True BCG needs market-wide data (competitors, total market).
-- This is an adapted version using internal sales share and internal
-- YoY growth as proxies — a documented limitation, not a full BCG.
-- ============================================

-- PR1 (BCG basis): Sub-Category share of total sales + YoY growth
WITH subcat_yearly AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        p.sub_category,
        SUM(oi.sales) AS total_sales
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products_clean p ON oi.product_id = p.product_id
    GROUP BY year, p.sub_category
),
growth AS (
    SELECT
        sub_category,
        year,
        total_sales,
        (total_sales - LAG(total_sales) OVER (PARTITION BY sub_category ORDER BY year))
            * 100.0 / LAG(total_sales) OVER (PARTITION BY sub_category ORDER BY year) AS yoy_growth_pct
    FROM subcat_yearly
),
latest_year AS (
    SELECT * FROM growth WHERE year = 2017
),
market_share AS (
    SELECT
        sub_category,
        total_sales,
        yoy_growth_pct,
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS share_pct
    FROM latest_year
)
SELECT
    sub_category,
    ROUND(total_sales::NUMERIC, 2) AS sales_2017,
    ROUND(yoy_growth_pct::NUMERIC, 2) AS yoy_growth_pct,
    share_pct,
    CASE
        WHEN share_pct >= (SELECT AVG(share_pct) FROM market_share)
         AND yoy_growth_pct >= (SELECT AVG(yoy_growth_pct) FROM market_share)
            THEN 'Star'
        WHEN share_pct >= (SELECT AVG(share_pct) FROM market_share)
         AND yoy_growth_pct < (SELECT AVG(yoy_growth_pct) FROM market_share)
            THEN 'Cash Cow'
        WHEN share_pct < (SELECT AVG(share_pct) FROM market_share)
         AND yoy_growth_pct >= (SELECT AVG(yoy_growth_pct) FROM market_share)
            THEN 'Question Mark'
        ELSE 'Dog'
    END AS bcg_quadrant
FROM market_share
ORDER BY share_pct DESC;

-- PR1-validation: Cross-check BCG quadrants against actual profit margin
-- to catch cases like Tables (classified Cash Cow but actually unprofitable)
WITH subcat_margin AS (
    SELECT
        p.sub_category,
        ROUND(SUM(oi.profit) * 100.0 / SUM(oi.sales), 2) AS margin_pct
    FROM order_items oi
    JOIN products_clean p ON oi.product_id = p.product_id
    GROUP BY p.sub_category
)
SELECT sub_category, margin_pct
FROM subcat_margin
ORDER BY margin_pct ASC;

-- PR2: Top 10 and Bottom 10 products by profit (Top already done in P3;
-- this adds Top 10 most profitable for comparison)
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.profit)::NUMERIC, 2) AS total_profit
FROM order_items oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_profit DESC
LIMIT 10;