select

*

from bronze.crm_cust_info




-- 1) locate duplicates in primary key  |  expectation is no resluts ---
select

cst_id ,
count(*) 

from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null




-------------------------------------------------------------

-- 2) remove duplicates from primary key with testing an example-- 

select 
*

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info


)t where rn = 1 and cst_id = 29466


/*===================================================================================================*/
--3) check unwanted value like space in strings   | expectation is no results ---

select

cst_firstname

from bronze.crm_cust_info
where cst_firstname  != trim(cst_firstname)


--lastname-- 

select

cst_lastname

from bronze.crm_cust_info
where cst_lastname  != trim(cst_lastname)

--gender  , result = 0 --

select

cst_gndr

from bronze.crm_cust_info
where cst_gndr  != trim(cst_gndr)

--- marital status , result = 0  --

select

cst_marital_status

from bronze.crm_cust_info
where cst_marital_status  != trim(cst_marital_status)

/*===================================================================================================*/
------------ lets clean up unwanted spaces + cleaned primary key --------------------------------------

select 
cst_id ,
cst_key ,
trim(cst_firstname) as cst_firstame ,
trim(cst_lastname) as cst_lastname,
cst_marital_status ,
cst_gndr ,
cst_create_date

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info
where cst_id is not null               -- remove nulls from primary key which i added --
)t where rn = 1 

----------------------------------------------------------------------------------------------------
/*==================================================================================================*/
--lets check data consistency --

select 

distinct cst_gndr

from bronze.crm_cust_info

-- in out data better to store clear data like , f = female --


-- lets applay it on the general code ---

select 
cst_id ,
cst_key ,
trim(cst_firstname) as cst_firstame ,
trim(cst_lastname) as cst_lastname,
cst_marital_status ,
case
when trim (upper (cst_gndr)) = 'F' then 'Female'
when trim (upper (cst_gndr)) = 'M' then 'Male'
else 'n/a'
end as cst_gndr ,
cst_create_date

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info
where cst_id is not null              
)t where rn = 1 

-- lets  do the same for marital status aslo --


select 
cst_id ,
cst_key ,
trim(cst_firstname) as cst_firstame ,
trim(cst_lastname) as cst_lastname,


case
when upper (trim (cst_marital_status)) = 'M' then 'Married'
when upper (trim (cst_marital_status)) = 'S' then 'Single'
else 'n/a'
end as cst_marital_status ,

case
when upper (trim (cst_gndr)) = 'F' then 'Female'
when upper (trim (cst_gndr)) = 'M' then 'Male'
else 'n/a'
end as cst_gndr ,
cst_create_date

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info
where cst_id is not null              
)t where rn = 1 

/*=======================================================================================*/


SELECT cst_create_date
FROM bronze.crm_cust_info
WHERE cst_create_date IS NULL;


SELECT 

coalesce ( cst_create_date , '1900-01-01')

FROM bronze.crm_cust_info
-------------------------------------------------------------------------------------------------------------
--fianl stage-- 







select 
cst_id ,
cst_key ,
trim(cst_firstname) as cst_firstame ,
trim(cst_lastname) as cst_lastname,
cst_marital_status ,
case
when trim (upper (cst_gndr)) = 'F' then 'Female'
when trim (upper (cst_gndr)) = 'M' then 'Male'
else 'n/a'
end as cst_gndr ,
cst_create_date

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info
where cst_id is not null              
)t where rn = 1 

-- lets  do the same for marital status aslo --


select 
cst_id ,
cst_key ,
trim(cst_firstname) as cst_firstame ,
trim(cst_lastname) as cst_lastname,


case
when upper (trim (cst_marital_status)) = 'M' then 'Married'
when upper (trim (cst_marital_status)) = 'S' then 'Single'
else 'n/a'
end as cst_marital_status ,

case
when upper (trim (cst_gndr)) = 'F' then 'Female'
when upper (trim (cst_gndr)) = 'M' then 'Male'
else 'n/a'
end as cst_gndr ,
coalesce ( cst_create_date , '1900-01-01') as cst_create_date

from (
select

* ,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

from bronze.crm_cust_info
where cst_id is not null              
)t where rn = 1 
