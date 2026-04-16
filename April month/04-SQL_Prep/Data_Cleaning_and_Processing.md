# 🛠️ SQL for Data Cleaning & Processing

*Turning raw, messy data into analysis-ready gold. A guide to the most common data prep patterns in SQL.*

> **📂 Practice Along:** All examples use datasets in `./sample_data/`. Load them into your SQL engine to run these queries yourself.

---

## 1. 👯 Handling Duplicates
Duplicates are the silent killers of accurate analysis. Identifying them correctly is step one.

### A. The "Big Hammer" (DISTINCT)
Use when you want to remove exact duplicate rows across all selected columns.
```sql
-- Quick de-dup of the orders table
SELECT DISTINCT * FROM orders;
```

### B. Grouping to Find Count
Useful for identifying which keys are duplicated.
```sql
-- Using customers.csv: Check if any email is registered twice
SELECT email, COUNT(*) 
FROM customers 
GROUP BY email 
HAVING COUNT(*) > 1;
-- Expected: No duplicates in our clean sample — but in real data, 
-- this is your first sanity check.
```

```sql
-- Using orders.csv: Which customers ordered the same category more than once?
SELECT customer_id, product_category, COUNT(*) AS times_ordered
FROM orders
GROUP BY customer_id, product_category
HAVING COUNT(*) > 1;
```

**Expected Output:**

| customer_id | product_category | times_ordered |
|-------------|-----------------|---------------|
| C001        | Electronics      | 3             |
| C002        | Clothing         | 2             |

### C. The Precision Tool (Window Functions)
The most robust way to deduplicate while keeping one record (e.g., the most recent one).
```sql
-- Using orders.csv: Keep only the latest order per customer
WITH Deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id 
               ORDER BY order_date DESC
           ) as row_num
    FROM orders
)
SELECT order_id, customer_id, order_date, order_amount 
FROM Deduplicated 
WHERE row_num = 1;
```

**Expected Output (1 row per customer, most recent order):**

| order_id | customer_id | order_date | order_amount |
|----------|-------------|------------|-------------|
| 1019     | C001        | 2024-06-25 | 1100.00     |
| 1013     | C002        | 2024-04-18 | 225.00      |
| 1016     | C003        | 2024-05-20 | 670.00      |
| 1012     | C004        | 2024-04-10 | 1500.00     |
| ...      | ...         | ...        | ...         |

---

## 2. 🕳️ Managing Missing Values (NULLs)
NULLs behave differently than zeros or empty strings. They require special handling.

- `COALESCE(col, default)`: Returns the first non-null value. Perfect for filling holes.
- `NULLIF(col, value)`: Returns NULL if the column matches the value (e.g., swapping `0` or `''` for `NULL`).

```sql
-- Using employees.csv: Replace NULL phone numbers, flag missing contacts
SELECT 
    employee_id,
    first_name,
    COALESCE(phone_number, 'N/A') AS clean_phone,
    CASE WHEN phone_number IS NULL THEN 'Missing' ELSE 'Available' END AS phone_status
FROM employees;
```

**Expected Output (showing rows with NULLs):**

| employee_id | first_name | clean_phone | phone_status |
|------------|-----------|-------------|-------------|
| 104         | Sneha      | N/A         | Missing      |
| 110         | Meera      | N/A         | Missing      |
| 115         | Nikhil     | N/A         | Missing      |

```sql
-- Using orders.csv: Treat 0% discount as "no discount applied" (NULL)
SELECT 
    order_id,
    order_amount,
    discount_pct,
    NULLIF(discount_pct, 0) AS meaningful_discount,
    order_amount * (1 - COALESCE(NULLIF(discount_pct, 0), 0) / 100.0) AS final_price
FROM orders;
```

### Conditional Imputation
```sql
-- Using employees.csv: Impute missing phone numbers with department-based defaults
SELECT 
    employee_id,
    first_name,
    department,
    CASE 
        WHEN phone_number IS NULL AND department = 'Engineering' THEN '000-ENG-0000'
        WHEN phone_number IS NULL AND department = 'Data Science' THEN '000-DS-0000'
        WHEN phone_number IS NULL THEN '000-GEN-0000'
        ELSE phone_number 
    END AS imputed_phone
FROM employees;
```

---

## 3. 🧶 String Standardization
Messy text data often contains trailing spaces, inconsistent casing, or unwanted characters.

| Function | Use Case |
| :--- | :--- |
| `TRIM()` / `LTRIM()` / `RTRIM()` | Remove whitespace. |
| `LOWER()` / `UPPER()` | Standardize case for joins. |
| `REPLACE()` | Remove special characters (e.g., `$`, `,`). |
| `SPLIT_PART()` / `SUBSTRING()` | Extract nested information. |

```sql
-- Using customers.csv: Normalize email domains for analysis
SELECT 
    customer_id,
    email,
    LOWER(SUBSTRING(email FROM POSITION('@' IN email) + 1)) AS email_domain,
    UPPER(SUBSTRING(first_name, 1, 1)) || LOWER(SUBSTRING(first_name, 2)) AS proper_name
FROM customers;
```

**Expected Output:**

| customer_id | email                  | email_domain | proper_name |
|-------------|------------------------|-------------|-------------|
| C001        | ravi.kumar@gmail.com   | gmail.com   | Ravi        |
| C003        | arun.menon@yahoo.com   | yahoo.com   | Arun        |
| C005        | deepak.jain@hotmail.com | hotmail.com | Deepak      |
| C009        | manish.tiwari@company.com | company.com | Manish   |

```sql
-- Using employees.csv: Create a clean "full_name" column for reporting
SELECT 
    employee_id,
    CONCAT(TRIM(first_name), ' ', TRIM(last_name)) AS full_name,
    LOWER(CONCAT(TRIM(first_name), '.', TRIM(last_name), '@company.com')) AS generated_email
FROM employees;
```

---

## 4. 📅 Date & Timeline Normalization
Date formats are notoriously inconsistent.

- **Casting:** `CAST(raw_date AS DATE)` or `raw_date::DATE`.
- **Parsing:** `TO_DATE('2023-Oct-01', 'YYYY-Mon-DD')`.
- **Handling Timestamps:** Always normalize to UTC where possible.

```sql
-- Using orders.csv: Time-based analysis
SELECT 
    order_id,
    order_date,
    EXTRACT(MONTH FROM order_date) AS order_month,
    EXTRACT(QUARTER FROM order_date) AS order_quarter,
    order_date - INTERVAL '30 days' AS thirty_days_before,
    CASE 
        WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type
FROM orders;
```

```sql
-- Using employees.csv: Calculate exact tenure
SELECT 
    first_name,
    hire_date,
    CURRENT_DATE - hire_date AS days_employed,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_tenure,
    CASE 
        WHEN CURRENT_DATE - hire_date > 1825 THEN 'Veteran (5+ yrs)'
        WHEN CURRENT_DATE - hire_date > 1095 THEN 'Experienced (3-5 yrs)'
        WHEN CURRENT_DATE - hire_date > 365 THEN 'Growing (1-3 yrs)'
        ELSE 'New Hire (<1 yr)'
    END AS tenure_bucket
FROM employees
ORDER BY hire_date;
```

---

## 5. 📏 Outliers & Data Integrity
Before running a model, ensure your numeric ranges make sense.

### Capping (Winsorization) logic
```sql
-- Using orders.csv: Cap order amounts at reasonable limits
SELECT 
    order_id,
    order_amount,
    CASE 
        WHEN order_amount > 3000 THEN 3000   -- Cap at 3k (99th percentile)
        WHEN order_amount < 50 THEN 50        -- Floor at 50
        ELSE order_amount 
    END AS adjusted_amount,
    CASE 
        WHEN order_amount > 3000 OR order_amount < 50 THEN 'Capped'
        ELSE 'Original'
    END AS cap_flag
FROM orders;
```

**Expected flagged rows:**

| order_id | order_amount | adjusted_amount | cap_flag |
|----------|-------------|-----------------|----------|
| 1014     | 3200.00     | 3000            | Capped   |
| 1017     | 45.00       | 50              | Capped   |

### Z-score based outlier detection
```sql
-- Using employees.csv: Flag salary outliers using Z-score
WITH SalaryStats AS (
    SELECT 
        AVG(salary) AS mean_sal,
        STDDEV(salary) AS std_sal
    FROM employees
)
SELECT 
    e.first_name,
    e.department,
    e.salary,
    ROUND((e.salary - s.mean_sal) / s.std_sal, 2) AS z_score,
    CASE 
        WHEN ABS((e.salary - s.mean_sal) / s.std_sal) > 2 THEN '⚠️ Outlier'
        ELSE '✅ Normal'
    END AS outlier_flag
FROM employees e, SalaryStats s
ORDER BY z_score DESC;
```

---

## 6. 🔄 Reshaping Data (Pivoting)
Converting long-format data into wide-format (often needed for features).

```sql
-- Using sales.csv: Pivot sales by region
SELECT 
    category,
    SUM(CASE WHEN region = 'North' THEN price * quantity ELSE 0 END) AS north_revenue,
    SUM(CASE WHEN region = 'South' THEN price * quantity ELSE 0 END) AS south_revenue,
    SUM(CASE WHEN region = 'East' THEN price * quantity ELSE 0 END) AS east_revenue,
    SUM(CASE WHEN region = 'West' THEN price * quantity ELSE 0 END) AS west_revenue,
    SUM(price * quantity) AS total_revenue
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;
```

**Expected Output:**

| category    | north_revenue | south_revenue | east_revenue | west_revenue | total_revenue |
|------------|--------------|--------------|-------------|-------------|---------------|
| Electronics | 166800        | 195000       | 260000      | 26400       | 648200        |
| Apparel     | 36000         | 39975        | 28000       | 36750       | 140725        |
| Home         | 0            | 81500        | 48000       | 21600       | 151100        |
| Books        | 0            | 23300        | 13500       | 9750        | 46550         |

```sql
-- Using orders.csv: Monthly order pivot by payment method
SELECT 
    EXTRACT(MONTH FROM order_date) AS month_num,
    COUNT(CASE WHEN payment_method = 'Credit Card' THEN 1 END) AS credit_card_orders,
    COUNT(CASE WHEN payment_method = 'UPI' THEN 1 END) AS upi_orders,
    COUNT(CASE WHEN payment_method = 'EMI' THEN 1 END) AS emi_orders,
    COUNT(CASE WHEN payment_method = 'Debit Card' THEN 1 END) AS debit_card_orders
FROM orders
GROUP BY 1
ORDER BY 1;
```

---

## 🚀 Pro-Tips for Interviews

1. When asked how you clean data in SQL, always mention **CTEs** over subqueries for readability, and explain **why** you chose a specific window function (e.g., `ROW_NUMBER` vs `RANK`) for deduplication.

2. **COALESCE vs IFNULL:** `COALESCE` is ANSI standard (works everywhere), `IFNULL` is MySQL-specific. Always default to `COALESCE`.

3. **Data Quality Checklist in SQL:**
   ```sql
   -- Quick data quality report for any table
   SELECT 
       COUNT(*) AS total_rows,
       COUNT(DISTINCT customer_id) AS unique_customers,
       COUNT(phone_number) AS non_null_phones,
       COUNT(*) - COUNT(phone_number) AS null_phones,
       ROUND(100.0 * (COUNT(*) - COUNT(phone_number)) / COUNT(*), 1) AS null_pct
   FROM customers;
   ```
