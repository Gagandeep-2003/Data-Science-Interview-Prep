CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    amount INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


INSERT INTO customers (customer_id, name, city) VALUES
(101, 'Asha', 'Delhi'),
(102, 'Ravi', 'Mumbai'),
(103, 'Neha', 'Pune'),
(104, 'Karan', 'Delhi');


INSERT INTO orders (order_id, customer_id, amount, order_date) VALUES
(1, 101, 500, '2024-01-01'),
(2, 102, 300, '2024-01-02'),
(3, 101, 700, '2024-01-03'),
(4, 103, 200, '2024-01-04'),
(5, 102, 400, '2024-01-05'),
(6, 104, 1000, '2024-01-06');

CREATE TABLE order_items (
    order_id INT,
    product VARCHAR(50),
    quantity INT,
    price INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
INSERT INTO order_items VALUES
(1, 'Laptop', 1, 500),
(1, 'Mouse', 1, 100),

(2, 'Keyboard', 1, 300),

(3, 'Laptop', 1, 700),

(4, 'Mouse', 2, 100),

(5, 'Phone', 1, 400),

(6, 'Laptop', 1, 1000),
(6, 'Phone', 1, 500);
select * from customers join orders 
on customers.customer_id = orders.customer_id




WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
select * 
from customer_spending;



WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
select c.name, cs.total_spent
from customer_spending cs 
join customers c
on cs.customer_id = c.customer_id



WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_spending
WHERE total_spent > 700;


WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *,
       RANK() OVER (ORDER BY total_spent DESC) AS rank
FROM customer_spending;


WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
high_spenders AS (
    SELECT *
    FROM customer_spending
    WHERE total_spent > 700
)
SELECT *
FROM high_spenders;



WITH customer_spending AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
average_spending as(
select avg(total_spent) as avg_spending from customer_spending
)
select cs.* from customer_spending cs, average_spending a
where cs.total_spent > a.avg_spending



WITH daily_orders AS (
    SELECT order_date, SUM(amount) AS daily_total
    FROM orders
    GROUP BY order_date
)
SELECT *,
       SUM(daily_total) OVER (ORDER BY order_date) AS running_total
FROM daily_orders;



with customer_spending as(
select customer_id, sum(amount) as total_spend from orders
group by customer_id
),
ranked as(
select c.name, c.city, cs.total_spend, rank() over (partition by c.city order by cs.total_spend) 
as citywise_customer_spendRank from customers c join customer_spending cs
on c.customer_id = cs.customer_id
)
select * from ranked
where citywise_customer_spendRank = 1


with big_orders as(
select distinct customer_id
from orders o
where o.amount > 500
)
select * from customers c
where exists (
select 1 from big_orders bo
where bo.customer_id = c.customer_id
)


select name, count(order_id) customer_order_count from customers join orders
on customers.customer_id = orders.customer_id
group by name
having count(order_id) >= 1
order by count(order_id) desc


select name, count(order_id) customer_order_count from customers join orders
on customers.customer_id = orders.customer_id
group by name
having count(order_id) = 0



select name, count(order_id) customer_order_count from customers join orders
on customers.customer_id = orders.customer_id
group by name



select name, sum(amount) customer_order_count from customers join orders
on customers.customer_id = orders.customer_id
group by name



select name, sum(amount) customer_order_count from customers join orders
on customers.customer_id = orders.customer_id
group by name
order by sum(amount) desc
limit 1


select name
from customers join orders
on customers.customer_id = orders.customer_id
join order_items 
on orders.order_id = order_items.order_id
where order_items.product = 'Laptop'
group by name



select name
from customers join orders
on customers.customer_id = orders.customer_id
join order_items 
on orders.order_id = order_items.order_id
group by name


select customer_id, STRING_AGG(order_items.product, ', ') as allProducts
from order_items join orders
on order_items.order_id = orders.order_id
group by customer_id
HAVING SUM(CASE WHEN order_items.product = 'Laptop' THEN 1 ELSE 0 END) = 0;

-- or 
SELECT c.name, c.customer_id
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id
      AND oi.product = 'Laptop'
);

select c.name from customers c
where not exists(
select 1 from orders o
join order_items  oi
on o.order_id = oi.order_id
where o.customer_id = c.customer_id
and oi.product = 'Keyboard'
)


select c.name from customers c
where exists(
select 1 from orders o
join order_items  oi
on o.order_id = oi.order_id
where o.customer_id = c.customer_id
and oi.product = 'Laptop' 
)
and not exists(
select 1
form orders o
join order_items oi
on o.order_id = oi.order_id
where o.customer_id = c.customer_id
and oi.product = 'Phone'
)
-- or 
SELECT c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.name
HAVING 
    SUM(CASE WHEN oi.product = 'Laptop' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN oi.product = 'Phone' THEN 1 ELSE 0 END) = 0;


SELECT distinct c.customer_id, c.name, count(*),  string_agg(oi.product, ',') as product_ordered
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name, oi.product
having count(*) > 1


-- ❓ Case 1: “Product appears exactly 2 times (rows)”
SELECT  c.customer_id, c.name, count(*),  string_agg(oi.product, ',') as product_ordered
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name, oi.product
having count(*) = 2


-- ❓ Case 2: “Product ordered in exactly 2 different orders” 🔥
SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
HAVING 
    COUNT(DISTINCT o.order_id) = 2
    AND COUNT(DISTINCT oi.product) = 2;



-- Find customers who have ordered at least 2 different products
SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
HAVING 
    COUNT(DISTINCT o.order_id) = 2
    AND COUNT(DISTINCT oi.product) >= 2;


-- Find customers who have ordered all available products
select c.name, string_agg(oi.product, ','), count(*) from order_items oi
join orders o
on o.order_id = oi.order_id join customers c
on c.customer_id = o.customer_id
group by c.customer_id, c.name
having count(distinct oi.product) = (select count(distinct product) from order_items)



SELECT c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT oi.product) = (
    SELECT COUNT(DISTINCT product)
    FROM order_items
);

-- Find customers who have placed more orders than average customer
select c.customer_id, c.name, sum(o.amount), string_agg(oi.product, ','), count(*) from order_items oi
join orders o
on o.order_id = oi.order_id join customers c
on c.customer_id = o.customer_id
group by c.customer_id, c.name
having count(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        GROUP BY customer_id
    ) t
);

-- Find customers who spent more than average spending
select c.customer_id, c.name, sum(o.amount), string_agg(oi.product, ','), count(*) from order_items oi
join orders o
on o.order_id = oi.order_id join customers c
on c.customer_id = o.customer_id
group by c.customer_id, c.name
HAVING SUM(o.amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM orders
        GROUP BY customer_id
    ) t
);


-- Find customers whose every order has at least one item

select * from customers c
where not exists (
select 1 from orders o
where c.customer_id = o.customer_id
and not exists (
select 1 from order_items oi
where oi.order_id = o.order_id
)
) 


-- Find customers whose every order contains only 1 item
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND (
          SELECT COUNT(*)
          FROM order_items oi
          WHERE oi.order_id = o.order_id
      ) > 1
);


















