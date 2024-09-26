/** cleaning data in SQL queries**//

SELECT * FROM [Portfolio Project].[dbo].[Nashville Housing Data]

---standardize date format--

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM [Portfolio Project].[dbo].[Nashville Housing Data]

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD SaleDateconverted DATE;

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET SaleDateconverted = CONVERT(Date,SaleDate)

SELECT SaleDateconverted,CONVERT(Date,SaleDate)
FROM [Portfolio Project].[dbo].[Nashville Housing Data]

---Populate property address data

SELECT *
FROM [Portfolio Project].[dbo].[Nashville Housing Data]
----WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].[dbo].[Nashville Housing Data] AS a
JOIN [Portfolio Project].[dbo].[Nashville Housing Data] AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].[dbo].[Nashville Housing Data] AS a
JOIN [Portfolio Project].[dbo].[Nashville Housing Data] AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL;

----Breaking out address into individual columns(address,city,state)
SELECT PropertyAddress
FROM [Portfolio Project].[dbo].[Nashville Housing Data]

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].[dbo].[Nashville Housing Data]

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD Propertysplitaddress NVARCHAR(255);

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET Propertysplitaddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 )

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD Propertysplitcity NVARCHAR(255);

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET Propertysplitcity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM 
[Portfolio Project].[dbo].[Nashville Housing Data]

----splittin owner address

SELECT OwnerAddress FROM 
[Portfolio Project].[dbo].[Nashville Housing Data]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM 
[Portfolio Project].[dbo].[Nashville Housing Data]

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD ownersplitaddress NVARCHAR(255);

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD ownersplitcity NVARCHAR(255);

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET ownersplitcity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
ADD ownersplitstate NVARCHAR(5);

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET ownersplitstate  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM 
[Portfolio Project].[dbo].[Nashville Housing Data]

----change Y and N to Yes and No in "Sold as vacant field'

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [Portfolio Project].[dbo].[Nashville Housing Data]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
   CASE WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
	ELSE 	SoldAsVacant
	END
FROM [Portfolio Project].[dbo].[Nashville Housing Data]

UPDATE [Portfolio Project].[dbo].[Nashville Housing Data]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
	ELSE 	SoldAsVacant
	END

---Remove duplicates
WITH RownumCTE AS (
SELECT *,
  ROW_NUMBER() OVER (
             PARTITION BY ParcelID,
             PropertyAddress,
			  CAST (SalePrice AS NVARCHAR(100)),
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID)
			   AS row_num
FROM [Portfolio Project].[dbo].[Nashville Housing Data]
----ORDER BY ParcelID)
)                            
----SELECT *
DELETE FROM
 RownumCTE
WHERE row_num >1
---ORDER BY PropertyAddress

-----delete unused columns
SELECT * FROM 
[Portfolio Project].[dbo].[Nashville Housing Data]

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing Data]
DROP COLUMN SaleDate
