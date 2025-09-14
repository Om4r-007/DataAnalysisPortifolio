-- Exploring Data

SELECT * 
FROM ..ushouse

---------------------------------------------------------------------------
SELECT SaleDate , convert (DATE , SaleDate) as SaleDateConverted
FROM ..ushouse

ALTER TABLE ushouse
ADD SaleDateConverted DATE

UPDATE ushouse
SET SaleDateConverted = convert(DATE , SaleDate)

SELECT SaleDate , SaleDateConverted 
FROM ..ushouse

--------------------------------------------------------------------------

SELECT *
FROM ..ushouse
ORDER BY ParcelID

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM ..ushouse a
JOIN ..ushouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM ..ushouse a
JOIN ..ushouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT *
FROM ..ushouse
WHERE PropertyAddress IS NULL

------- Breaking down proprty address into individual Columns

SELECT PropertyAddress
FROM ..ushouse

ALTER TABLE ..ushouse
ADD PropertyAddressStreet NVARCHAR(255)

UPDATE ..ushouse
SET PropertyAddressStreet = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE ..ushouse 
ADD PropertyAddressCity NVARCHAR(255)

UPDATE ..ushouse
SET PropertyAddressCity = SUBSTRING(PropertyAddress , CHARINDEX(',' , PropertyAddress )+1 , LEN(PropertyAddress))

SELECT PropertyAddress , PropertyAddressStreet , PropertyAddressCity
FROM ..ushouse

------ Breaking down owner address into individual Columns

SELECT OwnerAddress
FROM ..ushouse


ALTER TABLE ..ushouse
ADD OwnerAddressStreet NVARCHAR(255)

UPDATE ..ushouse
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,3)

ALTER TABLE ..ushouse
ADD OwnerAddressCity NVARCHAR(255)

UPDATE ..ushouse
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,2)

ALTER TABLE ..ushouse
ADD OwnerAddressState NVARCHAR(255)

UPDATE ..ushouse
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,1)

SELECT OwnerAddress , OwnerAddressStreet , OwnerAddressCity , OwnerAddressState 
FROM ..ushouse


------------ Change "Y" to "Yes" and "N" to "No"

SELECT DISTINCT SoldAsVacant , count(SoldAsVacant)
FROM ..ushouse
GROUP BY SoldAsVacant

UPDATE ..ushouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
						END


--------- Removing duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID , PropertyAddress , SalePrice , LegalReference 
ORDER BY UniqueID ) row_num
FROM ..ushouse
)
--Select *
DELETE
FROM RowNumCTE
WHERE row_num > 1

------------- Delete unused columns

SELECT *
FROM ..ushouse

ALTER TABLE ..ushouse
DROP COLUMN SaleDate , OwnerAddress , PropertyAddress
