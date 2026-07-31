	
    -- Introduction --
/*
Blinkit is one of India's leading quick-commerce platforms, providing fast delivery of groceries and daily essentials.
The company generates a large amount of transactional data, which can be analysed to understand sales performance,
customer purchasing behaviour, store performance, and revenue trends.
This project uses SQL to analyse the Blinkit sales dataset and answer real-world business questions.
Various SQL concepts such as Joins, Aggregate Functions, CASE Statements, Common Table Expressions (CTEs), Subqueries, 
and Window Functions are applied to extract meaningful information from the data. 
The analysis helps identify business patterns and supports data-driven decision-making.	
*/
    
   -- Project Objectives --
/*
- Analyse the Blinkit sales dataset using SQL.
- Calculate key business metrics such as total revenue, average order value, and total orders.
- Identify the top-performing stores, products, and customers.
- Analyse customer purchasing behaviour and payment preferences.
- Evaluate monthly sales trends and revenue growth.
- Apply advanced SQL concepts including Joins, CTEs, CASE Statements, Subqueries, and Window Functions.
- Generate meaningful insights from transactional data to support business decision-making.
*/
    
			--  Database Creation--
CREATE DATABASE blinkit_project;
use blinkit_project;

			-- Dataset information/understanding--
select count(customer_id) from blinkit_orders;
select count(distinct customer_id) from blinkit_orders;
show columns from blinkit_orders;
select * from blinkit_customers;
select * from blinkit_orders;
select * from blinkit_order_items;
select * from blinkit_products;
select * from blinkit_inventory;
 
select count(*) from blinkit_order_items;
select count(*) from blinkit_customers;
select count(*) from blinkit_products;
select count(*) from  blinkit_inventory;
			-- Check NULL value--
select * from blinkit_orders
where order_id is NULL;

select * from blinkit_customers
where customer_id is NULL;

select * from blinkit_order_items
where order_id is NULL;

select * from blinkit_products
where product_id IS NULL;
-- No missing values were found in the dataset --

                
			-- Business Queries--
            
-- Q1 Find Total_revenue,Avg_revenue and Total_orders

SELECT
	SUM(order_total) AS 'Total Revenue',
    AVG(order_total) AS 'Avg revenue',
    COUNT(order_id) AS 'Total orders'
FROM blinkit_orders;

-- Q2 Top 5 orders by Revenue

SELECT store_id,
SUM(order_total) AS 'Total_revenue'
FROM blinkit_orders
GROUP BY store_id
ORDER BY total_revenue DESC
LIMIT 5;

-- Q3 Which payment method used the most

SELECT count(payment_method) AS 'total_orders',payment_method
FROM blinkit_orders
GROUP BY payment_method
ORDER BY total_orders DESC
LIMIT 1 ;

-- Q4 Total delivery in each delivery status

SELECT delivery_status,
		Count(delivery_status) AS 'total_delivery'
FROM blinkit_orders
GROUP BY delivery_status;

-- Q5 Top 10 customers by revenue

SELECT customer_id,
		SUM(order_total) AS 'Total_revenue'
FROM blinkit_orders
GROUP BY customer_id
ORDER BY Total_revenue DESC
LIMIT 10;

-- Q6 Find the average order value for each payment method

SELECT payment_method,
		AVG(order_total) AS 'Avg_value'
FROM blinkit_orders
GROUP BY payment_method;

-- Q7 For each store show Total orders, Total revenue, Average Order value in single query

SELECT store_id,
	COUNT(order_id) AS 'Total_orders',
    SUM(order_total) AS 'Total revenue',
    AVG(order_total) AS 'Average order'
FROM blinkit_orders
GROUP BY store_id;

-- Q8 Show Order ID, Customer name, Order total

SELECT o.order_id,
		c.customer_name,
        o.order_total
FROM blinkit_orders o 
INNER JOIN blinkit_customers c 
ON o.customer_id = c.customer_id;

-- Q9 Top 10 products by Total sales

SELECT p.product_name,
		SUM(i.quantity*i.unit_price) AS 'Total_Sales'
FROM blinkit_order_items i 
INNER JOIN blinkit_products p 
ON i.product_id = p.product_id
GROUP BY p.product_name
ORDER BY Total_Sales DESC
LIMIT 10;

-- Q10 Classify each order into three categories 

SELECT order_id,order_total,
	CASE
		WHEN order_total <= 1500 THEN 'Low Value'
		WHEN order_total >1500 AND order_total <3000 THEN 'Medium Value'
		ELSE 'High Value'
	END AS 'order category'
FROM blinkit_orders;

-- Q11 Rank Highest order under each store

SELECT * FROM
			(SELECT order_id, order_total, store_id,
					DENSE_RANK() OVER(Partition by store_id
					ORDER BY order_total desc) AS 'rnk'
			FROM blinkit_orders) t
WHERE rnk = 1;

-- Q12 Find the Top 5 customers by total revenue using a CTE

WITH customer_revenue AS
(
	SELECT customer_id,
			SUM(order_total) AS 'total_revenue'
	FROM blinkit_orders
    GROUP BY customer_id
)
SELECT * FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 5;

-- Q13 Find customers whose total spending is greater than the average customer spending

SELECT customer_id,
		SUM(order_total) AS 'Total_revenue'
FROM blinkit_orders
GROUP BY customer_id
HAVING SUM(order_total) > 
	( SELECT AVG(Total_revenue)
		FROM
			(SELECT SUM(order_total) AS 'Total_revenue'
			FROM blinkit_orders
			GROUP BY customer_id) AS t);
            
-- Q14 Show all customer who have not placed any order

SELECT c.customer_id,
		c.customer_name,
        o.order_id
FROM blinkit_customers c 
LEFT JOIN blinkit_orders o
ON c.customer_id = o.customer_id
where o.order_id IS NULL;

-- Q15 Which 5 stores generate the highest revenue

SELECT store_id,
		SUM(order_total) AS 'Total_revenue'
FROM blinkit_orders
GROUP BY store_id
ORDER BY Total_revenue DESC
LIMIT 5;

-- Q16 Which customer have placed more than 1 orders

SELECT customer_id,
		COUNT(order_id) AS 'Total_order'
FROM blinkit_orders
group by customer_id
Having COUNT(order_id) > 1
order by Total_order DESC;

-- Q17 Find Second Highest order value 

WITH order_rnk As (
		SELECT order_id,
				order_total,
		DENSE_RANK() OVER(ORDER BY order_total DESC) AS 'rnk'
        FROM blinkit_orders
        )
SELECT order_id,order_total,rnk
FROM order_rnk
WHERE rnk = 2;

-- Q18 Running total of revenue

SELECT order_date,
		order_total,
	SUM(order_total) OVER(ORDER BY order_date) AS 'Running_total'
FROM blinkit_orders;

-- Q19 Find Duplicate value in customers table

WITH duplicate_value AS(
		SELECT customer_id,
				customer_name,
				email,
	DENSE_RANK() OVER(partition by email) AS 'rnk'
    FROM blinkit_customers)
    
SELECT * FROM duplicate_value
WHERE rnk > 1;

-- Q20 Monthly Revenue Trend

SELECT 
	YEAR(order_date) AS 'year',
    MONTH(order_date) AS 'month',
    SUM(order_total) AS 'total_rvenue'
FROM blinkit_orders
Group by YEAR(order_date),MONTH(order_date)
Order by year,month;

-- Q21 How did revenue grow or decline month over month?

WITH revenue_growth AS (
	select 
			Year(order_date) AS 'year',
            month(order_date) AS 'mnth',
			SUM(order_total) AS 'revenue'
	from blinkit_orders
    group by year(order_date),month(order_date)
    )
select year,
		mnth,
        revenue,
	LAG(revenue) OVER(order by year,mnth) AS 'previous_month',
    revenue - LAG(revenue) OVER(order by year,mnth) AS 'monthly_growth'
    from revenue_growth;
    
-- Q22 Monthly order count

SELECT YEAR(order_date) AS 'year',
		MONTH(order_date) AS 'mnth',
        COUNT(order_total) AS 'order_count'
FROM blinkit_orders
GROUP BY year, mnth
ORDER BY year, mnth;

-- Q23 Divide customer into 4 spending groups using NTILE()

WITH customer_spending AS (
		SELECT customer_id,
				SUM(order_total) AS 'total_revenue'
		FROM blinkit_orders
        GROUP BY customer_id
        )
        
SELECT customer_id,
		total_revenue,
        NTILE(4) OVER(order by total_revenue DESC) AS 'spending_group'
        FROM customer_spending;
        
-- Q24 Product contribution to total sales

SELECT p.product_name,
		SUM(i.quantity*i.unit_price) AS 'total_sales'
FROM blinkit_order_items i
JOIN blinkit_products p
ON i.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales desc;

-- Q25 Daily revenue trend

SELECT 
	date(order_date) AS 'Date',
			SUM(order_total) AS 'total_revenue'
	FROM blinkit_orders
	GROUP BY date(order_date)
	ORDER BY Date;

-- Q26 Which store perform above the average store revenue

SELECT 
	store_id,
    SUM(order_total) AS 'total_revenue'
FROM blinkit_orders
GROUP BY store_id
HAVING SUM(order_total) > (
						SELECT AVG(store_revenue)
                        FROM 
							(SELECT SUM(order_total) AS 'store_revenue'
                            FROM blinkit_orders
                            group by store_id
                            ) AS t
                        )
ORDER BY total_revenue;

-- Q27 What percentage of total revenue comes from each store

SELECT
	store_id,
    SUM(order_total) AS 'total_revenue',
ROUND( SUM(order_total)*100/
		(SUM(SUM(order_total)) OVER()),2)
        AS contribution_percentage
FROM blinkit_orders
GROUP BY store_id;

-- Q28 customer inactive for long time

SELECT customer_id,
	MAX(order_date) AS last_order_date
FROM blinkit_orders
GROUP BY customer_id
ORDER BY last_order_date;

-- Q29 How much revenue come from each delivery status

SELECT delivery_status,
	SUM(order_total) AS 'total_revenue',
ROUND(
	SUM(order_total)*100/ (SUM(SUM(order_total)) OVER()),2)   
    AS 'revenue_share'
FROM blinkit_orders
GROUP BY delivery_status;

-- Q30 Top 10% customer based on total spending

WITH customer_spending AS(
	SELECT customer_id,
    SUM(order_total) AS 'total_spending',
    NTILE(10) OVER(ORDER BY SUM(order_total) desc) AS 'customer_group'
    FROM blinkit_orders
    GROUP BY customer_id
    )
SELECT * FROM customer_spending
WHERE customer_group = 1;

-- Conclusion ---
/* 
This project demonstrates how SQL can be used to analyse business data and answer real-world business questions. 
Various SQL concepts such as Joins, Aggregate Functions, CASE Statements, CTEs, Subqueries, and
Window Functions were applied to generate meaningful insights from the Blinkit dataset. 
The project strengthened my SQL querying, analytical thinking, and data exploration skills.
*/

