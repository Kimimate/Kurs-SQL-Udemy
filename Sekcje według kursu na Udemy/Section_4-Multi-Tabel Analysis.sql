-- Connect to database (MySQL)
USE maven_advanced_sql;

-- 1. Basic joins
select	* from happiness_scores;
select * from country_stats;

select 	happiness_scores.year, happiness_scores.country, happiness_scores.happiness_score, country_stats.continent
from	happiness_scores
		inner join country_stats
        on happiness_scores.country = country_stats.country;

select 	hs.year, hs.country, hs.happiness_score, cs.continent
from	happiness_scores hs
		inner join country_stats cs
        on hs.country = cs.country;ey
        
-- 2. Join types

select 	hs.year, hs.country, hs.happiness_score, cs.country, cs.continent
from	happiness_scores hs
		inner join country_stats cs
        on hs.country = cs.country;
        
select 	hs.year, hs.country, hs.happiness_score, cs.country, cs.continent
from	happiness_scores hs
		left join country_stats cs
        on hs.country = cs.country
where cs.country is null;

select 	hs.year, hs.country, hs.happiness_score, cs.country, cs.continent
from	happiness_scores hs
		right join country_stats cs
        on hs.country = cs.country
where hs.country is null;

select 	distinct hs.country
from	happiness_scores hs
		left join country_stats cs
        on hs.country = cs.country
where cs.country is null;

select 	 distinct cs.country
from	happiness_scores hs
		right join country_stats cs
        on hs.country = cs.country
where hs.country is null;

-- 3. Joining on multiple columns
select * from happiness_scores;
select * from country_stats;
select * from inflation_rates;

select * 
from	happiness_scores hs
		inner join inflation_rates ir
        on hs.country = ir.country_name and hs.year = ir.year;

-- 4. Joining multiple tables
select * from happiness_scores;
select * from country_stats;
select * from inflation_rates;

select hs.year, hs.country, hs.happiness_score, cs.continent, ir.inflation_rate
from	happiness_scores hs
		left join country_stats cs
			on hs.country = cs.country
        left join inflation_rates ir
			on hs.year = ir.year and hs.country = ir.country_name
where ir.inflation_rate is not null;


-- 5. Self joins
CREATE TABLE IF NOT EXISTS employees (
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(100),
	salary INT,
	manager_id INT
);

INSERT INTO employees (employee_id, employee_name, salary, manager_id) VALUES
	(1, 'Ava', 85000, NULL),
	(2, 'Bob', 72000, 1),
	(3, 'Cat', 59000, 1),
	(4, 'Dan', 85000, 2);
    
select * from employees;
-- Employees with the same salary
select 	e1.employee_id, e1.employee_name, e1.salary,
		e2.employee_id, e2.employee_name, e2.salary
from 	employees e1 inner join employees e2
        on e1.salary = e2.salary
where e1.employee_name > e2.employee_name;

-- Employees that have a greater salary
select 	e1.employee_id, e1.employee_name, e1.salary,
		e2.employee_id, e2.employee_name, e2.salary
from 	employees e1 inner join employees e2
        on e1.salary > e2.salary
order by e1.employee_id;

-- Employees and their managers
select e1.employee_id, e1.employee_name, e1.salary, e1.manager_id, e2.employee_name as menager_name
from	employees e1 left join employees e2
		on e1.manager_id = e2.employee_id;
-- 6. Cross joins
create table tops (
	id int,
    item varchar(50)
);

create table sizes (
	id int,
    size varchar(50)
);

create table outerwear (
	id int,
    item varchar(50)
);
	
INSERT INTO tops (id, item) VALUES
	(1, 'T-Shirt'),
	(2, 'Hoodie');

INSERT INTO sizes (id, size) VALUES
	(101, 'Small'),
	(102, 'Medium'),
	(103, 'Large');

INSERT INTO outerwear (id, item) VALUES
	(2, 'Hoodie'),
	(3, 'Jacket'),
	(4, 'Coat');
    
-- View the tables
select * from tops;
select * from outerwear;
select * from sizes;


-- Cross join the tables
select 	*
from	tops cross join sizes
order by item;

-- From the self join assignment:
-- Which products are within 25 cents of each other in terms of unit price?

-- Rewritten with a CROSS JOIN
select	p1.product_name, p1.unit_price,
		p2.product_name, p2.unit_price,
        p1.unit_price - p2.unit_price as price_dfference
from 	products p1 cross join products p2
where	abs(p1.unit_price - p2.unit_price) < 0.25
		and p1.product_name < p2.product_name
order by price_dfference desc;

-- 7. Union vs union all
select * from tops;
select * from outerwear;

-- Union
select * from tops
union
select * from outerwear;

-- Union all
select * from tops
union all
select * from outerwear;

-- Union with different column names
select * from happiness_scores;
select * from happiness_scores_current;

select year, country, happiness_score from happiness_scores
union
select 2024, country, ladder_score from happiness_scores_current;

select year, country, happiness_score from happiness_scores
union
select 2024, country, ladder_score from happiness_scores_current;