select 

cid ,
cntry

from bronze.erp_loc_a101



---------------------------------------------------------------------------------
--1) 
select 

len (cid)

from bronze.erp_loc_a101
where len (cid) != 11
------

select 

len (cst_key ) 

from bronze.crm_cust_info
where len (cst_key )  !=  10
---
select 

replace (cid, '-', '') cid ,
cntry

from bronze.erp_loc_a101
where replace (cid, '-', '') not in (select 

cst_key 

from bronze.crm_cust_info
) --> test approved



-----------------------------------------------------------------------------------


select distinct

cntry

from bronze.erp_loc_a101 --- > bad quality  

--- :


select distinct


cntry ,
case
when trim (cntry ) = '' or  cntry is null then  'n/a'
when trim (cntry )  in ('US' ,'USA' ) then  'United States'
when trim (cntry ) = 'DE' then  'Germany'
else trim (cntry)
end as cntry

from bronze.erp_loc_a101

-------------------------



--since we did not changr any ddl in our exsiting tabl so we can insert right away 1




select 

replace (cid, '-', '') cid ,
case
when trim (cntry ) = '' or  cntry is null then  'n/a'
when trim (cntry )  in ('US' ,'USA' ) then  'United States'
when trim (cntry ) = 'DE' then  'Germany'
else trim (cntry)
end as cntry


from bronze.erp_loc_a101
