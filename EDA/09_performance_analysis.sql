/*
===============================================================================
EDA: Performance Analysis
===============================================================================
Purpose:
    Analyze the yearly performance of each product by comparing its sales
    to both its own all-time average and the previous year's sales.

Note:
    Includes an "alternate query" that solves the same question with a
    tidier CTE structure; kept side by side for reference, not meant to
    both be run downstream.

Source:
    Extracted from EDA_Data_warehouse_project.sql - queries only, no code
    changed.
===============================================================================
*/

-- ======================================================================================
-- Performance analysis
-- ======================================================================================


-- Analyze the yearly performance of products by comparing each product's 
-- sales to both its average sales performance and the previous year's sales.

-- LAG(...) pulls each product's prior-year sales (0 if none, via COALESCE) to
-- compute year-over-year change; AVG(...) OVER(partition by product) computes
-- each product's all-time average sales to compare the current year against
with Yearly_product_sales as (
select
year(s.order_date) as Order_year,
p.product_name,
sum(s.sales_amount) as Total_sales
from gold.fact_sales as s
left join gold.Dim_products as p
on s.product_key = p.product_key
where order_date is not null
group by p.product_name , year(s.order_date)
order by p.product_name , year(s.order_date) )

select 
Order_year,
Product_name,
Total_sales,
coalesce(lag(Total_sales) over(partition by Product_name order by Order_year),0) as py_sales,
(Total_sales - coalesce(lag(Total_sales) over(partition by Product_name order by Order_year),0)) as diff_py,
case 
	when (Total_sales - coalesce(lag(Total_sales) over(partition by Product_name order by Order_year),0)) > 0 then 'Increase'
    when (Total_sales - coalesce(lag(Total_sales) over(partition by Product_name order by Order_year),0)) < 0 then 'Decrease'
    else 'No change'
end as py_sales_changes,
Round(avg(Total_sales) over(partition by Product_name),0) as avg_sales,
(Total_sales - Round(avg(Total_sales) over(partition by Product_name),0)) as avg_diff,
case 
	when (Total_sales - Round(avg(Total_sales) over(partition by Product_name),0)) > 0 then 'Above avg'
    when (Total_sales - Round(avg(Total_sales) over(partition by Product_name),0)) = 0 then 'Average'
    else 'Below avg'
end as Avg_changes
from Yearly_Product_sales;

-- alternate query

with Yearly_product_sales as (
    select
        year(s.order_date) as Order_year,
        p.product_name,
        sum(s.sales_amount) as Total_sales
    from gold.fact_sales as s
    left join gold.Dim_products as p
        on s.product_key = p.product_key
    where order_date is not null
    group by p.product_name, year(s.order_date)
),
calc as (
    select
        Order_year,
        product_name,
        Total_sales,
        lag(Total_sales) over (partition by product_name order by Order_year) as py_sales,
        round(avg(Total_sales) over (partition by product_name), 0) as avg_sales
    from Yearly_product_sales
)
select
    Order_year,
    product_name,
    Total_sales,
    py_sales,
    case when py_sales is null then null
         else Total_sales - py_sales end as diff_py,
    case
        when py_sales is null then 'No prior year'
        when Total_sales > py_sales then 'Increase'
        when Total_sales < py_sales then 'Decrease'
        else 'No change'
    end as py_sales_changes,
    avg_sales,
    Total_sales - avg_sales as avg_diff,
    case
        when Total_sales > avg_sales then 'Above avg'
        when Total_sales = avg_sales then 'Average'
        else 'Below avg'
    end as avg_vs_changes
from calc;

