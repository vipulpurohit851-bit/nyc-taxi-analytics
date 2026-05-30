# 🚕 NYC Taxi Analytics 2021–2023
### End-to-End Data Analytics | 106 Million Trips | Python • Snowflake • SQL • Tableau

![Banner](dashboard_images/dashboard1.png)

---

## 🔗 Quick Access Links

| Resource | Link |
|---|---|
| 📊 **Live Tableau Dashboard** | [Click to View Dashboard](YOUR_TABLEAU_PUBLIC_URL) |
| 📓 **Python EDA Notebook** | [Click to View on Colab](https://colab.research.google.com/drive/1ht40cdzSkwUeO6schjpkF9StEwuu6V6p?usp=sharing) |
| ❄️ **Snowflake SQL Analysis** | [Click to View SQL](https://github.com/vipulpurohit851-bit/nyc-taxi-analytics/blob/main/NYC_TAXI_ANALYSIS.sql) |

---

## 📌 Problem Statement

> NYC Taxi revenue dropped significantly during COVID-19 in 2020.
> As a Data Analyst, analyze the **recovery pattern from 2021 to 2023**,
> identify key revenue drivers, understand passenger demand patterns,
> and provide **actionable business recommendations**.

---

## 🔑 Key Business Findings

| Metric | Result |
|---|---|
| 💰 Total Revenue | **$2.51 Billion** |
| 🚕 Total Trips | **106 Million** |
| 📈 Revenue Growth | **+79% from 2021→2023** |
| 🏆 Best Year | **2023 crossed $1 Billion revenue** |
| ⏰ Peak Hour | **6 PM (7.5M trips)** |
| 📅 Busiest Day | **Thursday ($395M revenue)** |
| ✈️ Top Revenue Route | **JFK Airport routes** |
| 💳 Payment Trend | **Credit card grew 73%→80%** |
| 🗺️ Top Pickup Zone | **Upper East Side South (5.1M trips)** |

---

## 📊 Dashboards

### Dashboard 1 — Executive Overview
> KPI Cards • Monthly Revenue Trend • Payment Analysis • Weekday Revenue

![Dashboard 1](dashboard_images/dashboard1.png)

---

### Dashboard 2 — Demand Analysis
> Hourly Pattern • Rush Hour Analysis • Heatmap • Day vs Night

![Dashboard 2](dashboard_images/dashboard2.png)

---

### Dashboard 3 — Location & Route Insights
> Top 10 Pickup Zones • Top 10 Dropoff Zones • Top Routes by Trips & Revenue

![Dashboard 3](dashboard_images/dashboard3.png)

---

### Dashboard 4 — Revenue Efficiency & Customer Behavior
> Revenue Matrix • Revenue Per Mile • Tip by Borough • Payment Analysis

![Dashboard 4](dashboard_images/dashboard4.png)

---

## 🐍 Phase 1 — Python EDA & Cleaning

📓 **[Open Full Notebook on Google Colab](https://colab.research.google.com/drive/1ht40cdzSkwUeO6schjpkF9StEwuu6V6p?usp=sharing)**

**Sampling Strategy:**
```
36 parquet files × 50,000 rows each = 1.8 Million sample rows
Full 106M rows → loaded into Snowflake
```

**Cleaning Performed:**
```
✅ Dropped airport_fee column (99% null)
✅ Filled nulls → passenger_count, RatecodeID,
                  store_and_fwd_flag, congestion_surcharge
✅ Removed wrong year entries (2002, 2008, 2070)
✅ Filtered valid fare ($1–$500)
✅ Filtered valid distance (0.1–100 miles)
✅ Filtered valid tip ($0–$200)
✅ Final clean rows → 106,140,252
```

---

## ❄️ Phase 2 — Snowflake Data Warehouse

📄 **[Open Full SQL File](https://github.com/vipulpurohit851-bit/nyc-taxi-analytics/blob/main/NYC_TAXI_ANALYSIS.sql)**

```sql
Database  : NYC_TAXI_DB
Schema    : NYC_SCHEMA
Table     : TRIPS        → 108,870,632 raw rows
View      : TRIPS_CLEAN  → 106,140,252 clean rows
```

**Data Loading Process:**
```
36 Parquet files
      ↓
Snowflake Internal Stage
      ↓
COPY INTO TRIPS table
      ↓
TRIPS_CLEAN view (cleaning applied)
      ↓
SQL Analysis
```

---

## 🔍 Phase 3 — SQL Analysis (20 Queries)

📄 **[View All SQL Queries](https://github.com/vipulpurohit851-bit/nyc-taxi-analytics/blob/main/NYC_TAXI_ANALYSIS.sql)**

| # | Business Question | Finding |
|---|---|---|
| Q1 | YoY Revenue & Trip Growth | Revenue +79% over 3 years |
| Q2 | Avg Fare, Tip & Distance | Fare up 47% (2021→2023) |
| Q3 | Revenue Per Trip | $19.70 → $28.91 (+47%) |
| Q4 | Monthly Trip Trends | Oct peak, Jan lowest |
| Q5 | Hourly Demand | 6 PM = peak hour |
| Q6 | Day of Week Revenue | Thursday highest |
| Q7 | Rush Hour Analysis | 41.59% trips in rush hours |
| Q8 | Late Night vs Daytime | 92.7% daytime trips |
| Q9 | Payment Split by Year | Card 73%→80% |
| Q10 | Tip by Payment Type | Card $3.68 vs Cash $0.00 |
| Q11 | Top Premium Routes | Newark Airport highest fare |
| Q12 | Zero Tip Analysis | 23.61% zero tip |
| Q13 | Top Pickup Zones | Upper East Side South #1 |
| Q14 | Top Dropoff Zones | Upper East Side North #1 |
| Q15 | Most Popular Route | UES South → UES North |
| Q16 | Longest Distance Zones | Charleston/Tottenville |
| Q17 | Data Quality | Handled in TRIPS_CLEAN view |
| Q18 | Avg Trip Duration | ~14 minutes average |
| Q19 | Airport Analysis | JFK = 2nd busiest pickup |
| Q20 | Vendor Performance | Vendor 2 leads in trips |

---

## 🛠️ Tech Stack

```
📊 Python    → Pandas, NumPy, Matplotlib, Seaborn
              (EDA & Cleaning on 1.8M sample)

❄️ Snowflake → Cloud Data Warehouse
              (Full 106M rows stored & queried)

🔍 SQL       → 20 Business Queries
              (Window functions, CTEs, DENSE_RANK, LAG)

📈 Tableau   → 4 Interactive Dashboards
              (Published on Tableau Public)
```

---

## 💡 Business Recommendations

```
1. Surge pricing during 5–8 PM evening rush
2. Increase fleet capacity before May (peak season)
3. Promote cashless payments → card users tip 3x more
4. Focus driver deployment in Manhattan & JFK corridor
5. Review minimum fare for trips under 1 mile (21% of trips)
```

---

## 📁 Repository Structure

```
nyc-taxi-analytics/
│
├── 📓 notebooks/
│   └── nyc_texi_Analysis1.ipynb    ← Python EDA & Cleaning
│
├── 📄 NYC_TAXI_ANALYSIS.sql        ← 20 SQL Business Queries
│
├── 📊 Nyc_texi.twb                 ← Tableau Workbook
│
├── 📁 dashboard_images/
│   ├── dashboard1.png              ← Executive Overview
│   ├── dashboard2.png              ← Demand Analysis
│   ├── dashboard3.png              ← Location & Routes
│   └── dashboard4.png              ← Revenue Efficiency
│
└── 📄 README.md
```

---

## 👨‍💻 Author

**Vipul Purohit**
BCA Graduate | Aspiring Data Analyst

🔧 **Skills:** Python | SQL | Snowflake | Tableau | Power BI | Excel

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Vipul_Purohit-blue?style=for-the-badge&logo=linkedin)](YOUR_LINKEDIN_URL)
[![Tableau](https://img.shields.io/badge/Tableau-Dashboard-orange?style=for-the-badge&logo=tableau)](YOUR_TABLEAU_PUBLIC_URL)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-black?style=for-the-badge&logo=github)](https://github.com/vipulpurohit851-bit)

---

⭐ *If you found this project helpful, please give it a star!*
