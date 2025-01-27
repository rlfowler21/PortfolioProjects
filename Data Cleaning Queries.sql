/* 
Cleaning Data in SQL

Summary of Cleaning:
-Standardized date format
-Handled NULL values in 'PropertyAddress'
-Split 'PropertyAddress' into street and city components and 'OwnerAddress' into street, city, and state components
-Standardized 'SoldAsVacant' field
-Removed duplicate rows
-Dropped unused columns
*/ 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

-- Standardize Date Format 
SELECT SaleDate,
	CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Replacing SaleDate with Converted Column 

ALTER TABLE NashvilleHousing 
DROP COLUMN SaleDate;


-- Populate Property Address Data

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing 
WHERE PropertyAddress IS NULL

SELECT 
	a.ParcelID, a.PropertyAddress, 
	b.ParcelID, b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Property Address into Individual Columns (Address, City, State) Using SUBSTRING

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Breaking out Owner Address into Individual Columns (Address, City, State) Using PARSENAME

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
	PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
	PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT  
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing 

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-- Remove Duplicate Rows

WITH RowNumCTE AS 
(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY 
					UniqueID 
						) row_num
FROM PortfolioProject.dbo.NashvilleHousing 
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN 
OwnerAddress, 
PropertyAddress,
TaxDistrict
