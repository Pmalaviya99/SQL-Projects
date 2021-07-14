SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing


-- Standardize date format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM [Portfolio Project].dbo.Nashvillehousing

ALTER TABLE [Portfolio Project].dbo.Nashvillehousing
ADD SaleDateConverted date

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM [Portfolio Project].dbo.Nashvillehousing

-------------------------------------------------------------------------------------------



-- Populate null addresses

SELECT PropertyAddress FROM
[Portfolio Project].dbo.Nashvillehousing
WHERE PropertyAddress IS NULL

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL

SELECT ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL

UPDATE b
SET b.PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [Portfolio Project].dbo.Nashvillehousing a
JOIN [Portfolio Project].dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------



-- Combining bedrooms and bathrooms

SELECT Bedrooms, FullBath, Halfbath
FROM [Portfolio Project].dbo.Nashvillehousing

SELECT Bedrooms, Fullbath, Halfbath, CONCAT(Bedrooms, ' and ', Fullbath, '+', Halfbath)
FROM [Portfolio Project].dbo.Nashvillehousing

ALTER TABLE [Portfolio Project].dbo.Nashvillehousing
ADD Bed_bathroom nvarchar(100)

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET Bed_bathroom = CONCAT(Bedrooms, ' and ', Fullbath, '+', Halfbath)

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing

-------------------------------------------------------------------------------------------



-- Breaking out address into individual Columns (Res-Number, Address, city)

SELECT PropertyAddress FROM
[Portfolio Project].dbo.Nashvillehousing

SELECT PropertyAddress,
SUBSTRING (PropertyAddress, 1, CHARINDEX(' ', PropertyAddress))
FROM
[Portfolio Project].dbo.Nashvillehousing

SELECT PropertyAddress,
SUBSTRING (PropertyAddress, 1, CHARINDEX(' ', PropertyAddress) - 1),
SUBSTRING (PropertyAddress, CHARINDEX(' ', PropertyAddress) + 1, CHARINDEX(',', PropertyAddress) - CHARINDEX(' ', PropertyAddress) + 1),
RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))
FROM
[Portfolio Project].dbo.Nashvillehousing

ALTER TABLE [Portfolio Project].dbo.Nashvillehousing
ADD Resident_Numb varchar(100),
	StrAdd varchar(155),
	Tow varchar (155)

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET Resident_Numb = SUBSTRING (PropertyAddress, 1, CHARINDEX(' ', PropertyAddress) - 1),
	StrAdd = SUBSTRING (PropertyAddress, CHARINDEX(' ', PropertyAddress) + 1, CHARINDEX(',', PropertyAddress) - CHARINDEX(' ', PropertyAddress) + 1),
	Tow = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))
FROM [Portfolio Project].dbo.Nashvillehousing

ALTER TABLE [Portfolio Project].dbo.Nashvillehousing
DROP COLUMN Ci, StreetAddr, Res_Numb, Cit, StreetAdd, Res_Num, City, StreetAddress, Res_Number

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing

-------------------------------------------------------------------------------------------



-- Splitting Owner's address

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.Nashvillehousing

ALTER TABLE [Portfolio Project].dbo.Nashvillehousing
ADD Own_Address varchar(100),
	Own_city varchar(155),
	Own_state varchar (155)

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET Own_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	Own_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	Own_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.Nashvillehousing

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing

-------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No

SELECT DISTINCT SoldAsVacant
FROM [Portfolio Project].dbo.Nashvillehousing

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant, 'N', 'No') 
WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
ELSE SoldAsVacant
END AS Uniformed_SAV
FROM [Portfolio Project].dbo.Nashvillehousing

SELECT SoldAsVacant, Uniformed_SAV
FROM 
(SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant, 'N', 'No') 
WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
ELSE SoldAsVacant
END AS Uniformed_SAV
FROM [Portfolio Project].dbo.Nashvillehousing) S2
WHERE SoldAsVacant IN ('Y', 'N')

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant, 'N', 'No') 
WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant, 'Y', 'Yes')
ELSE SoldAsVacant
END

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing
WHERE SoldAsVacant IN ('Y', 'N')

-------------------------------------------------------------------------------------------



-- Remove duplicates

SELECT * FROM
[Portfolio Project].dbo.Nashvillehousing

WITH S4 AS
(SELECT *, ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					OwnerName,
					LegalReference
					ORDER BY UniqueID) AS Row_Num
FROM
[Portfolio Project].dbo.Nashvillehousing)

SELECT Row_Num, COUNT(Row_Num)
FROM S4
GROUP BY Row_Num

DELETE 
FROM S4
WHERE Row_Num > 1

WITH S4 AS
(SELECT *, ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					OwnerName,
					LegalReference
					ORDER BY UniqueID) AS Row_Num
FROM
[Portfolio Project].dbo.Nashvillehousing)

SELECT *
FROM S4 
WHERE Row_Num > 1

-------------------------------------------------------------------------------------------



-- Filter NULLS from LandValue

SELECT LandValue, COALESCE(LandValue, 1) AS Non_null
FROM [Portfolio Project].dbo.Nashvillehousing

SELECT COUNT(LandValue), COUNT(Non_null)
FROM 
(SELECT LandValue, COALESCE(LandValue, 1) AS Non_null
FROM [Portfolio Project].dbo.Nashvillehousing)

SELECT ISNULL(LandValue, 0)
FROM [Portfolio Project].dbo.Nashvillehousing

UPDATE [Portfolio Project].dbo.Nashvillehousing
SET LandValue = ISNULL(LandValue, 0)

SELECT * FROM 
[Portfolio Project].dbo.Nashvillehousing
WHERE LandValue IS NULL

-------------------------------------------------------------------------------------------




