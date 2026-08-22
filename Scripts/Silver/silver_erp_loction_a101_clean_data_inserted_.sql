/*
===============================================================================
Load Script: silver.erp_loction_a101
===============================================================================
Script Purpose:
    (Re)creates the 'silver.erp_loction_a101' table and populates it with
    cleaned ERP customer location data sourced from bronze.erp_loction_a101.

    Cleaning applied on load:
        - Strips dashes from 'cust_id' so it lines up with the key format
          used elsewhere in the silver layer.
        - Standardizes 'country' values: 'DE' -> 'Germany', 'USA'/'US' ->
          'united States', blank/NULL -> 'Unknown', everything else trimmed.

    This mirrors the final cleaning logic developed and validated in
    bronze_erp_loction_a101_cleaning.sql, now applied as a repeatable table
    rebuild + INSERT load into the silver layer.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild)
Drop table if exists silver.erp_loction_a101;
create table silver.erp_loction_a101(
cust_id varchar(50),
country varchar(50)
);


insert into silver.erp_loction_a101(
cust_id, 
country
)
select
 replace(cust_id,'-','') as cust_id, 
 case
	when trim(country) = 'DE' then 'Germany'
    when trim(country) in ('USA','US') THEN 'united States'
    when trim(country) = '' or country is NULL THEN 'Unknown'
    else trim(country)
end as country
from bronze.erp_loction_a101;



-- Quick sanity check on the freshly loaded, standardized country values
select distinct country
from silver.erp_loction_a101;
