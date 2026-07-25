----------------------------------------------------------------------------------------------------

-- Data Cleaning

select * from [SQL data cleaning].dbo.layoffs$

select DATA_TYPE,COLUMN_NAME 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_SCHEMA='dbo' AND  TABLE_NAME='layoffs$';

-- Create an empty table with the same structure
SELECT TOP 0 *
INTO layoffs_staging
FROM [SQL data cleaning].dbo.layoffs$

-- Copy data from the existing table to the new table
INSERT INTO layoffs_staging
SELECT *
FROM [SQL data cleaning].dbo.layoffs$

select * from layoffs_staging


---- 1.	Remove Duplicates

select * from layoffs_staging
with duplicate_CTE As
(
Select *,
ROW_NUMBER() over(
                  partition by 
				  company,
				  location,
				  industry, 
				  total_laid_off,
				  percentage_laid_off,
				  'date',
				  stage,
				  country,
				  funds_raised_millions
				  Order by funds_raised_millions)AS row_num
from layoffs_staging
)
select * from duplicate_CTE
where row_num>1





---- 2. Standarize data

Select company, TRIM(company)
from layoffs_staging

update layoffs_staging
set company= TRIM(company)

--- changing date format

Select date, CONVERT(date,date)
from layoffs_staging

Alter table layoffs_staging
Add Dates date

Update layoffs_staging
set Dates=CONVERT(date,date)

select * from layoffs_staging

ALTER TABLE layoffs_staging
DROP COLUMN [date];

----- Changing data

select * from layoffs_staging
where industry like 'crypto%'

update layoffs_staging
set industry='crypto'
where industry like 'crypto%'

select distinct country from layoffs_staging
order by 1

select country from layoffs_staging
where country like 'United States.%'

update layoffs_staging
set country='United States'
where country like 'United States%'


----- 3.Null values or blank values

Select * from layoffs_staging
where percentage_laid_off Is null and total_laid_off is null

Select *  from layoffs_staging
where industry is null or industry=''


Select *  from layoffs_staging
where company like 'ball%'

update layoffs_staging 
set industry=NULL
where industry=''

select t1.industry,t2.industry from layoffs_staging t1
join layoffs_staging t2
on t1.company=t2.company And t1.location=t2.location
where (t1.industry is null) and t2.industry is not null

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;


----- 4. Remove any columns

select * from layoffs_staging

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging
WHERE TRIM(total_laid_off) IS NULL AND TRIM(percentage_laid_off) IS NULL;

-- Find rows where percentage_laid_off appears empty or null but isn't
SELECT *, LEN(percentage_laid_off) AS len, DATALENGTH(percentage_laid_off) AS data_len
FROM layoffs_staging
WHERE percentage_laid_off IS NULL OR LEN(percentage_laid_off) = 0;

-- Update rows where percentage_laid_off has hidden characters to NULL
UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE DATALENGTH(percentage_laid_off) = 0;



alter table layoffs_staing
drop column row_num