# ============================================
# Superstore — Prepare CSV files for import
# ============================================

import pandas as pd

# مسیر فایل اصلی
df = pd.read_csv(
    "C:/Users/Ali Aghili/Desktop/superstore-analysis/data/raw/Sample - Superstore.csv",
    encoding="cp1252",
)

# ============================================
# جدول ۱: customers
# ============================================
customers = df[
    [
        "Customer ID",
        "Customer Name",
        "Segment",
        "Country",
        "City",
        "State",
        "Postal Code",
        "Region",
    ]
].drop_duplicates(subset=["Customer ID"])

customers.columns = [
    "customer_id",
    "customer_name",
    "segment",
    "country",
    "city",
    "state",
    "postal_code",
    "region",
]

customers.to_csv(
    "C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/customers.csv",
    index=False,
)
print(f"customers: {len(customers)} rows")

# ============================================
# جدول ۲: products
# ============================================
products = df[
    ["Product ID", "Category", "Sub-Category", "Product Name"]
].drop_duplicates(subset=["Product ID"])

products.columns = ["product_id", "category", "sub_category", "product_name"]

products.to_csv(
    "C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/products.csv",
    index=False,
)
print(f"products: {len(products)} rows")

# ============================================
# جدول ۳: orders
# ============================================
orders = df[["Order ID", "Order Date", "Ship Date", "Ship Mode"]].drop_duplicates(
    subset=["Order ID"]
)

orders.columns = ["order_id", "order_date", "ship_date", "ship_mode"]

orders.to_csv(
    "C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/orders.csv",
    index=False,
)
print(f"orders: {len(orders)} rows")

# ============================================
# جدول ۴: order_items
# ============================================
order_items = df[
    [
        "Row ID",
        "Order ID",
        "Customer ID",
        "Product ID",
        "Sales",
        "Quantity",
        "Discount",
        "Profit",
    ]
]

order_items.columns = [
    "row_id",
    "order_id",
    "customer_id",
    "product_id",
    "sales",
    "quantity",
    "discount",
    "profit",
]

order_items.to_csv(
    "C:/Users/Ali Aghili/Desktop/superstore-analysis/data/processed/order_items.csv",
    index=False,
)
print(f"order_items: {len(order_items)} rows")

print("\n✅ همه فایل‌ها آماده شدند")
