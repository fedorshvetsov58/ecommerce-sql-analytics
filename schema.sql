PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Users table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name   TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    city        TEXT NOT NULL,
    signup_date DATE NOT NULL
);

-- Store items
CREATE TABLE products (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL,
    category     TEXT NOT NULL,
    price        REAL NOT NULL CHECK (price > 0)
);

-- Main orders table
CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    order_date  DATE NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('completed', 'cancelled', 'returned')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Items inside each order
CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);