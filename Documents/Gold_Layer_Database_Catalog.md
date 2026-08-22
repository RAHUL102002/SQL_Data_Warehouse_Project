
# Gold Layer Data Catalog

## 1. Gold Layer Overview

The **Gold Layer** represents the business-ready level of the data warehouse. It organizes validated and enriched information into **dimension** and **fact** tables, making the data suitable for analytical reporting, business intelligence, and downstream decision-making.

The Gold Layer contains the following core datasets:

- **`gold.dim_customers`** — Customer and demographic information
- **`gold.dim_products`** — Product and classification information
- **`gold.fact_sales`** — Sales transaction information

---

# 2. `gold.dim_customers`

### Business Purpose

The **`gold.dim_customers`** table provides a consolidated view of customer information. It combines core customer attributes with demographic and geographic details, creating a business-friendly customer dimension for analytical activities.

### Data Dictionary

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key used to uniquely identify a customer record within the dimension table. |
| `customer_id` | INT | Numeric identifier assigned to the customer for unique identification. |
| `customer_number` | NVARCHAR(50) | Alphanumeric customer reference used to identify and track the customer across the system. |
| `first_name` | NVARCHAR(50) | First name of the customer as maintained in the source system. |
| `last_name` | NVARCHAR(50) | Family name or surname associated with the customer. |
| `country` | NVARCHAR(50) | Country in which the customer resides, such as `'Australia'`. |
| `marital_status` | NVARCHAR(50) | Indicates the customer's marital status, such as `'Married'` or `'Single'`. |
| `gender` | NVARCHAR(50) | Gender information recorded for the customer, including values such as `'Male'`, `'Female'`, or `'n/a'`. |
| `birthdate` | DATE | Customer's date of birth, represented in `YYYY-MM-DD` format, for example `1971-10-06`. |
| `create_date` | DATE | Date and time associated with the creation of the customer record in the system. |

---

# 3. `gold.dim_products`

### Business Purpose

The **`gold.dim_products`** table contains descriptive information about the products available within the business. It combines product identifiers, classifications, pricing, maintenance information, and product-line attributes to support product-level analysis.

### Data Dictionary

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key that uniquely identifies a product record within the product dimension. |
| `product_id` | INT | Unique numeric identifier assigned to the product for internal reference and tracking. |
| `product_number` | NVARCHAR(50) | Structured alphanumeric reference used to identify and categorize a product. |
| `product_name` | NVARCHAR(50) | Name assigned to the product, including relevant characteristics such as type, color, and size. |
| `category_id` | NVARCHAR(50) | Identifier associated with the product's category and used to establish its classification. |
| `category` | NVARCHAR(50) | High-level classification used to group products, such as `Bikes` or `Components`. |
| `subcategory` | NVARCHAR(50) | More specific classification that identifies the product type within its broader category. |
| `maintenance_required` | NVARCHAR(50) | Indicates whether maintenance is required for the product, with values such as `'Yes'` or `'No'`. |
| `cost` | INT | Base cost or monetary value associated with the product, expressed in whole currency units. |
| `product_line` | NVARCHAR(50) | Identifies the product series or line to which the product belongs, such as `Road` or `Mountain`. |
| `start_date` | DATE | Date on which the product became available for sale or use. |

---

# 4. `gold.fact_sales`

### Business Purpose

The **`gold.fact_sales`** table captures individual sales transactions and their associated product, customer, quantity, pricing, and order-date information. It serves as the primary fact table for analyzing sales performance and transactional business metrics.

### Data Dictionary

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | Alphanumeric reference that uniquely identifies a sales order, such as `'SO54496'`. |
| `product_key` | INT | Surrogate key that connects each sales transaction to the corresponding product in `gold.dim_products`. |
| `customer_key` | INT | Surrogate key that connects each sales transaction to the corresponding customer in `gold.dim_customers`. |
| `order_date` | DATE | Date on which the customer order was placed. |
| `shipping_date` | DATE | Date on which the ordered product was shipped to the customer. |
| `due_date` | DATE | Date by which payment for the order was due. |
| `sales_amount` | INT | Total sales value recorded for the individual line item, expressed in whole currency units, such as `25`. |
| `quantity` | INT | Number of units of the product included in the individual sales line item, such as `1`. |
| `price` | INT | Unit selling price of the product for the individual sales line item, expressed in whole currency units, such as `25`. |

---

# 5. Gold Layer Table Structure

The Gold Layer can be viewed as a simple analytical model in which **dimension tables provide descriptive context** and the **fact table records measurable business activity**.

### Dimension Tables

| Table | Role |
|---|---|
| `gold.dim_customers` | Provides customer, demographic, and geographic attributes. |
| `gold.dim_products` | Provides product, category, pricing, and product-line attributes. |

### Fact Table

| Table | Role |
|---|---|
| `gold.fact_sales` | Stores sales transactions and measurable sales-related values. |

### Key Relationships

- `gold.fact_sales.product_key` → `gold.dim_products.product_key`
- `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`

This structure allows sales transactions to be analyzed from multiple business perspectives, including **customer**, **product**, **category**, **quantity**, **price**, and **sales amount**.
