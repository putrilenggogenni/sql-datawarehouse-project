/*
===================================================================================================
Script: Create Database & Schemas
===================================================================================================
Script Purpose:
    This script creates the 'DataWarehouse' database and its required schemas.

    The script first checks whether the 'DataWarehouse' database already exists.
    If it exists, the database is dropped and recreated to ensure a clean and
    consistent environment.

    The following schemas are created within the 'DataWarehouse' database:
        - bronze : Stores raw data ingested from source systems.
        - silver : Stores cleaned and transformed data.
        - gold   : Stores business-ready data for reporting and analytics.

WARNING:
    This script will permanently drop the existing 'DataWarehouse' database,
    including all data and objects within it.

    Make sure you have a backup or are working in a development environment
    before executing this script.
===================================================================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO  

USE DataWarehouse;
GO

-- Create the Data Warehouse schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
