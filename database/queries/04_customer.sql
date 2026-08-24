-- ============================================
-- Customer Analysis + RFM (CU1-CU3)
-- ============================================

-- CU1-summary: Distribution of RFM combined scores
-- (aggregated version of the raw customer-level RFM query)
WITH snapshot AS (
    SELECT MAX(order_date) + INTERVAL '1 day' AS snapshot_date
    FROM orders
),
customer_rfm AS (
    SELECT
        oi.customer_id,
        (SELECT snapshot_date FROM snapshot) - MAX(o.order_date) AS recency_days,
        COUNT(DISTINCT oi.order_id) AS frequency,
        SUM(oi.sales) AS monetary
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.customer_id
),
scored AS (
    SELECT
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_rfm
)
SELECT
    CASE
        WHEN r_score>=4 AND f_score>=4 AND m_score>=4 THEN 'Champions'
        WHEN r_score<=2 AND f_score<=2 AND m_score<=2 THEN 'Lost/At Risk'
        ELSE 'Mid-tier'
    END AS rough_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM scored
GROUP BY rough_segment
ORDER BY customer_count DESC;
-- CU2: Segment comparison (Consumer / Corporate / Home Office)
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)       AS customer_count,
    ROUND(SUM(oi.sales)::NUMERIC, 2)    AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)   AS total_profit,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT c.customer_id)::NUMERIC, 2) AS avg_sales_per_customer
FROM order_items oi
JOIN customers c ON oi.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- CU3: Customer Lifetime Value proxy by segment
-- (True CLV needs churn/retention modeling we don't have data for;
-- this is a simplified proxy = total historical profit per customer)
SELECT
    c.segment,
    ROUND(AVG(customer_profit)::NUMERIC, 2) AS avg_clv_proxy
FROM (
    SELECT customer_id, SUM(profit) AS customer_profit
    FROM order_items
    GROUP BY customer_id
) cp
JOIN customers c ON cp.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY avg_clv_proxy DESC;

-- Do Champions contribute disproportionately to revenue?
WITH snapshot AS (
    SELECT MAX(order_date) + INTERVAL '1 day' AS snapshot_date FROM orders
),
customer_rfm AS (
    SELECT
        oi.customer_id,
        (SELECT snapshot_date FROM snapshot) - MAX(o.order_date) AS recency_days,
        COUNT(DISTINCT oi.order_id) AS frequency,
        SUM(oi.sales) AS monetary
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.customer_id
),
scored AS (
    SELECT
        customer_id, monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_rfm
)
SELECT
    CASE WHEN r_score>=4 AND f_score>=4 AND m_score>=4 THEN 'Champions' ELSE 'Others' END AS grp,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (), 1) AS pct_of_revenue
FROM scored
GROUP BY grp;