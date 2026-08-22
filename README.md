# 🏗️ SQL Data Warehouse & Analytics Project

A modern **MySQL Data Warehouse** project that demonstrates the complete data lifecycle — from raw CSV ingestion through a layered (Bronze → Silver → Gold) ETL pipeline, SQL-based exploratory analysis, and a final business intelligence dashboard.

This project showcases industry-standard practices in **Data Engineering**, **Data Warehousing**, and **Business Analytics** by transforming raw, messy source data into a clean, query-ready analytical model — and then turning that model into insights stakeholders can actually act on.

---

## 📖 Project Overview

The goal of this project is to build a centralized data warehouse in **MySQL** by integrating data from two business source systems — a **CRM** and an **ERP** — using the **Medallion Architecture** (Bronze / Silver / Gold layers). The warehouse supports analytical reporting, business intelligence, and data-driven decision-making, and feeds directly into an interactive dashboard.

The project covers:
- Data Extraction (CSV → MySQL)
- Data Cleaning & Quality Checks
- Data Transformation & Standardization
- Data Integration (CRM + ERP)
- ETL Pipeline Development
- Dimensional Data Modeling (Star Schema)
- SQL-Based Exploratory Data Analysis
- Dashboard & Business Reporting

---

## 🎯 Project Objectives

- Build a modern, layered data warehouse using MySQL.
- Integrate data from multiple business source systems (CRM + ERP).
- Clean, deduplicate, and standardize raw datasets.
- Design an optimized dimensional (star schema) data model for reporting.
- Generate business insights using SQL analytics.
- Visualize key metrics in an interactive dashboard.

---

## 🛠️ Project Requirements

### 1️⃣ Data Engineering

**Objective:** Develop a modern MySQL data warehouse capable of consolidating business data into a centralized repository for analytical reporting and decision-making.

**Specifications:**
- Import data from two source systems: **ERP** and **CRM**.
- Source data is provided as CSV files.
- Profile, clean, and resolve data quality issues (nulls, duplicates, inconsistent codes, invalid dates) before loading.
- Integrate both sources into a single, unified analytical data model.
- Load only the latest available dataset — historical/versioned tracking is not in scope.
- Maintain clear documentation and inline comments throughout every script.

### 2️⃣ Data Analytics

**Objective:** Develop SQL-based analytical solutions and a dashboard that surface valuable business insights.

The analytics focus on:
- 👥 Customer Behavior & Segmentation
- 📦 Product Performance
- 📈 Sales Trends Over Time

These insights help stakeholders make informed, data-driven business decisions.

---

## 🏛️ Data Architecture

This project follows the **Medallion Architecture** (Bronze → Silver → Gold):

```
   ERP CSV Files                    CRM CSV Files
        │                                 │
        └───────────────┬─────────────────┘
                         ▼
              🥉 BRONZE LAYER
        Raw data loaded as-is from source
      (bronze.crm_*, bronze.erp_* tables)
                         │
                         ▼
              🥈 SILVER LAYER
   Cleaned, deduplicated, standardized data
   (nulls handled, types cast, codes mapped)
       (silver.crm_*, silver.erp_* tables)
                         │
                         ▼
              🥇 GOLD LAYER
     Business-ready star schema (views)
   gold.dim_customers · gold.dim_products
   gold.fact_sales · gold.customer_report
                         │
                         ▼
        📊 SQL Analytics (EDA) & Dashboard
```

**Star Schema (Gold Layer):**

```
                gold.dim_customers
                        │
                        │
gold.dim_products ──── gold.fact_sales
                        │
                        │
              gold.customer_report (view)
```

---

## 📂 Repository Structure

```
sql-data-warehouse-analytics/
│
├── datasets/                      # Raw source CSV files (ERP + CRM)
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql                       # Bronze table definitions
│   │   ├── bronze_crm_cust_info_cleaning.sql
│   │   ├── bronze_crm_product_info_cleaning.sql
│   │   ├── bronze_crm_sales_details_cleaning.sql
│   │   ├── bronze_erp_customer_az12_cleaning.sql
│   │   ├── bronze_erp_loction_a101_cleaning.sql
│   │   └── bronze_erp_px_category_g1v2_cleaning.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql                       # Silver table definitions
│   │   ├── silver_crm_cust_info_clean_data_inserted_.sql
│   │   ├── silver_crm_product_info_clean_data_inserted_.sql
│   │   ├── silver_erp_customer_az12_clean_data_inserted_.sql
│   │   ├── silver_erp_loction_a101_clean_data_inserted_.sql
│   │   ├── silver_erp_px_category_g1v2_clean_data_inserted_.sql
│   │   └── silver_sales_details_clean_data_inserted_.sql
│   │
│   └── gold/
│       ├── Gold_Dim_Customers_View_.sql
│       ├── gold_Dim_Products_view_.sql
│       ├── Gold_Fact_Sales_view_.sql
│       └── Gold_Customer_report_view.sql
│
├── eda/                            # SQL-based exploratory analysis
│   ├── 02_dimensions_exploration.sql
│   ├── 03_date_range_exploration.sql
│   ├── 04_measures_exploration.sql
│   ├── 05_magnitude_analysis.sql
│   ├── 06_ranking_analysis.sql
│   ├── 07_change_over_time_analysis.sql
│   ├── 08_cumulative_analysis.sql
│   ├── 09_performance_analysis.sql
│   ├── 10_data_segmentation.sql
│   └── 11_part_to_whole_analysis.sql
│
├── dashboard/
│   └── screenshots/
│       └── sales_customer_analytics_dashboard.png
│
├── docs/
│   └── data_architecture.png       # Bronze/Silver/Gold diagram
│
├── README.md
└── LICENSE
```

---

## ⚙️ Technologies Used

- MySQL
- SQL (DDL, DML, Window Functions, CTEs)
- CSV Files
- ETL Processes
- Data Warehousing (Medallion Architecture)
- Dimensional Data Modeling (Star Schema)
- Power BI / Dashboarding
- Business Analytics

---

## ✨ Key Features

- End-to-end MySQL data warehouse, built layer by layer (Bronze → Silver → Gold)
- Documented ETL pipeline with data quality checks at every stage
- Data cleaning, standardization, and deduplication logic
- CRM + ERP data integration into a single analytical model
- Star schema dimensional modeling for fast, simple reporting queries
- 10+ SQL exploratory analysis scripts covering measures, magnitude, ranking, trends, and segmentation
- Interactive business dashboard built on the Gold layer

---

## 📊 Dashboard: Sales & Customer Analytics

The Gold layer feeds directly into an interactive dashboard covering sales performance and customer behavior.
<img width="1544" height="872" alt="image" src="https://github.com/user-attachments/assets/822eef18-ca14-4338-931d-9293dafa8494" />


**Headline metrics:**

| Metric | Value |
|---|---|
| Total Sales | 29.35M |
| Total Quantity Sold | 60.37K |
| Total Products | 59K |
| Total Orders | 60K |
| Average Order Value (AOV) | 507.30 |
| Total Customers | 18.482K |

**What the dashboard covers:**
- Monthly sales trend vs. average sales trend, year over year
- Customer distribution by gender (49.01% female / 50.84% male / 0.15% unknown)
- Total orders and AOV broken down by customer category (New / Regular / VIP)
- Customer count and sales performance by age group
- Customer distribution by category — the "New" segment makes up 80.22% of customers, with Regular at 11.03% and VIP at 8.75%
- Year filters (2010–2014) and customer-category filters for interactive drill-down

**A quick read on the data:** the customer base skews heavily toward the "New" segment (80%+), while VIP customers — under 9% of the base — likely represent a disproportionate share of revenue given the AOV-by-category breakdown. That's the kind of gap a retention or loyalty campaign would typically target.

---

## 🧹 Data Quality & Cleaning Highlights

A few of the real-world data issues identified and resolved while building the Silver layer:
- Duplicate customer records → deduplicated via `ROW_NUMBER()`, keeping the most recent record per customer
- Inconsistent/coded values (e.g. `'S'`/`'M'`, `'F'`/`'M'`) → standardized into readable labels (`single`/`married`, `female`/`male`)
- Sales stored as raw integer dates (`YYYYMMDD`) → validated and cast to proper `DATE` types
- Sales/Quantity/Price inconsistencies → recalculated using the rule `Sales = Quantity × Price` wherever the original values were missing, zero, negative, or inconsistent
- ERP customer IDs with source-system prefixes (`NAS...`) → stripped to match the CRM key format for joining
- Country name inconsistencies (`'DE'`, `'USA'`, `'US'`) → standardized into full, consistent country names

---

## 📈 Skills Demonstrated

- MySQL & SQL (DDL, DML, window functions, CTEs, views)
- Data Warehousing (Medallion Architecture)
- ETL Development
- Data Cleaning & Data Quality Validation
- Data Transformation & Standardization
- Data Integration (multi-source)
- Dimensional Data Modeling (Star Schema)
- Exploratory Data Analysis (SQL)
- Business Intelligence Dashboarding
- Query Optimization

---

## 📊 Business Value

The completed data warehouse and dashboard provide:
- A centralized, trustworthy source of truth across CRM and ERP data
- Faster, simpler analytical queries via a star schema
- Improved data consistency and quality
- Clear visibility into sales trends, customer segments, and product performance
- A scalable foundation for future analytics or BI tooling
- Data-driven inputs for decisions like retention campaigns, pricing, and inventory planning

---

## 👨‍💻 Author

**Rahul**
🔗 **LinkedIn:** [linkedin.com/in/rahul-rahul-r05102002](https://www.linkedin.com/in/rahul-rahul-r05102002)

---

## ⭐ Support

If you found this project helpful, consider giving it a ⭐ on GitHub!

---

## 📄 License

This project is licensed under the MIT License.
