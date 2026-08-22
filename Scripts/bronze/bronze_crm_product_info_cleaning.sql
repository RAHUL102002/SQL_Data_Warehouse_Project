/*
===============================================================================
Data Cleaning Script: bronze.crm_product_info
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.crm_product_info' table.
    It performs the following actions:
        1. Checks the 'prd_id' primary key column for NULLs and duplicates.
        2. Checks 'prd_nm' for unwanted leading/trailing spaces.
        3. Checks 'prd_cost' for NULLs and negative values.
        4. Checks that 'prd_end_date' is never earlier than 'prd_start_date'.
        5. Cleans and reshapes the data: splits 'prd_key' into a category key
           and a shortened product key, maps coded 'prd_line' values to
           readable labels, and derives 'prd_end_date' from the next row's
           start date per product (using LEAD), since the raw end-date
           values are unreliable.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of product data ready for downstream use.

Note:
    This is an exploratory/cleaning script - the top section is read-only
    profiling (SELECT checks), while the final SELECT reshapes the data into
    the cleaned structure (used later to populate the silver layer).
===============================================================================
*/

select* from bronze.crm_product_info;

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

-- NOTE: uses AND, so this only flags a group as a duplicate if it ALSO has a
-- NULL prd_id; a duplicate group with non-null IDs would not be surfaced here
select 
prd_id,
count(*)
from bronze.crm_product_info
group by prd_id
having count(*) > 1 and prd_id is null;

-- Check for unwanted Spaces
-- Expectation: No Results

select prd_nm from bronze.crm_product_info
where prd_nm != trim(prd_nm);

-- Check for NULLs or Negative Numbers
-- Expectation: No Results

select prd_cost from bronze.crm_product_info
where prd_cost < 0 or prd_cost is null;

-- Check for Invalid Date Orders
-- End date must not be earlier than the start date
-- Expectation: No Result

select 
prd_start_date,
prd_end_date
from bronze.crm_product_info
where prd_end_date < prd_start_date;


--  data cleaning 
-- prd_key is split into: the first 5 chars (with '-' swapped to '_') as the
-- category_key used to join to the ERP category table, and everything after
-- position 7 as the shortened sls_prd_key used to join to sales details.
-- prd_line codes are mapped to descriptive labels.
-- prd_end_date is recalculated as one day before the next record's
-- prd_start_date for the same prd_key (via LEAD), since the source end
-- dates are not trustworthy.
select 
	prd_id,
    prd_key,
    replace(substring(prd_key, 1 , 5),'-','_') as category_key,
    trim(substring(prd_key,7)) as sls_prd_key,
    prd_nm,
    prd_cost,
    case upper(trim(prd_line))
		when 'M' then 'Mountain'
        when 'R' then  'Road'
        when 'S' then 'Other Sales'
        when 'T' then 'Touring'
		else 'Unknown'
	end as prd_line,
    cast(prd_start_date as date) as prd_start_date,
    date_sub(cast(lead(prd_start_date) over(partition by prd_key order by prd_start_date asc ) as date), interval 1 day) as prd_end_date 
from bronze.crm_product_info;
 
