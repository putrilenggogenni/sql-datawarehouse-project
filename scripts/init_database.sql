/*
===================================================================================================
CREATE DATABASE & SCHEMAS
===================================================================================================
Script Purpose :
  This Script is for Create a Database called 'DataWarehouse' before executed it, it would check if 
  exist then delete that Database. Additionally, In 'DataWarehouse' Database , i have create 3 schemas
  which is schema 'bronze', 'silver' and 'gold'. 

WARNING:
  Before Executed this Script makesure that you ready to accept if 'DataWarehouse' database (if exist
  in your database would be drop), to prevent this, you could make a backup for the database.
*/

USE master;
GO

--Drop and recreate the 'DataWarehouse' database
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

-- Creates Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
