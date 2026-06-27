-- ============================================
-- Superstore Analysis — Database Schema
-- Created: 2026
-- ============================================

-- Drop tables if exist 
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- ============================================
-- Table 1: customers
-- ============================================
CREATE TABLE customers (
    customer_id     VARCHAR(20)     PRIMARY KEY,
    customer_name   VARCHAR(100)    NOT NULL,
    segment         VARCHAR(20)     NOT NULL,
    country         VARCHAR(50)     NOT NULL,
    city            VARCHAR(50)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    postal_code     VARCHAR(10),
    region          VARCHAR(20)     NOT NULL
);

-- ============================================
-- Table 2: products
-- ============================================
CREATE TABLE products (
    product_id      VARCHAR(20)     PRIMARY KEY,
    category        VARCHAR(50)     NOT NULL,
    sub_category    VARCHAR(50)     NOT NULL,
    product_name    VARCHAR(200)    NOT NULL
);

-- ============================================
-- Table 3: orders
-- ============================================
CREATE TABLE orders (
    order_id        VARCHAR(20)     PRIMARY KEY,
    order_date      DATE            NOT NULL,
    ship_date       DATE            NOT NULL,
    ship_mode       VARCHAR(20)     NOT NULL
);

-- ============================================
-- Table 4: order_items (جدول مرکزی)
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