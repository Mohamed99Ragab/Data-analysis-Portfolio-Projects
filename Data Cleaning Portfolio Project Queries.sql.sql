/*
Cleaning Data in SQL Queries
*/
use PortfolioProject;

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select saledate , CONVERT(date , SaleDate) as 'Sale Date Converted'
from NashvilleHousing;

update NashvilleHousing
set SaleDate = CONVERT(date , SaleDate);

--or other way to date format 

alter table NashvilleHousing
alter column saledate date;


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- split column propertyAddress to two columns by substring function

select PropertyAddress,
SUBSTRING(PropertyAddress , 1,CHARINDEX(',' ,PropertyAddress)-1),
SUBSTRING(PropertyAddress ,CHARINDEX(',' ,PropertyAddress)+1 ,LEN(PropertyAddress) )

from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress , 1,CHARINDEX(',' ,PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',' ,PropertyAddress)+1 ,LEN(PropertyAddress) );

--other way to spilt column ownerAdress to three column by parseName function

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing
where OwnerAddress is not null;


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,ROW_NUMBER() over (
partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	  order by UniqueID) as row_Num
	  from NashvilleHousing	  
)
delete from RowNumCTE
where row_Num >1;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



----------------Thanks to view --------------------
---------------- Mohamed Ragab ----------------------