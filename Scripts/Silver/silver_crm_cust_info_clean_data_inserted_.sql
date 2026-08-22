/*
===============================================================================
Load Script: silver.crm_cust_info
===============================================================================
Script Purpose:
    (Re)creates the 'silver.crm_cust_info' table and populates it with
    cleaned customer data sourced from bronze.crm_cust_info.

    Cleaning applied on load:
        - Deduplicates by cust_id, keeping only the most recent record per
          customer (via ROW_NUMBER() partitioned by cust_id, ordered by
          cust_create_date desc).
        - Standardizes 'cust_marital_status' codes ('S'/'M') into full,
          readable labels ('single'/'married'), defaulting to 'unknown'.
        - Standardizes 'cust_gender' codes ('F'/'M') into full labels
          ('female'/'male'), defaulting to 'unknown'.

    This mirrors the logic developed and validated in the bronze cleaning
    script (bronze_crm_cust_info_cleaning.sql), now applied as a repeatable
    TRUNCATE + INSERT load into the silver layer.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild)
Drop table if exists silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
cust_id INT,
cust_key varchar(50),
cust_firstname varchar(50),
cust_lastname varchar(50),
cust_marital_status varchar(50),
cust_gender varchar(50),
cust_create_date date
);

-- inserting data into silver.crm_cust_info.

-- Clear out any existing rows before reloading (keeps this script idempotent)
TRUNCATE TABLE silver.crm_cust_info;

insert into silver.crm_cust_info
(
cust_id,
cust_key,
cust_firstname,
cust_lastname,
cust_marital_status,
cust_gender,
cust_create_date
)

select 
cust_id,
cust_key,
cust_firstname,
cust_lastname,
case 
	when upper(trim(cust_marital_status)) = 'S'then 'single'
    when upper(trim(cust_marital_status)) = 'M' then  'married'
    else 'unknown'
end as cust_marital_status,
case
	when upper(trim(cust_gender)) = 'F' then  'female'
	when upper(trim(cust_gender)) = 'M' then 'male'
    else 'unknown'
end as cust_gender,
cust_create_date
from (
select * ,
row_number() over(partition by cust_id order by cust_create_date desc) flag_last
from bronze.crm_cust_info)t
where flag_last = 1
;

-- Quick sanity check on the freshly loaded data
select * from silver.crm_cust_info;
