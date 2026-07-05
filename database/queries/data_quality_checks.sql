-- ============================================
-- Phase 3: Data Quality Assessment — Audit Queries
-- These are diagnostic queries, not part of the schema.
-- Run against a freshly imported database to reproduce findings.
-- ============================================

-- 1. Functional Dependency Audit
-- Test 1: Does each product_id map to exactly one product_name?
SELECT product_id, COUNT(DISTINCT product_name) AS name_count
FROM products
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;

-- Test 2: Does each sub_category belong to exactly one category?
SELECT sub_category, COUNT(DISTINCT category) AS cat_count
FROM products
GROUP BY sub_category
HAVING COUNT(DISTINCT category) > 1;

-- Test 3: Does each product_id map to a stable category/sub_category?
SELECT product_id,
       COUNT(DISTINCT category) AS cat_count,
       COUNT(DISTINCT sub_category) AS subcat_count
FROM products
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1 OR COUNT(DISTINCT sub_category) > 1;

-- Test 4: Does each order_id map to a exactly one customer_id?
SELECT order_id, COUNT(DISTINCT customer_id) AS customer_count
FROM order_items
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1;

-- 2.Duplicate Records
-- Check 1: Duplicate row_id (tautological — guaranteed by PRIMARY KEY,
-- kept here only for completeness of the audit trail)
SELECT row_id, COUNT(*)
FROM order_items
GROUP BY row_id
HAVING COUNT(*) > 1;

-- Check 2: Duplicate full transaction (same order+product+financials)
-- Finding: 1 duplicate found (US-2014-150119, FUR-CH-10002965).
-- Confirmed present in raw CSV (Row ID 3406 and 3407) — not an
-- artifact of our import pipeline. Decision on handling deferred
-- to Phase 4 (Data Cleaning). See decisions.md, Decision 003.
SELECT order_id, customer_id, product_id, sales, quantity, discount, profit, COUNT(*)
FROM order_items
GROUP BY order_id, customer_id, product_id, sales, quantity, discount, profit
HAVING COUNT(*) > 1;