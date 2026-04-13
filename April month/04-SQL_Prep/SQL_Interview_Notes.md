# 📘 SQL Masterclass Notes: Data Science Interview Prep

*A comprehensive guide to structured querying, from basic retrieval to advanced analytics.*

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
-- Retrieve the top 5 highest paid employees in the Engineering department
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
-- Find customers whose email ends with '@gmail.com' and country is USA, UK, or Canada
SELECT 
    customer_id, 
    email, 
    signup_date
FROM customers
WHERE email LIKE '%@gmail.com'
  AND country IN ('USA', 'UK', 'CA')
  AND phone_number IS NOT NULL;
```

---

## 3. 📊 Aggregation & Grouping

Summarizing data. Crucial for reporting and BI.

**Key Functions:** `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`

- `GROUP BY`: Groups rows that have the same values in specified columns into summary rows.
- `HAVING`: Filters aggregated data. **(WHERE is for rows, HAVING is for groups!)**

```sql
-- Find departments with an average salary greater than $80,000, 
-- but only consider employees hired after 2020.
SELECT 
    department,
    COUNT(employee_id) AS total_employees,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE hire_date > '2020-01-01'  -- Filter rows first
GROUP BY department             -- Then group
HAVING AVG(salary) > 80000;     -- Then filter the groups
```

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
-- LEFT JOIN example: Get all customers and their total order amounts, 
-- even if they haven't placed an order yet (total will be NULL).
SELECT 
    c.customer_id,
    c.first_name,
    SUM(o.order_amount) AS total_spent
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name;
```

```sql
-- SELF JOIN example: Find employees who earn more than their managers.
SELECT 
    e.employee_name,
    e.salary AS employee_salary,
    m.employee_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
INNER JOIN employees m 
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

---

## 5. 🏗️ Subqueries & CTEs (Common Table Expressions)

Making complex queries readable and modular.

**Subqueries** can be in the `SELECT`, `FROM`, or `WHERE` clauses.
**CTEs (`WITH` clause)** are temporary result sets, highly preferred over nested subqueries for readability.

```sql
-- Using a CTE to find the percentage of revenue each product contributes to the total
WITH TotalRevenue AS (
    SELECT SUM(price * quantity) AS grand_total
    FROM sales
)
SELECT 
    product_name,
    SUM(price * quantity) AS product_revenue,
    ROUND((SUM(price * quantity) / (SELECT grand_total FROM TotalRevenue)) * 100, 2) AS revenue_percentage
FROM sales
GROUP BY product_name;
```

---

## 6. 🪟 Window Functions (Advanced Analytics)

Perform calculations across a set of table rows that are somehow related to the current row, **without** collapsing them like `GROUP BY` does.

**Syntax:** `function_name() OVER (PARTITION BY ... ORDER BY ...)`

- **Ranking:** `ROW_NUMBER()` (1, 2, 3), `RANK()` (1, 1, 3), `DENSE_RANK()` (1, 1, 2).
- **Value Analysis:** `LAG()` (previous row value), `LEAD()` (next row value).

```sql
-- Find the top 2 highest paid employees in EACH department
WITH RankedSalaries AS (
    SELECT 
        department,
        employee_name,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank_in_dept
    FROM employees
)
SELECT * 
FROM RankedSalaries
WHERE rank_in_dept <= 2;
```

```sql
-- Calculate month-over-month revenue growth using LAG()
WITH MonthlyRevenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS order_month,
        SUM(amount) AS total_revenue
    FROM orders
    GROUP BY 1
)
SELECT 
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY order_month) AS absolute_growth
FROM MonthlyRevenue;
```

---

## 7. 🎛️ Flow Control & Data Cleaning Functions

**CASE Statements:** If/Then logic in SQL. Very useful for creating buckets or flags.

```sql
-- Categorize customers based on their total spend
SELECT 
    customer_id,
    total_spent,
    CASE 
        WHEN total_spent > 1000 THEN 'VIP'
        WHEN total_spent > 500 THEN 'Premium'
        ELSE 'Standard'
    END AS customer_tier
FROM customer_spending;
```

**Handling NULLs:** `COALESCE()` returns the first non-null value in a list of arguments. Useful for replacing NULLs with default values.

```sql
SELECT 
    product_name,
    COALESCE(discount_percentage, 0) AS effective_discount -- Replaces NULL with 0
FROM products;
```

**String Functions:**
`CONCAT()`, `SUBSTRING()`, `TRIM()`, `UPPER()`, `LOWER()`

**Date Functions:** 
`EXTRACT(year from date)`, `DATE_ADD()`, `DATEDIFF()` (syntax varies heavily by SQL dialect).

---

## 8. 🧠 Quick Interview Cheat Sheet

1.  **Execution Order:** `FROM` -> `WHERE` -> `GROUP BY` -> `HAVING` -> `SELECT` -> `ORDER BY` -> `LIMIT`. (This is why you can't use an alias defined in `SELECT` inside a `WHERE` clause!).
2.  **`COUNT(*)` vs `COUNT(column_name)`:** `COUNT(*)` counts all rows including NULLs. `COUNT(column)` ignores NULL values in that specific column.
3.  **`UNION` vs `UNION ALL`:** `UNION` removes duplicates (slower, implies a sort operation). `UNION ALL` keeps duplicates (faster).
4.  **How to handle duplicates:** Use `DISTINCT` in `SELECT`, or use `ROW_NUMBER() OVER (PARTITION BY identical_columns ORDER BY auto_id) as rn` and filter for `rn = 1`.
5.  **Correlated Subquery:** A subquery that references a column from the outer query. It runs once for every row processed by the outer query (usually slow, try to rewrite using JOINs).
