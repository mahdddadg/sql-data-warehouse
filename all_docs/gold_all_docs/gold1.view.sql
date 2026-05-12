
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




