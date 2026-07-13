-- Connect to database


-- ASSIGNMENT 1: Numeric functions
-- Calculate the total spend for each customer
SELECT  o.customer_id, o.product_id, o.units
FROM    orders o;


SELECT  p.product_id, p.unit_price
FROM products p;

SELECT  o.customer_id, SUM(o.units * p.unit_price) AS total_spend
FROM    orders o LEFT JOIN products p
        ON o.product_id = p.product_id
GROUP BY o.customer_id;


-- Put the spend into bins of $0-$10, $10-20, etc.
SELECT  o.customer_id, 
        SUM(o.units * p.unit_price) AS total_spend,
        FLOOR(SUM(o.units * p.unit_price) /10 ) * 10 AS total_spend_bin
FROM    orders o LEFT JOIN products p
        ON o.product_id = p.product_id
GROUP BY o.customer_id;

-- Number of customers in each spend bin
WITH bin AS (SELECT o.customer_id, 
                    SUM(o.units * p.unit_price) AS total_spend,
                    FLOOR(SUM(o.units * p.unit_price) /10 ) * 10 AS total_spend_bin
            FROM    orders o LEFT JOIN products p
                    ON o.product_id = p.product_id
            GROUP BY o.customer_id)

SELECT  total_spend_bin, COUNT(customer_id) as num_customers
FROM    bin
GROUP BY total_spend_bin
ORDER BY total_spend_bin;


-- ASSIGNMENT 2: Datetime functions

-- Extract just the orders from Q2 2024
SELECT  order_id, order_date
FROM    orders
WHERE YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;
-- Add a column called ship_date that adds 2 days to each order date
SELECT  order_id, order_date,
        DATE_ADD(order_date, INTERVAL 2 DAY) AS ship_date
FROM    orders
WHERE YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

-- ASSIGNMENT 3: String functions

-- View the current factory names and product IDs
SELECT  factory, product_id
FROM    products;

-- Remove apostrophes and replace spaces with hyphens
SELECT  factory, product_id,
        REPLACE(REPLACE(factory, "'", ""), " ", "-") AS factory_clean
FROM    products
ORDER BY factory, product_id;

-- Create new ID column called factory_product_id
WITH fp AS (SELECT  factory, product_id,
                    REPLACE(REPLACE(factory, "'", ""), " ", "-") AS factory_clean
            FROM    products)

SELECT  factory, product_id,
        CONCAT(factory_clean, "-", product_id) AS factory_product_id
FROM    fp
ORDER BY factory, product_id;

-- ASSIGNMENT 4: Pattern matching

-- View the product names
SELECT  product_name 
FROM    products
ORDER BY product_name;

-- Only extract text after the hyphen for Wonka Bars
SELECT  product_name,
        REPLACE(product_name, 'Wonka Bar - ', '') AS new_product_name
FROM    products
ORDER BY product_name;

-- Alternative using substrings
SELECT  product_name,
        CASE    WHEN INSTR(product_name, '-') = 0 THEN product_name
                ELSE SUBSTR(product_name, INSTR(product_name, '-') + 2) END AS new_product_name
FROM    products
ORDER BY product_name;

-- ASSIGNMENT 5: Null functions

-- View the columns of interest


-- Replace NULL values with Other


-- Find the most common division for each factory


-- Replace NULL values with top division for each factory


-- Replace division with Other value and top division


