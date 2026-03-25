-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
select * from products;

-- View the average unit price
select avg(unit_price) from products;


-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
select	product_id, product_name, unit_price, (select avg(unit_price) from products) as avg_unit_price,
		unit_price - (select avg(unit_price) from products) as diff_price
from 	products;


-- Order the results from most to least expensive
select	product_id, product_name, unit_price, (select avg(unit_price) from products) as avg_unit_price,
		unit_price - (select avg(unit_price) from products) as diff_price
from 	products
order by unit_price desc;




-- ASSIGNMENT 2: Subqueries in the FROM clause

-- Return the factories, product names from the factory
-- and number of products produced by each factory

-- All factories and products
select	factory, product_name 
from 	products;


-- All factories and their total number of products
select	 factory, count(product_id) as num_produscts
from	 products
group by factory;

-- Final query with subqueries
select 
	fp.factory,
    fp.product_name,
    fn.num_produscts
from
		(select	factory, product_name 
		 from 	products) fp
	left join
		(select	  factory, count(product_id) as num_produscts
		 from	  products
		 group by factory) fn
	on fp.factory = fn.factory
    order by fp.factory, fp.product_name;


-- ASSIGNMENT 3: Subqueries in the WHERE clause

-- View all products from Wicked Choccy's
select * 
from products
where factory = "Wicked Choccy's";


-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
select 	*
from 	products
where unit_price < all(
					select unit_price 
					from products
					where factory = "Wicked Choccy's" );

-- ASSIGNMENT 4: CTEs

-- View the orders and products tables
select * from orders; 
select * from products;

-- Calculate the amount spent on each product, within each order
select o.order_id, p.product_name, p.product_id, p.unit_price, o.units as order_units, (p.unit_price * o.units) as amount
from orders o left join products p
on o.product_id = p.product_id
order by amount desc;

-- Return all orders over $200
select 	o.order_id, 
		sum(p.unit_price * o.units) as amount
from	orders o left join products p
		on o.product_id = p.product_id
group by o.order_id
having amount > 200
order by amount desc;

-- Return the number of orders over $200

with tas as (select o.order_id, 
					sum(p.unit_price * o.units) as amount
			from	orders o left join products p
					on o.product_id = p.product_id
			group by o.order_id
			having amount > 200
			order by amount desc)

select count(*) from tas;

-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution
select 
	fp.factory,
    fp.product_name,
    fn.num_produscts
from
		(select	factory, product_name 
		 from 	products) fp
	left join
		(select	  factory, count(product_id) as num_produscts
		 from	  products
		 group by factory) fn
	on fp.factory = fn.factory
    order by fp.factory, fp.product_name;

-- Rewrite the Assignment 2 subquery solution using CTEs instead

with fp as (select factory, product_name from products),
	 fn as (select factory, count(product_id) as num_produscts 
			from products 
			group by factory)
            
select 	fp.factory, fp.product_name, fn.num_produscts
from	fp left join fn
		on fp.factory = fn.factory
order by fp.factory, fp.product_name;