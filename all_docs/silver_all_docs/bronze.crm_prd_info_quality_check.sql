--data quality check ---

select
prd_id ,
count(*) 
from silver.crm_prd_info
group by prd_id 
having count (*) > 1 or prd_id is null 
-----------------------------------------------------------

select

	
	prd_nm
	

from silver.crm_prd_info
where prd_nm != trim (prd_nm) 
------------------------------------------------------------

select

	
	prd_cost
	

from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null 
------------------------------------------------------------------


select

	
	distinct prd_line
	
from silver.crm_prd_info
---------------------------------------------------------
select

    prd_id,
	prd_key,
	prd_start_dt ,
	prd_end_dt
	

from silver.crm_prd_info
where 	prd_end_dt < prd_start_dt ;
-----------------------------------------------------------------

select *
from silver.crm_prd_info
