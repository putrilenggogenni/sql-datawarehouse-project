/*
===================================================================================================
DDL Script: Create Silver Tables
===================================================================================================
Script Purpose:
    This script creates the tables required for the Silver layer of the Data Warehouse.

    The Silver layer stores data transformed from the Bronze layer. Data in this layer
    is cleaned, validated, standardized, and prepared for further transformation and
    integration.

    Existing tables are dropped before being recreated to ensure the table structure
    is consistently defined.

Layer Purpose:
    Bronze:
        Stores raw data loaded directly from source systems.

    Silver:
        Cleans, standardizes, validates, and transforms data from the Bronze layer.

    Gold:
        Stores business-ready data for reporting and analytics.

Tables Created:
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

Metadata:
    Each Silver table includes 'dwh_create_date' to record the timestamp
    when the record is created in the Silver layer.

Usage:
    Run this script to create or re-define the Silver layer table structures.
===================================================================================================
*/


/*
===================================================================================================
Table: silver.crm_cust_info
Source: Bronze CRM
Purpose:
    Stores cleaned and standardized customer information transformed from
    the Bronze CRM customer data.
===================================================================================================
*/

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cts_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===================================================================================================
Table: silver.crm_prd_info
Source: Bronze CRM
Purpose:
    Stores cleaned and standardized product information transformed from
    the Bronze CRM product data.
===================================================================================================
*/

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===================================================================================================
Table: silver.crm_sales_details
Source: Bronze CRM
Purpose:
    Stores cleaned and standardized sales transaction details transformed
    from the Bronze CRM sales data.
===================================================================================================
*/

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===================================================================================================
Table: silver.erp_cust_az12
Source: Bronze ERP
Purpose:
    Stores cleaned and standardized customer demographic information
    transformed from the Bronze ERP customer data.
===================================================================================================
*/

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===================================================================================================
Table: silver.erp_loc_a101
Source: Bronze ERP
Purpose:
    Stores cleaned and standardized customer location information
    transformed from the Bronze ERP location data.
===================================================================================================
*/

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===================================================================================================
Table: silver.erp_px_cat_g1v2
Source: Bronze ERP
Purpose:
    Stores cleaned and standardized product category and maintenance
    information transformed from the Bronze ERP product data.
===================================================================================================
*/

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
