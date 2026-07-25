/*
    Housing Data Cleaning
    SQL Server

    Source table:
    [SQL data cleaning].[dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]

    The script creates and cleans a separate working table so that the
    original imported data remains unchanged.
*/

USE [SQL data cleaning];

-------------------------------------------------------------------------------
-- 1. Create a fresh working table
-------------------------------------------------------------------------------

IF OBJECT_ID('dbo.nashville_housing_clean', 'U') IS NOT NULL
    DROP TABLE dbo.nashville_housing_clean;

SELECT *
INTO dbo.nashville_housing_clean
FROM dbo.[Nashville Housing Data for Data Cleaning (reuploaded)];

-------------------------------------------------------------------------------
-- 2. Standardize the sale date
-------------------------------------------------------------------------------

ALTER TABLE dbo.nashville_housing_clean
ADD SaleDateConverted date;

UPDATE dbo.nashville_housing_clean
SET SaleDateConverted = TRY_CONVERT(date, SaleDate);

-------------------------------------------------------------------------------
-- 3. Fill missing property addresses
--    Records with the same ParcelID normally refer to the same property.
-------------------------------------------------------------------------------

;WITH AddressLookup AS
(
    SELECT
        ParcelID,
        MAX(PropertyAddress) AS PropertyAddress
    FROM dbo.nashville_housing_clean
    WHERE PropertyAddress IS NOT NULL
    GROUP BY ParcelID
)
UPDATE h
SET h.PropertyAddress = a.PropertyAddress
FROM dbo.nashville_housing_clean AS h
INNER JOIN AddressLookup AS a
    ON h.ParcelID = a.ParcelID
WHERE h.PropertyAddress IS NULL;

-------------------------------------------------------------------------------
-- 4. Split the property address into address and city
-------------------------------------------------------------------------------

ALTER TABLE dbo.nashville_housing_clean
ADD
    PropertySplitAddress varchar(255),
    PropertySplitCity varchar(255);

UPDATE dbo.nashville_housing_clean
SET
    PropertySplitAddress =
        LTRIM(RTRIM(LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1))),
    PropertySplitCity =
        LTRIM(RTRIM(SUBSTRING(
            PropertyAddress,
            CHARINDEX(',', PropertyAddress) + 1,
            LEN(PropertyAddress)
        )))
WHERE PropertyAddress IS NOT NULL
  AND CHARINDEX(',', PropertyAddress) > 0;

-------------------------------------------------------------------------------
-- 5. Split the owner address into address, city, and state
-------------------------------------------------------------------------------

ALTER TABLE dbo.nashville_housing_clean
ADD
    OwnerSplitAddress varchar(255),
    OwnerSplitCity varchar(255),
    OwnerSplitState varchar(255);

UPDATE dbo.nashville_housing_clean
SET
    OwnerSplitAddress =
        LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))),
    OwnerSplitCity =
        LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))),
    OwnerSplitState =
        LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)))
WHERE OwnerAddress IS NOT NULL;

-------------------------------------------------------------------------------
-- 6. Standardize SoldAsVacant values
-------------------------------------------------------------------------------

UPDATE dbo.nashville_housing_clean
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-------------------------------------------------------------------------------
-- 7. Remove duplicate records
--    One record is retained from each exact duplicate group.
-------------------------------------------------------------------------------

;WITH DuplicateRows AS
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDateConverted,
                LegalReference
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM dbo.nashville_housing_clean
)
DELETE FROM DuplicateRows
WHERE row_num > 1;

-------------------------------------------------------------------------------
-- 8. Remove columns replaced by cleaned address fields
-------------------------------------------------------------------------------

ALTER TABLE dbo.nashville_housing_clean
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

-------------------------------------------------------------------------------
-- 9. Review the cleaned data
-------------------------------------------------------------------------------

SELECT *
FROM NewTable nt ;

SELECT name
FROM sys.databases
ORDER BY name;

SELECT
    'MyDatabase' AS database_name,
    TABLE_SCHEMA,
    TABLE_NAME
FROM MyDatabase.INFORMATION_SCHEMA.TABLES

UNION ALL

SELECT
    'SalesDB' AS database_name,
    TABLE_SCHEMA,
    TABLE_NAME
FROM SalesDB.INFORMATION_SCHEMA.TABLES
ORDER BY database_name, TABLE_NAME;