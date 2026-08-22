/*
===============================================================================
EDA: Part-to-Whole Analysis
===============================================================================
Purpose:
    Determine which product categories contribute the most to overall
    sales, expressed as a percentage of total revenue.

Source:
    Extracted from EDA_Data_warehouse_project.sql - query only, no code
    changed.
===============================================================================
*/

-- ======================================================================================
-- Part to whole analysis
-- ======================================================================================

-- which categories contributes the most to overall sales.
-- SUM(Total_sales) OVER() (no partition) computes the grand total across all
-- categories in the same result set, letting each row divide into it to get
-- its percentage share
with Category_sales as (
select 
p.Category,
sum(s.sales_amount) as total_sales
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
group by p.Category)

select 
category,
Total_sales,
sum(Total_sales) over() as Overall_sales,
concat(round((Total_sales /sum(Total_sales) over())*100,2),'%') as Perc_of_overall_sales
from category_sales;
