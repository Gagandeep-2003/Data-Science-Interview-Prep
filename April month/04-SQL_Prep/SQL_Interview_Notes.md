# 📘 SQL Masterclass Notes: Data Science Interview Prep

*A comprehensive guide to structured querying, from basic retrieval to advanced analytics.*

> **📂 Sample Datasets:** All examples in this guide use the datasets in `./sample_data/` — `employees.csv`, `orders.csv`, `customers.csv`, and `sales.csv`. Load them into any SQL engine (PostgreSQL, MySQL, SQLite) to practice along.

---

## 1. 🔍 Basic Retrieval & Filtering

The foundation of every query. Pay attention to the logical order of operations (Written vs. Executed).

**Core Keywords:**
- `SELECT`: Specifies columns.
- `FROM`: Specifies the table.
- `WHERE`: Filters rows BEFORE aggregation.
- `ORDER BY`: Sorts the final result set `ASC` or `DESC`.
- `LIMIT` / `TOP`: Restricts the number of returned rows.

```sql
-- Using employees.csv: Get the top 5 highest paid employees in Engineering
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary
FROM employees
WHERE department = 'Engineering' 
  AND status = 'Active'
ORDER BY salary DESC
LIMIT 5;
```

**Expected Output (from sample data):**

| employee_id | first_name | last_name | salary  |
|-------------|------------|-----------|---------|
| 107         | Karan      | Mehta     | 110000  |
| 101         | Amit       | Sharma    | 95000   |
| 113         | Siddharth  | Verma     | 92000   |
| 102         | Priya      | Patel     | 88000   |

*💡 **Tip:** Always filter early! Put the most restrictive conditions in the `WHERE` clause first to reduce the processed dataset size (helps with performance).*

---

## 2. 🧩 Pattern Matching & Advanced Filtering

Sometimes exact matches aren't enough. We need to look for patterns or ranges.

- `IN (...)`: Matches any value in a list.
- `BETWEEN x AND y`: Matches a range (inclusive).
- `LIKE`: Pattern matching (`%` for zero or more characters, `_` for exactly one character).
- `ILIKE`: Case-insensitive pattern matching (PostgreSQL specific, but super handy).
- `IS NULL` / `IS NOT NULL`: Checking for missing values.

```sql
-- Using customers.csv: Find gmail customers who have a phone number
SELECT 
    customer_id, 
    email, 
    signup_date
FROM customers
WHERE email LIKE '%@gmail.com'
  AND city IN ('Mumbai', 'Delhi', 'Bangalore')
  AND phone_number IS NOT NULL;
```

**Expected Output:**

| customer_id | email                    | signup_date |
|-------------|--------------------------|-------------|
| C001        | ravi.kumar@gmail.com     | 2022-06-15  |
| C002        | nisha.sharma@gmail.com   | 2023-01-20  |

```sql
-- Using employees.csv: Find employees hired between 2020 and 2022
SELECT first_name, last_name, department, hire_date
FROM employees
WHERE hire_date BETWEEN '2020-01-01' AND '2022-12-31'
  AND phone_number IS NOT NULL;
```

---

## 3. 📊 Aggregation & Grouping

Summarizing data. Crucial for reporting and BI.

**Key Functions:** `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`

- `GROUP BY`: Groups rows that have the same values in specified columns into summary rows.
- `HAVING`: Filters aggregated data. **(WHERE is for rows, HAVING is for groups!)**

```sql
-- Using employees.csv: Department-wise stats, only departments with avg salary > 80k
SELECT 
    department,
    COUNT(employee_id) AS total_employees,
    ROUND(AVG(salary), 2) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary
FROM employees
WHERE hire_date > '2018-01-01'
GROUP BY department
HAVING AVG(salary) > 80000;
```

**Expected Output:**

| department   | total_employees | avg_salary | max_salary | min_salary |
|-------------|-----------------|------------|------------|------------|
| Engineering  | 4               | 92500.00   | 110000     | 85000      |
| Data Science | 3               | 98333.33   | 105000     | 92000      |

```sql
-- Using orders.csv: Total revenue by product category, sorted descending
SELECT 
    product_category,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM orders
GROUP BY product_category
ORDER BY total_revenue DESC;
```

**Expected Output:**

| product_category | total_orders | total_revenue | avg_order_value |
|-----------------|-------------|---------------|-----------------|
| Electronics      | 8           | 13250.00      | 1656.25         |
| Clothing         | 4           | 920.50        | 230.13          |
| Home & Kitchen   | 3           | 1870.00       | 623.33          |
| Books            | 5           | 459.49        | 91.90           |

---

## 4. 🪢 The Art of JOINs

Combining tables based on a related column. This is where SQL shines.

- `INNER JOIN`: Returns records that have matching values in **both** tables.
- `LEFT JOIN`: Returns all records from the left table, and matched records from the right (fills with `NULL` if no match).
- `RIGHT JOIN`: Opposite of LEFT JOIN.
- `FULL OUTER JOIN`: Returns all records when there is a match in either left or right table.
- `CROSS JOIN`: Returns the Cartesian product of the two tables (use with caution!).
- `SELF JOIN`: Joining a table to itself (useful for hierarchical data, e.g., Employee-Manager relation).

```sql
-- Using customers.csv + orders.csv: Total spending per customer (even if no orders)
SELECT 
    c.customer_id,
    c.first_name,
    c.city,
    COALESCE(SUM(o.order_amount), 0) AS total_spent,
    COUNT(o.order_id) AS num_orders
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name,
    c.city
ORDER BY total_spent DESC;
```

**Expected Output:**

| customer_id | first_name | city      | total_spent | num_orders |
|-------------|-----------|-----------|-------------|------------|
| C001        | Ravi       | Mumbai    | 3230.00     | 4          |
| C010        | Suresh     | Bangalore | 2750.00     | 1          |
| C003        | Arun       | Bangalore | 2649.99     | 3          |
| C004        | Fatima     | Chennai   | 3600.00     | 2          |
| ...         | ...        | ...       | ...         | ...        |
| C009        | Manish     | Delhi     | 45.00       | 1          |

```sql
-- SELF JOIN on employees.csv: Find employees and their managers
SELECT 
    e.first_name AS employee,
    e.salary AS emp_salary,
    m.first_name AS manager,
    m.salary AS mgr_salary
FROM employees e
LEFT JOIN employees m 
    ON e.manager_id = m.employee_id;
-- Note: manager_id 201-204 don't exist in our 15-row sample, 
-- so manager columns will be NULL — great practice for understanding LEFT JOINs!
```

---

## 5. 🏗️ Subqueries & CTEs (Common Table Expressions)

Making complex queries readable and modular.

**Subqueries** can be in the `SELECT`, `FROM`, or `WHERE` clauses.
**CTEs (`WITH` clause)** are temporary result sets, highly preferred over nested subqueries for readability.

```sql
-- Using sales.csv: Revenue % contribution of each product
WITH TotalRevenue AS (
    SELECT SUM(price * quantity) AS grand_total
    FROM sales
)
SELECT 
    product_name,
    category,
    SUM(price * quantity) AS product_revenue,
    ROUND(
        (SUM(price * quantity) / (SELECT grand_total FROM TotalRevenue)) * 100, 
        2
    ) AS revenue_pct
FROM sales
GROUP BY product_name, category
ORDER BY revenue_pct DESC;
```

**Expected Output (top rows):**

| product_name  | category    | product_revenue | revenue_pct |
|--------------|------------|-----------------|-------------|
| Laptop Pro    | Electronics | 585000          | 68.42       |
| Standing Desk | Home       | 54000           | 6.31        |
| Office Chair  | Home       | 48000           | 5.61        |
| ...           | ...        | ...             | ...         |

```sql
-- Using orders.csv: Customers who spent more than the average customer
WITH CustomerSpend AS (
    SELECT 
        customer_id,
        SUM(order_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT 
    cs.customer_id,
    c.first_name,
    cs.total_spent,
    cs.total_spent - (SELECT AVG(total_spent) FROM CustomerSpend) AS above_avg_by
FROM CustomerSpend cs
JOIN customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > (SELECT AVG(total_spent) FROM CustomerSpend)
ORDER BY cs.total_spent DESC;
```

---

## 6. 🪟 Window Functions (Advanced Analytics)

Perform calculations across a set of table rows that are somehow related to the current row, **without** collapsing them like `GROUP BY` does.

**Syntax:** `function_name() OVER (PARTITION BY ... ORDER BY ...)`

- **Ranking:** `ROW_NUMBER()` (1, 2, 3), `RANK()` (1, 1, 3), `DENSE_RANK()` (1, 1, 2).
- **Value Analysis:** `LAG()` (previous row value), `LEAD()` (next row value).
- **Running Totals:** `SUM() OVER (ORDER BY ...)`.

```sql
-- Using employees.csv: Rank employees by salary within each department
WITH RankedSalaries AS (
    SELECT 
        department,
        first_name,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department 
            ORDER BY salary DESC
        ) as rank_in_dept,
        salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_dept_avg
    FROM employees
    WHERE status = 'Active'
)
SELECT * 
FROM RankedSalaries
WHERE rank_in_dept <= 2;
```

**Expected Output:**

| department   | first_name | salary  | rank_in_dept | diff_from_dept_avg |
|-------------|-----------|---------|-------------|-------------------|
| Data Science | Kavitha    | 115000  | 1           | 12500.00          |
| Data Science | Rahul      | 105000  | 2           | 2500.00           |
| Engineering  | Karan      | 110000  | 1           | 17500.00          |
| Engineering  | Amit       | 95000   | 2           | 2500.00           |
| ...          | ...        | ...     | ...         | ...               |

```sql
-- Using orders.csv: Running total of revenue by month
WITH MonthlyRevenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS order_month,
        SUM(order_amount) AS monthly_revenue
    FROM orders
    GROUP BY 1
)
SELECT 
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY order_month) AS cumulative_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month) AS prev_month,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month)) 
        / LAG(monthly_revenue) OVER (ORDER BY order_month) * 100, 
        2
    ) AS mom_growth_pct
FROM MonthlyRevenue
ORDER BY order_month;
```

**Expected Output:**

| order_month | monthly_revenue | cumulative_revenue | prev_month | mom_growth_pct |
|------------|----------------|-------------------|------------|----------------|
| 2024-01    | 1680.49        | 1680.49           | NULL       | NULL           |
| 2024-02    | 2835.00        | 4515.49           | 1680.49    | 68.71          |
| 2024-03    | 2259.50        | 6774.99           | 2835.00    | -20.30         |
| 2024-04    | 2475.00        | 9249.99           | 2259.50    | 9.54           |
| 2024-05    | 3560.00        | 12809.99          | 2475.00    | 43.84          |
| 2024-06    | 2035.00        | 14844.99          | 3560.00    | -42.84         |
| 2024-07    | 2750.00        | 17594.99          | 2035.00    | 35.14          |

---

## 7. 🎛️ Flow Control & Data Cleaning Functions

**CASE Statements:** If/Then logic in SQL. Very useful for creating buckets or flags.

```sql
-- Using orders.csv: Categorize customers by spending tier
SELECT 
    customer_id,
    SUM(order_amount) AS total_spent,
    COUNT(*) AS total_orders,
    CASE 
        WHEN SUM(order_amount) > 2000 THEN '🔥 VIP'
        WHEN SUM(order_amount) > 1000 THEN '⭐ Premium'
        WHEN SUM(order_amount) > 500 THEN '📦 Regular'
        ELSE '🆕 New'
    END AS customer_tier
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC;
```

**Expected Output:**

| customer_id | total_spent | total_orders | customer_tier |
|-------------|-------------|-------------|---------------|
| C004        | 3600.00     | 2           | 🔥 VIP         |
| C001        | 3230.00     | 4           | 🔥 VIP         |
| C010        | 2750.00     | 1           | 🔥 VIP         |
| C003        | 2649.99     | 3           | 🔥 VIP         |
| ...         | ...         | ...         | ...           |

**Handling NULLs:** `COALESCE()` returns the first non-null value in a list of arguments. Useful for replacing NULLs with default values.

```sql
-- Using employees.csv: Replace NULL phone numbers with a default
SELECT 
    first_name,
    department,
    COALESCE(phone_number, 'Not Provided') AS contact_number
FROM employees
WHERE phone_number IS NULL;
```

**Expected Output:**

| first_name | department   | contact_number |
|-----------|-------------|----------------|
| Sneha      | Data Science | Not Provided   |
| Meera      | Engineering  | Not Provided   |
| Nikhil     | Marketing    | Not Provided   |

**String Functions:**
`CONCAT()`, `SUBSTRING()`, `TRIM()`, `UPPER()`, `LOWER()`

**Date Functions:** 
`EXTRACT(year from date)`, `DATE_ADD()`, `DATEDIFF()` (syntax varies heavily by SQL dialect).

```sql
-- Using employees.csv: Calculate tenure in years
SELECT 
    first_name,
    hire_date,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM hire_date) AS approx_tenure_years,
    CASE 
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM hire_date) >= 5 THEN 'Senior'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM hire_date) >= 3 THEN 'Mid-level'
        ELSE 'Junior'
    END AS seniority_level
FROM employees
WHERE status = 'Active'
ORDER BY hire_date;
```

---

## 8. 🧠 Quick Interview Cheat Sheet

1.  **Execution Order:** `FROM` -> `WHERE` -> `GROUP BY` -> `HAVING` -> `SELECT` -> `ORDER BY` -> `LIMIT`. (This is why you can't use an alias defined in `SELECT` inside a `WHERE` clause!).
2.  **`COUNT(*)` vs `COUNT(column_name)`:** `COUNT(*)` counts all rows including NULLs. `COUNT(column)` ignores NULL values in that specific column.
3.  **`UNION` vs `UNION ALL`:** `UNION` removes duplicates (slower, implies a sort operation). `UNION ALL` keeps duplicates (faster).
4.  **How to handle duplicates:** Use `DISTINCT` in `SELECT`, or use `ROW_NUMBER() OVER (PARTITION BY identical_columns ORDER BY auto_id) as rn` and filter for `rn = 1`.
5.  **Correlated Subquery:** A subquery that references a column from the outer query. It runs once for every row processed by the outer query (usually slow, try to rewrite using JOINs).
6.  **Window vs Aggregate:** Window functions keep individual rows while aggregate functions collapse them. If an interviewer asks "without using GROUP BY", think window functions.
7.  **NULL gotchas:** `NULL = NULL` is FALSE! Always use `IS NULL`. NULLs in `COUNT(col)` are ignored. NULLs in `SUM()` are treated as 0.

---

## 📁 Sample Datasets Reference

All datasets are located in `./sample_data/`:

| File | Rows | Key Columns | Practice Topics |
|------|------|-------------|-----------------|
| `employees.csv` | 15 | employee_id, dept, salary, manager_id | WHERE, GROUP BY, SELF JOIN, Window |
| `orders.csv` | 20 | customer_id, order_date, amount, category | Aggregation, Date functions, CASE |
| `customers.csv` | 10 | customer_id, email, signup_date, city | JOINs, Pattern matching, NULLs |
| `sales.csv` | 20 | product, category, price, quantity, region | CTEs, Revenue analysis, Pivoting |
