/*
===============================================================================
EDA: Cumulative Analysis
===============================================================================
Purpose:
    Calculate total sales per month and the running (year-to-date) total of
    sales over time.

Source:
    Extracted from EDA_Data_warehouse_project.sql (Change over time analysis
    section) - query only, no code changed.
===============================================================================
*/

-- calculate the total sales per month and the running total of sales over time.
-- Inner query aggregates sales per calendar month; outer SUM(...) OVER(...)
-- resets and accumulates within each year (partition by Order_Year), giving
-- a year-to-date running total ordered by month
select
*,
sum(Total_sales) over(partition by Order_Year order by sales_month) as Cummulative_Sales_SUM 
from 
(select
year(order_date) as Order_Year,
DATE_FORMAT(Order_date, '%Y-%m-01') as sales_month,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by year(order_date),
		DATE_FORMAT(Order_date, '%Y-%m-01'))t;
