# 🌟 Popular SQL Interview Questions

A curated list of the most frequently asked SQL interview questions for Data Science and Data Analyst roles. These cover both theoretical concepts and practical query scenarios.

---

## 🧠 Part 1: Theoretical Concepts

### 1. What is the difference between `WHERE` and `HAVING`?
- **`WHERE`** is used to filter rows **before** any grouping or aggregation takes place.
- **`HAVING`** is used to filter groups or aggregated data **after** the `GROUP BY` clause has been applied.
*Example: You use `WHERE` to filter employees in the 'Sales' department, but you use `HAVING` to find departments where the average salary is > $50,000.*

### 2. Explain the difference between `DELETE`, `TRUNCATE`, and `DROP`.
- **`DELETE`**: A DML (Data Manipulation Language) command. It removes rows one by one based on a `WHERE` condition. It can be rolled back.
- **`TRUNCATE`**: A DDL (Data Definition Language) command. It removes all rows from a table by deallocating the data pages. It is much faster than `DELETE` but cannot be rolled back easily. It resets identity columns.
- **`DROP`**: A DDL command. It completely removes the table structure, its dependencies, and all its data from the database.

### 3. What is the difference between `UNION` and `UNION ALL`?
- Both are used to combine the result sets of two or more `SELECT` statements.
- **`UNION`** removes duplicate rows between the sets. Because it checks for duplicates, it is computationally slower.
- **`UNION ALL`** keeps all rows, including duplicates. It is faster and should be preferred unless deduplication is explicitly required.

### 4. What are Window Functions, and how do they differ from Aggregate Functions?
- **Aggregate functions** (like `SUM`, `AVG`) collapse multiple rows into a single summary row.
- **Window functions** (like `ROW_NUMBER()`, `RANK()`, `SUM() OVER()`) perform calculations across a set of related rows but **keep each individual row intact** in the result set.

### 5. What is the difference between an `INNER JOIN` and a `LEFT JOIN`?
- **`INNER JOIN`** returns only the rows that have matching values in both tables.
- **`LEFT JOIN`** returns all rows from the left table, and the matched rows from the right table. If there is no match, the result will contain `NULL` for the right table's columns.

---

## 💻 Part 2: Classic Query Patterns

### 6. Find the Nth highest salary.
*A classic question. Often asked as "Find the 2nd highest salary" or finding the Nth highest without using `LIMIT`.*

**Modern approach (using Window Functions):**
```sql
WITH RankedSalaries AS (
    SELECT 
        employee_id, 
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) as rank
    FROM employees
)
SELECT salary FROM RankedSalaries WHERE rank = 2; -- Replace 2 with N
```

### 7. How do you find and remove duplicate rows?
*Interviewers want to see if you know how to use `ROW_NUMBER()` or `GROUP BY`.*

**Finding duplicates:**
```sql
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

**Keeping only the most recent row per user (Deduplication):**
```sql
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY email 
               ORDER BY created_at DESC
           ) as rn
    FROM users
)
-- To view the dupes: SELECT * FROM CTE WHERE rn > 1;
-- To delete the dupes:
DELETE FROM users 
WHERE id IN (SELECT id FROM CTE WHERE rn > 1);
```

### 8. Calculate a Cumulative Sum (Running Total).
*Shows your proficiency with basic window functions.*

```sql
SELECT 
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) as cumulative_revenue
FROM daily_sales;
```

### 9. Find employees who earn more than their managers.
*Tests your ability to write a `SELF JOIN`.*

```sql
SELECT e.first_name as employee_name, e.salary, m.first_name as manager_name, m.salary
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

### 10. Year-over-Year (YoY) Growth calculation.
*A must-know for product/data analytics roles.*

```sql
WITH YearlyRevenue AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) as yr,
        SUM(revenue) as total_rev
    FROM sales
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT 
    current.yr,
    current.total_rev as current_revenue,
    previous.total_rev as previous_revenue,
    (current.total_rev - previous.total_rev) / previous.total_rev * 100 as yoy_growth_percentage
FROM YearlyRevenue current
LEFT JOIN YearlyRevenue previous ON current.yr = previous.yr + 1;
```

---

## 💡 Pro Tips for SQL Interviews:
1. **Clarify assumptions:** Before writing queries, ask if there are `NULL` values, duplicates, or negative numbers you should account for.
2. **Talk through your thought process:** Explain what tables you are joining and why, before you start coding the exact syntax.
3. **Format your code:** A well-indented SQL query is much easier for an interviewer to read and grade. Use capital letters for SQL keywords (`SELECT`, `FROM`).
4. **Think about edge cases:** What happens if two employees have the exact same salary? (Hence why we use `DENSE_RANK()` over `RANK()` or `ROW_NUMBER()` for the Nth highest salary problem).
