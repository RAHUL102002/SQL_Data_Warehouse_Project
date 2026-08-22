/*
===============================================================================
Load Script: silver.erp_px_category_g1v2
===============================================================================
Script Purpose:
    (Re)creates the 'silver.erp_px_category_g1v2' table and populates it
    with product category reference data sourced from
    bronze.erp_px_category_g1v2.

    No transformations are applied - the bronze cleaning script found this
    source data already clean, so this is a straight pass-through load.
===============================================================================
*/

-- Define the silver table structure (drop-and-recreate for a clean rebuild)
Drop table if exists silver.erp_px_category_g1v2;
create table silver.erp_px_category_g1v2(
id varchar(50),
category varchar(50),
sub_category varchar(50),
maintenance varchar(50)
);

insert into silver.erp_px_category_g1v2(
id, 
category, 
sub_category, 
maintenance
)
select 
id, 
category, 
sub_category, 
maintenance
from bronze.erp_px_category_g1v2;
