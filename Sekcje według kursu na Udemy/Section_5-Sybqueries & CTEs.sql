-- Connect to database (MySQL)
USE maven_advanced_sql;

-- 1. Subqueries in the SELECT clause
SELECT * FROM happiness_scores;

-- Average happiness score
SELECT AVG(happiness_score) FROM happiness_scores;

-- Happiness score deviation from the average
SELECT	year, country, happiness_score,
		(SELECT AVG(happiness_score) FROM happiness_scores) AS avg_hs,
        happiness_score - (SELECT AVG(happiness_score) FROM happiness_scores) AS diff_from_avg
FROM	happiness_scores;

-- 2. Subqueries in the FROM clause
SELECT * FROM happiness_scores;

-- Average happiness score for each country
SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
FROM	 happiness_scores
GROUP BY country;

/* Return a country's happiness score for the year as well as
the average happiness score for the country across years */
SELECT	hs.year, hs.country, hs.happiness_score,
		country_hs.avg_hs_by_country
FROM	happiness_scores hs LEFT JOIN
		(SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
		 FROM	 happiness_scores
		 GROUP BY country) AS country_hs
		ON hs.country = country_hs.country;
            
-- View one country
SELECT	hs.year, hs.country, hs.happiness_score,
		country_hs.avg_hs_by_country
FROM	happiness_scores hs LEFT JOIN
		(SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
		 FROM	 happiness_scores
		 GROUP BY country) AS country_hs
		ON hs.country = country_hs.country
WHERE	hs.country = 'United States';

-- 3. Multiple subqueries

-- Return happiness scores for 2015 - 2024
select distinct year from happiness_scores;
select * from happiness_scores_current;

select year, country, happiness_score from happiness_scores
union all
select 2024, country, ladder_score from happiness_scores_current;


            
/* Return a country's happiness score for the year as well as
the average happiness score for the country across years */
SELECT	hs.year, hs.country, hs.happiness_score,
		country_hs.avg_hs_by_country
FROM	(select year, country, happiness_score from happiness_scores
		 union all
		 select 2024, country, ladder_score from happiness_scores_current) hs 
         LEFT JOIN
		(SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
		 FROM	 happiness_scores
		 GROUP BY country) AS country_hs
		ON hs.country = country_hs.country;


       
/* Return years where the happiness score is a whole point
greater than the country's average happiness score */
select
	hs_country_hs.year,
    hs_country_hs.country,
    hs_country_hs.happiness_score,
    hs_country_hs.avg_hs_by_country
from
		(
        SELECT	
			hs.year, 
            hs.country, 
            hs.happiness_score,
			country_hs.avg_hs_by_country
		 FROM	(select year, country, happiness_score from happiness_scores
				 UNION ALL
				 select 2024, country, ladder_score from happiness_scores_current) hs 
		 LEFT JOIN
				(SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
				 FROM	 happiness_scores
				 GROUP BY country) AS country_hs
		 ON hs.country = country_hs.country
         ) as hs_country_hs
where hs_country_hs.happiness_score > hs_country_hs.avg_hs_by_country + 1;



-- 4. Subqueries in the WHERE and HAVING clauses

-- Average happiness score
select avg(happiness_score) from happiness_scores;

-- Above average happiness scores (WHERE)
select * 
from happiness_scores
where happiness_score > (select avg(happiness_score) from happiness_scores);

-- Above average happiness scores for each region (HAVING)
select 	 region, avg(happiness_score) as avg_hs
from 	 happiness_scores
group by region
having avg_hs > (select avg(happiness_score) from happiness_scores);

-- 5. ANY vs ALL
SELECT * FROM happiness_scores; -- 2015-2023
SELECT * FROM happiness_scores_current; -- 2024

-- Scores that are greater than ANY 2024 scores
select 	*
from 	happiness_scores
where	happiness_score >
		any(SELECT ladder_score FROM happiness_scores_current);


-- Scores that are greater than ALL 2024 scores
select 	*
from 	happiness_scores
where	happiness_score >
		all(SELECT ladder_score FROM happiness_scores_current);

-- 6. EXISTS
select * from happiness_scores;
select * from inflation_rates;

/* Return happiness scores of countries
that exist in the inflation rates table */
select	*
from 	happiness_scores hs
where exists(
			 select ir.country_name 
             from inflation_rates ir
             where ir.country_name = hs.country);

-- Alternative to EXISTS: INNER JOIN
select	*
from	happiness_scores hs
inner join inflation_rates ir
on hs.country = ir.country_name and hs.year = ir.year;

-- 7. CTEs: Readability

/* SUBQUERY: Return the happiness scores along with
   the average happiness score for each country */

SELECT	hs.year, hs.country, hs.happiness_score,
		country_hs.avg_hs_by_country
FROM	happiness_scores hs LEFT JOIN
		(SELECT	 country, AVG(happiness_score) AS avg_hs_by_country
		 FROM	 happiness_scores
		 GROUP BY country) AS country_hs
		ON hs.country = country_hs.country;

/* CTE: Return the happiness scores along with
the average happiness score for each country */

with country_hs as (select country, avg(happiness_score) as avg_hs_by_country
					from happiness_scores
                    group by country)
                    
select 	hs.year, hs.country, hs.happiness_score,
		country_hs.avg_hs_by_country
from 	happiness_scores hs left join country_hs
		on hs.country = country_hs.country;

-- 8. CTEs: Reusability
        
-- SUBQUERY: Compare the happiness scores within each region in 2023
select * from happiness_scores where year = 2023;

select	hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
from 	(select * from happiness_scores where year = 2023) hs1 
		inner join 
        (select * from happiness_scores where year = 2023) hs2
		on hs1.region = hs2.region;

-- CTE: Compare the happiness scores within each region in 2023

with hs as (select * from happiness_scores 
			where year = 2023)
             
select	hs1.region, hs1.country, hs1.happiness_score,
		hs2.country, hs2.happiness_score
from 	hs hs1 
		inner join 
        hs hs2
		on hs1.region = hs2.region
		and hs1.country <> hs2.country;

-- 9. Multiple CTEs

-- Step 1: Compare 2023 vs 2024 happiness scores side by side
select * from happiness_scores where year=2023;
select * from happiness_scores_current;
        
with	hs23 as (select * from happiness_scores where year=2023),
		hs24 as (select * from happiness_scores_current)

select 	hs23.country,
		hs23.happiness_score as hs_2023,
        hs24.ladder_score as hs_2024
from 	hs23 left join hs24
		on hs23.country = hs24.country;
        
-- Step 2: Return the countries where the score increased
with	hs23 as (select * from happiness_scores where year=2023),
		hs24 as (select * from happiness_scores_current),
		hs_23_24 as (select hs23.country,
							hs23.happiness_score as hs_2023,
							hs24.ladder_score as hs_2024
					 from 	hs23 left join hs24
							on hs23.country = hs24.country)
select * from hs_23_24 where hs_2024 > hs_2023;
-- Alternative: CTEs only // sam sie już domyśłiłem że można tak zrobic dlatego jest na górze


-- 10. Recursive CTEs

-- Create a stock prices table
CREATE TABLE IF NOT EXISTS stock_prices (
    date DATE PRIMARY KEY,
    price DECIMAL(10, 2)
);

INSERT INTO stock_prices (date, price) VALUES
	('2024-11-01', 678.27),
	('2024-11-03', 688.83),
	('2024-11-04', 645.40),
	('2024-11-06', 591.01);
    
/* Employee table was created in prior section:
   This is the code if you need to create it again */
    
/*
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
*/

-- Example 1: Generating sequences
SELECT * FROM stock_prices;

-- Generate a column of dates

-- Include the original prices
-- Example 2: Working with hierachical data
-- Return the reporting chain for each employee

-- 11. Subquery vs CTE vs Temp Table vs View

-- Subquery
select * from 
(select year, country, happiness_score from happiness_scores
union all
select 2024, country, ladder_score from happiness_scores_current) as my_subquery;

-- CTE
with my_cte as (select year, country, happiness_score from happiness_scores
				union all
				select 2024, country, ladder_score from happiness_scores_current)
select * from my_cte;

-- Temporary table

create temporary table my_temp_table as
select year, country, happiness_score from happiness_scores
union all
select 2024, country, ladder_score from happiness_scores_current;

select * from my_temp_table;
-- View
create view my_view as
select year, country, happiness_score from happiness_scores
union all
select 2024, country, ladder_score from happiness_scores_current;

select * from my_view;