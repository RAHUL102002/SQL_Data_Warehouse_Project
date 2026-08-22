/*
===============================================================================
Load Script: silver.erp_customer_az12
===============================================================================
Script Purpose:
    (Re)creates the 'silver.erp_customer_az12' table and populates it with
    cleaned ERP customer demographic data sourced from
    bronze.erp_customer_az12.

    Cleaning applied on load:
        - Strips the 'NAS' source-system prefix from 'cust_id' where present.
        - Nulls out 'Birth_Date' values set in the future (invalid data).
        - Standardizes 'gender' into 'Male'/'Female'/'Unknown', accepting
          both short codes ('M'/'F') and full words ('MALE'/'FEMALE').

    This mirrors the final cleaning logic developed and validated in
    bronze_erp_customer_az12_cleaning.sql, now applied as a repeatable
    table rebuild + INSERT load into the silver layer.

Note:
    As in the bronze cleaning script, double-check the gender mapping below:
    'M' and 'FEMALE' both map to 'Male', and 'F' and 'MALE' both map to
    'Female' - confirm this pairing is intentional before relying on it
    downstream.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild)
Drop table if exists silver.erp_customer_az12;
create table silver.erp_customer_az12(
cust_id varchar(50),
Birth_Date date,
gender varchar(50)
);

insert into silver.erp_customer_az12(
cust_id, 
Birth_Date, 
gender
)

select 
case
	when cust_id like 'NAS%' then substring(cust_id,4)
    else cust_id
end as cust_id,
case 
	when Birth_Date > current_date() then NULL 
	else Birth_Date
end as Birth_Date,
case
	when upper(trim(gender)) in ('M','FEMALE') then 'Male'
    when upper(trim(gender)) IN ('F','MALE') then 'Female'
	else  'Unknown'
end as gender
from bronze.erp_customer_az12;
