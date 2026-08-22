/*
===============================================================================
EDA: Data Segmentation Analysis
===============================================================================
Purpose:
    Segment products into cost ranges (and count products per range), and
    segment customers into VIP / Regular / New tiers based on spending and
    lifespan, then count customers per tier.

Source:
    Extracted from EDA_Data_warehouse_project.sql - queries only, no code
    changed.
===============================================================================
*/

-- ======================================================================================
-- Data Segmentation analysis
-- ======================================================================================

/*Segment products into cost ranges and
count how many products fall into each segment*/
with Product_seg as (
select 
Product_key,
Product_name,
cost,
case
	when cost < 100 then 'Below - 100'
    when cost between 100 and 500 then '100 - 500'
    when cost between 500 and 1000 then '500 - 1000'
    else 'above - 1000'
end as cost_range
from gold.dim_products)
select 
cost_range ,
count(Product_key) as Total_customers
from product_seg
group by cost_range
order by Total_customers desc;


/*Group customers into three segments based on their spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than €5,000.
    - Regular: Customers with at least 12 months of history but spending €5,000 or less.
    - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

-- lifespan = months between each customer's first and last order; combined
-- with total spending, this drives the VIP/Regular/New segmentation below
with customer_seg as (
select
c.customer_key,
sum(s.sales_amount) as Total_spending,
min(s.Order_date) as First_orderDate,
max(s.Order_date) as Last_orderDate,
TIMESTAMPDIFF(month ,min(s.Order_date), max(s.Order_date) ) as lifespan
from gold.fact_sales as s
left join gold.dim_customers as c
on s.customer_key = c.customer_key
group by c.customer_key ),

Calc as (
select 
*,
case
	when Total_spending > 5000 and lifespan >= 12 then 'VIP'
    when Total_spending <= 5000 and lifespan >= 12 then 'Regular'
	else 'new'
end as Customer_category
from customer_seg)

select 
	Customer_category,
    count(customer_key) as Total_customer
from Calc
group by Customer_category
order by count(customer_key);

