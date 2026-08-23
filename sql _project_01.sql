CREATE DATABASE sql_project_01;

USE sql_project_01;

CREATE TABLE project_queries
	(transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,	
    customer_id	INT,
    gender	VARCHAR(20),
    age	INT,
    category VARCHAR(50),	
    quantiy	INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT);

SELECT * FROM project_queries
LIMIT 10;

ALTER TABLE project_queries
MODIFY COLUMN quantiy INT;

ALTER TABLE project_queries
RENAME COLUMN quantiy TO quantity;

SELECT COUNT(transactions_id) 
FROM project_queries;

SELECT * FROM project_queries
where 
	transactions_id is null	
    or sale_date is null	
    or sale_time is null	
    or customer_id is null	
    or gender is null	
    or age is null
	or category is null	
    or quantiy is null	
    or price_per_unit is null	
    or cogs is null	
    or total_sale is null;
    
-- How many sales we have
SELECT COUNT(*) 
FROM project_queries;

-- How many unique customers we ahve
SELECT COUNT(DISTINCT customer_id) 
FROM project_queries;

-- How many unique categories we have 
SELECT DISTINCT category 
FROM project_queries;

-- DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT * FROM project_queries
WHERE sale_date = "2022-11-05";


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

SELECT * FROM project_queries
WHERE category = "Clothing" 
AND quantity > 3
AND sale_date >= '2022-11-01'
AND sale_date < '2022-12-01';


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale)
FROM project_queries
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT category, AVG(age)
FROM project_queries
WHERE category = "Beauty";


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM project_queries
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transactions_id) made by each gender in each category.

SELECT category, gender, COUNT(transactions_id)
FROM project_queries
GROUP BY gender, category;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT * FROM
(SELECT
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        ROUND(AVG(total_sale),2) AS total_sales,
        RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS ranks
FROM project_queries
GROUP BY 1, 2 ) as t1
WHERE ranks = 1;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT customer_id, SUM(total_sale) AS total_sales
FROM project_queries
GROUP BY customer_id
order by total_sales desc
limit 5 ; 

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM project_queries
GROUP BY category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
    
SELECT
    CASE
        WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) <= 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS Time_shift,
    COUNT(*) AS number_of_orders
FROM project_queries
GROUP BY
    CASE
        WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) <= 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;
    