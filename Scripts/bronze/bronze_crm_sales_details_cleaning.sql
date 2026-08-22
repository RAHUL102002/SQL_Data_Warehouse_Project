/*
===============================================================================
Data Cleaning Script: bronze.crm_sales_details
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.crm_sales_details' table.
    It performs the following actions:
        1. Checks 'sls_ord_num' for unwanted leading/trailing spaces.
        2. Checks referential integrity of 'sls_prd_key' against
           silver.crm_product_info, and 'sls_cust_id' against
           silver.crm_cust_info.
        3. Checks the quality of the date columns (order/ship/due), which are
           stored as raw integers (e.g. 20130101) rather than DATE types.
        4. Checks that order date is never later than ship or due date.
        5. Checks consistency between sales, quantity, and price
           (Sales = Quantity * Price), and flags NULL/zero/negative values.
        6. Produces a cleaned SELECT that casts the integer date columns to
           proper DATE values (nulling out anything invalid), and recomputes
           sls_sales / sls_price where they are missing or inconsistent with
           the Sales = Quantity * Price rule.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of sales transaction data ready for
    downstream use.

Note:
    This script depends on the silver layer already being populated
    (silver.crm_product_info, silver.crm_cust_info) for the integrity checks.
    The top section is read-only profiling (SELECT checks); the final SELECT
    is the cleaned output (used later to populate the silver layer).
===============================================================================
*/

select * FROM bronze.crm_sales_details;

-- Check for unwanted Spaces
-- Expectation: No Results

select *
from bronze.crm_sales_details
where sls_ord_num != trim(sls_ord_num);

-- check integrity  of sls_prd_key column
-- Finds sales rows whose product key doesn't exist in the cleaned silver product table

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT sls_prd_key
    FROM silver.crm_product_info
);
-- check integrity  of sls_cust_id column
-- Finds sales rows whose customer id doesn't exist in the cleaned silver customer table

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
where sls_cust_id not in (
select cust_id from silver.crm_cust_info
);

-- check the quality of date columns 
-- Dates are stored as integers in YYYYMMDD format; flags NULL, zero, or any
-- value that isn't exactly 8 digits long (i.e. not a valid YYYYMMDD date)
select nullif(sls_order_dt,0)
from bronze.crm_sales_details
where sls_order_dt is null or sls_order_dt = 0 or length(sls_order_dt) != 8 ;

-- Order Date must always be earlier
-- than the Shipping Date or Due Date

select 
sls_order_dt,
sls_ship_dt,
sls_due_dt
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;


-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

-- Rules
-- If Sales is negative, zero, or null, derive it using Quantity and Price.
-- If Price is zero or null, calculate it using Sales and Quantity.
-- If Price is negative, convert it to a positive value.

select distinct
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_sales <=0 or sls_sales is null or sls_sales = '' or
sls_quantity <=0 or sls_quantity is null or sls_quantity = '' or
sls_price <=0 or sls_price is null or sls_price = ''or
sls_sales != sls_price * sls_quantity;




-- Final cleaned output:
-- - Date columns: cast to DATE only when the raw value is a valid 8-digit,
--   non-zero number; otherwise set to NULL
-- - sls_sales: recalculated as ABS(price) * quantity whenever the original
--   is null, <= 0, or doesn't match price * quantity
-- - sls_price: recalculated as ABS(sales) / quantity whenever the original
--   is null, <= 0, or doesn't match sales / quantity (NULLIF guards against
--   divide-by-zero on quantity in the consistency check)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    case
		when sls_order_dt is null or sls_order_dt = 0 or length(sls_order_dt) != 8 then null
        else cast(sls_order_dt as date)
	end as sls_order_dt,
    case
		when sls_ship_dt is null or sls_ship_dt = 0 or length(sls_ship_dt) != 8 then null
        else cast(sls_ship_dt as date)
	end as sls_ship_dt,
    case
		when sls_due_dt is null or sls_due_dt = 0 or length(sls_due_dt) != 8 then null
        else cast(sls_due_dt as date)
	end as sls_due_dt,
    case
		when sls_sales is null or sls_sales <= 0 or sls_sales != sls_price * sls_quantity then abs(sls_price) * sls_quantity
        else sls_sales
	end as sls_sales,
    sls_quantity,
    case 
		when sls_price is null or sls_price <= 0 or sls_price != sls_sales / nullif(sls_quantity,0) then abs(sls_sales) / sls_quantity
        else sls_price
	end as sls_price
FROM bronze.crm_sales_details ;
