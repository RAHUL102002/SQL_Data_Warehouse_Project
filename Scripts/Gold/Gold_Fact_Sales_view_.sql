/*
===============================================================================
Gold Layer View: Fact_Sales
===============================================================================
Purpose:
    Builds the sales fact table for the gold (reporting) layer by joining
    cleaned sales transactions to the customer and product dimensions,
    resolving natural keys down to the surrogate keys used in reporting.

Sources:
    - silver.crm_sales_details : cleaned sales transaction data
    - gold.dim_products         : joined on sls_prd_key = product_number
    - gold.dim_customers         : joined on sls_cust_id = customer_id

Grain:
    One row per sales order line (order number + product + customer).
===============================================================================
*/

create view Gold.Fact_Sales as 
SELECT
dp.product_key,
dc.customer_key,
sd.sls_ord_num as Order_Number,
sd.sls_order_dt as Order_Date,
sd.sls_ship_dt as Shipping_date,
sd.sls_due_dt as Due_date,
sd.sls_quantity as Quantity,
sd.sls_price as Price,
sd.sls_sales as Sales_Amount
FROM silver.crm_sales_details as sd
left join gold.dim_products as dp
on sd.sls_prd_key = dp.product_number
left join gold.dim_customers as dc
on sd.sls_cust_id = dc.customer_id
;
