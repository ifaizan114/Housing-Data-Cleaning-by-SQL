/*
Data Cleaning by SQL Queries
*/

SELECT *
FROM SqlPortfolio.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM SqlPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM SqlPortfolio.dbo.NashvilleHousing
Where PropertyAddress is Null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SqlPortfolio.dbo.NashvilleHousing a
JOIN SqlPortfolio.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SqlPortfolio.dbo.NashvilleHousing a
JOIN SqlPortfolio.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM SqlPortfolio.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM SqlPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

----------------------------------------------

SELECT OwnerAddress
FROM SqlPortfolio.dbo.NashvilleHousing

SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From SqlPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From SqlPortfolio.dbo.NashvilleHousing
Group By SoldAsVacant
Order BY 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM SqlPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
					) AS row_num
FROM SqlPortfolio.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM SqlPortfolio.dbo.NashvilleHousing
)
Delete
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM SqlPortfolio.dbo.NashvilleHousing

ALTER TABLE SqlPortfolio.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

---------------------------------------------------------------------------------------------------------

-- Removing Nulls

WITH CleanedData AS (
SELECT *,
        ROW_NUMBER() OVER (
        PARTITION BY OwnerName,
				Acreage,
				LandValue,
				BuildingValue,
				TotalValue,
				YearBuilt,
				Bedrooms,
				FullBath,
				HalfBath,
				SaleDateConverted
                ORDER BY UniqueID
                          ) AS row_null
FROM SqlPortfolio.dbo.NashvilleHousing
WHERE 
    OwnerName IS NOT NULL
AND Acreage IS NOT NULL
AND LandValue IS NOT NULL
AND BuildingValue IS NOT NULL
AND TotalValue IS NOT NULL
AND YearBuilt IS NOT NULL
AND Bedrooms IS NOT NULL
AND FullBath IS NOT NULL
AND HalfBath IS NOT NULL
AND SaleDateConverted IS NOT NULL
)
SELECT *
FROM CleanedData
WHERE row_null IS NOT NULL
Order By UniqueID

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
