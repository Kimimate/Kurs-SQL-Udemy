-- Connect to database (MySQL) **Połącz z bazą danych (MySQL)**

USE maven_advanced_sql;

-- 1. View the students table **Wyświetl tabelę uczniów (students)**
SELECT * FROM students;

-- 2. The big 6 **Wielka szóstka (kluczowe klauzule SQL)**
SELECT	grade_level, AVG(gpa) AS avg_gpa
FROM	students
WHERE	school_lunch = 'Yes'
GROUP BY grade_level
HAVING   avg_gpa < 3.3
ORDER BY grade_level;

-- 3. Common keywords **Popularne słowa kluczowe**

-- DISTINCT **(Unikalne wartości)**
SELECT	DISTINCT grade_level
FROM	students;

-- COUNT **(Zliczanie)**
SELECT	COUNT(DISTINCT grade_level)
FROM	students;

-- MAX and MIN **(Wartości ekstremalne)**
SELECT	MAX(gpa) - MIN(gpa) AS gpa_range
FROM	students;

-- AND **(Operator logiczny "i")**
SELECT	*
FROM	students
WHERE	grade_level < 12 AND school_lunch = 'Yes';

-- IN **(Operator przynależności do zbioru)**
SELECT	*
FROM	students
WHERE	grade_level IN (9, 10, 11);

-- IS NULL **(Sprawdzanie wartości pustych)**
SELECT	*
FROM	students
WHERE	email IS NOT NULL;

-- LIKE **(Wyszukiwanie według wzorca)**
SELECT	*
FROM	students
WHERE	email LIKE '%.edu';

-- ORDER BY **(Sortowanie)**
SELECT	*
FROM	students
ORDER BY gpa DESC;

-- LIMIT **(Ograniczenie liczby wyników)**
SELECT	*
FROM	students
LIMIT	5;

-- CASE statements **Instrukcje warunkowe CASE**
SELECT	student_name, grade_level,
		CASE WHEN grade_level = 9 THEN 'Freshman'
			 WHEN grade_level = 10 THEN 'Sophomore'
             WHEN grade_level = 11 THEN 'Junior'
             ELSE 'Senior' END AS student_class
FROM	students;
