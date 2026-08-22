/*
===============================================================================
EDA: Dimensions Exploration
===============================================================================
Purpose:
    Explore the distinct values held in the gold layer's dimension views
    (dim_customers, dim_products) - countries, product categories, and
    category/sub-category combinations.

Source:
    Extracted from EDA_Data_warehouse_project.sql (Dates and Dimensions
    Exploration section) - queries only, no code changed.
===============================================================================
*/

-- Explore All Countries our customers come from.
select distinct 
	country 
from gold.dim_customers;

-- Explore All Categories "The major Divisions"
select distinct
	category
from gold.dim_products;

-- Explore All Categories and Sub_categories "The major Divisions"
select distinct
	Category,
    sub_category
from gold.dim_products
order by 1,2;
