--- since we created 2 new coloums in out table we need to add them , in silver layer


if object_id ('silver.crm_prd_info' , 'U')is not null
drop table silver.crm_prd_info;


create table silver.crm_prd_info (
    prd_id int,
	cat_id nvarchar(50) ,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt date,
	prd_end_dt date ,
	dwh_create_date datetime2 default getdate()
	)




)
