select 

cid,
bdate,
gen

from bronze.erp_cust_az12

-------------------------> by checking out integration we will undsrand that we need to make some chages in order to connect the two table s:
--1) id 

select
cst_key
from bronze.crm_cust_info


select 
cid
from bronze.erp_cust_az12
where cid like '%AW00011001%'


select 

case 
when cid like 'NAS%' then substring (cid , 4 , len(cid))
else cid
end cid ,
bdate,
gen

from bronze.erp_cust_az12

--test --

select 

*

from bronze.erp_cust_az12

where 

case 
when cid like 'NAS%' then substring (cid , 4 , len(cid))
end 
not in (select cst_key from bronze.crm_cust_info) ---> works fine

-----------------------------------------------------------------------
--2)  birthadte

select 

cid,
bdate,
gen

from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate() 



select 

case 
when cid like 'NAS%' then substring (cid , 4 , len(cid))
else cid
end cid ,

case 
when bdate < '1924-01-01' or bdate > getdate() then  null 
else bdate 
end bdate,

bdate,
gen


from bronze.erp_cust_az12

----------------------------------------------------------------------------
--- 3) gen



select 

case 
when cid like 'NAS%' then substring (cid , 4 , len(cid))
else cid
end cid ,

case 
when bdate < '1924-01-01' or bdate > getdate() then  null 
else bdate 
end bdate,


gen


from bronze.erp_cust_az12
----------------------------------------------------------

select distinct
gen
from bronze.erp_cust_az12 -- > problem 



select distinct

gen ,
case 
when upper(trim(gen)) in ( 'F' , 'FEMALE' ) then 'Female'
when upper(trim(gen)) in ( 'M' , 'MALE' ) then 'Male'
else'n/a'
end as gen

from bronze.erp_cust_az12


----------------------------------------------
-- we did not vhange any ddl base so , table says by defalut thta we ,ade in bronze layaer 



select 

case 
when cid like 'NAS%' then substring (cid , 4 , len(cid))
else cid
end cid ,

case 
when bdate < '1924-01-01' or bdate > getdate() then  null 
else bdate 
end bdate,


case 
when upper(trim(gen)) in ( 'F' , 'FEMALE' ) then 'Female'
when upper(trim(gen)) in ( 'M' , 'MALE' ) then 'Male'
else'n/a'
end as gen


from bronze.erp_cust_az12
