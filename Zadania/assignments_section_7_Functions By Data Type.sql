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


-- Add a column called ship_date that adds 2 days to each order date


-- ASSIGNMENT 3: String functions

-- View the current factory names and product IDs


-- Remove apostrophes and replace spaces with hyphens


-- Create new ID column called factory_product_id


-- ASSIGNMENT 4: Pattern matching

-- View the product names


-- Only extract text after the hyphen for Wonka Bars


-- Alternative using substrings


-- ASSIGNMENT 5: Null functions

-- View the columns of interest


-- Replace NULL values with Other


-- Find the most common division for each factory


-- Replace NULL values with top division for each factory


-- Replace division with Other value and top division


