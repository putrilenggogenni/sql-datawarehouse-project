/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Run after creating the Gold views.
Every check below should return NO ROWS (or the stated expectation).
===============================================================================
*/

-- 1. Surrogate key must be unique in dim_customers
SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- 2. Surrogate key must be unique in dim_products
SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- 3. Natural keys must also be unique (otherwise the fact join duplicates rows)
SELECT customer_id, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_number, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- 4. Referential integrity: every fact row must find its dimension rows
SELECT f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products  p ON p.product_key  = f.product_key
WHERE c.customer_key IS NULL
   OR p.product_key  IS NULL;

-- 5. No row fan-out: fact row count must equal the Silver row count
-- Expectation: difference = 0
SELECT
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_rows,
    (SELECT COUNT(*) FROM gold.fact_sales)          AS gold_rows,
    (SELECT COUNT(*) FROM gold.fact_sales)
  - (SELECT COUNT(*) FROM silver.crm_sales_details) AS difference;
