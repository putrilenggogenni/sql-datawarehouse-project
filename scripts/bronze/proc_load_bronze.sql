/*
===================================================================================================
Stored Procedure: Load Bronze Layer
===================================================================================================
Script Purpose:
    This stored procedure loads raw data from external CSV files into the Bronze layer
    of the Data Warehouse.

    The Bronze layer serves as the initial landing zone for source data. Data is loaded
    with minimal transformation to preserve the original structure and content from
    the source systems.

Process Overview:
    1. Capture the start time of the overall Bronze loading process.
    2. Truncate existing Bronze tables before loading new data.
    3. Load raw data from CSV files using BULK INSERT.
    4. Capture and display the execution time for each table load.
    5. Capture and display the total execution time for the complete Bronze load.
    6. Handle unexpected errors using TRY...CATCH.

Source Systems:
    CRM:
        - Customer Information
        - Product Information
        - Sales Transaction Details

    ERP:
        - Customer Demographic Information
        - Customer Location Information
        - Product Category Information

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Performance Monitoring:
    The procedure records:
        - Start and end time for each table load.
        - Execution duration for each table load.
        - Start and end time for the complete Bronze load.
        - Total execution duration for the complete load.
        - Error details and elapsed time when the load fails.

Parameters:
    @base_path NVARCHAR(500)
        Full path to the 'dataset' folder that contains the 'source_crm' and
        'source_erp' sub-folders. The folder must be accessible by the SQL Server
        service. Default value is a placeholder, so pass your own path when executing.

Usage Example:
    EXEC bronze.load_bronze @base_path = 'C:\path\to\sql-datawarehouse-project\dataset\';

Note:
    BULK INSERT does not accept a variable as the file name, so each load statement is
    built as dynamic SQL and executed with sp_executesql.
===================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
	@base_path NVARCHAR(500) = N'C:\path\to\sql-datawarehouse-project\dataset\'
AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, 
				@end_time DATETIME, 
				@batch_start_time DATETIME, 
				@batch_end_time DATETIME,
				@sql NVARCHAR(MAX)

		-- Make sure the path ends with a backslash and is safe to embed in a string literal
		SET @base_path = REPLACE(@base_path, '''', '''''')
		IF RIGHT(@base_path, 1) <> '\'
			SET @base_path = @base_path + '\'

		PRINT('=================================================')
		PRINT('PROCEDURE LOAD BRONZE IS ABOUT TO BEGIN...')
		PRINT('=================================================')
		PRINT('')

		-- Get Start Time for Overall Load Process
		SET @batch_start_time = GETDATE()

		/*
		=================================================================
		Load Table: bronze.crm_cust_info
		Source File: source_crm\cust_info.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.crm_cust_info

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.crm_cust_info FROM ''' + @base_path + N'source_crm\cust_info.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Load Table: bronze.crm_prd_info
		Source File: source_crm\prd_info.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.crm_prd_info

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.crm_prd_info FROM ''' + @base_path + N'source_crm\prd_info.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Load Table: bronze.crm_sales_details
		Source File: source_crm\sales_details.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.crm_sales_details

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.crm_sales_details FROM ''' + @base_path + N'source_crm\sales_details.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Load Table: bronze.erp_cust_az12
		Source File: source_erp\CUST_AZ12.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.erp_cust_az12

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.erp_cust_az12 FROM ''' + @base_path + N'source_erp\CUST_AZ12.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Load Table: bronze.erp_loc_a101
		Source File: source_erp\LOC_A101.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.erp_loc_a101

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.erp_loc_a101 FROM ''' + @base_path + N'source_erp\LOC_A101.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Load Table: bronze.erp_px_cat_g1v2
		Source File: source_erp\PX_CAT_G1V2.csv
		=================================================================
		*/

		TRUNCATE TABLE bronze.erp_px_cat_g1v2

		PRINT('PROCESSING LOAD RAW DATA TO TABLE...')
		SET @start_time = GETDATE()

		SET @sql = N'BULK INSERT bronze.erp_px_cat_g1v2 FROM ''' + @base_path + N'source_erp\PX_CAT_G1V2.csv''
			WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);'
		EXEC sp_executesql @sql

		SET @end_time = GETDATE()

		PRINT('SUCCESSFULL LOAD DATA')
		PRINT('TOTAL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR))
		PRINT('')


		/*
		=================================================================
		Final Load Summary
		=================================================================
		*/

		SET @batch_end_time = GETDATE()

		PRINT('=================================================')
		PRINT('SUCCESSFULL LOAD ALL DATA')
		PRINT('=================================================')
		PRINT('TOTAL ALL LOAD PROCESS TABLE :  ' 
			+ CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR))
		PRINT('=================================================')

	END TRY

	BEGIN CATCH

		/*
		=================================================================
		Error Handling
		=================================================================
		*/

		SET @batch_end_time = GETDATE()

		PRINT('')
		PRINT('=================================================')
		PRINT('BRONZE LOAD FAILED')
		PRINT('=================================================')
		PRINT('ERROR MESSAGE    : ' + ERROR_MESSAGE())
		PRINT('ERROR NUMBER     : ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('ERROR LINE       : ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('ERROR PROCEDURE  : ' + ISNULL(ERROR_PROCEDURE(), 'N/A'))
		PRINT('TOTAL ELAPSED    : ' 
			+ CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
			+ ' seconds')
		PRINT('=================================================')

	END CATCH
END
