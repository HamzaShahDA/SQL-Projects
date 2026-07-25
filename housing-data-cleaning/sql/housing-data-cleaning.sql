------------------------------------------------------------------------------------------------------------------
/*
Cleaning Data in SQL

*/

Select * from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standarize Dates
Select SaleDateConverted, Convert(Date,SaleDate)
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set SaleDate= Convert(Date,SaleDate)

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add SaleDateConverted Date;

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set SaleDateConverted= Convert(Date,SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select *
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
--Where PropertyAddress is null
order by ParcelID


Select  a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)] a
join [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)] b
on a.ParcelID=b.ParcelID And a.UniqueID!=b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)] a
join [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)] b
on a.ParcelID=b.ParcelID And a.UniqueID!=b.UniqueID
where a.PropertyAddress is null



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, city , state)

Select PropertyAddress
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
--Where PropertyAddress is null
--order by ParcelID


Select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add PropertySlitAddress VarChar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set PropertySlitAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add PropertySplitCity VarChar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

Select * from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Select OwnerAddress from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add OwnerSplitAddress VarChar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add OwnerSplitCity VarChar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table [Nashville Housing Data for Data Cleaning (reuploaded)]
Add OwnerSplitState VarChar(255);

Update [Nashville Housing Data for Data Cleaning (reuploaded)]
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * FROM [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

ALTER TABLE  [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
DROP COLUMN PropertySplitAddress;

ALTER TABLE [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
DROP COLUMN OwnerPropertySplitAddress;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N into Yes or No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
FROM [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
Group by SoldAsVacant
Order by SoldAsVacant

Select SoldAsVacant,
Case When SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
FROM [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
     ROW_NUMBER()Over (
     Partition by
	    ParcelID,
	    PropertyAddress,
		Saleprice,
		SaleDate,
		LegalReference
		Order BY 
		  UniqueID
		  )row_num
from [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
)
Select *
From RownumCTE
where row_num>1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Column
Select *
From [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]

Alter Table [SQL data cleaning].dbo.[Nashville Housing Data for Data Cleaning (reuploaded)]
Drop Column PropertyAddress,OwnerAddress,TaxDistrict
