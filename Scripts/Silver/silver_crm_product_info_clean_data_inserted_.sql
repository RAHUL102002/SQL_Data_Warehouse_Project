/*
===============================================================================
Load Script: silver.crm_product_info
===============================================================================
Script Purpose:
    (Re)creates the 'silver.crm_product_info' table and populates it with
    cleaned product data sourced from bronze.crm_product_info.

    Cleaning applied on load:
        - Splits 'prd_key' into 'category_key' (first 5 chars, '-' -> '_',
          used to join to the ERP category table) and 'sls_prd_key' (the
          remainder, used to join to sales details).
        - Standardizes 'prd_line' codes (M/R/S/T) into full, readable
          labels, defaulting to 'Unknown'.
        - Recalculates 'prd_end_date' as one day before the next record's
          start date for the same prd_key (via LEAD), since the raw
          end-date values are unreliable; the current/latest version of
          each product ends up with a NULL end date.

    This mirrors the logic developed and validated in the bronze cleaning
    script (bronze_crm_product_info_cleaning.sql), now applied as a
    repeatable table rebuild + INSERT load into the silver layer.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild);
-- note the added 'category_key' and 'sls_prd_key' columns derived from
-- splitting the bronze 'prd_key', not present in the bronze table itself
Drop table if exists silver.crm_product_info;
CREATE TABLE silver.crm_product_info(
prd_id int,
prd_key varchar(50),
category_key varchar(50),
sls_prd_key varchar(50),
prd_nm varchar(50),
prd_cost varchar(50),
prd_line varchar(50),
prd_start_date date,
prd_end_date date
);

insert into silver.crm_product_info (
prd_id,
prd_key,
category_key,
sls_prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_date,
prd_end_date
)

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

-- Quick sanity check on the freshly loaded data
select*  from silver.crm_product_info;
