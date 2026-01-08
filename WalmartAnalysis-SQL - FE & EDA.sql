/* =====================================================
   WALMART SALES ANALYSIS – 2026
   ===================================================== */

CREATE DATABASE IF NOT EXISTS walmart;

USE walmart;


-- What is Feature Engineering?
 Feature Engineering is the process of creating, transforming, 
 or selecting data columns (features) so that a machine learning model can
 understand the data better and make accurate predictions.

-- In short:
Raw data → useful data for models


CREATE TABLE sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
vat FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);



USE walmart;

/* =====================================================
   FEATURE ENGINEERING
   ===================================================== */

-- 1. Time of Day
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day =
CASE 
    WHEN `time` >= '00:00:00' AND `time` <= '12:00:00' THEN 'Morning'
    WHEN `time` > '12:00:00' AND `time` <= '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- 2. Day Name
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(`date`);

-- 3. Month Name
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(`date`);

/* =====================================================
   EXPLORATORY DATA ANALYSIS (EDA)
   ===================================================== */


-- What is EDA?
Exploratory Data Analysis (EDA) is the process of understanding your data 
before doing anything serious with it (like modeling, prediction, or dashboards).

EDA = “Get to know your data”

You look at the data and ask:
What data do I have?
Is it clean?
Are there missing values?
Are there patterns or trends?
Are there any surprises?

-- --------------------
-- Generic Questions
-- --------------------

-- 1. Distinct cities
SELECT COUNT(DISTINCT city) AS total_cities FROM sales;

-- 2. Branch per city
SELECT DISTINCT branch, city FROM sales;

-- --------------------
-- Product Analysis
-- --------------------

-- 1. Distinct product lines
SELECT COUNT(DISTINCT product_line) AS total_product_lines FROM sales;

-- 2. Most common payment method
SELECT payment, COUNT(*) AS total
FROM sales
GROUP BY payment
ORDER BY total DESC
LIMIT 1;

-- 3. Most selling product line
SELECT product_line, COUNT(*) AS total
FROM sales
GROUP BY product_line
ORDER BY total DESC
LIMIT 1;

-- 4. Total revenue by month
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. Month with highest COGS
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- 6. Product line with highest revenue
SELECT product_line, SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- 7. City with highest revenue
SELECT city, SUM(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- 8. Product line with highest VAT
SELECT product_line, SUM(vat) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 9. Product category (Good / Bad)
ALTER TABLE sales ADD COLUMN product_category VARCHAR(20);

UPDATE sales
SET product_category =
CASE
    WHEN total >= (SELECT AVG(total) FROM sales) THEN 'Good'
    ELSE 'Bad'
END;

-- 10. Branch selling more than average quantity
SELECT branch, SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING total_quantity >
       (SELECT AVG(branch_qty)
        FROM (
            SELECT SUM(quantity) AS branch_qty
            FROM sales
            GROUP BY branch
        ) t)
ORDER BY total_quantity DESC;

-- 11. Most common product line by gender
SELECT gender, product_line, COUNT(*) AS total
FROM sales
GROUP BY gender, product_line
ORDER BY total DESC;

-- 12. Average rating per product line
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

/* =====================================================
   SALES ANALYSIS
   ===================================================== */

-- 1. Sales by time of day (weekdays only)
SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name NOT IN ('Saturday','Sunday')
GROUP BY day_name, time_of_day;

-- 2. Customer type with highest revenue
SELECT customer_type, SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;

-- 3. City with highest VAT
SELECT city, SUM(vat) AS total_vat
FROM sales
GROUP BY city
ORDER BY total_vat DESC
LIMIT 1;

-- 4. Customer type paying most VAT
SELECT customer_type, SUM(vat) AS total_vat
FROM sales
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;

/* =====================================================
   CUSTOMER ANALYSIS
   ===================================================== */

-- 1. Unique customer types
SELECT COUNT(DISTINCT customer_type) AS total_customer_types FROM sales;

-- 2. Unique payment methods
SELECT COUNT(DISTINCT payment) AS total_payment_methods FROM sales;

-- 3. Most common customer type
SELECT customer_type, COUNT(*) AS total
FROM sales
GROUP BY customer_type
ORDER BY total DESC
LIMIT 1;

-- 4. Customer type buying most (by revenue)
SELECT customer_type, SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;

-- 5. Gender distribution
SELECT gender, COUNT(*) AS total
FROM sales
GROUP BY gender
ORDER BY total DESC
LIMIT 1;

-- 6. Gender distribution per branch
SELECT branch, gender, COUNT(*) AS total
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- 7. Best rated time of day
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC
LIMIT 1;

-- 8. Best rated time of day per branch
SELECT branch, time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- 9. Best day by average rating
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

-- 10. Best day per branch
SELECT branch, day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

/* =====================================================
   END OF FILE
   ===================================================== */
