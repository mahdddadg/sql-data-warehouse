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

---------------------------------------------------------------

select

cst_firstname

from silver.crm_cust_info
where cst_firstname  != trim(cst_firstname)


--lastname-- ---------------------------------------------

select

cst_lastname

from silver.crm_cust_info
where cst_lastname  != trim(cst_lastname)

-----------------------------------------------
select 

distinct cst_gndr

from silver.crm_cust_info
------------------------------------------------
