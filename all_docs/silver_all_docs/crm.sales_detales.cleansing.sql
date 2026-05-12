select 

sls_ord_num ,
sls_prd_key ,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt , 
sls_sales , 
sls_quantity ,
sls_price


from bronze.crm_sales_details

-----------------------------------------------------------------------------------------------
--1)
select 

sls_ord_num 

from bronze.crm_sales_details
where sls_ord_num != trim(sls_ord_num )
----------------------------------------------------------------------------------------------
--2)
--lets check the keys to connect tables :

select 
sls_prd_key 
from bronze.crm_sales_details
where sls_prd_key  not in (select prd_key   from silver.crm_prd_info) -- approved , no issues

select 
sls_cust_id
from bronze.crm_sales_details
where sls_cust_id  not in (select cst_id   from silver.crm_cust_info)-- also approved , no issues


-------------------------------------------------------------------------------------------------------------
-- convert int to date : 

select 

nullif ( sls_order_dt , 0 ) as sls_order_dt

from bronze.crm_sales_details
where sls_order_dt <= 0   --- we have  zero but not negative , lets replace null with zero


----
select 

nullif ( sls_order_dt , 0 ) as sls_order_dt

from bronze.crm_sales_details
where sls_order_dt <= 0 or len(sls_order_dt ) != 8  -- problem there is  ,  2 bad data quality 
----

select 

nullif ( sls_order_dt , 0 ) as sls_order_dt

from bronze.crm_sales_details
where sls_order_dt <= 0  or sls_order_dt > 20261229  -- here is ok
--- final 


select 

sls_ord_num ,
sls_prd_key ,
sls_cust_id ,

case when sls_order_dt = 0 or len( sls_order_dt ) != 8 then null
else cast ( cast (sls_order_dt as varchar ) as date ) 
end as sls_order_dt,                         --- in sql no direct cast from int to date ! first to nvarvhar then date )))
-----------------------------
case when sls_ship_dt = 0 or len( sls_ship_dt ) != 8 then null
else cast ( cast (sls_ship_dt as varchar ) as date ) 
end as sls_ship_dt ,

case when sls_due_dt = 0 or len( sls_due_dt ) != 8 then null
else cast ( cast (sls_due_dt as varchar ) as date ) 
end as sls_due_dt , 
------------------------------------------------------------ > i expalin below 
sls_sales ,		
sls_quantity ,
sls_price


from bronze.crm_sales_details
---------------------------------------------------------------------------------------------------------

select 

sls_ship_dt 

from bronze.crm_sales_details 
where sls_ship_dt is null or  sls_ship_dt = 0
----
select 

sls_ship_dt 

from bronze.crm_sales_details 
where sls_ship_dt > 20261229 or sls_ship_dt < 20001229
-------
select 

sls_ship_dt 

from bronze.crm_sales_details 
where len ( sls_ship_dt ) != 8
-----------------------------------
-- anyways we apply the same rules on sls_ship_dt and sles_due_dt
----------------------------------------------------------------------------

--now it does not make sensce to have shipping orders > than orders !!
--lets check :


select 

sls_ord_num ,
sls_prd_key ,
sls_cust_id ,

case when sls_order_dt = 0 or len( sls_order_dt ) != 8 then null
else cast ( cast (sls_order_dt as varchar ) as date ) 
end as sls_order_dt,                         --- in sql no direct cast from int to date ! first to nvarvhar then date )))

case when sls_ship_dt = 0 or len( sls_ship_dt ) != 8 then null
else cast ( cast (sls_ship_dt as varchar ) as date ) 
end as sls_ship_dt ,

case when sls_due_dt = 0 or len( sls_due_dt ) != 8 then null
else cast ( cast (sls_due_dt as varchar ) as date ) 
end as sls_due_dt , 
sls_sales ,		
sls_quantity ,
sls_price


from bronze.crm_sales_details

--------------------------------------------------

select 
*
from bronze.crm_sales_details 
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt -- > well it's ok @\\




------------------------------------------------------------------

select 


sls_sales ,		
sls_quantity ,
sls_price


from bronze.crm_sales_details --  >here we can udrestand the busiiness logic :

-- totall_sales = quantity * price
-- no negative , zero , nulls are allowed 
-- and in real world projects this requiers to have talk with specialist .


select 


sls_sales ,		
sls_quantity ,
sls_price  ,

case
when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs (sls_price ) 
then sls_quantity * abs (sls_price ) 
else sls_sales
end as sls_sales ,

case 
when sls_price is null or sls_price <= 0 then  sls_sales / coalesce (sls_quantity , 0)
else sls_price
end as sls_price ,



from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null 
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0 

----- > noe lets add the cleaned data to our datacase 


select 

sls_ord_num ,
sls_prd_key ,
sls_cust_id ,

case when sls_order_dt = 0 or len( sls_order_dt ) != 8 then null
else cast ( cast (sls_order_dt as varchar ) as date ) 
end as sls_order_dt,                         --- in sql no direct cast from int to date ! first to nvarvhar then date )))

case when sls_ship_dt = 0 or len( sls_ship_dt ) != 8 then null
else cast ( cast (sls_ship_dt as varchar ) as date ) 
end as sls_ship_dt ,

case when sls_due_dt = 0 or len( sls_due_dt ) != 8 then null
else cast ( cast (sls_due_dt as varchar ) as date ) 
end as sls_due_dt , 

case
when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs (sls_price ) 
then sls_quantity * abs (sls_price ) 
else sls_sales
end as sls_sales ,


sls_quantity ,

case 
when sls_price is null or sls_price <= 0 then  sls_sales / coalesce (sls_quantity , 0)
else sls_price
end as sls_price


from bronze.crm_sales_details
