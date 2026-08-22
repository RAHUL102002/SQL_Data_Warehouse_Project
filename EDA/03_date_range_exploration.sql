/*
===============================================================================
EDA: Date Range Exploration
===============================================================================
Purpose:
    Explore the time span covered by the data - the first and last order
    dates, and the birth-date range of the youngest and oldest customers.

Source:
    Extracted from EDA_Data_warehouse_project.sql (Dates and Dimensions
    Exploration section) - queries only, no code changed.
===============================================================================
*/

-- Find the date of the first and last order 
select 
	min(order_date) as First_Order_date,
    max(order_date) as last_Order_date,
    timestampdiff(month,min(order_date),max(order_date)) as Order_range_months
from gold.Fact_Sales;

-- Find the youngest and the oldest customer

select 
	min(birth_date) as oldest_Birth_date,
    Max(Birth_date) as Youngest_Birth_date,
    timestampdiff(year,min(Birth_date),current_date()) as Oldest_Customer,
    timestampdiff(year,max(Birth_date),Current_date()) as Youngest_Customer
from gold.dim_customers;
