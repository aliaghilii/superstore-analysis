-- ============================================
-- Superstore Analysis — Views for downstream analysis
-- products_clean: excludes 32 products with ambiguous Product IDs.
-- Use this instead of raw products table in all Phase 5 queries
-- and Power BI to avoid name ambiguity. See decisions.md, Decision 002.
-- ============================================

CREATE VIEW products_clean AS
SELECT * FROM products
WHERE name_conflict = FALSE;