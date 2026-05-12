

INSERT INTO silver.crm_cust_info (

cst_id ,
cst_key ,
cst_firstname ,
cst_lastname,
cst_marital_status ,
cst_gndr ,
cst_create_date
)

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
