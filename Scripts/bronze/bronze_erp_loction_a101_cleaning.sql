/*
===============================================================================
Data Cleaning Script: bronze.erp_loction_a101
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.erp_loction_a101' table
    (ERP-sourced customer location/country data).
    It performs the following actions:
        1. Checks how many cust_id values carry the 'NAS' source-system
           prefix.
        2. Checks which cust_id values (with dashes stripped) don't yet
           exist in silver.crm_cust_info, to spot unmatched records.
        3. Reviews the distinct raw 'country' values present in the data.
        4. Produces a cleaned SELECT that strips dashes from cust_id (so it
           lines up with the key format used elsewhere) and standardizes
           country names/codes into consistent, full country names.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of customer location data ready for
    downstream use.

Note:
    This is an exploratory/cleaning script - the top section is read-only
    profiling (SELECT checks), while the final SELECT is the cleaned output
    (used later to populate the silver layer).
===============================================================================
*/

select * from bronze.erp_loction_a101;

-- Count/preview cust_id values carrying the 'NAS' source-system prefix
SELECT cust_id
FROM bronze.erp_loction_a101
WHERE cust_id LIKE 'NAS%';

-- Find location records whose (dash-stripped) cust_id has no match in
-- silver.crm_cust_info - these are unmatched/orphaned records
select
 replace(cust_id,'-','') as cust_id, 
 country
from bronze.erp_loction_a101
where replace(cust_id,'-','') not in 
(select cust_key from silver.crm_cust_info);

-- Review the distinct raw country values present in the source data
select distinct country
from bronze.erp_loction_a101
order by country;



-- #####################################################################
-- #####################################################################

-- Final cleaned query: strips dashes from cust_id, and maps country codes
-- and inconsistent spellings ('DE', 'USA'/'US') into full, standardized
-- country names; blanks/NULLs become 'Unknown', anything else is trimmed
select
 replace(cust_id,'-','') as cust_id, 
 case
	when trim(country) = 'DE' then 'Germany'
    when trim(country) in ('USA','US') THEN 'united States'
    when trim(country) = '' or country is NULL THEN 'Unknown'
    else trim(country)
end as country
from bronze.erp_loction_a101;
