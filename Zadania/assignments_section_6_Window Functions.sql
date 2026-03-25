-- Connect to database


-- ASSIGNMENT 1: Window function basics

-- View the orders table
select * from orders;

-- View the columns of interest
select	 customer_id, order_id, order_date, transaction_id
from 	 orders
order by customer_id, transaction_id;

-- For each customer, add a column for transaction number
select	customer_id, order_id, order_date, transaction_id, 
		row_number() over(partition by customer_id order by transaction_id) as transaction_num
from orders;

-- ASSIGNMENT 2: Row Number vs Rank vs Dense Rank

-- View the columns of interest
select 	customer_id, order_id, product_id, units
from	orders;

-- Try ROW_NUMBER to rank the units
select 	 order_id, product_id, units,
		 row_number() over(partition by order_id order by units desc) as produsct_rn
from	 orders
order by order_id, produsct_rn;

-- For each order, rank the products from most units to fewest units
-- If there's a tie, keep the tie and don't skip to the next number after
select 	order_id, product_id, units,
        dense_rank() over(partition by order_id order by units desc) as product_rank
from	orders
order by order_id, product_rank;
-- Check the order id that ends with 44262 from the results preview
select 	order_id, product_id, units,
        dense_rank() over(partition by order_id order by units desc) as product_rank
from	orders
where order_id like '%44262'
order by order_id, product_rank;

-- ASSIGNMENT 3: First Value vs Last Value vs Nth Value

-- View the rankings from the last assignment
select 	order_id, product_id, units,
        dense_rank() over(partition by order_id order by units desc) as product_rank
from	orders
order by order_id, product_rank;

-- Add a column that contains the 2nd most popular product
select 	order_id, product_id, units,
        nth_value(product_id, 2) over(partition by order_id order by units desc) as second_product
from	orders
order by order_id, second_product;

-- Return the 2nd most popular product for each order
with sp as (select 	order_id, product_id, units,
								nth_value(product_id, 2) over(partition by order_id order by units desc) as second_product
						from	orders
						order by order_id, second_product)
                        
select * 
from sp
where product_id = second_product;

-- Alternative using DENSE RANK
-- Add a column that contains the rankings
select 	order_id, product_id, units,
        dense_rank() over(partition by order_id order by units desc) as product_rank
from	orders
order by order_id, product_rank;

-- Return the 2nd most popular product for each order
with sp as (select	 order_id, product_id, units,
					 dense_rank() over(partition by order_id order by units desc) as product_rank
			from 	 orders
			order by order_id, product_rank)
            
select * 
from sp
where product_rank = 2;


-- ASSIGNMENT 4: Lead & Lag
-- View the columns of interest
select customer_id, order_id, product_id, transaction_id, order_date, units
from orders;

-- For each customer, return the total units within each order
select customer_id, order_id, sum(units) as total_units
from orders
group by customer_id, order_id
order by customer_id;


-- Add on the transaction id to keep track of the order of the orders
select customer_id, order_id, min(transaction_id) as min_tid, sum(units) as total_units
from orders
group by customer_id, order_id
order by customer_id, min_tid;

-- Turn the query into a CTE and view the columns of interest
with my_cte as	(select customer_id, order_id, min(transaction_id) as min_tid, sum(units) as total_units
			 from orders
			 group by customer_id, order_id
			 order by customer_id, min_tid)

select customer_id, order_id, total_units from my_cte;

-- Create a prior units column
with my_cte as	(select customer_id, order_id, min(transaction_id) as min_tid, sum(units) as total_units
			 from orders
			 group by customer_id, order_id
			 order by customer_id, min_tid)

select 	customer_id, order_id, total_units,
		lag(total_units) over(partition by customer_id order by min_tid) as piror_units
from my_cte;

-- For each customer, find the change in units per order over time
with my_cte as	(select customer_id, order_id, min(transaction_id) as min_tid, sum(units) as total_units
			 from orders
			 group by customer_id, order_id
			 order by customer_id, min_tid)

select 	customer_id, order_id, total_units,
		lag(total_units) over(partition by customer_id order by min_tid) as piror_units,
        total_units -lag(total_units) over(partition by customer_id order by min_tid)
from my_cte;

-- Final QUERY
with my_cte as	(select customer_id, order_id, min(transaction_id) as min_tid, sum(units) as total_units
				 from orders
				 group by customer_id, order_id
				 order by customer_id, min_tid),
	piror_cte as (select 	customer_id, order_id, total_units,
							lag(total_units) over(partition by customer_id order by min_tid) as piror_units
				  from my_cte)
                  
select 	customer_id, order_id, total_units, piror_units, 
		total_units - piror_units as diff_unit
from piror_cte;


-- ASSIGNMENT 5: NTILE
-- Calculate the total amount spent by each customer

-- View the data needed from the orders table
select customer_id, product_id, units
from orders;

-- View the data needed from the products table
select product_id, unit_price
from products;

-- Combine the two tables and view the columns of interest
select o.customer_id, o.product_id, o.units, pr.unit_price 
from	orders o 
		inner join products pr
        on o.product_id = pr.product_id;
        
-- Calculate the total spending by each customer and sort the results from highest to lowest
with total as (select	o.customer_id, 
						sum(o.units * p.unit_price) as total_spend
				 from	orders o 
						left join products p
						on o.product_id = p.product_id
				 group by o.customer_id
                 order by total_spend desc)
                        
select * from total;

-- Turn the query into a CTE and apply the percentile calculation
with ts as (select	o.customer_id, 
						sum(o.units * p.unit_price) as total_spend
				 from	orders o 
						left join products p
						on o.product_id = p.product_id
				 group by o.customer_id
                 order by total_spend desc),
	tsp as (select customer_id, total_spend,
						ntile(100) over(order by total_spend desc) as spend_pct
				 from ts)
                        
select * 
from tsp;


-- Return the top 1% of customers in terms of spending
with ts as (select	o.customer_id, 
						sum(o.units * p.unit_price) as total_spend
				 from	orders o 
						left join products p
						on o.product_id = p.product_id
				 group by o.customer_id
                 order by total_spend desc),
	tsp as (select customer_id, total_spend,
						ntile(100) over(order by total_spend desc) as spend_pct
				 from ts)
                        
select * 
from tsp
where spend_pct = 1;

