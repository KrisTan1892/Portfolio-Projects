--Cleaning Data in SQL Series

Select *
From Nashiville_Housing


--Standardize Date Format

Select Sale_Date_Converted, Convert(date, Saledate) 
From Nashiville_Housing


Update Nashiville_Housing
Set Sale_Date_Converted = Cast(Saledate as date) 

--Note: Update didnt work, 
--DI MO GANA ANG CONVERT WHEN UPDATING IDK WHY

Alter Table Nashiville_Housing
ADD Sale_Date_Converted Date;
  
Update Nashiville_Housing
Set Sale_Date_Converted = Cast(Saledate as date) 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Populate Property Address data

--Problem: There are null values in Property Address so something we can do to fix this issue is that
--we are going to populate the Parcel ID's Property Address to the rows that have null values since there are duplicate values in Parcel ID
 
Select *
From Nashiville_Housing
--Where PropertyAddress is null 
Where ParcelID = '033 15 0 123.00'


--This query solved the problem Solved
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashiville_Housing a
Join Nashiville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashiville_Housing a
Join Nashiville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--DONE!
select [UniqueID ], ParcelID, PropertyAddress
From Nashiville_Housing
Where PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Nashiville_Housing

--Going to separate the property address using the delimeter. the COMMA is our delimter

Select PropertyAddress
From Nashiville_Housing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
From Nashiville_Housing

--Still haven't figured this one out. use parsename nalang
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From Nashiville_Housing

--Adding to new column from the Address 

Alter Table Nashiville_Housing
ADD Property_Split_Address Nvarchar(255);
  
Update Nashiville_Housing
Set Property_Split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter Table Nashiville_Housing
ADD Property_Split_City Nvarchar(255);

Update Nashiville_Housing
Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

--Worked out well!
Select *
From Nashiville_Housing

Select Property_Split_Address, Property_Split_City
From Nashiville_Housing
-----------------------------------------------------------------------------------

--Now trying to do the same but more simple in /OwnerAddress Column/

Select ParcelID, OwnerAddress
From Nashiville_Housing


--PARSENAME is useful with periods so we combine it by REPLACE

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
From Nashiville_Housing


--PARSENAME does everything backwards 
Select 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
From Nashiville_Housing
--Where OwnerAddress is not null

Alter Table Nashiville_Housing
ADD Owner_Split_Address Nvarchar(255);
  
Update Nashiville_Housing
Set Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

Alter Table Nashiville_Housing
ADD Owner_Split_City Nvarchar(255);
  
Update Nashiville_Housing
Set Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2) 
 
Alter Table Nashiville_Housing
ADD Owner_Split_State Nvarchar(255);
  
Update Nashiville_Housing
Set Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)

--Worked out well!!
Select *
From Nashiville_Housing
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


--Changing Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldasVacant), COUNT(SoldasVacant)
From Nashiville_Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, Case
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End as Sold_As_Vacant
From Nashiville_Housing


Update Nashiville_Housing
Set SoldAsVacant = Case
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End 

Select *
From Nashiville_Housing
-----------------------------------------------------------------------------------------------------------------------------------------------------------------



--Remove Duplicates
--USING CTE's, Temp Tables and Windows Functions

--Deleting duplicates using CTE
WITH RowNuMCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as Row_Number
				
From Nashiville_Housing
--Order by ParcelID
)
DELETE
From RowNuMCTE
Where Row_Number > 1

--No more Duplicates!
WITH RowNuMCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as Row_Number
				
From Nashiville_Housing
--Order by ParcelID
)
Select *
From RowNuMCTE
Where Row_Number > 1



--Delete Unused Columns

Alter Table Nashiville_Housing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

Alter Table Nashiville_Housing
DROP COLUMN saledate

Select *
From Nashiville_Housing