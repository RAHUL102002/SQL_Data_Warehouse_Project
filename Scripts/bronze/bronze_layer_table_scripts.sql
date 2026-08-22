/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates the raw ("bronze") layer tables that mirror the
    source systems (CRM and ERP) as-is, before any cleaning is applied.
    Each table is dropped first if it already exists, so this script can be
    re-run safely to reset the bronze layer structure.

    Tables created:
        - bronze.crm_cust_info       : raw CRM customer master data
        - bronze.crm_product_info    : raw CRM product master data
        - bronze.crm_sales_details   : raw CRM sales transaction data
        - bronze.erp_loction_a101    : raw ERP customer location/country data
        - bronze.erp_customer_az12   : raw ERP customer demographic data
        - bronze.erp_px_category_g1v2: raw ERP product category reference data

    Run this script to re-define the DDL structure of the 'bronze' tables.
===============================================================================
*/

-- Raw CRM customer master data
Drop table if exists bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
cust_id INT,
cust_key varchar(50),
cust_firstname varchar(50),
cust_lastname varchar(50),
cust_meterial_status varchar(50),
cust_gender varchar(50),
cust_create_date date
);

-- Raw CRM product master data
Drop table if exists bronze.crm_product_info;
CREATE TABLE bronze.crm_product_info(
prd_id int,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost varchar(50),
prd_line varchar(50),
prd_start_date datetime,
prd_end_date datetime
);

-- Raw CRM sales transaction data (order/ship/due dates stored as raw ints)
Drop table if exists bronze.crm_sales_details;
create table bronze.crm_sales_details(
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

-- Raw ERP customer location/country data
Drop table if exists bronze.erp_loction_a101;
create table bronze.erp_loction_a101(
cust_id varchar(50),
country varchar(50)
);


-- Raw ERP customer demographic data (birth date, gender)
Drop table if exists bronze.erp_customer_az12;
create table bronze.erp_customer_az12(
cust_id varchar(50),
Birth_Date date,
gender varchar(50)
);

-- Raw ERP product category reference data
Drop table if exists bronze.erp_px_category_g1v2;
create table bronze.erp_px_category_g1v2(
id varchar(50),
category varchar(50),
sub_category varchar(50),
maintenance varchar(50)
);

