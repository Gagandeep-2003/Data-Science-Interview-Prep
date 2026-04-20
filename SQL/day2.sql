CREATE TABLE customers (
    customer_id INT,
    name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Aman', 'Delhi'),
(2, 'Simran', 'Chandigarh'),
(3, 'Ravi', 'Mumbai'),
(4, 'Neha', 'Delhi'),
(5, 'Arjun', 'Pune');

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders VALUES
(101, 1, '2023-01-10', 500),
(102, 1, '2023-02-15', 700),
(103, 2, '2023-03-20', 300),
(104, 3, '2023-01-05', 1000),
(105, 3, '2023-04-25', 1500),
(106, 4, '2023-02-18', 200);

CREATE TABLE order_items (
    order_id INT,
    product VARCHAR(50),
    quantity INT,
    price INT
);

INSERT INTO order_items VALUES
(101, 'Laptop', 1, 500),
(102, 'Phone', 1, 700),
(103, 'Mouse', 2, 150),
(104, 'Tablet', 1, 1000),
(105, 'Laptop', 1, 1500),
(106, 'Keyboard', 1, 200);

select * from customers
select * from orders
select * from order_items


select c.customer_id, o.order_id, c.name, oi.product, oi.quantity, o.amount,
sum(o.amount) over(partition by c.customer_id) as customer_expense from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id


select *
from customers c left join orders o
on c.customer_id = o.customer_id
where o.customer_id is  null

select *
from customers c left join orders o
on c.customer_id = o.customer_id
where o.customer_id is not null

select c.name, count(order_id)
from customers c full join orders o
on c.customer_id = o.customer_id
group by c.name


select c.name, sum(amount)
from customers c inner join orders o
on c.customer_id = o.customer_id
group by name
order by sum(amount) desc


select c.name, sum(amount)
from customers c inner join orders o
on c.customer_id = o.customer_id
group by name
order by sum(amount) desc
limit 1


select c.name, count(order_id) as orderCount
from customers c inner join orders o
on c.customer_id = o.customer_id
group by c.name
having count(o.order_id) > 1



select c.customer_id, o.order_id, c.name, oi.product, oi.quantity, o.amount,
sum(o.amount) over(partition by c.customer_id) as customer_expense from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
where oi.product = 'Laptop'


SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.product IN ('Laptop', 'Phone')
group by c.customer_id, c.name
having count(distinct oi.product) = 2


SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
group by c.customer_id, c.name
having count(distinct oi.product) = 1

SELECT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
group by c.customer_id, c.name
having count(distinct oi.product) = (select count(*) from order_items)


SELECT 
    c.customer_id,
    c.name,
    c.city,
    o.order_id,
    o.order_date,
    o.amount,
    oi.product,
    oi.quantity,
    oi.price
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id;

	
select * from customers
select * from orders
select * from order_items

SELECT *
FROM customers c, 
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

SELECT c.customer_id, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id;


SELECT c.customer_id, count(*)
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
-- where oi.product = 'Laptop'
GROUP BY c.customer_id
HAVING COUNT(DISTINCT oi.product) = 1;


SELECT c.customer_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT oi.product) = (
    SELECT COUNT(DISTINCT product)
    FROM order_items
);


SELECT c.customer_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT oi.product) = 1
   AND MAX(oi.product) = 'Mouse';


SELECT o.*
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;


select customer_id from orders c join order_items oi 
on c.order_id = oi.order_id
group by c.customer_id
having MAX(oi.product) = 'Mouse'


select customer_id from orders c join order_items oi 
on c.order_id = oi.order_id
group by c.customer_id
having MAX(oi.product) != 'Keyboard'



select customer_id from orders c join order_items oi 
on c.order_id = oi.order_id
group by c.customer_id
having count(oi.order_id) = 2

SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) t
);


SELECT customer_id, count(*)
FROM orders
GROUP BY customer_id
HAVING COUNT(*) = 2;


SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (
    SELECT *
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id
      AND oi.product = 'Keyboard'
);


select c.* from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on oi.order_id = o.order_id
where oi.product = 'Laptop' and oi.product != 'Mouse'



select c.name from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.name
having count(distinct oi.product) >= 2


select c.name from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.name
having count(distinct oi.product) >= 2




select c.name from customers c join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.name
having count(*) > 1

select o.product, o.customer_id, o.order_id
from order_items o join order_items o2
where o.product = o2.product 








