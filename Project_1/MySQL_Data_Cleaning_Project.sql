-- DATA CLEANING
-- steps
-- 1. check and remove duplicates
-- 2. standardize data and fix errors
-- 3. look for null values and fix them either populate or delete
-- 4. remove columns or rows thats unnecessary

SELECT *
FROM layoffs;

-- staging tables are where data cleaning is done

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT company, industry, total_laid_off, `date`,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM layoffs_staging;

SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;

SELECT * FROM layoffs_staging
WHERE company = 'Oda';

-- Real duplicates found
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- Deleting the duplicates
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;

WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;

ALTER TABLE layoffs_staging ADD row_num INT;

-- table to have the row_num and to delete the row with duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging;
-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM layoffs_staging2
WHERE row_num >= 2;

SELECT * FROM layoffs_staging2;

-- 2. Standardize Data
SELECT * FROM layoffs_staging2;

-- if we look at industry, there are some null and empty rows
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;

SELECT * FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- airbnb is travel but its empty, need to fix this
-- if there is another row with the same company name it will update it to non-null
SELECT * FROM layoffs_staging2
WHERE company LIKE 'Airbnb%';

-- set blanks to nulls since they are easier to work with
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- if we check those are all null
SELECT * FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;

-- now to populate those nulls if possible
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;

-- crypto has multiple variations, standardize it, to say all to crypto
SELECT industry
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- problem is now fixed
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT * FROM layoffs_staging2;

-- everythings good, except 'United States.' period problem
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- if we run this again, it is fixed
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Lets fix the date columns
SELECT * FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * FROM layoffs_staging2;


-- 3. Null values, leave them for now to be used later on for EDA

-- 4. remove any columns and rows we dont need
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete useless data we cant use
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;

-- End