-- Nashville Housing Project 

-- Starting 

-- Cleaning data with SQL Querries 

select * from Project..NashvilleHousing

-- We see sale date is with time and date we will standardize it as it is in date time format 
Select saledate, convert(date, saledate) from Project..NashvilleHousing

update NashvilleHousing set SaleDate = CONVERT(date, saledate)

-- To check the data now 
select saledate from Project..NashvilleHousing 

-- the abpve update query sometimes don't run might be server or sql issue, querry is perfectly fine.. so used another querry

Alter table NashvilleHousing 
add SaleDateConverted date; 

update NashvilleHousing set SaleDateConverted = CONVERT(date, saledate)

select SaleDateConverted from Project..NashvilleHousing

select * from Project..NashvilleHousing

-- Populate Property address
-- Let's check which address are null 

select * from Project..NashvilleHousing where PropertyAddress is null

select Nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress
from Project..NashvilleHousing NH1
join Project..NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID
and NH1.[UniqueID ] != NH2.[UniqueID ]
where NH1.PropertyAddress is null

-- by the above querry we can see that we have the addresses of the null values using parcel ID and we can fill them 
-- so we will create a column with the same property address which are currently null and then update it

select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from Project..NashvilleHousing NH1
join Project..NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID
and NH1.[UniqueID ] != NH2.[UniqueID ]
where NH1.PropertyAddress is Null 

-- To populate the table, we can use the above command with update and set and then to check run the above querry again

update NH1
Set PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
from Project..NashvilleHousing NH1
join Project..NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID
and NH1.[UniqueID ] != NH2.[UniqueID ]
where NH1.PropertyAddress is Null 

-- Now separate the address in separate columns 
-- If we look at the data in address columns, we can see that there is a "," delimeter and we can separate the column on he bases of that 

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as AddressofProperty
, substring(PropertyAddress, charindex(',',PropertyAddress) +1, LEN(PropertyAddress)) as PropertyCity 
from Project..NashvilleHousing

-- Now as to update these twi new columns we will alter table and then add it 
--sometimes alter table and update comand runs with project..tablename as it will not recognize the table name alone 

Alter table project..NashvilleHousing
add AddressOfProperty Nvarchar(255)

Update project..NashvilleHousing
Set AddressOfProperty = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

Alter Table project..NashvilleHousing
add PropertyCity Nvarchar(255)

update project..NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

Select * from Project..NashvilleHousing

-- Now to separate owner address 
-- The another way of separation is by using parsename function but it only runs on '.' not on ',' so we will replace the comma
-- Syntax for PARSENAME is PARSENAME(Columnname, 1) and it truns from back so 1 mans here is State 

select 
PARSENAME(replace(OwnerAddress, ',','.'), 3),
PARSENAME(replace(OwnerAddress, ',','.'), 2),
PARSENAME(replace(OwnerAddress, ',','.'), 1)
from Project..NashvilleHousing

-- Now to Alter and update 

Alter table Project..NashvilleHousing
add AddressOfOwner Nvarchar(255)

Update project..NashvilleHousing 
set AddressOfOwner = PARSENAME(replace(OwnerAddress, ',','.'), 3)

Alter Table Project..NashvilleHousing
add OwnerCity Nvarchar(255)

Update Project..NashvilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress, ',','.'), 2)

Alter table Project..NashvilleHousing
add OwnerState Nvarchar(255)

Update Project..NashvilleHousing
set OwnerState = PArsename(replace(OwnerAddress, ',','.'), 1)

Select * from Project..NashvilleHousing

-- Let's check sold as vacant column 
select distinct(SoldAsVacant), COUNT(SoldAsVacant) 
from Project..NashvilleHousing
group by SoldAsVacant
order by COUNT(SoldAsVacant)

--As checked we have to change the values of Y and N to Yes and No respectively 

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 End
from Project..NashvilleHousing

update Project..NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						End

Select distinct SoldAsVacant from Project..NashvilleHousing

-- Remove duplicates from the data 
-- We will do it by CTE 

with RowNumCTE As(
select *, row_number() over(
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by uniqueID) row_num 
from project..NashvilleHousing
--order by parcelID
)
Select * from RowNumCTE where row_num > 1
order by PropertyAddress
 
-- We see that we have duplicate rows so we will delete them using the above querry 
with RowNumCTE As(
select *, row_number() over(
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by uniqueID) row_num 
from project..NashvilleHousing
--order by parcelID
)
delete from RowNumCTE where row_num > 1
--order by PropertyAddress
 

 -- Now we will delete some unused column 
 -- Usually we do not do it on the raw data as we may require is again 

 Alter table project..NashvilleHousing 
 drop column PropertyAddress, Saledate, TaxDistrict, OwnerAddress

 Select * from Project..NashvilleHousing