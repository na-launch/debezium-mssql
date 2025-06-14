-- Enable Agent XPs (required for SQL Server Agent)
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'Agent XPs', 1;
GO
RECONFIGURE;
GO
-- Wait for DB creation to complete (in case this script runs quickly)
WAITFOR DELAY '00:00:05';
GO

CREATE DATABASE testdb;
GO
USE master;
GO
ALTER DATABASE testdb SET RECOVERY FULL;
GO

-- Enable CDC for the testdb database
USE testdb;
GO
-- Create dbo.users table
CREATE TABLE dbo.users (
  id INT PRIMARY KEY IDENTITY(1,1),
  name NVARCHAR(100),
  email NVARCHAR(100) CONSTRAINT UQ_email UNIQUE
);
GO
EXEC sys.sp_cdc_enable_db;
GO

-- Enable CDC on dbo.users table
EXEC sys.sp_cdc_enable_table
  @source_schema = 'dbo',
  @source_name = 'users',
  @role_name = NULL;
GO

-- Verify CDC is enabled
SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'testdb';
GO
SELECT * FROM cdc.change_tables;
GO

-- Check if CDC jobs are running
USE msdb;
GO
SELECT name FROM sysjobs WHERE name LIKE 'cdc.%';
GO

-- Check contents of the capture instance table
USE testdb;
GO
SELECT * FROM cdc.dbo_users_CT;
GO

-- Insert sample data to test CDC capture
INSERT INTO dbo.users (name, email) VALUES ('Alice Smith', 'alice@example.com');
INSERT INTO dbo.users (name, email) VALUES ('Bob Johnson', 'bob@example.com');
GO

-- Delay to allow CDC capture to run
WAITFOR DELAY '00:00:05';
GO

-- Query capture instance again to confirm changes
SELECT * FROM cdc.dbo_users_CT;
GO