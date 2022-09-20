--Cleaning Data with SQL queries
select * from [Data cleaning].[dbo].[NashvilleHousing]

order by [UniqueID ]


-----------------------------------------------------------------------------------------------------

--Standardize Date Format
select SaleDate, convert(date,SaleDate) from [Data cleaning].[dbo].[NashvilleHousing]

--update [Data cleaning].[dbo].[NashvilleHousing]
--set SaleDate= convert(date,SaleDate)

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD SaleDateConverted date;

update [Data cleaning].[dbo].[NashvilleHousing]
set SaleDateConverted= convert(date,SaleDate)


-------------------------------------------------------------------------------------------------------------------------


--Populate Property address data 
select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(  A.PropertyAddress,B.PropertyAddress)
from [Data cleaning].[dbo].[NashvilleHousing] as A
left join [Data cleaning].[dbo].[NashvilleHousing] as B
on A.ParcelID=B.parcelID and A.uniqueID!=B.[UniqueID ]
where A.PropertyAddress is null

update A
Set A.PropertyAddress= isnull(  A.PropertyAddress,B.PropertyAddress)
from [Data cleaning].[dbo].[NashvilleHousing] as A
left join [Data cleaning].[dbo].[NashvilleHousing] as B
on A.ParcelID=B.parcelID and A.uniqueID!=B.[UniqueID ]
where A.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------------


--Breaking out Property Address into Individual Columns (Address, City, State) 
select PropertyAddress 
from [Data cleaning].[dbo].[NashvilleHousing]

select substring (PropertyAddress, 1,4) 
from [Data cleaning].[dbo].[NashvilleHousing]
 
select substring(PropertyAddress, 1, (charindex(',', PropertyAddress))-1) as PostalCode,
substring(PropertyAddress, (charindex(',', PropertyAddress))+1, len(PropertyAddress)) as City
from [Data cleaning].[dbo].[NashvilleHousing]

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD PropertySplitAddress nvarchar(255);

update [Data cleaning].[dbo].[NashvilleHousing]
set PropertySplitAddress= substring(PropertyAddress, 1, (charindex(',', PropertyAddress))-1)

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD PropertySplitCity nvarchar(255);

update [Data cleaning].[dbo].[NashvilleHousing]
set PropertySplitCity= substring(PropertyAddress, (charindex(',', PropertyAddress))+1, len(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------


--Breaking out Owner Address into Individual Columns (Address, City, State) 

select * 
from [Data cleaning].[dbo].[NashvilleHousing]

select REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.') , 1)) AS address,
       REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.') , 2)) AS city,
       REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.') , 3)) AS state
from [Data cleaning].[dbo].[NashvilleHousing]

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State 
	from [Data cleaning].[dbo].[NashvilleHousing]

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255);

update [Data cleaning].[dbo].[NashvilleHousing]
set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD OwnerSplitCity nvarchar(255);

update [Data cleaning].[dbo].[NashvilleHousing]
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE [Data cleaning].[dbo].[NashvilleHousing]
ADD OwnerSplitState nvarchar(255);

update [Data cleaning].[dbo].[NashvilleHousing]
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


----------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" column

select  SoldAsVAcant
from [Data cleaning].[dbo].[NashvilleHousing]
where SoldAsVacant='Y'  or SoldAsVacant='N'


update [Data cleaning].[dbo].[NashvilleHousing]  
Set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
when  SoldAsVacant='N' then 'No'
else SoldAsVacant
end 


--------------------------------------------------------------------------------------


--Remove duplicates 

select * from [Data cleaning].[dbo].[NashvilleHousing]

with row_num as (
select *, 
	ROW_NUMBER() over (
		PARTITION BY ParcelID,
					 PropertyAddress, 
					 SaleDate,
					 SalePrice,
					 LegalReference,
					 OwnerName,
					 SaleDateConverted
		order by UniqueID) as RowNo
 from [Data cleaning].[dbo].[NashvilleHousing]
 )
select *  
 from row_num
 where RowNo>1


--Delete unused columns 
Alter Table [Data cleaning].[dbo].[NashvilleHousing]
DROP COLUMN O
       