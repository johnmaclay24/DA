CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  * --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--1)

SELECT 
	customer_id,
    SUM(price) AS amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

--2)

SELECT 
	customer_id,
    COUNT(DISTINCT(order_date)) AS days_visited
FROM dannys_diner.sales
GROUP BY customer_id;

--3)
-- CTE for ranking the order date by cutomers
WITH rnk_cte AS
(
	SELECT
		customer_id,
    	product_name,
    	RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS rnk
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu
	ON sales.product_id = menu.product_id )

SELECT 
	customer_id,
    product_name
FROM rnk_cte
WHERE rnk = 1;

--4)

SELECT 
	product_name,
    COUNT(order_date) AS orders
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY COUNT(order_date) DESC
LIMIT 1;

--5)

WITH CTE5 AS 
(
SELECT
	s.customer_id ,
    m.product_name, 
    COUNT(s.product_id) as count_products,
    RANK()  OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC ) AS rnk
FROM dannys_diner.menu AS m
INNER JOIN dannys_diner.sales AS s
ON m.product_id = s.product_id
GROUP BY s.customer_id,s.product_id,m.product_name
)

SELECT
	customer_id,
    product_name
FROM CTE5
WHERE rnk = 1;

--6)

WITH CTE6 AS

(
  
SELECT
	s.customer_id,
    mu.product_name,
  	s.order_date,
  	m.join_date,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY (s.order_date)) AS rnk
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.members AS m
ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu AS mu
ON s.product_id = mu.product_id
WHERE s.order_date >= m.join_date )

SELECT 
	customer_id,
    product_name
FROM CTE6
WHERE rnk = 1;

--7)
--8)
--9)
--10)
-- NOT YET FINISHED