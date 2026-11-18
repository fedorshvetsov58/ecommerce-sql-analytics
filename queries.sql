-- QUERY 1: Total sales by city
SELECT 
    c.city AS city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS items_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_sales_pln
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY c.city
ORDER BY total_sales_pln DESC;


-- QUERY 2: Top 5 best selling products
SELECT 
    p.product_name AS product,
    p.category AS category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_sales_pln,
    ROUND(
        SUM(oi.quantity * p.price) * 100.0 / (
            SELECT SUM(oi2.quantity * p2.price)
            FROM order_items oi2
            JOIN orders o2 ON oi2.order_id = o2.order_id
            JOIN products p2 ON oi2.product_id = p2.product_id
            WHERE o2.status = 'completed'
        ), 2
    ) AS sales_percent
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales_pln DESC
LIMIT 5;


-- QUERY 3: Customer groups by money spent
SELECT 
    c.full_name AS customer,
    c.city AS city,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(COALESCE(SUM(oi.quantity * p.price), 0), 2) AS total_spent_pln,
    CASE 
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) >= 3000 THEN 'VIP'
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) >= 1000 THEN 'Regular'
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) > 0     THEN 'New'
        ELSE 'No Orders'
    END AS customer_type
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'completed'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent_pln DESC;


-- QUERY 4: Average order item price and cancel rate by category
SELECT 
    p.category AS category,
    COUNT(DISTINCT o.order_id) AS all_orders,
    ROUND(AVG(oi.quantity * p.price), 2) AS avg_price_pln,
    ROUND(
        SUM(CASE WHEN o.status IN ('cancelled', 'returned') THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 1
    ) AS cancel_percent
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY avg_price_pln DESC;


-- QUERY 5: Top product in each category
WITH ProductSales AS (
    SELECT 
        p.category,
        p.product_name,
        ROUND(SUM(oi.quantity * p.price), 2) AS sales,
        RANK() OVER (
            PARTITION BY p.category 
            ORDER BY SUM(oi.quantity * p.price) DESC
        ) AS rnk
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY p.category, p.product_name
)
SELECT 
    category,
    product_name AS top_product,
    sales AS total_sales_pln
FROM ProductSales
WHERE rnk = 1
ORDER BY total_sales_pln DESC;