
/*  

/*
===============================================================================
Silver Layer Data Quality & Validation Checks
===============================================================================


    This script is used to validate and test data quality in the silver layer
    after the transformation process from bronze to silver.

    It performs several checks to ensure data accuracy, consistency, and
    business rule compliance, including:

    - Checking for duplicate records and null primary keys
    - Validating trimmed text fields (first name, last name, product name)
    - Verifying standardized values such as gender and product line
    - Checking for invalid or negative product costs
    - Validating product start and end dates
    - Ensuring sales order dates, shipping dates, and due dates are correct
    - Validating sales calculations using quantity × price = sales amount

    These tests help confirm that the silver layer contains clean,
    reliable, and analysis-ready data before moving to the gold layer.

Usage:
    Run the script after loading data into the silver schema.

===============================================================================
*/





*/



--------------------------------------------------------------------------------- > silver.crm_cust_info
select
*
from silver.crm_cust_info


---now lwts check the qiality of silver with  the same code we used on bronze ---

select

cst_id ,
count(*) 

from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-------------------------------------------------

select

cst_firstname

from silver.crm_cust_info
where cst_firstname  != trim(cst_firstname)


--lastname-- -----------------------------------

select

cst_lastname

from silver.crm_cust_info
where cst_lastname  != trim(cst_lastname)

----------------------------------------------
select 

distinct cst_gndr

from silver.crm_cust_info
-----------------------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------- > silver.crm_prd_info


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
--------------------------------------------------------------


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
---------------------------------------------------------

select *
from silver.crm_prd_info
---------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------- > silver.crm_sales_details



---quality check ---
select 
*
from silver.crm_sales_details


--------
select 
*
from silver.crm_sales_details 
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-------------

select 


sls_sales ,		
sls_quantity ,
sls_price  

from silver.crm_sales_details 
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null 
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0 

------------


select *
from silver.crm_sales_details
