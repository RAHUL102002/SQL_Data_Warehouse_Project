/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates the cleaned ("silver") layer tables that will hold
    the standardized, deduplicated, and quality-checked versions of the
    bronze source data. Each table is dropped first if it already exists,
    so this script can be re-run safely to reset the silver layer structure.

    Tables created:
        - silver.crm_cust_info       : cleaned CRM customer master data
        - silver.crm_product_info    : cleaned CRM product master data
        - silver.crm_sales_details   : cleaned CRM sales transaction data
        - silver.erp_loction_a101    : cleaned ERP customer location data
        - silver.erp_customer_az12   : cleaned ERP customer demographic data
        - silver.erp_px_category_g1v2: cleaned ERP product category data

    Run this script to re-define the DDL structure of the 'silver' tables.

Note:
    This version of crm_cust_info still has the 'cust_meterial_status' typo
    carried over from bronze, and crm_product_info here is missing the
    'category_key' / 'sls_prd_key' columns that the actual load script
    (silver_crm_product_info_clean_data_inserted_.sql) adds - that load
    script's own CREATE TABLE statement is the one that reflects the final,
    correct silver structure for both tables.
===============================================================================
*/

-- Cleaned CRM customer master data
Drop table if exists silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
cust_id INT,
cust_key varchar(50),
cust_firstname varchar(50),
cust_lastname varchar(50),
cust_meterial_status varchar(50),
cust_gender varchar(50),
cust_create_date date
);

-- Cleaned CRM product master data
Drop table if exists silver.crm_product_info;
CREATE TABLE silver.crm_product_info(
prd_id int,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost varchar(50),
prd_line varchar(50),
prd_start_date datetime,
prd_end_date datetime
);

-- Cleaned CRM sales transaction data
Drop table if exists silver.crm_sales_details;
create table silver.crm_sales_details(
sls_ord_num varchar(50),
sls_prd_key	varchar(50),
sls_cust_id	int,
sls_order_dt int,	
sls_ship_dt	int,
sls_due_dt	int,
sls_sales	int,
sls_quantity	 int,
sls_price int
);

-- Cleaned ERP customer location/country data
Drop table if exists silver.erp_loction_a101;
create table silver.erp_loction_a101(
cust_id varchar(50),
country varchar(50)
);


-- Cleaned ERP customer demographic data
Drop table if exists silver.erp_customer_az12;
create table silver.erp_customer_az12(
cust_id varchar(50),
Birth_Date date,
gender varchar(50)
);

-- Cleaned ERP product category reference data
Drop table if exists silver.erp_px_category_g1v2;
create table silver.erp_px_category_g1v2(
id varchar(50),
category varchar(50),
sub_category varchar(50),
maintenance varchar(50)
);

