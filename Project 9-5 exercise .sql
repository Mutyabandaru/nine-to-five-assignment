-- Database Exploration

/* Database Exploration — Tables, Columns, and Relationships
Tables and Columns
annual_2016
Columns: id, series_id, year, period, value, foot_note, original_file
Contains annual employment/earnings data for 2016 keyed by series_id.

datatype
Columns: data_type_code, data_type_text
Describes the type of data captured (e.g., employment, payroll, hours).

footname
Columns: footnote_code, footnote_text
Provides textual explanations for footnotes referenced in facts.

industry
Columns: industry_code, naics_code, publishing_status, industry_name, display_level, selectable, sort_sequence
Holds industry identifiers and classification details.

january_2017
Columns: id, series_id, year, period, value, foot_note, original_file
Contains monthly data (January 2017) analogous to annual_2016.

period
Columns: unspecified, but examples include codes like M01, JAN, January
Holds period definitions (month codes and labels).

seasonal
Columns: industry_code, seasonal_text
Contains seasonality descriptions linked to industries.

series
Columns: series_id, supersector_code, industry_code, data_type_code, seasonal, series_title, footnote_codes, begin_year, begin_period, end_year
Serves as the bridge linking facts to descriptive metadata (industry, data type, seasonality). The primary key (series_id) joins to fact tables.

supersector
Columns: supersector_code, supersector_name
Provides grouping of industries into broader sectors for reporting.

Relationships and Schema Structure
The fact tables (annual_2016, january_2017) contain observed values linked by series_id to the series table.

The series table is central and connects to:

industry via industry_code

datatype via data_type_code

supersector via supersector_code

Further classification details (e.g., seasonal adjustments, footnotes) augment the data for interpretation.

period and seasonal tables provide descriptive contexts for timing and seasonality respectively.

Diagrammatic Representation (Conceptual)

         +-------------+
          |  supersector|<-----------+
          +-------------+            |
                 ^                   |
                 |                   |
         +---------------+           |
         |   series      |-----------+
         +---------------+
         | series_id (PK)|
         | industry_code |-----------> +-----------+
         | data_type_code|-----------> | datatype  |
         | seasonal     |             +-----------+
         +--------------+
                 |
     +-----------+-----------+
     |                       |
+------------+        +--------------+
|  industry  |        |  footname    |
+------------+        +--------------+
                    (used for footnote_codes in series/facts)
                    
    
         +---------------+       +-----------------+ 
         | annual_2016   |       |  january_2017   |
         +---------------+       +-----------------+
         | series_id (FK)|       | series_id (FK)  |
         | value         |       | value           |
         | year, period  |       | year, period    |
         +---------------+       +-----------------+
*/

--Question2:
SELECT data_type_code, data_type_text
FROM dbo.datatype
WHERE data_type_text LIKE '%women%';
   
--Answer: 10, 39

-- --Question3:
SELECT s.series_id, s.industry_code, i.industry_name, d.data_type_text
FROM dbo.series s
JOIN dbo.industry i ON  s.industry_code = i.industry_code
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%women%' 
AND i.industry_name LIKE '%commercial bank%';
-- --Answer: 
-- -- CES5552211010	55522110	Commercial banking	WOMEN EMPLOYEES
-- -- CEU5552211010	55522110	Commercial banking	WOMEN EMPLOYEES


--Aggregate Your Friends and Code some SQL
--Question1:
SELECT ROUND(SUM(a.value),0) AS total_employees_2016
FROM annual_2016 a
JOIN series s ON a.series_id = s.series_id
WHERE s.data_type_code = '01'  

--Answer: 2340612

--Question2:
SELECT ROUND(SUM(a.value), 0) AS total_women_employees_2016
FROM dbo.annual_2016 a
JOIN dbo.series s ON a.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%women%';

--Answer: 1125490

--Question3:
SELECT ROUND(SUM(a.value), 0) AS total_employees_2016
FROM dbo.annual_2016 a
JOIN dbo.series s ON a.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%production%' OR d.data_type_text LIKE '%nonsupervisory%';
--Answer: 949314508

--Question4:
SELECT  ROUND(AVG(j.VALUE), 2) AS AVG_weekly_hours_jan2017
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%average weekly hours%' 
AND d.data_type_text LIKE '%production and nonsupervisory%' ;

--Answer: 36.06

 --Question5:
SELECT  ROUND(SUM(j.VALUE), 2) AS total_weekly_hours_jan2017
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%weekly payroll%' 
AND d.data_type_text LIKE '%production and nonsupervisory%' ;
--Answer: 1839113368.8


--Question6:
--Highest
SELECT  TOP 1 i.industry_name, j.VALUE 
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON i.industry_code = s.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%' 
AND d.data_type_text LIKE '%weekly hours%' 
ORDER BY j.value DESC;
--Answer: industry_name-Total private,    Value-3412651

--Lowest:
SELECT  TOP 1 i.industry_name, j.VALUE 
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON i.industry_code = s.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%' 
AND d.data_type_text LIKE '%weekly hours%' 
ORDER BY j.value ASC;
--Answer: industry_name-Fitness and recreational sports centers,    Value-16.7


--Question7:
--Highest 
-- There is no table of 2021 in dataset , so im just assuming as there is 2021 table and wrote the query and also assumed ot to be 2017 and wrote query for tahta s well.

-- SELECT i.industry_name,ROUND(SUM(j.value), 2) AS total_weekly_payroll
-- FROM dbo.january_2021 j
-- JOIN dbo.series s ON j.series_id = s.series_id
-- JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
-- JOIN dbo.industry i ON s.industry_code = i.industry_code
-- WHERE d.data_type_text LIKE '%production and nonsupervisory%'
--   AND d.data_type_text LIKE '%weekly payroll%'
-- GROUP BY i.industry_name
-- ORDER BY total_weekly_payroll ASC;

-- Assumed it to be 2017 table

SELECT i.industry_name,ROUND(SUM(j.value), 2) AS total_weekly_payroll
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON s.industry_code = i.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%'
  AND d.data_type_text LIKE '%weekly payroll%'
GROUP BY i.industry_name
ORDER BY total_weekly_payroll ASC;


--Answer: industry_name-Total private,    Value-3412651

--Lowest:
SELECT  TOP 1 i.industry_name, j.VALUE 
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON i.industry_code = s.industry_code
WHERE j.year = '2021' AND d.data_type_text LIKE '%production and nonsupervisory%' 
AND d.data_type_text LIKE '%weekly hours%' 
ORDER BY j.value ASC; 



--Join in on the Fun
--Question1:
SELECT TOP 50 *
FROM dbo.annual_2016 a
LEFT JOIN dbo.series s ON a.series_id = s.series_id
ORDER BY id;

--Question2:
SELECT TOP 50 *
FROM dbo.series s
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
ORDER BY series_id;

--Question3:
SELECT TOP 50 *
FROM dbo.series s
JOIN dbo.industry i ON s.industry_code = i.industry_code
ORDER BY id;

--Subqueries, Unions, Derived Tables, Oh My!
--Question1:
SELECT j.series_id, s.industry_code, i.industry_name, j.value
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
Join dbo.industry i ON i.industry_code = s.industry_code
WHERE (j.value) > 
(SELECT avg(a.value) 
FROM dbo.annual_2016 a
JOIN dbo.series s2 ON a.series_id = s2.series_id
WHERE s2.data_type_code =  82
);

--CTE
WITH avg_val AS (
    SELECT AVG(a.value) AS avg_value
    FROM dbo.annual_2016 a
    JOIN dbo.series s2 ON a.series_id = s2.series_id
    WHERE s2.data_type_code = 82
)
SELECT 
    j.series_id, 
    s.industry_code, 
    i.industry_name, 
    j.value
FROM 
    dbo.january_2017 j
JOIN 
    dbo.series s ON j.series_id = s.series_id
JOIN 
    dbo.industry i ON i.industry_code = s.industry_code
CROSS JOIN 
    avg_val
WHERE 
    j.value > avg_val.avg_value;



--Question2:
SELECT 
    ROUND(AVG(a.value), 2) AS average_earnings,
    '2016' AS year,
    'annual' AS period
FROM 
    dbo.annual_2016 a
JOIN 
    dbo.series s ON a.series_id = s.series_id
WHERE 
    s.data_type_code = 30

UNION ALL

SELECT 
    ROUND(AVG(j.value), 2) AS average_earnings,
    '2017' AS year,
    'january' AS period
FROM 
    dbo.january_2017 j
JOIN 
    dbo.series s ON j.series_id = s.series_id
WHERE 
    s.data_type_code = 30;



--Summarize Your Results:
-- 1. During which time period did production and nonsupervisory employees fare better?
-- Production and nonsupervisory employees fared better in January 2017 compared to 2016. The average weekly hours worked in January 2017 was about 36.06 hours, reflecting more consistent work hours. The total weekly payroll in January 2017 was $1,839,113,368.80, which suggests strong compensation during this period. These figures indicate better conditions compared to annual 2016 data.

SELECT '2016' AS year, 
       ROUND(AVG(value), 2) AS avg_weekly_hours, 
       NULL AS total_weekly_payroll
FROM dbo.annual_2016 a
JOIN dbo.series s ON a.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%average weekly hours%'
  AND d.data_type_text LIKE '%production and nonsupervisory%'

UNION ALL

SELECT '2017' AS year, 
       ROUND(AVG(j.value), 2) AS avg_weekly_hours,
       (SELECT ROUND(SUM(j2.value), 2) 
        FROM dbo.january_2017 j2
        JOIN dbo.series s2 ON j2.series_id = s2.series_id
        JOIN dbo.datatype d2 ON s2.data_type_code = d2.data_type_code
        WHERE d2.data_type_text LIKE '%weekly payroll%'
          AND d2.data_type_text LIKE '%production and nonsupervisory%') AS total_weekly_payroll
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
WHERE d.data_type_text LIKE '%average weekly hours%' 
  AND d.data_type_text LIKE '%production and nonsupervisory%';


/*2. In which industries did production and nonsupervisory employees fare better?
The "Total private" industry had the highest average weekly hours and payroll for production and nonsupervisory employees, showing that this broad sector offered better employment and pay conditions.

The "Fitness and recreational sports centers" industry had the lowest average weekly hours suggesting this industry fared worse in terms of hours worked.
This contrast highlights that employees in large private sectors had better work and pay conditions than those in niche industries.*/

--Highest average weekly hours
SELECT TOP 1 i.industry_name, ROUND(j.value, 2) AS avg_weekly_hours
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON s.industry_code = i.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%'
  AND d.data_type_text LIKE '%weekly hours%'
ORDER BY j.value DESC;

-- Lowest average weekly hours
SELECT TOP 1 i.industry_name, ROUND(j.value, 2) AS avg_weekly_hours
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON s.industry_code = i.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%'
  AND d.data_type_text LIKE '%weekly hours%'
ORDER BY j.value ASC;

-- Highest total weekly payroll
SELECT TOP 1 i.industry_name, ROUND(j.value, 2) AS total_weekly_payroll
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON s.industry_code = i.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%'
  AND d.data_type_text LIKE '%weekly payroll%'
ORDER BY j.value DESC;

-- Lowest total weekly payroll
SELECT TOP 1 i.industry_name, ROUND(j.value, 2) AS total_weekly_payroll
FROM dbo.january_2017 j
JOIN dbo.series s ON j.series_id = s.series_id
JOIN dbo.datatype d ON s.data_type_code = d.data_type_code
JOIN dbo.industry i ON s.industry_code = i.industry_code
WHERE d.data_type_text LIKE '%production and nonsupervisory%'
  AND d.data_type_text LIKE '%weekly payroll%'
ORDER BY j.value ASC;


--Question3: Now that you have explored the datasets, is there any data or information that you wish you had in this analysis?

/*While the dataset is comprehensive, it would be helpful to have:

More granular demographic data (age, ethnicity) to understand disparities within production and nonsupervisory employees.

Data on regional/geographic differences to see how employment conditions vary across locations.

More detailed time series data beyond just 2016 and January 2017 to understand trends.

Information on part-time vs full-time status to better contextualize hours worked and payroll.*/
  

