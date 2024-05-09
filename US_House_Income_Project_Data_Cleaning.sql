-- Retrieve all records from us_household_income table.
SELECT *
FROM us_household_income;

-- Retrieve all records from us_household_income_statistics table.
SELECT *
FROM us_household_income_statistics;

#--------------------------------------------------------------------------------------------------------------------------
-- Identifying duplicate entries in the us_household_income table by checking the id field.
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

-- Listing duplicate rows based on the id, showing rows with a row number greater than 1 as duplicates.
SELECT *
FROM (
	SELECT row_id, id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_household_income
    ) AS duplicates
WHERE row_num > 1;

-- Delete duplicate rows from us_household_income, keeping only the first entry for each duplicate id.
DELETE FROM us_household_income
WHERE row_id IN (
	SELECT row_id 
	FROM (
		SELECT row_id, id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_household_income
		) AS duplicates
	WHERE row_num > 1);
    
#--------------------------------------------------------------------------------------------------------------------------
-- Check for duplicates in the us_household_income_statistics table; this query finds no duplicates.
SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1;

#--------------------------------------------------------------------------------------------------------------------------
-- Check for spelling mistakes or formatting needs in state names and abbreviations.

-- List distinct state names to check for misspellings.
SELECT DISTINCT State_Name
FROM us_household_income
ORDER BY 1;

-- Correct the spelling of 'georia' to 'Georgia'.
UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

-- Correct the spelling of 'alabama' to 'Alabama'.
UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

-- List distinct state abbreviations to check for misspellings.
SELECT DISTINCT State_ab
FROM us_household_income
ORDER BY 1;

-- Identify rows where the Place column is blank.
SELECT *
FROM us_household_income
WHERE Place = ''
ORDER BY 1;

-- Update blank fields in the Place column, where specific conditions are met.
UPDATE us_household_income
SET Place = 'Autaugaville' 
WHERE County = 'Autauga County'
AND City = 'Vinemont';

#--------------------------------------------------------------------------------------------------------------------------
-- Check for errors or formatting needs in the Type column.

-- List all entries from the Type column to check for errors or inconsistencies.
SELECT Type, COUNT(*)
FROM us_household_income
GROUP BY Type;

-- Update the value 'Boroughs' to 'Borough'.
UPDATE us_household_income
SET Type = 'Borough' 
WHERE Type = 'Boroughs';

-- Correct the misentered 'CPD' to 'CDP'.
UPDATE us_household_income
SET Type = 'CDP'
WHERE Type = 'CPD';

#--------------------------------------------------------------------------------------------------------------------------
-- Update the columns Place, City, County, and State_Name to uppercase to ensure consistency in data format.
UPDATE us_household_income
SET County = UPPER(County),
    City = UPPER(City),
    Place = UPPER(Place),
    State_Name = UPPER(State_Name);

#--------------------------------------------------------------------------------------------------------------------------
-- Check the ALand and AWater columns for entries where AWater is zero, indicating no water coverage.

-- List ALand and AWater values where there is no water recorded.
SELECT ALand, AWater
FROM us_household_income
WHERE AWater = 0 OR AWater = '' OR AWater IS NULL;
-- Uncomment the following line if you want to include a check for no land coverage as well.
-- AND (ALand = 0 OR ALand = '' OR ALand IS NULL);
