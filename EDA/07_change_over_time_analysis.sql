/*
===============================================================================
EDA: Change Over Time Analysis
===============================================================================
Purpose:
    Analyze sales performance trends by year and by month.

Note:
    The related running-total (cumulative) query originally grouped under
    the same "Change over time analysis" heading has been split out into
    08_cumulative_analysis.sql.

Source:
    Extracted from EDA_Data_warehouse_project.sql - queries only, no code
    changed.
===============================================================================
*/

-- analyze sales performance over time(Years/months).

select
Year(Order_date) as Order_year,
Sum(sales_amount) as Total_sales,
count(distinct Customer_key) as Total_customers ,
sum(Quantity) as total_quantity
from gold.fact_sales
where Year(Order_date) is not null
group by Year(Order_date)
order by Year(Order_date) ;


select
DATE_FORMAT(Order_date, '%Y-%m-01') AS Order_month,
month(Order_date) as Order_month,
Sum(sales_amount) as Total_sales 
from gold.fact_sales
where month(Order_date) is not null
group by DATE_FORMAT(Order_date, '%Y-%m-01'),month(Order_date)
order by month(Order_date) ;
