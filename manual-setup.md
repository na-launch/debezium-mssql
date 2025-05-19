# Use the official Microsoft image
docker run --platform linux/amd64 \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=<PASSWORD>" \
  -p 1433:1433 \
  --name sql1 \
  --hostname sql1 \
  -d mcr.microsoft.com/mssql/server:2022-latest



docker logs -f sql1

# Connect using sqlcmd (if installed):
sqlcmd -S localhost -U SA -P "<PASSWORD>"

# or

# Bash to the container:
docker exec -it sql1 bash
# Run sqlcommand
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "<PASSWORD>"

# If your local SQL Server container isn’t configured with a TLS certificate, the connection fail, you need to disable security (use this command TODO explain -N -C -l 30)
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P '<PASSWORD>' -N -C -l 30

# OPTIONAL TEST (once inside SQL Shell)
# To list all databases in SQL Server using sqlcmd, run:
SELECT name FROM sys.databases;
GO


# Create a sample database
CREATE DATABASE testdb;
GO
USE testdb;
GO


#  Required SQL Server Configuration
-- Grant permissions to the Debezium SQL user (assuming it's 'debezium')
CREATE LOGIN debezium WITH PASSWORD = '<PASSWORD>';
CREATE USER debezium FOR LOGIN debezium;
ALTER ROLE db_owner ADD MEMBER debezium;

# GRANT VIEW SERVER STATE TO debezium;
USE master;
GO
GRANT VIEW SERVER STATE TO debezium;
GO
USE testdb;
GO

# Enable CDC on your new DB
EXEC sys.sp_cdc_enable_db;
GO

# Create a sample table:
CREATE TABLE dbo.users (
    id INT PRIMARY KEY,
    name NVARCHAR(100),
    email NVARCHAR(100)
);
GO


#	Enable CDC on the table:
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'users',
    @role_name = NULL;
GO




Excellent — that message means CDC was enabled successfully on the users table! 🎉
⸻
🟡 What the warnings mean
	1.	Update mask evaluation disabled:
	•	This just affects how cdc.fn_cdc_get_net_changes_* computes updated columns.
	•	It can safely be ignored for most Debezium use cases.
	2.	SQL Server Agent not running:
	•	SQL Server Agent is used to manage CDC cleanup and scheduling.
	•	Inside containers, it’s typically not started — and Debezium does not depend on it.
	•	⚠️ However, it does mean you must manually manage CDC cleanup or enable the agent later if needed.

--- SQL SERVER CONFIGURED!!




# Compose Kafka and Debezium
vim docker-compose.yml 

# Run Kafka and Debezium (inside docker compose)
docker compose up -d


# Register the SQL Server connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sqlserver-connector",
    "config": {
      "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
      "database.hostname": "host.docker.internal",
      "database.port": "1433",
      "database.user": "debezium",
      "database.password": "Samnmax13#",
      "database.names": "testdb",
      "topic.prefix": "sql3",
      "table.include.list": "dbo.users",
      "database.server.name": "sql3",
      "database.encrypt": "false",
      "database.trustServerCertificate": "true",
      "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
      "schema.history.internal.kafka.topic": "schema-changes.testdb",
      "snapshot.mode": "always"
    }
  }'

# bash back to sql
# add user that should be cdc'ing
USE testdb;
GO

INSERT INTO dbo.users (id, name, email)
VALUES (1, 'Alice', 'alice@example.com');
GO  


# 2. Confirm topic in Kafka
# Check that a topic like this now exists:
sql1.testdb.dbo.users

# example kafka CLI command to verify
/bin/kafka-topics --bootstrap-server kafka:9092 --list


/bin/kafka-console-consumer \
  --bootstrap-server kafka:9092 \
  --topic sql3.testdb.dbo.users \
  --from-beginning

# CONGRATS!