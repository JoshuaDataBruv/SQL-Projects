-- Retrieve all records from the original household income table.
SELECT *
FROM us_household_income;

-- Change the delimiter to $$ to define the stored procedure.
DELIMITER $$

-- Drop the existing procedure if it exists to avoid conflicts.
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;

-- Create a new procedure named Copy_and_Clean_Data.
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN

	-- Create a new table us_household_income_cleaned if it doesn't exist with the specified schema.
	CREATE TABLE IF NOT EXISTS `us_household_income_cleaned`(
	  `row_id` bigint DEFAULT NULL,
	  `id` bigint DEFAULT NULL,
	  `State_Code` bigint DEFAULT NULL,
	  `State_Name` varchar(1052) DEFAULT NULL,
	  `State_ab` varchar(1052) DEFAULT NULL,
	  `County` varchar(1052) DEFAULT NULL,
	  `City` varchar(1052) DEFAULT NULL,
	  `Place` varchar(1052) DEFAULT NULL,
	  `Type` varchar(1052) DEFAULT NULL,
	  `Primary` varchar(1052) DEFAULT NULL,
	  `Zip_Code` bigint DEFAULT NULL,
	  `Area_Code` bigint DEFAULT NULL,
	  `ALand` bigint DEFAULT NULL,
	  `AWater` bigint DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- Copy all data from us_household_income to the cleaned table and add a current timestamp.
	INSERT INTO `us_household_income_cleaned`
    SELECT *, CURRENT_TIMESTAMP
    FROM us_household_income;
    
    -- Remove duplicates based on the 'id' and 'TimeStamp' by keeping only the first occurrence.
	DELETE FROM us_household_income_cleaned
	WHERE 
		row_id IN (
			SELECT row_id
			FROM (
				SELECT row_id, id,
					ROW_NUMBER() OVER (
						PARTITION BY id, `TimeStamp`
						ORDER BY id, `TimeStamp`) AS row_num
				FROM 
					us_household_income_cleaned
			) duplicates
			WHERE 
				row_num > 1
		);

	-- Correct misspelling in State_Name from 'georia' to 'Georgia'.
	UPDATE us_household_income_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	-- Convert County names to uppercase.
	UPDATE us_household_income_cleaned
	SET County = UPPER(County);

	-- Convert City names to uppercase.
	UPDATE us_household_income_cleaned
	SET City = UPPER(City);

	-- Convert Place names to uppercase.
	UPDATE us_household_income_cleaned
	SET Place = UPPER(Place);

	-- Convert State_Name to uppercase.
	UPDATE us_household_income_cleaned
	SET State_Name = UPPER(State_Name);

	-- Correct Type from 'CPD' to 'CDP'.
	UPDATE us_household_income_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	-- Correct Type from 'Boroughs' to 'Borough'.
	UPDATE us_household_income_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';

END $$

-- Reset the delimiter back to the default.
DELIMITER ;

-- Execute the procedure to perform data cleaning.
CALL Copy_and_Clean_Data();

-- Create a scheduled event to run data cleaning every 2 minutes.
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 2 MINUTE
    DO CALL Copy_and_Clean_Data();

-- Select distinct timestamps to verify when data cleaning occurred.
SELECT DISTINCT(TimeStamp)
FROM us_household_income_cleaned;

-- Retrieve all records from the cleaned household income table after processing.
SELECT *
FROM us_household_income_cleaned;

-- Disables run_data_cleaning event.
ALTER EVENT run_data_cleaning
DISABLE;
