/*
===============================================================================
Load Script: silver.crm_sales_details
===============================================================================
Script Purpose:
    (Re)creates the 'silver.crm_sales_details' table and populates it with
    cleaned sales transaction data sourced from bronze.crm_sales_details.

    Cleaning applied on load:
        - Converts the integer-encoded (YYYYMMDD) order/ship/due dates into
          proper DATE values, nulling out anything that isn't a valid
          8-digit, non-zero value.
        - Recalculates 'sls_sales' as ABS(price) * quantity whenever the
          original is missing, <= 0, or inconsistent with
          price * quantity.
        - Recalculates 'sls_price' as ABS(sales) / quantity whenever the
          original is missing, <= 0, or inconsistent with sales / quantity.

    This mirrors the final cleaning logic developed and validated in
    bronze_crm_sales_details_cleaning.sql, now applied as a repeatable
    table rebuild + INSERT load into the silver layer.

Note:
    Unlike the bronze table (which stores dates as raw INT), this silver
    table stores sls_order_dt/sls_ship_dt/sls_due_dt as proper DATE columns.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild);
-- date columns are DATE here vs. INT in the bronze source table
Drop table if exists silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

insert into silver.crm_sales_details(
sls_ord_num, sls_prd_key, sls_cust_id, 
sls_order_dt, sls_ship_dt, sls_due_dt, 
sls_sales, sls_quantity, sls_price
)

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

















