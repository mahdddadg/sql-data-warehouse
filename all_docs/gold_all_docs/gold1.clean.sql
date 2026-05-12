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
--->2)   we havw 2 gender lets fix it , which one is madter table ? crm or erp 
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
