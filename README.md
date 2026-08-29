# 🏗️ SQL Data Warehouse & Analytics

<p align="center">
  <img src="https://img.shields.io/badge/SQL%20Server-Data%20Warehouse-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/ETL-Data%20Pipelines-2563EB?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Analytics-SQL-0F766E?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Architecture-Bronze%20%7C%20Silver%20%7C%20Gold-7C3AED?style=for-the-badge"/>
</p>

<p align="center">
  <strong>Transform raw ERP & CRM data into analytics-ready business intelligence.</strong>
</p>

<p align="center">
  A portfolio project demonstrating data warehousing, ETL, data quality, dimensional modeling,
  and SQL-based business analysis.
</p>

---

## 🎯 Business Problem

Raw operational data is often distributed across different systems, contains quality issues, and is difficult to use directly for reporting.

This project builds a structured analytical warehouse that answers business questions around:

- 👥 Customer behavior
- 📦 Product performance
- 💰 Sales performance
- 📈 Sales trends
- 🔄 Data quality and transformation

The objective is to move from **raw source data → trusted analytical data → business insight**.

---

# 🏛️ Data Architecture

This project follows a **Medallion Architecture** with three layers:

```text
┌─────────────────────────────┐
│       SOURCE SYSTEMS        │
│      ERP + CRM CSVs         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       🥉 BRONZE LAYER       │
│                             │
│ Raw data                   │
│ Minimal transformation      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       🥈 SILVER LAYER       │
│                             │
│ Cleaning                    │
│ Standardization             │
│ Deduplication               │
│ Data quality checks         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         🥇 GOLD LAYER       │
│                             │
│ Business-ready data         │
│ Star schema                 │
│ Fact + Dimension tables      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       📊 ANALYTICS          │
│                             │
│ SQL Reports & Insights      │
└─────────────────────────────┘
```

The repository includes architecture documentation under `docs/`, including data architecture, data flow, ETL, data models, and the data catalog. fileciteturn11file0L2-L2

---

# 🔄 ETL Pipeline

```text
CSV SOURCE FILES
      │
      ▼
   EXTRACT
      │
      ▼
🥉 BRONZE
      │
      │ Clean + Validate
      ▼
🥈 SILVER
      │
      │ Model + Integrate
      ▼
🥇 GOLD
      │
      ▼
SQL ANALYTICS
      │
      ▼
BUSINESS INSIGHTS
```

### Bronze — Raw

Source data is loaded with minimal changes so the original information remains available for downstream processing.

### Silver — Cleaned

Data quality problems are addressed through cleaning, standardization, normalization, and validation.

### Gold — Business Ready

Cleaned data is transformed into analytical models designed for efficient reporting and business analysis.

---

# ⭐ Data Modeling

The Gold layer follows a **star-schema approach**:

```text
                 ┌──────────────┐
                 │ Dim Customer │
                 └──────┬───────┘
                        │
                        │
┌──────────────┐   ┌────▼─────┐   ┌──────────────┐
│ Dim Product  ├──►│Fact Sales│◄──┤ Dim Date    │
└──────────────┘   └────┬─────┘   └──────────────┘
                        │
                        ▼
                 Sales Analytics
```

This separates descriptive dimensions from measurable business events and makes analytical queries easier to understand and maintain.

---

# 🧹 Data Quality

The transformation layer focuses on common real-world data problems such as:

- Missing or invalid values
- Inconsistent formats
- Duplicate records
- Invalid dates
- Incorrect or inconsistent categorical values
- Data type inconsistencies
- Source-system integration issues

The goal is not simply to load data, but to create a **trusted analytical layer**.

---

# 📊 Analytics & Business Questions

The analytical layer is designed to answer questions such as:

### 👥 Customer Analysis

- Who are the highest-value customers?
- How does customer activity change over time?
- Which customer groups contribute the most sales?

### 📦 Product Analysis

- Which products generate the most revenue?
- Which categories perform best?
- Which products may require attention?

### 💰 Sales Analysis

- What are the overall sales trends?
- How does performance change over time?
- Which products and customers drive revenue?

---

# 🧠 SQL Skills Demonstrated

This project is designed to demonstrate practical analytical SQL, including:

```text
JOINs
GROUP BY
CASE expressions
CTEs
Subqueries
Aggregations
Window Functions
ROW_NUMBER()
RANK()
LAG()
LEAD()
SUM() OVER()
AVG() OVER()
Date / time analysis
Data quality validation
```

The emphasis is on using SQL to answer **business questions**, not simply writing syntactically correct queries.

---

# 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/
│   └── ERP + CRM source CSVs
│
├── docs/
│   ├── data_architecture.drawio
│   ├── data_flow.drawio
│   ├── data_models.drawio
│   ├── etl.drawio
│   ├── data_catalog.md
│   ├── naming-conventions.md
│   └── requirements.md
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/
├── README.md
├── LICENSE
└── requirements.txt
```

---

# 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **SQL Server** | Data warehouse database |
| **T-SQL** | ETL and analytics |
| **SSMS** | Database development and management |
| **Draw.io** | Architecture and data-model diagrams |
| **Git/GitHub** | Version control and documentation |

---

# 🚀 Getting Started

## Prerequisites

- SQL Server Express or another compatible SQL Server installation
- SQL Server Management Studio (SSMS)
- Git

## Workflow

```text
1. Clone repository
       ↓
2. Load source CSV files
       ↓
3. Execute Bronze scripts
       ↓
4. Run Silver transformations
       ↓
5. Build Gold analytical models
       ↓
6. Run analytical SQL scripts
       ↓
7. Explore business insights
```

---

# 📈 Why This Project Matters for Analytics

A strong analyst needs to understand not only how to query data, but also **where the data comes from and how trustworthy it is**.

This project demonstrates the complete path:

**Source Systems → ETL → Data Quality → Data Modeling → SQL → Business Insights**

That makes the project relevant to both **Data Analyst** and **BI / Analytics** roles.

---

# 🔮 Future Improvements

- [ ] Connect the Gold layer to Power BI
- [ ] Add automated data-quality reporting
- [ ] Add incremental ETL processing
- [ ] Add more advanced customer analytics
- [ ] Add scheduled pipeline execution
- [ ] Add automated testing for transformation rules
- [ ] Add an executive BI dashboard

---

# 👨‍💻 Author

**M Naveenkumar**  
CSE Student | Aspiring Data Analyst | SQL | Python | Business Intelligence

🔗 [GitHub](https://github.com/Naveenkumar2028)

🔗 [LinkedIn](https://www.linkedin.com/in/m-naveenkumar-aa1b923b4)

---

<p align="center">

### 🗄️ Raw Data → Clean Data → Analytics → Business Decisions 📊

</p>
