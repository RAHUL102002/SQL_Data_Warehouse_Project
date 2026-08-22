/*
===============================================================================
Data Cleaning Script: bronze.erp_customer_az12
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.erp_customer_az12' table
    (ERP-sourced customer demographic data: birth date and gender).
    It performs the following actions:
        1. Checks 'cust_id' for duplicates.
        2. Checks 'cust_id' for unwanted leading/trailing spaces.
        3. Checks 'cust_id' length consistency (comparison as written; see
           note below).
        4. Checks how many cust_id values carry the 'NAS' prefix used by
           this ERP source system.
        5. Checks for birth dates set in the future (data entry errors).
        6. Reviews the distinct raw 'gender' values present in the data.
        7. Produces two exploratory cleaned SELECTs: the first strips the
           'NAS' prefix from cust_id and standardizes gender, restricted to
           customers that don't already exist in silver.crm_cust_info; the
           second (final) version applies the same cust_id/birth date
           cleanup with a slightly different, more permissive gender mapping
           and returns the full table.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of ERP customer demographic data ready for
    downstream use.

Note:
    - Check #3 (`cust_id != length(cust_id)`) compares a string to a number
      and will effectively always evaluate as a mismatch; it does not
      reliably validate ID length as likely intended.
    - The two exploratory queries near the bottom use different gender
      mapping logic - only the final query (bottom of file) represents the
      cleaning logic actually used downstream.
===============================================================================
*/

select * from bronze.erp_customer_az12;

-- Check for duplicate customer IDs
select
cust_id,
count(*)
from bronze.erp_customer_az12
group by cust_id
having count(*) > 1;


-- Check for unwanted leading/trailing spaces in cust_id
select
cust_id
from bronze.erp_customer_az12
WHERE cust_id != trim(cust_id);

-- NOTE: compares cust_id (string) to length(cust_id) (number); this does not
-- meaningfully validate ID length as the query name might suggest
select
count(cust_id)
from bronze.erp_customer_az12
WHERE cust_id != length(cust_id);


-- Count how many cust_id values carry the 'NAS' source-system prefix
select count(*)
from
(select
cust_id
from bronze.erp_customer_az12
WHERE cust_id like 'NAS%')t;

-- Check for birth dates set in the future (invalid data)
select Birth_Date 
from bronze.erp_customer_az12
where Birth_Date > current_date();


-- Review the distinct raw gender values present in the source data
select distinct gender
from bronze.erp_customer_az12;


-- #########################################################################--
-- #########################################################################--

-- Exploratory cleaned query: strips the 'NAS' prefix from cust_id, nulls out
-- future-dated birth dates, and standardizes gender codes; restricted to
-- customers not already present in silver.crm_cust_info (i.e. new/unmatched
-- records worth reviewing)
select 
case
	when cust_id like 'NAS%' then substring(cust_id,4)
    else cust_id
end as cust_id,
case 
	when Birth_Date > current_date() then null
	else Birth_Date
end as Birth_Date,
case
	when trim(gender) = 'M' then 'Male'
    when trim(gender) = 'F' then 'Female'
    when trim(gender) = '' then 'Unknown'
    else gender
end as gender
from bronze.erp_customer_az12
where case
	when cust_id like 'NAS%' then substring(cust_id,4)
    else cust_id
end not in (select cust_key from silver.crm_cust_info);
-- #########################################################################--
-- #########################################################################--

-- Final cleaned query: same cust_id/birth date cleanup as above, but with a
-- broader, case-insensitive gender mapping (also treats 'FEMALE'/'MALE'
-- spelled out as valid inputs) and runs against the full table rather than
-- filtering to unmatched customers
-- NOTE: as written, 'M' and 'FEMALE' both map to 'Male', and 'F' and 'MALE'
-- both map to 'Female' - worth double-checking whether this pairing is
-- intentional or the two spelled-out labels were meant to be swapped
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
