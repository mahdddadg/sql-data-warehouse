/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================

Script Purpose:
    This stored procedure loads data into the 'silver' schema from the bronze layer.
    It performs the following actions:
    
    - Cleanses and transforms bronze data.
    - Applies standardization and business rules.
    - Handles data type conversions and null values.
    - Loads processed data into silver tables.

Parameters:
    None.

    This stored procedure does not accept any parameters or return any values.

Usage Example:
    
    ---- >>>>>>    EXEC silver.load_silver;

===============================================================================
*/




create or alter procedure silver.load_silver as 

begin

declare @start_time datetime , @end_time datetime , @batch_start_time datetime ,@batch_end_time datetime  ;

begin try

	set @batch_start_time = getdate() ;

	--1---------------------------------------------------------------------------------
		print'======================================'
		print 'Loading data into silver layer...';
		print'======================================'

		print'-------------------------------------------'
		print 'Loading CRM data...';
		print'-------------------------------------------'


		set @start_time = getdate() ;

		print'>>>>>>>>>>>  truncing tables silver.crm_cust_info  <<<<<<<<<<<<'

		truncate table silver.crm_cust_info


		print'inserting data into table: silver..crm_cust_info '
		INSERT INTO silver.crm_cust_info (

		cst_id ,
		cst_key ,
		cst_firstname ,
		cst_lastname,
		cst_marital_status ,
		cst_gndr ,
		cst_create_date
		)

		select 
		cst_id ,
		cst_key ,
		trim(cst_firstname) as cst_firstame ,
		trim(cst_lastname) as cst_lastname,
		cst_marital_status ,
		case
		when trim (upper (cst_gndr)) = 'F' then 'Female'
		when trim (upper (cst_gndr)) = 'M' then 'Male'
		else 'n/a'
		end as cst_gndr ,
		cst_create_date

		from (
		select

		* ,
		ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

		from bronze.crm_cust_info
		where cst_id is not null              
		)t where rn = 1 

		-- lets  do the same for marital status aslo --


		select 
		cst_id ,
		cst_key ,
		trim(cst_firstname) as cst_firstame ,
		trim(cst_lastname) as cst_lastname,


		case
		when upper (trim (cst_marital_status)) = 'M' then 'Married'
		when upper (trim (cst_marital_status)) = 'S' then 'Single'
		else 'n/a'
		end as cst_marital_status ,

		case
		when upper (trim (cst_gndr)) = 'F' then 'Female'
		when upper (trim (cst_gndr)) = 'M' then 'Male'
		else 'n/a'
		end as cst_gndr ,
		coalesce ( cst_create_date , '1900-01-01') as cst_create_date

		from (
		select

		* ,
		ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as rn

		from bronze.crm_cust_info
		where cst_id is not null              
		)t where rn = 1 

		set @end_time = getdate() ;
		print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;
	print '---------------------------------------------------------------------------'

		--2-------------------------------------------------------------------------------------

		set @start_time = getdate() ;

		print'>>>>>>>>>>>  truncing tables silver.crm_prd_info  <<<<<<<<<<<<'

		truncate table silver.crm_prd_info
		print'inserting data into table: silver.crm_prd_info '
		insert into silver.crm_prd_info(
			prd_id ,
			cat_id  ,
			prd_key ,
			prd_nm ,
			prd_cost ,
			prd_line ,
			prd_start_dt ,
			prd_end_dt 
	
		)
		select
			prd_id,
			replace ( substring (prd_key , 1 , 5 ), '-' , '_' )  as cat_id ,
			substring (prd_key , 7 , len(prd_key)) as prd_key ,
			prd_nm,
			coalesce ( prd_cost , 0 ) as prd_cost , 
	
			case upper(trim(prd_line))
			when  'M' then 'Mountain'
			when  'R' then 'Road'
			when  'S' then 'Other sales'
			when  'T' then 'Touring'
			else 'n/a'
			end as prd_line ,
			cast (prd_start_dt as date ) as prd_start_dt ,
			cast ( lead(prd_start_dt) over (partition by prd_key order by prd_start_dt )-1 as date  ) as  prd_end_dt 

		from bronze.crm_prd_info
		set @end_time = getdate() ;
		print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;

		--3----------------------------------------------------------------------------------------

		set @start_time = getdate() ;

		print'>>>>>>>>>>>  truncing tables silver.crm_sales_details  <<<<<<<<<<<<'

		truncate table silver.crm_sales_details

		print'inserting data into table: silver.crm_sales_details '
		insert into silver.crm_sales_details(

		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt , 
		sls_sales , 
		sls_quantity ,
		sls_price

		)



		select 

		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,

		case when sls_order_dt = 0 or len( sls_order_dt ) != 8 then null
		else cast ( cast (sls_order_dt as varchar ) as date ) 
		end as sls_order_dt,                         

		case when sls_ship_dt = 0 or len( sls_ship_dt ) != 8 then null
		else cast ( cast (sls_ship_dt as varchar ) as date ) 
		end as sls_ship_dt ,

		case when sls_due_dt = 0 or len( sls_due_dt ) != 8 then null
		else cast ( cast (sls_due_dt as varchar ) as date ) 
		end as sls_due_dt , 
		case
		when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs (sls_price ) 
		then sls_quantity * abs (sls_price ) 
		else sls_sales
		end as sls_sales ,

		sls_quantity ,

		case 
		when sls_price is null or sls_price <= 0 then  sls_sales / coalesce (sls_quantity , 0)
		else sls_price
		end as sls_price


		from bronze.crm_sales_details



		set @end_time = getdate() ;
		print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;


		print'======================================'
		print 'Loading data into silver layer...';
		print'======================================'

		print'-------------------------------------------'
		print 'Loading ERP data...';
		print'-------------------------------------------'

		--4-------------------------------------------------------------------------------------------

		set @start_time = getdate() ;

		print'>>>>>>>>>>>  truncing tables silver.erp_cust_az12  <<<<<<<<<<<<'

		truncate table silver.erp_cust_az12

		print'inserting data into table: silver.erp_cust_az12'
		insert into silver.erp_cust_az12 (

		cid,
		bdate,
		gen




		)
		select 

		case 
		when cid like 'NAS%' then substring (cid , 4 , len(cid))
		else cid
		end cid ,

		case 
		when bdate < '1924-01-01' or bdate > getdate() then  null 
		else bdate 
		end bdate,


		case 
		when upper(trim(gen)) in ( 'F' , 'FEMALE' ) then 'Female'
		when upper(trim(gen)) in ( 'M' , 'MALE' ) then 'Male'
		else'n/a'
		end as gen


		from bronze.erp_cust_az12

		set @end_time = getdate() ;
		print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;

		--5----------------------------------------------------------------------------------------


		set @start_time = getdate() ;

		print'>>>>>>>>>>>  truncing tables silver.erp_loc_a101  <<<<<<<<<<<<'

		truncate table silver.erp_loc_a101

		print'inserting data into table: silver.erp_loc_a101'
		insert into silver.erp_loc_a101 (

		cid ,
		cntry

		)


		select 

		replace (cid, '-', '') cid ,
		case
		when trim (cntry ) = '' or  cntry is null then  'n/a'
		when trim (cntry )  in ('US' ,'USA' ) then  'United States'
		when trim (cntry ) = 'DE' then  'Germany'
		else trim (cntry)
		end as cntry


		from bronze.erp_loc_a101


		set @end_time = getdate() ;
		print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;

		--6---------------------------------------------------------------------------------------------------
	
	      set @start_time = getdate() ;



		print'>>>>>>>>>>>.truncing tables<<<<<<<<<<<<'

		truncate table silver.erp_px_cat_g1v2

			print'inserting data into table: silver.erp_px_cat_g1v2'
		insert into silver.erp_px_cat_g1v2 (
	
		id,
		cat,
		subcat,
		maintenance
	
	
		)
		select
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2
	


	set @end_time = getdate() ;
	   print'<<< Load Duration  >>>' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds' ;

	set @batch_end_time = getdate() ;

	print'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
	print'loading bronze layaer is completed '
	print'total load duaation : ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds' ;
	print'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


	



	end try
	begin catch
	    print'============================================================'
		print 'Error loading data into bronze layer: ' + ERROR_MESSAGE();
		print 'Error number' + cast(error_number() as nvarchar );
		print 'Error line' + cast(error_line() as nvarchar );
		print 'Error procudure' + cast(error_procedure() as nvarchar );
		print 'Error state' + cast(error_state() as nvarchar );
		print 'Error severity' + cast(error_severity() as nvarchar );
	    print'============================================================'
		
	end catch

end
