# customer-churn-analysis-sql

## Project Overview

**Project Title**: Customer Churn Analysis  
**Database**: `customer_churn_analysis`  
**Table**: `c_churn`  
**SQL Dialect**: MySQL

This project demonstrates SQL skills and techniques typically used by data analysts to explore and analyze customer churn data for a subscription-based (telecom-style) business. It covers setting up the database, exploring the data, answering business questions with aggregations and window functions, normalizing the data into separate tables, and combining them again with JOINs. It is ideal for anyone building a solid foundation in SQL and wanting to understand *why customers leave*.

## Objectives

1. **Set up a customer churn database**: Create a database and load the churn dataset into the `c_churn` table.
2. **Exploratory Data Analysis (EDA)**: Understand the size and structure of the dataset and how customers are distributed across contract types.
3. **Churn Analysis**: Calculate churn rates by contract type, internet service and payment method to find high-risk segments.
4. **Advanced SQL**: Use window functions (`RANK()`), `HAVING`, and conditional aggregation.
5. **Data Modeling**: Split the flat table into `customers`, `services` and `billing` tables and combine them with JOINs to answer business questions.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `customer_churn_analysis`.
- **Table**: The dataset is imported into a table named `c_churn` (one row per customer).

```sql
CREATE DATABASE customer_churn_analysis;
USE customer_churn_analysis;

SELECT * FROM c_churn;
```

**Columns in `c_churn`**

| Group | Columns |
|-------|---------|
| Customer | `customerid`, `gender`, `seniorcitizen`, `partner`, `dependents`, `tenure` |
| Services | `phoneservice`, `multiplelines`, `internetservice`, `onlinesecurity`, `onlinebackup`, `deviceprotection`, `techsupport`, `streamingtv`, `streamingmovies` |
| Billing | `contract`, `paperlessbilling`, `paymentmethod`, `monthlycharges`, `totalcharges`, `churn` |

### 2. Data Exploration

- **Customer Count**: Total number of customers in the dataset.
- **Contract Distribution**: Number of customers in each contract type.

```sql
-- 1. How many customers are in the dataset?
SELECT COUNT(*) AS total_customers
FROM c_churn;

-- 2. How many customers are there in each contract type?
SELECT contract, COUNT(*) AS customers
FROM c_churn
GROUP BY contract
ORDER BY customers DESC;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions.

#### 3.1 Churn vs. Charges

3. **Do churned customers have higher monthly charges?**
```sql
SELECT churn, ROUND(AVG(monthlycharges), 2) AS avg_monthly_charges
FROM c_churn
GROUP BY churn;
```

4. **How does total customer value differ by churn status?**
```sql
SELECT churn, ROUND(AVG(totalcharges), 2) AS avg_total_charges
FROM c_churn
GROUP BY churn;
```

5. **Who are the top 10 highest-paying customers who churned?**
```sql
SELECT customerid, contract, monthlycharges, totalcharges
FROM c_churn
WHERE churn = 'yes'
ORDER BY monthlycharges DESC
LIMIT 10;
```

#### 3.2 Churn Rate by Segment

6. **Which contract type has the highest churn rate?**
```sql
SELECT contract,
       COUNT(*) AS customers,
       SUM(churn = 'yes') AS churned,
       ROUND(SUM(churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM c_churn
GROUP BY contract
ORDER BY churn_rate DESC;
```

7. **Which internet service has the highest churn rate?**
```sql
SELECT internetservice,
       COUNT(*) AS customers,
       SUM(churn = 'yes') AS churned,
       ROUND(SUM(churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM c_churn
GROUP BY internetservice
ORDER BY churn_rate DESC;
```

8. **Which payment method has the highest churn rate?**
```sql
SELECT paymentmethod,
       COUNT(*) AS customers,
       SUM(churn = 'yes') AS churned,
       ROUND(SUM(churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM c_churn
GROUP BY paymentmethod
ORDER BY churn_rate DESC;
```

#### 3.3 Ranking with Window Functions

9. **Rank contract types by churn rate**
```sql
SELECT contract,
       ROUND(SUM(churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate,
       RANK() OVER (ORDER BY SUM(churn = 'yes') * 100 / COUNT(*) DESC) AS churn_rank
FROM c_churn
GROUP BY contract;
```

10. **Rank internet services by churn rate**
```sql
SELECT internetservice,
       ROUND(SUM(churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate,
       RANK() OVER (ORDER BY SUM(churn = 'yes') * 100 / COUNT(*) DESC) AS churn_rank
FROM c_churn
GROUP BY internetservice;
```

#### 3.4 Filtering

11. **Which customers have both a partner and dependents?**
```sql
SELECT customerid, gender, tenure, contract, churn
FROM c_churn
WHERE partner = 'yes' AND dependents = 'yes';
```

12. **Which contract has more than 1,000 customers?**
```sql
SELECT contract, COUNT(*) AS customers
FROM c_churn
GROUP BY contract
HAVING COUNT(*) > 1000;
```

### 4. Data Modeling: Splitting the Table

To practice working with relational data, `c_churn` is split into three tables linked by `customerid`:

```sql
CREATE TABLE customers AS
SELECT customerid, gender, seniorcitizen, partner, dependents, tenure
FROM c_churn;

CREATE TABLE services AS
SELECT customerid, phoneservice, multiplelines, internetservice, onlinesecurity,
       onlinebackup, deviceprotection, techsupport, streamingtv, streamingmovies
FROM c_churn;

CREATE TABLE billing AS
SELECT customerid, contract, paperlessbilling, paymentmethod,
       monthlycharges, totalcharges, churn
FROM c_churn;
```

| Table | Purpose |
|-------|---------|
| `customers` | Demographic details of each customer |
| `services` | Phone, internet and add-on services subscribed |
| `billing` | Contract, payment, charges and churn status |

### 5. JOIN Analysis

13. **Combine customer and service information**
```sql
SELECT c.customerid, c.gender, c.tenure, s.internetservice, s.onlinesecurity
FROM customers c
JOIN services s ON c.customerid = s.customerid;
```

14. **Combine customer and billing information**
```sql
SELECT c.customerid, c.gender, c.tenure, b.contract, b.monthlycharges, b.churn
FROM customers c
JOIN billing b ON c.customerid = b.customerid;
```

15. **Which internet service has the highest churn rate (using JOIN)?**
```sql
SELECT s.internetservice,
       COUNT(*) AS customers,
       SUM(b.churn = 'yes') AS churned,
       ROUND(SUM(b.churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM services s
JOIN billing b ON s.customerid = b.customerid
GROUP BY s.internetservice
ORDER BY churn_rate DESC;
```

16. **Analyze churn by contract (using JOIN)**
```sql
SELECT b.contract,
       COUNT(*) AS customers,
       ROUND(SUM(b.churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM customers c
JOIN billing b ON c.customerid = b.customerid
GROUP BY b.contract
ORDER BY churn_rate DESC;
```

17. **Final business query: customer + service + billing**
```sql
SELECT c.gender, s.internetservice, b.contract,
       COUNT(*) AS customers,
       ROUND(SUM(b.churn = 'yes') * 100 / COUNT(*), 2) AS churn_rate
FROM customers c
JOIN services s ON c.customerid = s.customerid
JOIN billing b ON c.customerid = b.customerid
GROUP BY c.gender, s.internetservice, b.contract
ORDER BY churn_rate DESC;
```

## Findings

- **Contract Type**: Customers are split across month-to-month, one-year and two-year contracts; comparing churn rates across them highlights which commitment level keeps customers longest.
- **Charges vs. Churn**: Comparing average monthly and total charges for churned vs. retained customers shows whether higher-paying customers are more likely to leave.
- **Service & Payment Segments**: Churn rates by internet service and payment method pinpoint the segments with the highest risk.
- **High-Value Churners**: The top churned customers by monthly charges represent the biggest revenue loss and are good targets for win-back campaigns.
- **Combined View**: The final 3-table JOIN reveals which combination of gender, internet service and contract has the highest churn.

## Reports

- **Churn Summary**: Overall customer count and churn rate by contract, internet service and payment method.
- **Revenue Insights**: Average monthly and lifetime charges by churn status.
- **Segment Analysis**: Ranked churn rates and multi-dimension churn breakdown for retention planning.

## Conclusion

This project is an introduction to SQL for churn analytics: exploring data, measuring churn with conditional aggregation, ranking segments with window functions, and building a small relational model joined back together with JOINs. The insights can help a business understand why customers leave and where to focus retention efforts.
