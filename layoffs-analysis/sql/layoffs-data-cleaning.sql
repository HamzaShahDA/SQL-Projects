/*
    Layoffs Data Cleaning
    SQL Server

    Source table:
    [SQL data cleaning].[dbo].[layoffs$]

    The script creates and cleans a staging table so that the original
    imported data remains unchanged.
*/

USE [SQL data cleaning];

-------------------------------------------------------------------------------
-- 1. Create a fresh staging table
-------------------------------------------------------------------------------

IF OBJECT_ID('dbo.layoffs_staging', 'U') IS NOT NULL
    DROP TABLE dbo.layoffs_staging;

SELECT *
INTO dbo.layoffs_staging
FROM dbo.[layoffs$];

-------------------------------------------------------------------------------
-- 2. Convert text representations of missing values to SQL NULL
-------------------------------------------------------------------------------

UPDATE dbo.layoffs_staging
SET industry = NULL
WHERE industry IS NULL
   OR LTRIM(RTRIM(industry)) = ''
   OR UPPER(LTRIM(RTRIM(industry))) = 'NULL';

UPDATE dbo.layoffs_staging
SET total_laid_off = NULL
WHERE UPPER(LTRIM(RTRIM(CONVERT(varchar(100), total_laid_off)))) = 'NULL';

UPDATE dbo.layoffs_staging
SET percentage_laid_off = NULL
WHERE UPPER(LTRIM(RTRIM(CONVERT(varchar(100), percentage_laid_off)))) = 'NULL';

UPDATE dbo.layoffs_staging
SET funds_raised_millions = NULL
WHERE UPPER(LTRIM(RTRIM(CONVERT(varchar(100), funds_raised_millions)))) = 'NULL';

-------------------------------------------------------------------------------
-- 3. Standardize text values
-------------------------------------------------------------------------------

UPDATE dbo.layoffs_staging
SET company = LTRIM(RTRIM(company));

UPDATE dbo.layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE dbo.layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%';

-------------------------------------------------------------------------------
-- 4. Convert the date field
-------------------------------------------------------------------------------

ALTER TABLE dbo.layoffs_staging
ADD layoff_date date;

UPDATE dbo.layoffs_staging
SET layoff_date = TRY_CONVERT(date, [date], 101);

ALTER TABLE dbo.layoffs_staging
DROP COLUMN [date];

-------------------------------------------------------------------------------
-- 5. Fill missing industries from matching company and location records
-------------------------------------------------------------------------------

;WITH IndustryLookup AS
(
    SELECT
        company,
        location,
        MAX(industry) AS industry
    FROM dbo.layoffs_staging
    WHERE industry IS NOT NULL
    GROUP BY company, location
)
UPDATE s
SET s.industry = i.industry
FROM dbo.layoffs_staging AS s
INNER JOIN IndustryLookup AS i
    ON s.company = i.company
   AND s.location = i.location
WHERE s.industry IS NULL;

-------------------------------------------------------------------------------
-- 6. Remove duplicate records
--    One record is retained from each exact duplicate group.
-------------------------------------------------------------------------------

;WITH DuplicateRows AS
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                layoff_date,
                stage,
                country,
                funds_raised_millions
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM dbo.layoffs_staging
)
DELETE FROM DuplicateRows
WHERE row_num > 1;

-------------------------------------------------------------------------------
-- 7. Remove records with no reported layoff amount or percentage
-------------------------------------------------------------------------------

DELETE FROM dbo.layoffs_staging
WHERE
    NULLIF(
        NULLIF(
            UPPER(LTRIM(RTRIM(CONVERT(varchar(100), total_laid_off)))),
            ''
        ),
        'NULL'
    ) IS NULL
AND
    NULLIF(
        NULLIF(
            UPPER(LTRIM(RTRIM(CONVERT(varchar(100), percentage_laid_off)))),
            ''
        ),
        'NULL'
    ) IS NULL;

-------------------------------------------------------------------------------
-- 8. Review the cleaned data
-------------------------------------------------------------------------------

SELECT *
FROM dbo.layoffs_staging;
