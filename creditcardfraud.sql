CREATE DATABASE creditcard_analysis;

USE creditcard_analysis;

CREATE TABLE creditcard_data (
    Time FLOAT,
    V1 FLOAT, V2 FLOAT, V3 FLOAT, V4 FLOAT, V5 FLOAT, V6 FLOAT, V7 FLOAT,
    V8 FLOAT, V9 FLOAT, V10 FLOAT, V11 FLOAT, V12 FLOAT, V13 FLOAT, V14 FLOAT,
    V15 FLOAT, V16 FLOAT, V17 FLOAT, V18 FLOAT, V19 FLOAT, V20 FLOAT, V21 FLOAT,
    V22 FLOAT, V23 FLOAT, V24 FLOAT, V25 FLOAT, V26 FLOAT, V27 FLOAT, V28 FLOAT,
    Amount FLOAT,
    Class INT
);

select * from creditcard_data;

-- SQL Analysis Queries/ Data analysis--

-- view first few rows
select * from creditcard_data limit 10;

-- Check total transactions and columns
select count(*) as total_transactions from creditcard_data;

-- Check number of fraud vs. non-fraud cases
select class, count(*) as transaction_count, round(count(*) * 100 / (select count(*) from creditcard_data) ,4)
as percentage from creditcard_data group by class;

-- Transaction Amount Analysis
-- Average, minimum, and maximum transaction amount
select class,
 round(avg(amount), 2) as avg_amount,
 round(min(amount), 2) as min_amount,
 round(max(amount), 2) as max_amount
 from creditcard_data group by class;
 
 -- Fraud amount percentage of total transaction value 
select
 round(sum(case when class = 1 then amount else 0 end), 2) as fraud_amount_total,
 round(sum(case when class = 0 then amount else 0 end), 2) as non_fraud_amount_total, 
 round(sum(case when class = 1 then amount else 0 end) * 100/sum(amount), 4) as fraud_amount_percentage
 from creditcard_data;
 
-- Time-Based Analysis

-- Divide transactions into time ranges (Morning, Afternoon, Night)
select
     case 
        when time <43200 then 'morning'        -- 0-12 hours
        when time <86400 then 'afternoon'      -- 12-24 hours
        else 'night'
	 end as Time_range,
     count(*) as transaction_count,
     sum(class) as fraud_count,
     round(sum(class)*100/count(*),4) as fraud_rate_percentage
from creditcard_data
group by time_range
order by fraud_rate_percentage desc;

-- Average transaction amount by time period
select
     case
         when time <43200 then 'morning'
         when time <86400 then 'afternoon'
         else 'night'
     end as Time_Range,
     round(avg(amount),2) as avg_amount
from creditcard_data
group by time_range
order by avg_amount desc;

-- Feature (V1–V28) Analysis
-- Since these are PCA components, we can check which features differ most between fraud and non-fraud:
select
      round(avg(v1), 4) as avg_v1,
      round(avg(v2), 4) as avg_v2,
      round(avg(v3), 4) as avg_v3,
      round(avg(v4), 4) as avg_v4,
      round(avg(v5), 4) as avg_v5,
      class
from creditcard_data
group by class;

-- Each of these columns (V1 to V28) represents a Principal Component (PCA feature).
-- Since PCA is a dimensionality reduction technique, each feature (V1, V2, …) is a linear combination of the original credit card transaction attributes (like location, merchant type, amount patterns, etc.) — but in a compressed way.

SELECT 
    ROUND(AVG(V1), 4) AS avg_V1,
    ROUND(AVG(V2), 4) AS avg_V2,
    ROUND(AVG(V3), 4) AS avg_V3,
    ROUND(AVG(V4), 4) AS avg_V4,
    ROUND(AVG(V5), 4) AS avg_V5,
    ROUND(AVG(V6), 4) AS avg_V6,
    ROUND(AVG(V7), 4) AS avg_V7,
    ROUND(AVG(V8), 4) AS avg_V8,
    ROUND(AVG(V9), 4) AS avg_V9,
    ROUND(AVG(V10), 4) AS avg_V10,
    ROUND(AVG(V11), 4) AS avg_V11,
    ROUND(AVG(V12), 4) AS avg_V12,
    ROUND(AVG(V13), 4) AS avg_V13,
    ROUND(AVG(V14), 4) AS avg_V14,
    ROUND(AVG(V15), 4) AS avg_V15,
    ROUND(AVG(V16), 4) AS avg_V16,
    ROUND(AVG(V17), 4) AS avg_V17,
    ROUND(AVG(V18), 4) AS avg_V18,
    ROUND(AVG(V19), 4) AS avg_V19,
    ROUND(AVG(V20), 4) AS avg_V20,
    ROUND(AVG(V21), 4) AS avg_V21,
    ROUND(AVG(V22), 4) AS avg_V22,
    ROUND(AVG(V23), 4) AS avg_V23,
    ROUND(AVG(V24), 4) AS avg_V24,
    ROUND(AVG(V25), 4) AS avg_V25,
    ROUND(AVG(V26), 4) AS avg_V26,
    ROUND(AVG(V27), 4) AS avg_V27,
    ROUND(AVG(V28), 4) AS avg_V28,
    Class
FROM creditcard_data
GROUP BY Class;

-- Fraud Concentration Analysis --

-- Top 10 highest-value fraud transactions
select * from creditcard_data where class = 1 
order by amount desc limit 10;

-- Fraud rate among small, medium, and large transactions
SELECT 
    CASE
        WHEN amount < 100 THEN 'small <(100)'
        WHEN amount < 1000 THEN 'medium 100-999'
        ELSE 'Large (≥1000)'
    END AS amount_Range,
    COUNT(*) AS total_txn,
    SUM(class) AS fraud_txn,
    ROUND(SUM(class) * 100 / COUNT(*), 4) AS fraud_rate_percentage
FROM
    creditcard_data
GROUP BY amount_range
ORDER BY fraud_rate_percentage DESC;
         
-- Statistical Analysis

-- Correlation approximation between Amount and fraud
select
     (avg (amount*class) - avg(amount)*avg(class))/(stddev(amount)*stddev(class)) 
	as corelation_amount_class from creditcard_data;

-- Fraud Pattern Summary

-- Combine multiple insights    
select
      count(*) as total_txn,
      sum(class) as fraud_txn,
      round(sum(class)*100/count(*), 4) as fraud_percentage,
      round(avg(amount), 2) as avg_amount,
      round(avg(case when class=1 then amount end), 2) as avg_fraud_amount,
      round(avg(case when class=0 then amount end), 2) as avg_nonfraud_amount
from creditcard_data;      
      
-- View Summary for Tableau Dashboard
create view fraud_summary as 
           select
                 case
                     WHEN Amount < 100 THEN 'Small (<100)'
					 WHEN Amount < 1000 THEN 'Medium (100–999)'
                     ELSE 'Large (≥1000)'
				 end as amount_range,
                 case
					when time <43200 then 'Morning'
                    when time <86400 then 'afternoon'
                    else 'Night'
                 end as Time_range,
                 count(*) as Total_txn,
                 sum(class) as fraud_txn,
                 round(sum(class)*100/count(*), 3) as fraud_rate
from creditcard_Data
group by amount_range, Time_Range;
                 
select * from fraud_summary;
SELECT * FROM fraud_summary WHERE Amount_Range='Large (≥1000)' ORDER BY fraud_rate DESC;

select * from creditcard_data;


      




