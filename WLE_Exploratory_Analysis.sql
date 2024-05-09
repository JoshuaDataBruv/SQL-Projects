-- Retrieve all records from the worldlifeexpectancy2 table for initial overview.
SELECT *
FROM worldlifeexpectancy2;

-- Analyze the change in life expectancy over a 15-year period for each country, showing countries with the greatest increase first.
SELECT Country,
MIN(`Life expectancy`) AS Min_Life_Exp,
MAX(`Life expectancy`) AS Max_Life_Exp,
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM worldlifeexpectancy2
GROUP BY Country
HAVING Min_Life_Exp <> 0 AND Max_Life_Exp <> 0
ORDER BY Life_Increase_15_Years DESC;

-- Calculate the average life expectancy for each year across all countries, ensuring that zero values are excluded.
SELECT Year, ROUND(AVG(`Life expectancy`),2) AS AVG_Life_Exp
FROM worldlifeexpectancy2
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

-- Determine the average life expectancy and GDP for each country, filtered to include only those with non-zero values, and ordered by GDP.
SELECT Country,
ROUND(AVG(`Life expectancy`),1) AS AVG_Life_Exp,
ROUND(AVG(GDP),1) AS AVG_GDP
FROM worldlifeexpectancy2
GROUP BY Country
HAVING AVG_Life_Exp > 0 AND AVG_GDP > 0
ORDER BY AVG_GDP DESC;

-- Compare high GDP and low GDP countries in terms of life expectancy.
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS HIGH_GDP_COUNT,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END),1) AS HIGH_GDP_Life_expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS LOW_GDP_COUNT,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END),1) AS LOW_GDP_Life_expectancy
FROM worldlifeexpectancy2;

-- Analyze the average life expectancy grouped by the status (Developed or Developing) of the countries.
SELECT Status, ROUND(AVG(`Life expectancy`),1) AS AVG_Life_Expectancy, COUNT(DISTINCT Country) AS Num_Of_Countries
FROM worldlifeexpectancy2
GROUP BY Status;

-- Investigate the relationship between average life expectancy and BMI by country, ordered by BMI.
SELECT Country,
ROUND(AVG(`Life expectancy`),1) AS AVG_Life_Exp,
ROUND(AVG(BMI),1) AS AVG_BMI
FROM worldlifeexpectancy2
GROUP BY Country
HAVING AVG_Life_Exp > 0 AND AVG_BMI > 0
ORDER BY AVG_BMI DESC;

-- Calculate the rolling total of adult mortality by year for each country, helping to identify trends in mortality over time.
SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM worldlifeexpectancy2;
