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
