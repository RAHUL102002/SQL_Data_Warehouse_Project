/*
===============================================================================
Data Cleaning Script: bronze.crm_cust_info
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.crm_cust_info' table.
    It performs the following actions:
        1. Checks the 'cust_id' primary key column for NULLs and duplicates.
        2. Trims unwanted leading/trailing spaces from text columns and
           converts empty strings to NULL.
        3. Removes duplicate customer records, keeping only the most recent
           row per 'cust_id' (based on 'cust_create_date').
        4. Renames the misspelled 'cust_meterial_status' column to
           'cust_merital_status'.
        5. Standardizes coded values in 'cust_merital_status' and
           'cust_gender' into readable, consistent labels.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of customer data ready for downstream use.

Note:
    This is an exploratory/cleaning script - some statements (SELECT checks)
    are meant for review only, while UPDATE/ALTER statements modify the
    underlying table. Review each section before executing in production.
===============================================================================
*/

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT * FROM bronze.crm_cust_info;

-- Group by cust_id to surface any duplicate IDs (count > 1) or NULL IDs
-- Sorted descending so the worst offenders (most duplicates) appear first
select 
cust_id,
count(*)
from bronze.crm_cust_info
group by cust_id
having count(*) > 1 or cust_id is null
order by count(*) desc;

-- Check for unwanted Spaces and adding NULL in empty ceels
-- Disable MySQL's safe update mode so the UPDATE (which has no key-based WHERE) can run
set sql_safe_updates = 0;
-- TRIM removes leading/trailing whitespace; NULLIF then converts any resulting
-- empty string ('') to NULL, so blanks and whitespace-only values are treated consistently
UPDATE bronze.crm_cust_info
SET
	cust_id				= nullif(trim(cust_id),''),
    cust_firstname      = NULLIF(TRIM(cust_firstname), ''),
    cust_lastname       = NULLIF(TRIM(cust_lastname), ''),
    cust_meterial_status = NULLIF(TRIM(cust_meterial_status), ''),
    cust_gender           = NULLIF(TRIM(cust_gender), '');
-- Re-enable safe update mode
set sql_safe_updates = 1;

-- removing duplicates
-- ROW_NUMBER() resets to 1 for each cust_id group (partition), ordered by the
-- most recent cust_create_date first, so flag_last = 1 marks the latest record
-- per customer; filtering on flag_last = 1 keeps only that most recent row
select * from 
(
select * ,
row_number() over(partition by cust_id order by cust_create_date desc) flag_last
from bronze.crm_cust_info)t
where flag_last = 1;

-- changing the column name 
-- Fixing the typo in the original column name ('meterial' -> 'merital')
alter table bronze.crm_cust_info
rename column cust_meterial_status to cust_merital_status;

-- Data Standardization & Consistency
-- Maps short/coded values ('S','M','F') into full, human-readable labels;
-- UPPER(TRIM(...)) guards against case differences and stray whitespace,
-- and any unrecognized/missing code falls back to 'unknown'
select 
cust_id,
cust_key,
cust_firstname,
cust_lastname,
case 
	when upper(trim(cust_merital_status)) = 'S'then 'single'
    when upper(trim(cust_merital_status)) = 'M' then  'merried'
    else 'unknown'
end as cust_merital_status,
case
	when upper(trim(cust_gender)) = 'F' then  'female'
	when upper(trim(cust_gender)) = 'M' then 'male'
    else 'unknown'
end as cust_gender
from bronze.crm_cust_info;



