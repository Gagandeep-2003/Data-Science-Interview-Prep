# 🛠️ SQL for Data Cleaning & Processing

*Turning raw, messy data into analysis-ready gold. A guide to the most common data prep patterns in SQL.*

---

## 1. 👯 Handling Duplicates
Duplicates are the silent killers of accurate analysis. Identifying them correctly is step one.

### A. The "Big Hammer" (DISTINCT)
Use when you want to remove exact duplicate rows across all selected columns.
```sql
SELECT DISTINCT * FROM raw_orders;
```

### B. Grouping to Find Count
Useful for identifying which keys are duplicated.
```sql
SELECT email, COUNT(*) 
FROM users 
GROUP BY email 
HAVING COUNT(*) > 1;
```

### C. The Precision Tool (Window Functions)
The most robust way to deduplicate while keeping one record (e.g., the most recent one).
```sql
WITH Deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id 
               ORDER BY signup_date DESC
           ) as row_num
    FROM users
)
SELECT * FROM Deduplicated WHERE row_num = 1;
```

---

## 2. 🕳️ Managing Missing Values (NULLs)
NULLs behave differently than zeros or empty strings. They require special handling.

- `COALESCE(col, default)`: Returns the first non-null value. Perfect for filling holes.
- `NULLIF(col, value)`: Returns NULL if the column matches the value (e.g., swapping `0` or `''` for `NULL`).

```sql
-- Replace NULL zipcodes with a placeholder and 0 price with NULL
SELECT 
    user_id,
    COALESCE(zipcode, 'Unknown') AS clean_zipcode,
    NULLIF(price, 0) AS nullable_price
FROM sales;
```

### Conditional Imputation
```sql
SELECT 
    item_id,
    CASE 
        WHEN category = 'Electronics' AND price IS NULL THEN 299.99
        WHEN category = 'Office' AND price IS NULL THEN 19.99
        ELSE price 
    END AS imputed_price
FROM inventory;
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
-- Cleaning ' $ 1,200.50 ' -> 1200.50
SELECT 
    CAST(REPLACE(REPLACE(TRIM(price_str), '$', ''), ',', '') AS NUMERIC) AS clean_price
FROM messy_table;
```

---

## 4. 📅 Date & Timeline Normalization
Date formats are notoriously inconsistent.

- **Casting:** `CAST(raw_date AS DATE)` or `raw_date::DATE`.
- **Parsing:** `TO_DATE('2023-Oct-01', 'YYYY-Mon-DD')`.
- **Handling Timestamps:** Always normalize to UTC where possible.

```sql
-- Calculating time since last order
SELECT 
    customer_id,
    DATEDIFF('day', last_order_date, CURRENT_DATE) AS days_since_active,
    DATE_TRUNC('month', last_order_date) AS order_month
FROM customer_activity;
```

---

## 5. 📏 Outliers & Data Integrity
Before running a model, ensure your numeric ranges make sense.

### Capping (Winsorization) logic
```sql
SELECT 
    order_id,
    CASE 
        WHEN amount > 10000 THEN 10000 -- Cap at 10k
        WHEN amount < 0 THEN 0         -- Floor at 0
        ELSE amount 
    END AS adjusted_amount
FROM sales;
```

---

## 6. 🔄 Reshaping Data (Pivoting)
Converting long-format data into wide-format (often needed for features).

```sql
-- Converting multiple rows per user into one row with columns for categories
SELECT 
    user_id,
    SUM(CASE WHEN category = 'Apparel' THEN amount ELSE 0 END) AS apparel_spend,
    SUM(CASE WHEN category = 'Food' THEN amount ELSE 0 END) AS food_spend,
    SUM(CASE WHEN category = 'Tech' THEN amount ELSE 0 END) AS tech_spend
FROM transactions
GROUP BY user_id;
```

---

## 🚀 Pro-Tip for Interviews
When asked how you clean data in SQL, always mention **CTEs** over subqueries for readability, and explain **why** you chose a specific window function (e.g., `ROW_NUMBER` vs `RANK`) for deduplication.
