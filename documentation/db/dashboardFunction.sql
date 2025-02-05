-- 1. Total Sales Per Month
CREATE OR REPLACE FUNCTION get_sales_by_month(user_id INTEGER)
RETURNS TABLE (
    month_number INTEGER,
    total_sales_count INTEGER,
    total_purchase_amount NUMERIC,
    total_sales_amount NUMERIC,
    quantity INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(EXTRACT(MONTH FROM s.sale_date) AS INTEGER) AS month_number,
        CAST(COUNT(s.saleid) AS INTEGER) AS total_sales_count,
        CAST(SUM(o.purchase_price * s.quantity) AS NUMERIC) AS total_purchase_amount,
        CAST(SUM(o.sale_price * s.quantity) AS NUMERIC) AS total_sales_amount,
        CAST(SUM(s.quantity) AS INTEGER) AS quantity
    FROM sales s
    JOIN orders o ON s.orderid = o.orderid
    JOIN products p ON o.productid = p.productid
    WHERE p."userId" = user_id
    AND s.status = TRUE
    GROUP BY CAST(EXTRACT(MONTH FROM s.sale_date) AS INTEGER)
    ORDER BY month_number;
END;
$$ LANGUAGE plpgsql;

-- 2. Total Sales Per Category
CREATE OR REPLACE FUNCTION get_sales_by_category(user_id INTEGER)
RETURNS TABLE (
    category_name TEXT,
    total_sales_count INTEGER,
    total_sales_amount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(c.name AS TEXT) AS category_name,  -- Conversión explícita a TEXT
        CAST(COUNT(s.saleid) AS INTEGER) AS total_sales_count, 
        CAST(SUM(o.sale_price * s.quantity) AS NUMERIC) AS total_sales_amount 
    FROM sales s
    JOIN orders o ON s.orderid = o.orderid 
    JOIN products p ON o.productid = p.productid 
    JOIN categories c ON p.categoryid = c.categoryid 
    WHERE p."userId" = user_id
    AND s.status = TRUE 
    GROUP BY c.name 
    ORDER BY total_sales_amount DESC;
END;
$$ LANGUAGE plpgsql;



-- 3. Total Purchase and Sales Amount
CREATE OR REPLACE FUNCTION get_total_revenue(user_id INTEGER)
RETURNS TABLE (
    total_purchase_amount NUMERIC,
    total_sales_amount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(SUM(o.purchase_price * s.quantity) AS NUMERIC) AS total_purchase_amount,
        CAST(SUM(o.sale_price * s.quantity) AS NUMERIC) AS total_sales_amount
    FROM sales s
    JOIN orders o ON s.orderid = o.orderid
    JOIN products p ON o.productid = p.productid
    WHERE p."userId" = user_id
    AND s.status = TRUE;
END;
$$ LANGUAGE plpgsql;


-- 4. Best-Selling Products
CREATE OR REPLACE FUNCTION get_top_selling_products(user_id INTEGER)
RETURNS TABLE (
    product_name TEXT,
    productid INTEGER,
    total_sales_count INTEGER,
    total_sales_amount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(p.product_name AS TEXT) AS product_name,  -- Conversión a TEXT
        p.productid,
        CAST(COUNT(s.saleid) AS INTEGER) AS total_sales_count, 
        CAST(SUM(o.sale_price * s.quantity) AS NUMERIC) AS total_sales_amount 
    FROM sales s
    JOIN orders o ON s.orderid = o.orderid 
    JOIN products p ON o.productid = p.productid 
    WHERE p."userId" = user_id
    AND s.status = TRUE 
    GROUP BY p.productid, p.product_name  -- Se agrupa por ambos para evitar errores
    ORDER BY total_sales_amount DESC;
END;
$$ LANGUAGE plpgsql;



-- 5. Sales by Month and Category
CREATE OR REPLACE FUNCTION get_sales_by_month_and_category(user_id INTEGER)
RETURNS TABLE (
    month_number INTEGER,
    category_name TEXT,
    total_sales_count INTEGER,
    total_purchase_amount NUMERIC,
    total_sales_amount NUMERIC,
    total_quantity_sold INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(EXTRACT(MONTH FROM s.sale_date) AS INTEGER) AS month_number,
        CAST(c.name as TEXT) AS category_name, 
        CAST(COUNT(s.saleid) AS INTEGER) AS total_sales_count, 
        CAST(SUM(o.purchase_price * s.quantity) AS NUMERIC) AS total_purchase_amount,
        CAST(SUM(o.sale_price * s.quantity) AS NUMERIC) AS total_sales_amount, 
        CAST(SUM(s.quantity) AS INTEGER) AS total_quantity_sold 
    FROM sales s
    JOIN orders o ON s.orderid = o.orderid 
    JOIN products p ON o.productid = p.productid 
    JOIN categories c ON p.categoryid = c.categoryid 
    WHERE p."userId" = user_id
    AND s.status = TRUE
    GROUP BY CAST(EXTRACT(MONTH FROM s.sale_date) AS INTEGER), c.name 
    ORDER BY month_number, total_sales_amount DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_sales_by_month(11);
SELECT * FROM get_sales_by_category(11);
SELECT * FROM get_total_revenue(11);
SELECT * FROM get_top_selling_products(11);
SELECT * FROM get_sales_by_month_and_category(11);
