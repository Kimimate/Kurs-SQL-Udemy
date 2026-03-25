-- Connect to database (MySQL)
USE maven_advanced_sql;

-- 1. Window function basics
-- Return all row numbers
select
	country,
	year,
	happiness_score,
	row_number() over () as row_num
from
	happiness_scores
order by
	country,
	year;

-- Return all row numbers within each window
select
	country,
	year,
	happiness_score,
	row_number() over (
		partition by
			country
	) as row_num
from
	happiness_scores
order by
	country,
	year;

-- Return all row numbers within each window
-- where the rows are ordered by happiness score
select
	country,
	year,
	happiness_score,
	row_number() over (
		partition by
			country
		order by
			happiness_score
	) as row_num
from
	happiness_scores
order by
	country,
	row_num;

-- Return all row numbers within each window
-- where the rows are ordered by happiness score descending
select
	country,
	year,
	happiness_score,
	row_number() over (
		partition by
			country
		order by
			happiness_score DESC
	) as row_num
from
	happiness_scores
order by
	country,
	row_num;

-- 2. ROW_NUMBER vs RANK vs DENSE_RANK
/*CREATE TABLE baby_girl_names (
name VARCHAR(50),
babies INT);

INSERT INTO baby_girl_names (name, babies) VALUES
('Olivia', 99),
('Emma', 80),
('Charlotte', 80),
('Amelia', 75),
('Sophia', 72),
('Isabella', 70),
('Ava', 70),
('Mia', 64);
-- drop table baby_girl_names;
 */
-- View the table
select
	*
from
	baby_girl_names;

-- Compare ROW_NUMBER vs RANK vs DENSE_RANK
select
	name,
	babies,
	row_number() over (
		order by
			babies desc
	) as 'row_number',
	rank() over (
		order by
			babies desc
	) as 'rank',
	dense_rank() over (
		order by
			babies desc
	) as 'dense_rank'
from
	baby_girl_names;

-- 3. FIRST_VALUE, LAST VALUE & NTH_VALUE
/*
CREATE TABLE baby_names (
gender VARCHAR(10),
name VARCHAR(50),
babies INT);

INSERT INTO baby_names (gender, name, babies) VALUES
('Female', 'Charlotte', 80),
('Female', 'Emma', 82),
('Female', 'Olivia', 99),
('Male', 'James', 85),
('Male', 'Liam', 110),
('Male', 'Noah', 95);
 */
-- View the table
select
	*
from
	baby_names;

-- Return the first name in each window
select
	gender,
	name,
	babies,
	first_value (name) over (
		partition by
			gender
		order by
			babies desc
	) as top_names
from
	baby_names;

-- Return the top name for each gender
select
	*
from
	(
		select
			gender,
			name,
			babies,
			first_value (name) over (
				partition by
					gender
				order by
					babies desc
			) as top_name
		from
			baby_names
	) as top_names
where
	name = top_name;

-- CTE alternative
with
	top_names as (
		select
			gender,
			name,
			babies,
			first_value (name) over (
				partition by
					gender
				order by
					babies desc
			) as top_name
		from
			baby_names
	)
select
	*
from
	top_names
where
	name = top_name;

-- Return the second name in each window
select
	gender,
	name,
	babies,
	nth_value (name, 2) over (
		partition by
			gender
		order by
			babies desc
	) as top_names
from
	baby_names;

-- Return the 2nd most popular name for each gender
with
	top_names as (
		select
			gender,
			name,
			babies,
			nth_value (name, 2) over (
				partition by
					gender
				order by
					babies desc
			) as top_name
		from
			baby_names
	)
select
	*
from
	top_names
where
	name = top_name;

-- Alternative using ROW_NUMBER
-- Number all the rows within each window
with
	pop as (
		select
			gender,
			name,
			babies,
			row_number() over (
				partition by
					gender
				order by
					babies desc
			) as popularity
		from
			baby_names
	)
select
	*
from
	top_names;

-- Return the top 2 most popular names for each gender
with
	pop as (
		select
			gender,
			name,
			babies,
			row_number() over (
				partition by
					gender
				order by
					babies desc
			) as popularity
		from
			baby_names
	)
select
	*
from
	pop
where
	popularity <= 2;

-- 4. LEAD & LAG
-- Return the prior year's happiness score
with
	hs_piror as (
		select
			country,
			year,
			happiness_score,
			lag (happiness_score) over (
				partition by
					country
				order by
					year
			) as piror_hs
		from
			happiness_scores
	)
select
	*
from
	hs_piror;

-- Return the difference between yearly scores
with
	hs_piror as (
		select
			country,
			year,
			happiness_score,
			lag (happiness_score) over (
				partition by
					country
				order by
					year
			) as piror_hs
		from
			happiness_scores
	)
select
	country,
	year,
	happiness_score,
	piror_hs,
	happiness_score - piror_hs as hs_change
from
	hs_piror;

-- 5. NTILE
-- Add a percentile to each row of data
select
	region,
	country,
	happiness_score,
	NTILE (4) over (
		partition by
			region
		order by
			happiness_score desc
	) as hs_percentile
from
	happiness_scores
where
	year = 2023
order by
	region,
	happiness_score desc;

-- For each region, return the top 25% of countries, in terms of happiness score
with
	hs_pct as (
		select
			region,
			country,
			happiness_score,
			NTILE (4) over (
				partition by
					region
				order by
					happiness_score desc
			) as hs_percentile
		from
			happiness_scores
		where
			year = 2023
	)
select
	*
from
	hs_pct
where
	hs_percentile = 1;

/* This ORDER BY clause in the CTE doesn't affect the final order of
the query and can be removed to make the code run more efficiently */