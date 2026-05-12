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
