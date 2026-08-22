/*
================================================================================
Customer Report
================================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend

================================================================================
*/
-- Base_query: joins fact_sales to dim_customers and computes each customer's
-- age from their birth date; filters out rows with no order date since
-- those aren't real completed transactions
drop view if exists gold.customer_report;
create view gold.customer_report as

with Base_query as (
select
s.product_key,
c.customer_key, 
s.Order_Number, 
s.Order_Date, 
s.Quantity, 
s.Sales_Amount, 
c.Customer_Number, 
concat(c.Customer_Firstname,' ',c.Customer_Lastname) as customer_name, 
c.customer_Marital_Status, 
c.Country, 
c.Customer_Gender, 
timestampdiff(year,c.Birth_Date, current_date()) as age
from gold.fact_sales as s
left join gold.dim_customers as c
on c.customer_key = s.customer_key
where order_date is not null),

-- calc: aggregates Base_query down to one row per customer with the core
-- volume metrics (orders, products, sales, quantity) and lifespan (months
-- between their first and last order)
calc as (

select
customer_key,
customer_number,
customer_name,
customer_gender,
age,
count(order_number) as total_orders,
count(distinct product_key) as total_products,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
max(order_date) as last_orderDate,
timestampdiff(month ,min(order_date) , max(order_date)) as lifespan
from Base_query
group by customer_key, customer_number, customer_name,customer_gender, age)

-- Final SELECT: derives the KPIs (AOV, average monthly spend, recency) and
-- categorical buckets (age_group, Customer_category) on top of calc's
-- aggregated metrics
select 
customer_key,
customer_number,
customer_name,
customer_gender,
age,
total_orders,
total_products,
total_sales,
total_quantity,
last_orderDate,
lifespan,
-- Average Order Value: total sales divided by total orders (avoids
-- divide-by-zero by returning 0 when there are no orders)
case 
	when total_orders = 0 then 0
    else round((total_sales / total_orders),2)
end as AOV,
-- Average monthly spend: total sales spread over the customer's lifespan in
-- months; if lifespan is 0 (all activity within the same month), the full
-- total_sales is used instead of dividing by zero
case
	when lifespan = 0 then total_sales
    else round(total_sales / lifespan,2)
end as monthly_Avg_sales,
-- Recency: months since the customer's last order
timestampdiff( month, last_orderDate, current_date) as recency,
-- Buckets customers into 10-year age bands
case
	when age < 20 then 'under - 20'
    when age between 20 and 29 then '20 - 30'
    when age between 30 and 39 then '30 - 40'
    when age between 40 and 49 then '40 - 50'
    when age between 50 and 59 then '50 - 60'
    when age between 60 and 69 then '60 - 70'
    else '70 - above'
end as age_group ,
-- Same VIP/Regular/New spending-tier logic used in the EDA segmentation query
case
	when total_sales > 5000 and lifespan >= 12 then 'VIP'
    when total_sales <= 5000 and lifespan >= 12 then 'Regular'
	else 'new'
end as Customer_category
from calc;

