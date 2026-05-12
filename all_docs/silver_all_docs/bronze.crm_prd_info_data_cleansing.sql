select

	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt

from bronze.crm_prd_info


------------------------------------------------------------------------

-- 1) lets check for dublicate or nulls in primary key | expectition = 0 ---

select
prd_id ,
count(*) 
from bronze.crm_prd_info
group by prd_id 
having count (*) > 1 or prd_id is null 

------------------------------------------------------------------------------
-- 2) is prd_key , we have 2 parts that we need to extartct from prd_key : 
-- if we check our data integration model , we need  cat_id to connect with
-- erp_px_cat_g1v2 << id >> .

select

    prd_key ,
    substring (prd_key , 1 , 5 ) as cat_id 

from bronze.crm_prd_info

-- to connect to
select id from bronze.erp_px_cat_g1v2

--but there is a problem that :  CO-RF   ,   AC_BR -----> we need to re[lace '-' or '_' 


select

    prd_key ,
    replace ( substring (prd_key , 1 , 5 ), '-' , '_' )  as cat_id 

from bronze.crm_prd_info

--test
select

    prd_key ,
    replace ( substring (prd_key , 1 , 5 ), '-' , '_' )  as cat_id 

from bronze.crm_prd_info
where replace ( substring (prd_key , 1 , 5 ), '-' , '_' ) not in 
(select id from bronze.erp_px_cat_g1v2)

--extract part 2 : 

select

    prd_key ,
    substring (prd_key , 7 , len(prd_key) ) as prd_key 

from bronze.crm_prd_info

-- to connect to
select sls_prd_key from bronze.crm_sales_details

--test 

select

    prd_key ,
    substring (prd_key , 7 , len(prd_key)) as prd_key 

from bronze.crm_prd_info

where substring (prd_key , 7 , len(prd_key)) not in (select sls_prd_key from bronze.crm_sales_details) 

--a lot of products thta do not have orders !!

select

    prd_key ,
    substring (prd_key , 7 , len(prd_key)) as prd_key 

from bronze.crm_prd_info

where substring (prd_key , 7 , len(prd_key)) in (select sls_prd_key from bronze.crm_sales_details ) 

-- but  we can match these rows any ways ! 


-------------------------------------------------------------------------------------------------------
--3) unwanted space


select

	
	prd_nm
	

from bronze.crm_prd_info
where prd_nm != trim (prd_nm) 
--------------------------------------------------------------------------------------------------------

--4) nulls or negative numbers 

select

	
	prd_cost
	

from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null 

-- so , if bussiness logic allows we , replace null with zero. 

select

	
	coalesce ( prd_cost , 0 ) as prd_cost
	

from bronze.crm_prd_info




----------------------------------------------------------------------------------------
--5) data consictency
-- in order to be sure about the namigs we need to talk with source system experts .




select

	
	distinct prd_line
	
from bronze.crm_prd_info

----- so here ;ets put toheter what we did : 

select
    prd_id,
	prd_key,
	replace ( substring (prd_key , 1 , 5 ), '-' , '_' )  as cat_id ,
	substring (prd_key , 7 , len(prd_key)) as prd_key ,
	prd_nm,
	coalesce ( prd_cost , 0 ) as prd_cost , 
	
	case upper(trim(prd_line))
	when  'M' then 'Mountain'
	when  'R' then 'Road'
	when  'S' then 'Other sales'
	when  'T' then 'Touring'
	else 'n/a'
	end as prd_line ,

	prd_start_dt,
	prd_end_dt

from bronze.crm_prd_info

--------------------------------------------------------------------------------------

--6) check for invalid dates :

--end dates that are smaller tha nstart dates ! 

select

    prd_id,
	prd_key,
	prd_start_dt ,
	prd_end_dt
	

from bronze.crm_prd_info
where 	prd_end_dt < prd_start_dt ;

--- in order to fix such an issue better to take some exaples and brianstom about the isssue !
-- here is my seloution , we choose 2 prd_key thta the time has problem and after fixing and testing we can refer it to all coulmes : 




select

	prd_id,
	prd_key,
	prd_nm,

    prd_start_dt,
	prd_end_dt  ,

	lead(prd_start_dt)over(partition by prd_key order by prd_start_dt ) -1 as  prd_start_dt_test


from bronze.crm_prd_info 
where prd_key in ( 'AC-HE-HL-U509-R' , 'AC-HE-HL-U509' )

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--now apply to our general code :



select
    prd_id,
	replace ( substring (prd_key , 1 , 5 ), '-' , '_' )  as cat_id ,
	substring (prd_key , 7 , len(prd_key)) as prd_key ,
	prd_nm,
	coalesce ( prd_cost , 0 ) as prd_cost , 
	
	case upper(trim(prd_line))
	when  'M' then 'Mountain'
	when  'R' then 'Road'
	when  'S' then 'Other sales'
	when  'T' then 'Touring'
	else 'n/a'
	end as prd_line ,
	cast (prd_start_dt as date ) as prd_start_dt ,
	cast ( lead(prd_start_dt) over (partition by prd_key order by prd_start_dt )-1 as date  ) as  prd_end_dt 

from bronze.crm_prd_info
