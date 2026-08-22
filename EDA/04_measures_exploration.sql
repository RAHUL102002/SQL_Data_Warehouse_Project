/*
===============================================================================
EDA: Measures Exploration
===============================================================================
Purpose:
    Pull the core business totals - total sales, items sold, average selling
    price, total orders, total products, total customers, and customers who
    have placed an order - plus a combined "key metrics" report that unions
    all of them into a single result set.

Source:
    Extracted from EDA_Data_warehouse_project.sql - queries only, no code
    changed.
===============================================================================
*/

-- ======================================================================================
-- Measures Exploration
-- ======================================================================================

-- Find the Total Sales

select 
	sum(sales_Amount) as Total_Sales
from gold.fact_sales;

-- Find how many items are sold
select 
	sum(Quantity) as Total_Sold_Items
from gold.fact_sales;

-- Find the average selling price
select 
	Round(avg(Sales_Amount),2) as Average_Sales
from gold.fact_sales;


-- Find the Total number of Orders
select 
	count(distinct order_Number) as Total_Orders
from gold.fact_sales;

-- Find the total number of products
select 
    count(distinct Product_id) as Total_Products
from gold.dim_products;


-- Find the total number of customers
select
	count(distinct customer_id) as Total_Customers
from gold.dim_customers;

-- Find the total number of customers that has placed an order.

select 
	count(distinct Customer_key) as Total_Customer_Ordered
from gold.fact_sales;

-- Generate a Report that shows all key metrics of the business.

select 'Total_sales' as Measure_name, sum(sales_amount) as Measure_value from gold.fact_sales
union all 
select 'Total_Sold_Items' as Measure_name ,sum(Quantity) as Measure_Value from gold.fact_sales
union all 
select 'Average_Sales' as Measure_name ,Round(avg(Sales_Amount),2) as Measure_Value from gold.fact_sales
union all
select 'Total_Orders' as Measure_name ,count(distinct order_Number) as Measure_Value from gold.fact_sales
union all 
select 'Total_Products' as Measure_name ,count(distinct Product_id) as Measure_Value from gold.dim_Products
union all
select 'Total_Customers' as Measure_name ,count(distinct customer_id) as Measure_Value from gold.dim_Customers
union all 
select 'Total_Customer_Ordered' as Measure_name ,count(distinct Customer_key) as Measure_Value from gold.dim_Customers; 


