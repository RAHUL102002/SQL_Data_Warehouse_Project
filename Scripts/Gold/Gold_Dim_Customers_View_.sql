/*
===============================================================================
Gold Layer View: Dim_Customers
===============================================================================
Purpose:
    Builds the customer dimension for the gold (reporting) layer by combining
    cleaned CRM customer data with ERP demographic and location data.

Sources:
    - silver.crm_cust_info    : primary customer record (name, marital
                                 status, gender, create date)
    - silver.erp_customer_az12: gender/birth date fallback, joined on
                                 cust_key = cust_id
    - silver.erp_loction_a101 : country, joined on cust_key = cust_id

Logic:
    - Generates a surrogate 'customer_key' via ROW_NUMBER() ordered by
      cust_key, since the source systems don't provide one.
    - Prefers the CRM's gender value; falls back to the ERP gender value
      only when CRM gender is 'Unknown' (and defaults to 'Unknown' if both
      are missing).
===============================================================================
*/

Create view Gold.Dim_Customers as 
select 
row_number() over(order by cust_key) as customer_key,
ci.cust_id as Customer_id,
ci.cust_key as Customer_Number,
ci.cust_firstname as Customer_Firstname,
ci.cust_lastname as Customer_Lastname,
ci.cust_marital_status as customer_Marital_Status,
la.country as Country,
case
	when ci.cust_gender != 'Unknown' then ci.cust_gender
    else coalesce(ca.gender,'Unknown')
end as Customer_Gender,
ca.Birth_Date,
ci.cust_create_date
from silver.crm_cust_info as ci
left join silver.erp_customer_az12 as ca
on ci.cust_key = ca.cust_id
left join silver.erp_loction_a101 as la
on ci.cust_key = la.cust_id
;  
