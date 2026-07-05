# ============================================
# Superstore — Prepare CSV files for import (v2)
# Fix: address fields moved from customers to orders.
#      Verified: customer_name and segment are stable
#      per customer_id (0 inconsistencies). City/State/
#      Region/Postal Code are NOT stable per customer_id
#      (98.4% of customers appear with multiple cities),
#      but ARE stable per order_id (0 inconsistencies
#      across 5,009 orders) -> these belong in orders.
# ============================================

import pandas as pd

# Path to the raw source file
df = pd.read_csv("C:/Users/Ali Aghili/Desktop/superstore-analysis/data/raw/Sample - Superstore.csv", encoding='cp1252')
# ============================================
# Table 1: customers
# Only stable, verified customer-level attributes
# ============================================
customers = df[[
    'Customer ID',
    'Customer Name',
    'Segment'
]].drop_duplicates(subset=['Customer ID'])

customers.columns = [
    'customer_id',
    'customer_name',
    'segment'
]

customers.to_csv("C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/customers.csv", index=False)
print(f"customers: {len(customers)} rows")

# ============================================
# Table 2: products
# ============================================
# Identify product_ids with more than one distinct name in the RAW data
# (must be computed BEFORE drop_duplicates, since dedup would hide this)
name_check = df.groupby('Product ID')['Product Name'].nunique()
conflict_ids = set(name_check[name_check > 1].index)

products = df[[
    'Product ID',
    'Category',
    'Sub-Category',
    'Product Name'
]].drop_duplicates(subset=['Product ID'])

products.columns = [
    'product_id',
    'category',
    'sub_category',
    'product_name'
]

# Flag products whose ID mapped to more than one name in raw data
products['name_conflict'] = products['product_id'].isin(conflict_ids)

products.to_csv("C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/products.csv" ,index=False)
print(f"products: {len(products)} rows, {products['name_conflict'].sum()} flagged as name_conflict")

# ============================================
# Table 3: orders
# Address fields included here — verified to be
# consistent at the order_id level (shipping address
# of that specific order), not at the customer level.
# ============================================
orders = df[[
    'Order ID',
    'Order Date',
    'Ship Date',
    'Ship Mode',
    'City',
    'State',
    'Region',
    'Country',
    'Postal Code'
]].drop_duplicates(subset=['Order ID'])

orders.columns = [
    'order_id',
    'order_date',
    'ship_date',
    'ship_mode',
    'ship_city',
    'ship_state',
    'ship_region',
    'ship_country',
    'ship_postal_code'
]

orders.to_csv("C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/orders.csv", index=False)
print(f"orders: {len(orders)} rows")

# ============================================
# Table 4: order_items (central fact table)
# ============================================
order_items = df[[
    'Row ID',
    'Order ID',
    'Customer ID',
    'Product ID',
    'Sales',
    'Quantity',
    'Discount',
    'Profit'
]]

order_items.columns = [
    'row_id',
    'order_id',
    'customer_id',
    'product_id',
    'sales',
    'quantity',
    'discount',
    'profit'
]

order_items.to_csv("C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/order_items.csv", index=False)
print(f"order_items: {len(order_items)} rows")

print("\nAll files prepared successfully.")

