-- ============================================
-- Import prepared CSVs into PostgreSQL
-- NOTE: File paths below are specific to the machine
-- this project was built on (C:\Users\Public\superstore\).
-- Adjust paths if running on a different machine.
-- Import order matters: customers/products/orders must
-- exist before order_items (foreign key dependencies).
-- ============================================

-- CUSTOMERS TABLE
COPY customers(
    customer_id, customer_name, segment
)
FROM 'C:\Users\Public\superstore\customers.csv'
DELIMITER ',' CSV HEADER;

-- PRODUCTS TABLE
COPY products(
    product_id, category, sub_category, product_name
)
FROM 'C:\Users\Public\superstore\products.csv'
DELIMITER ',' CSV HEADER;

-- ORDERS TABLE
COPY orders(
    order_id, order_date, ship_date, ship_mode,
    ship_city, ship_state, ship_region, ship_country, ship_postal_code 
)
FROM 'C:\Users\Public\superstore\orders.csv'
DELIMITER ',' CSV HEADER;

-- ORDER-ITEMS TABLE
COPY order_items(
    row_id, order_id, customer_id, product_id,
    sales, quantity, discount, profit
)
FROM 'C:\Users\Public\superstore\order_items.csv'
DELIMITER ',' CSV HEADER;

-- Making sure
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

SELECT o.ship_region, COUNT(*) 
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.ship_region;
