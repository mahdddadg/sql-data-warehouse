/*
===============================================================================
 Script Name : Gold Layer Dimension & Fact Views
 Layer       : GOLD
 Author      : mahdi dehlaghi 
 Purpose     : Create analytical dimension and fact views for reporting and BI.

 Description :
 This script creates the following GOLD layer views:

 1. gold.dim_customers
    - Stores enriched customer information.
    - Combines CRM customer data with ERP demographic and location data.
    - Generates surrogate customer keys for dimensional modeling.

 2. gold.dim_products
    - Stores product-related information and attributes.
    - Enriches product data with category and maintenance information.
    - Includes only active products (where prd_end_dt is NULL).
    - Generates surrogate product keys.

 3. gold.fact_sales
    - Stores transactional sales data.
    - Links customer and product dimensions using surrogate keys.
    - Designed for analytical querying and reporting.

 Data Sources :
    - silver.crm_cust_info
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.crm_prd_info
    - silver.erp_px_cat_g1v2
    - silver.crm_sales_details

 Notes :
    - ROW_NUMBER() is used to generate surrogate keys.
    - LEFT JOINs are used to preserve source transactional integrity.
    - CRM gender data is prioritized over ERP data when available.
===============================================================================
*/

-- =====================================================================================

-- craete dimention : gold.dim_customers
-- =======================================================================================
if object_id('gold.dim_customers' , 'v') is not null
drop view gold.dim_customers

create view gold.dim_customers as

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

--
-- =====================================================================================

-- craete dimention : gold.dim_products
-- =======================================================================================


if object_id('gold.dim_products' , 'v') is not null
drop view gold.dim_products

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



--


-- =====================================================================================

-- craete fact : gold.dim_customers
-- =======================================================================================



if object_id('gold.facts_sales' , 'v') is not null
drop view gold.facts_sales


create view gold.facts_sales as 
select

sd.sls_ord_num as order_number,
pr.product_key,                
cu.customer_key,               
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
