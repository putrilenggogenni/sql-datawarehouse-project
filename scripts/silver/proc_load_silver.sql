/*
===================================================================================================
Stored Procedure: Load Silver Layer
===================================================================================================
Script Purpose:
    This stored procedure loads data from the Bronze layer into the Silver layer
    by applying data cleansing, validation, standardization, and transformation
    rules.

    The Silver layer improves data quality while preserving business meaning,
    preparing the data for integration into the Gold layer.

Process Overview:
    1. Capture the start time of the overall Silver loading process.
    2. Truncate existing Silver tables.
    3. Transform and load data from the Bronze layer.
    4. Apply data quality rules such as:
        - Removing duplicate records.
        - Trimming unnecessary whitespace.
        - Standardizing categorical values.
        - Handling NULL and missing values.
        - Validating date values.
        - Correcting invalid numeric values.
        - Standardizing business keys.
    5. Record execution time for each table load.
    6. Record the total execution time for the complete Silver load.
    7. Handle unexpected errors using TRY...CATCH.

Source Layer:
    Bronze

Target Layer:
    Silver

Target Tables:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

Parameters:
    None. This stored procedure does not accept any parameters.

Usage Example:
    EXEC silver.load_silver;

Note:
    This procedure assumes that the Bronze layer has already been successfully
    loaded before execution.
===================================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE
		@start_time DATETIME,
		@end_time DATETIME,
		@batch_start_time DATETIME,
		@batch_end_time DATETIME;

		PRINT('=================================================')
		PRINT('PROCEDURE LOAD SILVER IS ABOUT TO BEGIN...')
		PRINT('=================================================')
		SET @batch_start_time = GETDATE();
		
		/*
		=================================================================
		Transform Table: silver.crm_cust_info
		Purpose:
			Clean customer data by removing duplicates, trimming text,
			and standardizing marital status and gender values.
		=================================================================
		*/

		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.crm_cust_info')
		TRUNCATE TABLE silver.crm_cust_info
		PRINT('>>>Inserting Data to Table : silver.crm_cust_info')
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cts_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT cst_id, cst_key, 
			TRIM(cst_firstname) AS cst_firstname, 
			TRIM(cts_lastname) AS cts_lastname,
			CASE TRIM(UPPER(cst_marital_status)) 
				WHEN 'M' THEN 'Married'
				WHEN 'S' THEN 'Single'
				ELSE 'n/a' 
			END AS cst_marital_status,
			CASE TRIM(UPPER(cst_gndr)) 
				WHEN 'M' THEN 'Male'
				WHEN 'F' THEN 'Female'
				ELSE 'n/a' 
			END AS cst_gndr, 
			cst_create_date 
		FROM
			(SELECT *, ROW_NUMBER() 
			OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
			FROM bronze.crm_cust_info WHERE cst_id is not null) t
		WHERE flag = 1

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')

		/*
		=================================================================
		Transform Table: silver.crm_prd_info
		Purpose:
			Standardize product information, generate category identifiers,
			handle missing costs, and calculate product validity periods.
		=================================================================
		*/

		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.crm_prd_info')
		TRUNCATE TABLE silver.crm_prd_info
		PRINT('>>>Inserting Data to Table : silver.crm_prd_info')
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt	
		)

		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			COALESCE(prd_cost , 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'M' THEN 'Mountain'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST (prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) 
				AS prd_end_dt
		from bronze.crm_prd_info


		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')

		/*
		=================================================================
		Transform Table: silver.crm_sales_details
		Purpose:
			Validate sales dates, correct invalid sales amounts,
			and standardize price values.
		=================================================================
		*/
		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.crm_sales_details')
		TRUNCATE TABLE silver.crm_sales_details
		PRINT('>>>Inserting Data to Table : silver.crm_sales_details')
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num, 
			sls_prd_key, 
			sls_cust_id, 
			CASE
				WHEN sls_order_dt = 0 OR len(sls_order_dt) != 8 THEN NULL
				ELSE CAST(STR(sls_order_dt) AS DATE) 
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt = 0 OR len(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(STR(sls_ship_dt) AS DATE) 
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt = 0 OR len(sls_due_dt) != 8 THEN NULL
				ELSE CAST(STR(sls_due_dt) AS DATE) 
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales != sls_quantity * abs(sls_price) 
				THEN sls_quantity * abs(sls_price)
				ELSE sls_sales 
			END AS sls_sales,
			sls_quantity, 
			CASE 
				WHEN sls_price < 0 THEN ABS(sls_price) 
				ELSE sls_price
			END AS sls_price 
		FROM bronze.crm_sales_details

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')

		/*
		=================================================================
		Transform Table: silver.erp_cust_az12
		Purpose:
			Standardize customer identifiers, validate birth dates,
			and normalize gender values.
		=================================================================
		*/

		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.erp_cust_az12')
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT('>>>Inserting Data to Table : silver.erp_cust_az12')
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
			WHEN cid LIKE 'NASAW000%' THEN SUBSTRING(cid, 4, LEN(CID))
			ELSE cid
			END AS cid,
			CASE 
			WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
			END AS bdate,
			CASE
				WHEN TRIM(gen) = '' OR gen IS NULL THEN 'n/a'
				WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
				ELSE gen
			END AS gen
		FROM bronze.erp_cust_az12

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')
		/*
		=================================================================
		Transform Table: silver.erp_loc_a101
		Purpose:
			Standardize customer location information and normalize
			country names.
		=================================================================
		*/

		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.erp_loc_a101')
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT('>>>Inserting Data to Table : silver.erp_loc_a101')
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid,'-', '') AS cid,
			CASE 
				WHEN cntry is null or TRIM(cntry) = '' THEN 'n/a'
				WHEN UPPER(TRIM(cntry)) in ('DE', 'GERMANY') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) in ('US','USA', 'UNITED STATES') THEN 'United States'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101
		
		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')
		/*
		=================================================================
		Transform Table: silver.erp_px_cat_g1v2
		Purpose:
			Load standardized product category information.
		=================================================================
		*/

		SET @start_time = GETDATE()
		PRINT('>>>Truncating Table : silver.erp_px_cat_g1v2')
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT('>>>Inserting Data to Table : silver.erp_px_cat_g1v2')
		INSERT INTO silver.erp_px_cat_g1v2 (
			id, 
			cat, 
			subcat, 
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		
		SET @end_time = GETDATE()

		PRINT('SUCCESSFULLY TRANSFORMED DATA')
		PRINT('TOTAL PROCESS TIME : '
			+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('')
		
		SET @batch_end_time = GETDATE()
		PRINT('=================================================')
		PRINT('SUCCESSFULLY LOADED SILVER LAYER')
		PRINT('=================================================')
		PRINT('TOTAL ELAPSED : '
			+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('=================================================')
	END TRY

	BEGIN CATCH
		SET @batch_end_time = GETDATE()

		PRINT('')
		PRINT('=================================================')
		PRINT('SILVER LOAD FAILED')
		PRINT('=================================================')
		PRINT('ERROR MESSAGE    : ' + ERROR_MESSAGE())
		PRINT('ERROR NUMBER     : ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('ERROR LINE       : ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('ERROR PROCEDURE  : ' + ISNULL(ERROR_PROCEDURE(),'N/A'))
		PRINT('TOTAL ELAPSED    : '
			+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)
			+ ' seconds')
		PRINT('=================================================')
	END CATCH
END
