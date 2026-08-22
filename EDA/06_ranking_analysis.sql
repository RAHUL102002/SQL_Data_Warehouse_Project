/*
===============================================================================
EDA: Ranking Analysis
===============================================================================
Purpose:
    Identify top/bottom performers - the 5 highest and lowest revenue
    products, the top 10 revenue-generating customers, and the customers
    with the fewest orders placed.

Note:
    Includes an "alternate query" for the top-5-products question that
    solves it a different way (wrapped window function vs. direct ORDER BY);
    kept side by side for reference, not meant to both be run downstream.

Source:
    Extracted from EDA_Data_warehouse_project.sql - queries only, no code
    changed.
===============================================================================
*/

-- ======================================================================================
-- Ranking analysis
-- ======================================================================================

-- Which 5 products generate the highest revenue.

select 
 p.product_name,
 sum(s.sales_amount) as total_sales,
 row_number() over(order by sum(s.sales_amount) desc) as rn
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
group by p.product_name
;

-- alternate Query
select 
Product_name,
Total_sales
from
(select 
 p.product_name,
 sum(s.sales_amount) as total_sales,
 row_number() over(order by sum(s.sales_amount) desc) as rn
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
group by p.product_name)t
where rn <= 5
;



-- What are the 5 worst proforming products in the terms in sales.

select 
 p.product_name,
 sum(s.sales_amount) as total_sales
from gold.fact_sales as s
left join gold.dim_products as p
on s.product_key = p.product_key
group by p.product_name
order by sum(s.sales_amount)
limit 5;

-- Find the top 10 customers who have generated the highest revenue.
with RevenueByCustomers as (
select
c.customer_key,
concat(c.Customer_firstname,' ', c.customer_lastname) as Customer_name,
sum(s.Sales_amount) as Total_revenue,
row_number() over(order by sum(s.Sales_amount) desc ) as rn
from gold.fact_sales as s
left join gold.dim_customers as c
on c.customer_key = s.customer_key
group by c.customer_key, concat(c.Customer_firstname,' ', c.customer_lastname))

select 
Customer_key,
Customer_name,
Total_revenue
from RevenueByCustomers
where rn <= 10;

-- The 3 customers with the fewest orders placed
select *from
(select 
c.Customer_key,
Concat(c.Customer_firstname,' ',c.customer_lastname) as customer_name,
count(distinct order_number) as Total_orders
from gold.fact_sales as s
left join gold.dim_customers as c
on c.customer_key = s.Customer_key
group by c.Customer_key,
		Concat(c.Customer_firstname,' ',c.customer_lastname)
order by count(distinct order_number)  asc	)t
where Total_orders = 1
limit 3;

