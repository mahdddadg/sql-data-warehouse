# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

----
## 🌟 About Me

Hi, I'm **Mahdi Dehlaghi** — a **Data Analyst** Bachlor degree graduated (IT) and passionate about data engineering, analytics, and building scalable data solutions.

🔗 Connect with me:

* LinkedIn: https://www.linkedin.com/in/mahdi-dehlaghi-24b7153a2
* Notion (Project Planning): https://www.notion.so/Data-Warehouse-Project-By-Mahdi-Dehlaghi-356898b3c0bb80d29c05ed38893d9e83

---


## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into a SQL Server database.
2. **Silver Layer**: Includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema for reporting and analytics.

<img width="1120" height="1432" alt="DATA-architect drawio" src="https://github.com/user-attachments/assets/5129850e-0020-4730-8194-6f7cb42bd36a" />

   

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a modern data warehouse using Medallion Architecture (**Bronze**, **Silver**, **Gold**).
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.


---

## 🛠️ Important Links & Tools

Everything used in this project is free:

* **Datasets**: Available in the `/datasets` folder
* **SQL Server Express**: Lightweight database server
* **SQL Server Management Studio (SSMS)**: Database management tool
* **DrawIO**: For designing architecture and diagrams
* **Notion (Project Planning)**:
  👉 https://www.notion.so/Data-Warehouse-Project-By-Mahdi-Dehlaghi-356898b3c0bb80d29c05ed38893d9e83

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

**Objective:**
Develop a modern data warehouse using SQL Server to consolidate sales data and enable analytical reporting.

**Specifications:**

* Import data from ERP and CRM systems (CSV files)
* Clean and preprocess data before analysis
* Integrate data into a unified analytical model
* Focus on the latest dataset (no historization required)
* Document the data model clearly

---

### BI: Analytics & Reporting (Data Analysis)

**Objective:**
Develop SQL-based analytics to generate insights into:

* Customer Behavior
* Product Performance
* Sales Trends

These insights support better business decision-making.

---

## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/              # Raw datasets (ERP & CRM)
├── docs/                  # Documentation and architecture files
├── scripts/               # SQL scripts (Bronze, Silver, Gold layers)
├── tests/                 # Testing and data quality checks
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt
```

---

## 🛡️ License

This project is licensed under the MIT License.

---

