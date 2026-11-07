/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Run after EXEC silver.load_silver.
Unless a comment says otherwise, every check should return NO ROWS.
===============================================================================
*/

-- ---------- silver.crm_cust_info ----------
-- NULL or duplicate primary key
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces
SELECT cst_key FROM silver.crm_cust_info WHERE cst_key <> TRIM(cst_key);
SELECT cst_firstname FROM silver.crm_cust_info WHERE cst_firstname <> TRIM(cst_firstname);
SELECT cst_lastname FROM silver.crm_cust_info WHERE cst_lastname <> TRIM(cst_lastname);

-- Standardization (expect only: Married, Single, n/a / Male, Female, n/a)
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- ---------- silver.crm_prd_info ----------
SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm <> TRIM(prd_nm);

-- NULL or negative cost
SELECT prd_cost FROM silver.crm_prd_info WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Standardization (expect: Mountain, Road, Other Sales, Touring, n/a)
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Invalid date order
SELECT * FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt;

-- ---------- silver.crm_sales_details ----------
-- Invalid date order
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- sales = quantity * price, and no NULL / zero / negative values
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ---------- silver.erp_cust_az12 ----------
-- Birthdate out of range (expect: none older than 1924 or in the future)
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Standardization (expect: Male, Female, n/a)
SELECT DISTINCT gen FROM silver.erp_cust_az12;

-- ---------- silver.erp_loc_a101 ----------
-- Country standardization: review the list manually
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;

-- ---------- silver.erp_px_cat_g1v2 ----------
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat) OR subcat <> TRIM(subcat) OR maintenance <> TRIM(maintenance);

SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;
