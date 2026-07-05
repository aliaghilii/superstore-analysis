-- ============================================
-- Superstore Analysis — Database Schema (v2)
-- Fix: address fields (city/state/region/postal_code)
--      moved from customers to orders.
--      Verified via query: 98.4% of customers appear
--      with multiple cities -> address is an ORDER-level
--      attribute (shipping address), not a customer attribute.
--      Order-level consistency was tested and confirmed:
--      0 out of 5,009 orders have inconsistent address fields.
-- ============================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- ============================================
-- Table 1: customers
-- Only attributes verified to be stable per customer_id
-- (0 inconsistencies found for customer_name and segment)
-- ============================================
CREATE TABLE customers (
    customer_id     VARCHAR(20)     PRIMARY KEY,
    customer_name   VARCHAR(100)    NOT NULL,
    segment         VARCHAR(20)     NOT NULL
);

-- ============================================
-- Table 2: products
-- ============================================
CREATE TABLE products (
    product_id      VARCHAR(20)     PRIMARY KEY,
    category        VARCHAR(50)     NOT NULL,
    sub_category    VARCHAR(50)     NOT NULL,
    product_name    VARCHAR(200)    NOT NULL,
	name_conflict	BOOLEAN		    NOT NULL DEFAULT FALSE
);


-- ============================================
-- Table 3: orders
-- Address fields live here because they describe
-- the shipping destination of a specific order,
-- not a permanent customer attribute.
-- ============================================
CREATE TABLE orders (
    order_id           VARCHAR(20)     PRIMARY KEY,
    order_date          DATE            NOT NULL,
    ship_date           DATE            NOT NULL,
    ship_mode           VARCHAR(20)     NOT NULL,
    ship_city           VARCHAR(50)     NOT NULL,
    ship_state          VARCHAR(50)     NOT NULL,
    ship_region         VARCHAR(20)     NOT NULL,
	ship_country		VARCHAR(20)		NOT NULL,
    -- postal_code allows NULL: source data already has
    -- leading zeros stripped (read as integer upstream),
    -- so it is a known-imperfect field, not enforced NOT NULL
    ship_postal_code       VARCHAR(10)
);

-- ============================================
-- Table 4: order_items (central fact table)
-- ============================================
CREATE TABLE order_items (
    row_id          INTEGER         PRIMARY KEY,
    order_id        VARCHAR(20)     NOT NULL,
    customer_id     VARCHAR(20)     NOT NULL,
    product_id      VARCHAR(20)     NOT NULL,
    sales           NUMERIC(10,4)   NOT NULL,
    quantity        INTEGER         NOT NULL,
    discount        NUMERIC(4,2)    NOT NULL,
    profit          NUMERIC(10,4)   NOT NULL,

    CONSTRAINT fk_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);