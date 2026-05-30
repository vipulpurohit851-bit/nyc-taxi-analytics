# 🚕 NYC Taxi Analytics Project

## 📌 Project Overview

This project analyzes NYC Yellow Taxi trip data from 2021–2023 using Python, Snowflake SQL, and Tableau.

The objective is to identify demand patterns, revenue drivers, customer behavior, and route efficiency through end-to-end data analytics.

---

## 🎯 Problem Statement

NYC generates millions of taxi trips annually. Understanding demand trends, customer payment behavior, and revenue efficiency can help optimize operations and improve profitability.

This project answers:

- Which locations generate the highest revenue?
- What are the busiest pickup and dropoff zones?
- Which routes are most profitable?
- How do tips vary by payment type?
- Which boroughs operate most efficiently?

---

## 🛠️ Technology Stack

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Snowflake SQL
- Tableau
- GitHub

---

## 📂 Dataset

Dataset: NYC Yellow Taxi Trip Records

Source:
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

Period:
- 2021
- 2022
- 2023

---

## 🐍 Python EDA

Performed:

- Data Cleaning
- Missing Value Handling
- Feature Engineering
- Demand Analysis
- Revenue Analysis
- Customer Behavior Analysis
- Route Analysis

Notebook:

```text
notebooks/NYC_Taxi_EDA.ipynb
```

---

## ❄️ Snowflake SQL Analysis

Performed:

- Revenue Analysis
- Trip Analysis
- Route Analysis
- Payment Analysis
- Borough Analysis

SQL File:

```text
sql/NYC_TAXI_ANALYSIS.sql
```

---

# 📊 Dashboard 1 – Executive Overview

![Dashboard 1](dashboard_images/dashboard_1_executive_overview.png)

### Insights

- Generated over $2.5B revenue
- Completed 106M+ trips
- Credit card payments dominate revenue generation

---

# 📊 Dashboard 2 – Demand Analysis

![Dashboard 2](dashboard_images/dashboard_2_demand_analysis.png)

### Insights

- Lowest demand occurs between 3AM–5AM
- Evening rush exceeds morning rush
- Daytime accounts for most trips

---

# 📊 Dashboard 3 – Location & Route Insights

![Dashboard 3](dashboard_images/dashboard_3_location_route_insights.png)

### Insights

- Manhattan dominates taxi activity
- Airport routes generate highest revenue
- JFK routes are highly profitable

---

# 📊 Dashboard 4 – Revenue Efficiency & Customer Behavior

![Dashboard 4](dashboard_images/dashboard_4_revenue_efficiency.png)

### Insights

- EWR generates highest revenue per mile
- Credit card users provide higher tips
- Revenue efficiency matrix identifies top-performing zones

---

## 📁 Project Structure

```text
NYC-Taxi-Analytics
│
├── dashboard_images
├── notebooks
├── sql
├── tableau
├── README.md
└── requirements.txt
```

---

## 👨‍💻 Author

Vipul Rajpurohit

BCA | Data Analytics Enthusiast

Skills:
Python | SQL | Snowflake | Tableau | Excel
