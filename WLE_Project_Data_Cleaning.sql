-- Retrieve all records from the worldlifeexpectancy2 table.
select *
from worldlifeexpectancy2;

#--------------------------------------------------------------------------------------------------------------------------
-- Locating duplicate entries by merging Country and Year columns to create a unique identifier.
SELECT Country, Year, CONCAT(Country, Year) AS CountryYear, COUNT(CONCAT(Country, Year)) AS Count
FROM worldlifeexpectancy2
GROUP BY Country, Year, CountryYear
HAVING COUNT(CountryYear) > 1;

-- Finding row IDs where duplicates are located using a window function to assign a row number to each group of duplicated CountryYear.
SELECT *
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year) AS CountryYear,
	ROW_NUMBER() OVER(PARTITION BY CountryYear ORDER BY CountryYear) AS Row_Num
	FROM worldlifeexpectancy2
) AS Row_Table
WHERE Row_Num > 1;

-- Deleting duplicate entries based on the identified row IDs where duplicates occur.
DELETE FROM worldlifeexpectancy2
WHERE ROW_ID IN ( 
	SELECT ROW_ID
	FROM (
		SELECT ROW_ID,
		CONCAT(Country, Year) AS CountryYear,
		ROW_NUMBER() OVER(PARTITION BY CountryYear ORDER BY CountryYear) AS Row_Num
		FROM worldlifeexpectancy2
	) AS Row_Table
	WHERE Row_Num > 1);

#--------------------------------------------------------------------------------------------------------------------------
-- Checking for blanks in the 'Status' column.

-- Select entries where the 'Status' column is blank.
SELECT *
FROM worldlifeexpectancy2
WHERE Status = '';

-- List distinct countries marked as 'Developing'.
SELECT DISTINCT Country
FROM worldlifeexpectancy2
WHERE Status = 'Developing';

-- Update 'Status' to 'Developing' for entries that are blank and belong to countries marked as 'Developing' in other entries.
UPDATE worldlifeexpectancy2 t1
JOIN worldlifeexpectancy2 t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

-- Update 'Status' to 'Developed' for entries that are blank and belong to countries marked as 'Developed' in other entries.
UPDATE worldlifeexpectancy2 t1
JOIN worldlifeexpectancy2 t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

-- Verify if there are any blanks left in the 'Status' column.
SELECT *
FROM worldlifeexpectancy2
WHERE Status = '';

#--------------------------------------------------------------------------------------------------------------------------

-- Select entries where the 'Life expectancy' field is blank.
SELECT *
FROM worldlifeexpectancy2
WHERE `Life expectancy` = '';

-- Interpolate missing 'Life expectancy' values using the average of the previous and following years for the same country.
SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1) AS AverageLifeExpectancy
FROM worldlifeexpectancy2 t1
JOIN worldlifeexpectancy2 t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN worldlifeexpectancy2 t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

-- Update 'Life expectancy' using the calculated average for missing entries.
UPDATE worldlifeexpectancy2 t1
JOIN worldlifeexpectancy2 t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN worldlifeexpectancy2 t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';

-- Final check to see if there are any other blanks in the dataset.
select *
from worldlifeexpectancy2;
