/*
===============================================================================
Gold Layer View: Dim_Products
===============================================================================
Purpose:
    Builds the product dimension for the gold (reporting) layer by combining
    cleaned CRM product data with ERP category reference data.

Sources:
    - silver.crm_product_info      : product master data (name, cost, line,
                                      start date, category_key)
    - silver.erp_px_category_g1v2  : category / sub-category / maintenance
                                      lookup, joined on category_key = id

Logic:
    - Generates a surrogate 'product_key' via ROW_NUMBER(), ordered by
      start date then product number, since the source systems don't
      provide one.
    - Only includes CURRENT products: rows where prd_end_date IS NULL are
      kept, which filters out historical/superseded product versions
      (see silver.crm_product_info's end-date logic, derived via LEAD).
===============================================================================
*/

create view gold.Dim_Products as
select
	row_number() over(order by pi.prd_start_date , pi.sls_prd_key) as product_key,
	pi.prd_id as Product_id,
	pi.sls_prd_key as product_Number,
	pi.prd_nm as Product_name,
	pi.category_key as Category_id ,
	pcg.category as Category,
	pcg.sub_category,
	pcg.maintenance,
	pi.prd_cost as Cost,
	pi.prd_line as Product_line,
	pi.prd_start_date as Product_Start_date
FROM silver.crm_product_info as pi
left join silver.erp_px_category_g1v2 as pcg
on pi.category_key = pcg.id
where pi.prd_end_date is null
;
