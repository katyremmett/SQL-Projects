
--cleaning data for better usability

Select *
From SQLProject.dbo.nashvillehousing

--Change Date Format-----------------------------------------------------------------------------------------------------------------------------------


ALTER TABLE nashvillehousing
ALTER COLUMN SaleDate DATE;



-- Add Property Addresses where NULL-------------------------------------------------------------------------------------------------------------------

Select *
From SQLProject.dbo.nashvillehousing
--Where PropertyAddress is null
order by ParcelID


--matching parcelid with property address to fill in null values for property address


Select housingA.ParcelID, housingA.PropertyAddress, housingB.ParcelID, housingB.PropertyAddress, ISNULL(housingA.PropertyAddress, housingB.PropertyAddress)
From SQLProject.dbo.nashvillehousing AS housingA
JOIN SQLProject.dbo.nashvillehousing AS housingB
	on housingA.ParcelID = housingB.ParcelID
	AND housingA.UniqueID <> housingB.UniqueID
Where housingA.PropertyAddress is null

UPDATE housingA
SET PropertyAddress = ISNULL(housingA.PropertyAddress, housingB.PropertyAddress)
From SQLProject.dbo.nashvillehousing AS housingA
JOIN SQLProject.dbo.nashvillehousing AS housingB
	on housingA.ParcelID = housingB.ParcelID
	AND housingA.UniqueID <> housingB.UniqueID
Where housingA.PropertyAddress is null



--Separating Address, City, State into different columns-----------------------------------------------------------------------------------------------------


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From SQLProject.dbo.nashvillehousing

ALTER TABLE nashvillehousing
ADD StreetAddress Nvarchar(255);

Update nashvillehousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD PropertyCity Nvarchar(255);

Update nashvillehousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--splitting owner address


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreet
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
From SQLProject.dbo.nashvillehousing

ALTER TABLE nashvillehousing
ADD OwnerStreet Nvarchar(255);

Update nashvillehousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
ADD OwnerCity Nvarchar(255);

Update nashvillehousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashvillehousing
ADD State Nvarchar(255);

Update nashvillehousing
SET State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Making Sold as Vacant consistent----------------------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From SQLProject.dbo.nashvillehousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		Else SoldAsVacant
		END
FROM SQLProject.dbo.nashvillehousing

Update nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		Else SoldAsVacant
		END

--Remove Duplicate Entries------------------------------------------------------------------------------------------------------------

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by 
			UniqueID
			) row_num
From SQLProject.dbo.nashvillehousing
)
Select * -- Swap with Delete to delete extra rows
From RowNumCTE
Where row_num > 1


--Remove unused columns----------------------------------------------------------------------------------------------------------------------

Select *
From SQLProject.dbo.nashvillehousing


ALTER TABLE SQLProject.dbo.nashvillehousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress
