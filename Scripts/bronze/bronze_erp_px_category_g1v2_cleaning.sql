/*
===============================================================================
Data Cleaning Script: bronze.erp_px_category_g1v2
===============================================================================
Script Purpose:
    This script inspects and cleans the 'bronze.erp_px_category_g1v2' table
    (ERP-sourced product category / maintenance reference data).
    It performs the following actions:
        1. Checks the 'maintenance' column for unwanted leading/trailing
           spaces.
        2. Reviews the distinct values in 'maintenance', 'sub_category',
           and 'category' to check for inconsistent labeling.
        3. Produces a final SELECT of the (already-clean) category
           reference data, ready for downstream use.

    Run this script against the bronze layer to profile data quality issues
    and produce a cleaned view of product category data ready for
    downstream use.

Note:
    This table required minimal cleaning - the checks below found no
    transformations necessary, so the final SELECT simply passes the columns
    through unchanged.
===============================================================================
*/

select * from bronze.erp_px_category_g1v2;
-- Check for unwanted leading/trailing spaces in maintenance
select 
id, 
category, 
sub_category, 
maintenance
from bronze.erp_px_category_g1v2
where maintenance != trim(maintenance) ;

-- Review distinct maintenance values for inconsistent labeling
select distinct 
maintenance
from bronze.erp_px_category_g1v2 ;

-- Review distinct sub_category values for inconsistent labeling
select distinct 
sub_category
from bronze.erp_px_category_g1v2 ;

-- Review distinct category values for inconsistent labeling
select distinct 
category
from bronze.erp_px_category_g1v2 ;


-- ####################################################################
-- ####################################################################

-- Final cleaned query: no transformations needed, data passed through as-is
select 
id, 
category, 
sub_category, 
maintenance
from bronze.erp_px_category_g1v2;
