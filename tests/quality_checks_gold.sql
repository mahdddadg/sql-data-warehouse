---1---
/*==============================================================================
    GOLD.DIM_CUSTOMERS — DATA VALIDATION & TRANSFORMATION CHECKS
================================================================================

Purpose:
    Validate and prepare customer dimension data before creating the GOLD layer
    dimension view.

Validation & Design Steps:
    1. Check for duplicate customer IDs to ensure source key uniqueness.
    2. Resolve duplicate gender sources between CRM and ERP systems.
       - CRM gender is treated as the master source.
       - ERP gender is used only when CRM value = 'n/a'.
    3. Rename columns using standardized snake_case naming convention.
    4. Organize columns logically for readability and business usability.
    5. Confirm table type:
       - This is a DIMENSION table.
    6. Generate a surrogate key using ROW_NUMBER().

Data Sources:
    - silver.crm_cust_info
    - silver.erp_cust_az12
    - silver.erp_loc_a101 */

select


row_number() over(order by cst_id  ) as customer_key , 
ci.cst_id as customer_id ,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.CNTRY as country,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is master 
else coalesce(ca.gen , 'n/a')
end as  gender,
ci.cst_marital_status as marital_status,
ca.BDATE as birthdate ,
ci.cst_create_date as create_date



from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ca.cid = ci.cst_key
left join silver.erp_loc_a101 as la
on la.cid = ci.cst_key




--->1) lets check the deplicate in the primary key 
--->2)   we have 2 gender lets fix it , which one is madter table ? crm or erp 
--->3)   rename based on snack rule 
---> 4) check the order of colums 
----> 5) check whether we have afact table or dimantios table 
---> 6) check if we need t ogenerate a surrogate key 

--1 



select

	cst_id , 
	count (*) 

from ( 

select

	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.BDATE,
	ca.GEN ,
	la.CNTRY

from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ca.cid = ci.cst_key
left join silver.erp_loc_a101 as la
on la.cid = ci.cst_key
)t group by cst_id
having count(*) >1




--2


select distinct


ci.cst_gndr,
ca.GEN ,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is master 
else coalesce(ca.gen , 'n/a')
end as new_gen


from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ca.cid = ci.cst_key
left join silver.erp_loc_a101 as la
on la.cid = ci.cst_key
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------
---2---
/*==============================================================================
    GOLD.DIM_PRODUCTS — DATA VALIDATION & TRANSFORMATION CHECKS
================================================================================

Purpose:
    Validate and prepare product dimension data before creating the GOLD layer
    dimension view.

Validation & Design Steps:
    1. Filter active products only:
       - prd_end_dt IS NULL indicates the product is currently active.
       - Non-NULL values represent historical/inactive products.
    2. Validate uniqueness of product business key (prd_key).
    3. Group related attributes logically.
    4. Check for duplicated business information.
    5. Rename columns using business-friendly naming conventions.
    6. Confirm table type:
       - This is a DIMENSION table.
    7. Generate a surrogate product key.
    8. Build the final GOLD view.

Data Sources:
    - silver.crm_prd_info
    - silver.erp_px_cat_g1v2
==============================================================================*/

  
--1 ) if prd_end_dt -- > is null it means product still is in process , if there is date means
-- it is a history of porducts .
-- 2 ) lets check that primary key is unique .
-- 3 ) lets group up realted colums toghether .
-- 4) check if we have the asme information toice --- > no in this case 
--5) friendly and busiiness accepted names fro columns 
--6) is it a fact or dimention table ? -- > dimention 
--> 7) generate a primery key 
--> 8) last step is to build the view ! 


select
prd_key  ,
count (*) 
from (
select

prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt ,
pc.cat ,
pc.subcat ,
pc.maintenance


from silver.crm_prd_info as pn 
left join silver.erp_px_cat_g1v2 as pc
on pn.cat_id = pc.id
where prd_end_dt is null

)t group by prd_key
having count (*) >1  -- > approved 
----------------------------


create view gold.dim_products as 


select

row_number () over (order by pn.prd_start_dt  , pn.prd_key ) as product_key , 
pn.prd_id as product_id ,
pn.prd_key as  product_number,
pn.prd_nm as product_name ,
pn.cat_id as category_id ,
pc.cat  as category,
pc.subcat as subcategory,
pc.maintenance ,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date





from silver.crm_prd_info as pn 
left join silver.erp_px_cat_g1v2 as pc
on pn.cat_id = pc.id
where prd_end_dt is null
-----------------------------------------------------------------------------------------------------------------------------------
---3---
  /*==============================================================================
    GOLD.FACT_SALES — FACT TABLE DESIGN & LOOKUP PROCESS
================================================================================

Purpose:
    Create the central FACT table containing transactional sales data.

Design Notes:
    1. Confirm table type:
       - This is a FACT table.
       - It references multiple dimension tables.
    2. Perform data lookup operations:
       - Connect sales transactions to dimension surrogate keys.
       - Lookup customer_key from gold.dim_customers.
       - Lookup product_key from gold.dim_products.
    3. Build the final analytical sales view.

Lookup Logic:
    - sls_cust_id  -> customer_key
    - sls_prd_key  -> product_key

Data Sources:
    - silver.crm_sales_details
    - gold.dim_customers
    - gold.dim_products
==============================================================================*/
  
  -- 1) is it fact or dimention ----- > fact , which is made of diffrent dimentions ..
-- 2 ) here we have a neccessary step ' data lookup ' which will allow us to coonect
--  fact table to the other gold layers ( here we have 2 views ) .
-- > make the view 

create view gold.facts_sales as 
select

sd.sls_ord_num as order_number,
pr.product_key,                --sls_prd_key--> for lookup
cu.customer_key,               --sls_cust_id--> for lookup
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quality,
sd.sls_price as price 


from silver.crm_sales_details as sd
left join gold.dim_customers as cu
on sd.sls_cust_id = cu.customer_id
left join gold.dim_products as pr
on sd.sls_prd_key = pr.product_number
