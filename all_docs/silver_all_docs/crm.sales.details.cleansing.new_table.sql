-------- we casted 3 colums from int to date , so we need to chag eout table :


if object_id ( 'silver.crm_sales_details' ,'U ') is not null
 drop table silver.crm_sales_details ;


create table silver.crm_sales_details(

sls_ord_num nvarchar(50) ,
sls_prd_key nvarchar(50),
sls_cust_id int ,
sls_order_dt date ,
sls_ship_dt date,
sls_due_dt date, 
sls_sales  int, 
sls_quantity  int,
sls_price int,
dwh_create_date datetime2 default getdate () 


)
