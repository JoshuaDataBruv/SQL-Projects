-- Retrieve all records from the us_household_income table.
SELECT *
FROM us_household_income;

-- Retrieve all records from the us_household_income_statistics table.
SELECT *
FROM us_household_income_statistics;

#--------------------------------------------------------------------------------------------------------------------------
-- Query to identify the top ten states with the largest amount of land area.
SELECT State_Name, SUM(ALand) AS Total_Land, SUM(AWater) AS Total_Water
FROM us_household_income
GROUP BY State_Name
ORDER BY Total_Land DESC
LIMIT 10;

-- Query to identify the top ten states with the largest amount of water area.
SELECT State_Name, SUM(ALand) AS Total_Land, SUM(AWater) AS Total_Water
FROM us_household_income
GROUP BY State_Name
ORDER BY Total_Water DESC
LIMIT 10;

-- Joining the us_household_income and us_household_income_statistics tables on the id field to gather matching data, filtering out entries where Mean income is zero.
SELECT *
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0;

-- Query to calculate the average mean and median income per state, listing the top ten states with the highest average mean income.
SELECT u.State_Name, ROUND(AVG(Mean),1) AS AVG_Mean, ROUND(AVG(Median),1) AS AVG_Median
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY AVG_Mean DESC
LIMIT 10;

-- Analyze income data by the type of area (e.g., city, rural), showing only types with more than 100 entries, ordered by average mean income.
SELECT Type, COUNT(Type) AS Type_Count, ROUND(AVG(Mean),1) AS AVG_Mean, ROUND(AVG(Median),1) AS AVG_Median
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
HAVING Type_Count > 100
ORDER BY AVG_Mean DESC;

-- Detailed query to find the average mean and median income per city in each state, sorted by the highest average mean income.
SELECT u.State_Name, City, ROUND(AVG(Mean),1) AS AVG_Mean, ROUND(AVG(Median),1) AS AVG_Median
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name, City
ORDER BY AVG_Mean DESC;
