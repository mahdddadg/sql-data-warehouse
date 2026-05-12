
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
