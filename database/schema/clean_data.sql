-- ============================================
-- Phase 4: Data Cleaning
-- ============================================
-- Step 1: Remove duplicate transaction
-- Row 3406 is an exact duplicate of Row 3407 across all fields.
-- Root cause unverified (likely double data entry in source system).
-- Decision basis: keeping both rows would introduce double-counting
-- in all revenue/profit aggregations. See decisions.md, Decision 003.
DELETE FROM order_items WHERE row_id = 3406;
SELECT COUNT(*) AS order_items_after_dedup FROM order_items;

-- Step 2: Create products_clean view
-- Excludes the 32 products with name_conflict = TRUE.
-- Use this view in all downstream analysis (Phase 5, Power BI)
-- instead of the raw products table to avoid name ambiguity.
CREATE VIEW products_clean AS
SELECT * FROM products
WHERE name_conflict = FALSE;
SELECT COUNT(*) FROM products_clean;

-- Step 3: Validation queries
-- Row counts after cleaning
SELECT 'order_items' AS tbl, COUNT(*) AS rows FROM order_items
UNION ALL
SELECT 'products_clean', COUNT(*) FROM products_clean;

-- Confirm no more exact duplicates remain
SELECT order_id, customer_id, product_id, sales, quantity, discount, profit, COUNT(*)
FROM order_items
GROUP BY order_id, customer_id, product_id, sales, quantity, discount, profit
HAVING COUNT(*) > 1;