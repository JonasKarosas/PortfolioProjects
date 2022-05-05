/*
Cleaning Data in SQL Queries
*/
 
Select *
From PortfolioProject3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject3.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject3.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select *
From PortfolioProject3.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject3.dbo.NashvilleHousing a
JOIN PortfolioProject3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City)
Select PropertyAddress
From PortfolioProject3.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject3.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject3.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject3.dbo.NashvilleHousing

--Different way to aproach the task (Address, City nad State)
Select OwnerAddress
From PortfolioProject3.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject3.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject3.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject3.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject3.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case	WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject3.dbo.NashvilleHousing

Update PortfolioProject3.dbo.NashvilleHousing
SET SoldAsVacant = Case	
		WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProject3.dbo.NashvilleHousing
)
--DELETE
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Colums
Select *
From PortfolioProject3.dbo.NashvilleHousing

ALTER TABLE PortfolioProject3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



