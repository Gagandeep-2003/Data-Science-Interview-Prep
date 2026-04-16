# 🎯 SQL Practice Questions — Interview Prep

*50 graded questions based on the sample datasets in `./sample_data/`. Try solving them before looking at the solutions!*

> **Datasets used:** `employees.csv`, `orders.csv`, `customers.csv`, `sales.csv`

---

## 🟢 Level 1: Basics (Warm-Up)

### Q1. List all employees in the Engineering department, sorted by salary descending.
```sql
SELECT first_name, last_name, salary
FROM employees
WHERE department = 'Engineering'
ORDER BY salary DESC;
```

### Q2. Find all orders placed in March 2024.
```sql
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-03-01' AND '2024-03-31';
```

### Q3. Count how many employees are in each department.
```sql
SELECT department, COUNT(*) AS headcount
FROM employees
GROUP BY department
ORDER BY headcount DESC;
```

**Expected:**

| department   | headcount |
|-------------|-----------|
| Engineering  | 5         |
| Data Science | 3         |
| Marketing    | 3         |
| HR           | 2         |

### Q4. Find customers who signed up in 2023.
```sql
SELECT customer_id, first_name, signup_date
FROM customers
WHERE EXTRACT(YEAR FROM signup_date) = 2023;
```

### Q5. What is the total revenue from all orders?
```sql
SELECT 
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount), 2) AS avg_order
FROM orders;
```

---

## 🟡 Level 2: Intermediate (Joins + Aggregation)

### Q6. For each customer, find their name and total order amount. Include customers with no orders.
```sql
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COALESCE(SUM(o.order_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

### Q7. Find the most popular product category by number of orders.
```sql
SELECT 
    product_category,
    COUNT(*) AS order_count,
    SUM(order_amount) AS total_revenue
FROM orders
GROUP BY product_category
ORDER BY order_count DESC
LIMIT 1;
```

### Q8. Find departments where the average salary is above the company's overall average.
```sql
SELECT 
    department,
    ROUND(AVG(salary), 2) AS dept_avg
FROM employees
GROUP BY department
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees);
```

**Expected:**

| department   | dept_avg  |
|-------------|-----------|
| Data Science | 102500.00 |
| Engineering  | 94000.00  |

### Q9. Which cities have customers who have placed orders worth more than ₹1000 in a single order?
```sql
SELECT DISTINCT c.city, c.first_name, o.order_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_amount > 1000
ORDER BY o.order_amount DESC;
```

### Q10. Find the month with the highest total order value.
```sql
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS order_month,
    SUM(order_amount) AS monthly_total
FROM orders
GROUP BY 1
ORDER BY monthly_total DESC
LIMIT 1;
```

---

## 🟠 Level 3: Advanced (CTEs + Window Functions)

### Q11. Rank employees by salary within each department. Show only the top earner per dept.
```sql
WITH Ranked AS (
    SELECT 
        first_name,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT first_name, department, salary
FROM Ranked
WHERE rn = 1;
```

**Expected:**

| first_name | department   | salary  |
|-----------|-------------|---------|
| Kavitha    | Data Science | 115000  |
| Karan      | Mehta        | 110000  |
| Rohan      | Marketing    | 75000   |
| Divya      | HR           | 65000   |

### Q12. Calculate running total of order amounts per customer, ordered by date.
```sql
SELECT 
    customer_id,
    order_date,
    order_amount,
    SUM(order_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS running_total
FROM orders
ORDER BY customer_id, order_date;
```

### Q13. Find each product's contribution to total revenue in its category (using sales.csv).
```sql
WITH CategoryTotals AS (
    SELECT 
        category,
        SUM(price * quantity) AS cat_total
    FROM sales
    GROUP BY category
)
SELECT 
    s.product_name,
    s.category,
    SUM(s.price * s.quantity) AS product_revenue,
    ct.cat_total AS category_total,
    ROUND(SUM(s.price * s.quantity) / ct.cat_total * 100, 2) AS pct_of_category
FROM sales s
JOIN CategoryTotals ct ON s.category = ct.category
GROUP BY s.product_name, s.category, ct.cat_total
ORDER BY s.category, pct_of_category DESC;
```

### Q14. Find the gap (in days) between consecutive orders for each customer.
```sql
SELECT 
    customer_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_gap
FROM orders
ORDER BY customer_id, order_date;
```

**Expected (for C001):**

| customer_id | order_date | prev_order_date | days_gap |
|-------------|------------|-----------------|----------|
| C001        | 2024-01-05 | NULL            | NULL     |
| C001        | 2024-02-02 | 2024-01-05      | 28       |
| C001        | 2024-03-22 | 2024-02-02      | 49       |
| C001        | 2024-06-25 | 2024-03-22      | 95       |

### Q15. Classify each sale as "Above Average" or "Below Average" relative to its category.
```sql
SELECT 
    product_name,
    category,
    price * quantity AS revenue,
    AVG(price * quantity) OVER (PARTITION BY category) AS cat_avg,
    CASE 
        WHEN price * quantity > AVG(price * quantity) OVER (PARTITION BY category) 
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance
FROM sales;
```

---

## 🔴 Level 4: Interview Scenarios

### Q16. 🧩 Find customers who ordered in every single month that has data.
```sql
WITH MonthsAvailable AS (
    SELECT COUNT(DISTINCT DATE_TRUNC('month', order_date)) AS total_months
    FROM orders
),
CustomerMonths AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT DATE_TRUNC('month', order_date)) AS months_active
    FROM orders
    GROUP BY customer_id
)
SELECT cm.customer_id, cm.months_active
FROM CustomerMonths cm, MonthsAvailable ma
WHERE cm.months_active = ma.total_months;
-- Expected: No customer ordered in ALL 7 months — common in real data too.
```

### Q17. 📊 Calculate the YoY growth comparing each month to the same month last year.
```sql
-- Simulated: Since we only have 2024 data, this shows the pattern
WITH MonthlyRev AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS yr,
        EXTRACT(MONTH FROM order_date) AS mo,
        SUM(order_amount) AS revenue
    FROM orders
    GROUP BY 1, 2
)
SELECT 
    curr.yr, curr.mo,
    curr.revenue AS current_rev,
    prev.revenue AS prev_year_rev,
    ROUND((curr.revenue - prev.revenue) / prev.revenue * 100, 2) AS yoy_growth
FROM MonthlyRev curr
LEFT JOIN MonthlyRev prev 
    ON curr.yr = prev.yr + 1 
    AND curr.mo = prev.mo;
```

### Q18. 🏆 Find the second highest salary in each department (without LIMIT).
```sql
WITH RankedSalaries AS (
    SELECT 
        first_name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT first_name, department, salary
FROM RankedSalaries
WHERE rnk = 2;
```

### Q19. 🔄 Unpivot: Convert wide sales regions into long format.
```sql
-- First create the pivoted view, then unpivot
WITH Pivoted AS (
    SELECT 
        category,
        SUM(CASE WHEN region = 'North' THEN price * quantity END) AS north,
        SUM(CASE WHEN region = 'South' THEN price * quantity END) AS south,
        SUM(CASE WHEN region = 'East' THEN price * quantity END) AS east,
        SUM(CASE WHEN region = 'West' THEN price * quantity END) AS west
    FROM sales
    GROUP BY category
)
-- PostgreSQL LATERAL unpivot approach
SELECT category, region, revenue
FROM Pivoted,
LATERAL (VALUES 
    ('North', north), 
    ('South', south), 
    ('East', east), 
    ('West', west)
) AS t(region, revenue)
WHERE revenue IS NOT NULL;
```

### Q20. 🧮 Median salary per department (without a built-in `MEDIAN()` function).
```sql
WITH Ordered AS (
    SELECT 
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary) AS rn,
        COUNT(*) OVER (PARTITION BY department) AS cnt
    FROM employees
)
SELECT 
    department,
    ROUND(AVG(salary), 2) AS median_salary
FROM Ordered
WHERE rn IN (FLOOR((cnt + 1) / 2.0), CEIL((cnt + 1) / 2.0))
GROUP BY department;
```

---

## 📋 Answer Key Summary

| Q# | Concepts Tested | Difficulty |
|----|----------------|------------|
| Q1-Q5 | SELECT, WHERE, GROUP BY, COUNT, SUM | 🟢 Basic |
| Q6-Q10 | LEFT JOIN, HAVING, Subquery, Date funcs | 🟡 Intermediate |
| Q11-Q15 | CTE, ROW_NUMBER, LAG, Window AVG | 🟠 Advanced |
| Q16-Q20 | Complex CTEs, LATERAL, Median logic | 🔴 Interview |

> **💡 Practice Tip:** Don't just read these — type them out! Muscle memory matters in timed interviews. Load the sample data into [SQLite Online](https://sqliteonline.com/) or [DB Fiddle](https://www.db-fiddle.com/) and practice.
