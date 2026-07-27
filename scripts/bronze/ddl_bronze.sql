/*
=================================================================
DDL Script: Create Bronze Tables
=================================================================
Script Purpose:
    This script creates the tables required for the Bronze layer
    of the Data Warehouse.

    The Bronze layer stores raw data ingested from CRM and ERP
    source systems with minimal transformation.

    Existing tables are dropped before being recreated to ensure
    the table structure is consistently defined.

Tables Created:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Usage:
    Run this script to create or re-define the Bronze layer
    table structures.
=================================================================
*/


/*
=================================================================
Table: bronze.crm_cust_info
Source: CRM
Purpose:
    Stores raw customer information from the CRM source system.
=================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cts_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO


/*
=================================================================
Table: bronze.crm_prd_info
Source: CRM
Purpose:
    Stores raw product information from the CRM source system.
=================================================================
*/

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
GO


/*
=================================================================
Table: bronze.crm_sales_details
Source: CRM
Purpose:
    Stores raw sales transaction details from the CRM
    source system.
=================================================================
*/

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO


/*
=================================================================
Table: bronze.erp_cust_az12
Source: ERP
Purpose:
    Stores raw customer demographic information from the ERP
    source system.
=================================================================
*/

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO


/*
=================================================================
Table: bronze.erp_loc_a101
Source: ERP
Purpose:
    Stores raw customer location information from the ERP
    source system.
=================================================================
*/

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO


/*
=================================================================
Table: bronze.erp_px_CAT_G1V2
Source: ERP
Purpose:
    Stores raw product category and maintenance information
    from the ERP source system.
=================================================================
*/

IF OBJECT_ID('bronze.erp_px_CAT_G1V2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_CAT_G1V2;
GO

CREATE TABLE bronze.erp_px_CAT_G1V2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO
