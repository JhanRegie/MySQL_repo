-- Exploratory Data Analysis, EDA
-- Dataset collected from kaggle: https://www.kaggle.com/datasets/serhatabuk/sales-data-csv

-- Bike store sales in europe
SELECT * FROM sales_data_staging;

-- Maximum Revenue from table
SELECT MAX(Revenue) AS Maximum_revenue
FROM sales_data_staging;

-- Extract maximum and minimum profit generated
SELECT MAX(Profit) AS Max_profit, MIN(Profit) AS Min_profit
FROM sales_data_staging;


-- 1. What was the total revenue generated
SELECT SUM(Revenue) AS Total_revenue
FROM sales_data_staging; -- 2,980,643

-- list of different products
SELECT DISTINCT Product FROM sales_data_staging;

-- count of products per product, and popular product
SELECT Product, COUNT(Product) AS "Product Count"
FROM sales_data_staging
GROUP BY Product
ORDER BY COUNT(Product) DESC;

-- Which country and state has most products
SELECT DISTINCT Country, State, COUNT(Product) AS "Product count"
FROM sales_data_staging
GROUP BY Country, State
ORDER BY COUNT(Product) DESC;

-- 2. which product had the highest total revenue?
SELECT Product, SUM(Revenue) AS total_revenue 
FROM sales_data_staging
GROUP BY Product
ORDER BY total_revenue DESC;

-- which year has the highest total revenue?
SELECT Year, SUM(Revenue) AS total_revenue 
FROM sales_data_staging
GROUP BY Year
ORDER BY total_revenue DESC;

-- 4. How many unique products where sold?
SELECT COUNT(DISTINCT Product) FROM sales_data_staging;

-- 3. Which customers generated the most revenue
SELECT Age_Group, SUM(Revenue) AS total_revenue
FROM sales_data_staging
GROUP BY Age_Group
ORDER BY SUM(Revenue) DESC;

-- What is the average cost per product?
SELECT Product, AVG(Cost)
FROM sales_data_staging
GROUP BY Product
ORDER BY AVG(COST) DESC;

