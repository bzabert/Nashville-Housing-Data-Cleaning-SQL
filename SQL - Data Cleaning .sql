
----------------------------------------------------------------------------------------------------------------

--- Inspect the raw data
SELECT *
  FROM [covid].[dbo].[Nashville_housing]

----------------------------------------------------------------------------------------------------------------

--- Standardize Date Format
UPDATE Nashville_housing
SET SaleDate = CONVERT(Date, SaleDate)

SELECT SaleDate
FROM covid.dbo.Nashville_housing

----------------------------------------------------------------------------------------------------------------

  ---- Populate Property Address data
SELECT TOP(10) PropertyAddress
FROM Nashville_housing

SELECT ParcelID, PropertyAddress
FROM Nashville_housing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_housing a
JOIN covid.dbo.Nashville_housing b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

SELECT ParcelID, PropertyAddress
FROM Nashville_housing
WHERE PropertyAddress is null

----------------------------------------------------------------------------------------------------------------
  
  ---- Breaking out  Property Address into Individual Columns (Address, City, State)
SELECT TOP(10) PropertyAddress
FROM Nashville_housing

ALTER TABLE Nashville_housing
ADD Property NVARCHAR(225);
GO
UPDATE Nashville_housing
SET Property =SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_housing
ADD City NVARCHAR(225);
GO
UPDATE Nashville_housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))
 
----------------------------------------------------------------------------------------------------------------
  
  ---- Breaking out  Owner Address into Individual Columns (Address, City, State)

ALTER TABLE Nashville_housing
Add Owner_address NVARCHAR(225);
GO
UPDATE Nashville_housing
SET Owner_address = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE Nashville_housing
Add Owner_City NVARCHAR(225);
GO
UPDATE Nashville_housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE Nashville_housing
Add Owner_State NVARCHAR(225);
GO
UPDATE Nashville_housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT TOP(10) *
FROM Nashville_housing


----------------------------------------------------------------------------------------------------------------
  ---- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant)
FROM Nashville_housing

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN   SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM Nashville_housing

UPDATE Nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN   SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

--------------------------------------------------------------------------
  ---- Remove Duplicates

WITH RowNumCTE AS(
SELECT*, 
  ROW_NUMBER() Over(
      PARTITION BY    ParcelId,
              PropertyAddress,
              SaleDate,
              LegalReference
               Order BY
                UniqueID) row_number
FROM Nashville_housing)
DELETE
FROM RowNumCTE
WHERE row_number >1

WITH RowNumCTE AS(
SELECT*, 
  ROW_NUMBER() Over(
      PARTITION BY    ParcelId,
              PropertyAddress,
              SaleDate,
              LegalReference
               Order BY
                UniqueID) row_number
FROM Nashville_housing)
SELECT *
FROM RowNumCTE
WHERE row_number >1
ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------
  ---- Delete Unused Columns

ALTER TABLE Nashville_housing
DROP COLUMN TaxDistrict

SELECT * 
FROM Nashville_housing
----------------------------------------------------------------------------------------------------------------
