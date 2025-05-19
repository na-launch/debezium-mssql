# Using Debezium and SQL Server

The following project shows you how to quick set up change-data-capture on a containerized version of MS SQL Server using Debezium. Any CRUD operations made in MS SQL will be picked up by Debezium and published as a message to a topic in Kafka. The message is formatted via Debeziums connector schema. 

The project installs MS SQL Server (see version compatibility), Kafka, Zookeeper and Debezium. Everything runs in containers, so all you need is Podman or Docker. Please be wary of licensing when using SQL - for this example, we are using SQL Developer Edition. 


## Automatic Setup

### 1. Run the docker-compose command 

```
docker-compose up
```

ⓘ You may need to tweak the docker file to match your own set up.


---


### 2. Set up a connector

The following command creates a new debezium connector (we will call this a SQL connector for this example)

#### SQL Server
```
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sqlserver-connector",
    "config": {
      "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
      "database.hostname": "sqlserver",
      "database.port": "1433",
      "database.user": "[DBUSER]",
      "database.password": "[PASSWORD]",
      "topic.prefix": "[TOPIC-PREFIX]",
      "database.names": "[DBNAME]",
      "table.include.list": "dbo.[TABLE]",
      "database.encrypt": "false",
      "database.trustServerCertificate": "true",
      "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
      "schema.history.internal.kafka.topic": "schema-changes.[DBNAME]",
      "snapshot.mode": "always"
    }
  }'
```

#### POSTGRES
```
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "postgres-connector",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "database.hostname": "postgres",
      "database.port": "5432",
      "database.user": "postgres",
      "database.password": "postgres",
      "database.dbname": "inventory",
      "database.server.name": "postgresserver1",
      "plugin.name": "pgoutput",
      "topic.prefix": "postgresserver1"
    }
  }'
  ```
---


### 3. Insert Data into SQL
##### sqlcmd cli
```
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '[PASSWORD]' -C
```

##### CREATE new user
```sql
INSERT INTO dbo.users (name, email) VALUES ('debezium', 'new_user@debezium.io');
```

##### UPDATE user
```sql
UPDATE dbo.users
SET name = 'debezium_updated', email = 'updated@debezium.io'
WHERE name = 'debezium';
GO
```

##### DELETE User
```sql
DELETE FROM dbo.users
WHERE name = 'debezium_updated' AND email = 'updated@debezium.io';
GO
```
---
### 4. Verify in CDC worked by looking for topic in Kafka
From your Kafka Instance..

##### List all topics - verify CDC is there
```
kafka-topics \
    --bootstrap-server localhost:9092 \
    --list
```
Debezium will generate a KAFKA topic based on `topic.prefix` and `table name`


##### Consume the messages from beginning
```
kafka-console-consumer \
    --bootstrap-server kafka:9092  \
    --topic [TOPIC] \
    --from-beginning
```

<br><br>
---
<br>

# Reference Commands 
## Install sqlcmd
```
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install --no-sandbox msodbcsql18 mssql-tools18
```

## DEBEZIUM COMMANDS
### Get Connectors
> curl -s http://localhost:8083/connectors | jq

### Delete Connector
> curl -X DELETE http://localhost:8083/connectors/<connector-name>

### Get the configuration of the connector
> curl -s http://localhost:8083/connectors/sqlserver-connector/config | jq

### Debezium Connector Status
> curl -s http://localhost:8083/connectors/sqlserver-connector/status | jq


## KAFKA COMMANDS
### List topics
```docker
docker exec -it debezium-onmssql-kafka-1 /bin/kafka-topics \
    --bootstrap-server localhost:9092 \
    --list
```

### Consume messages
```docker
docker exec -it debezium-onmssql-kafka-1 /bin/kafka-console-consumer \
    --bootstrap-server kafka:9092  \
    --topic sqlserver.testdb.dbo.users \
    --from-beginning
```

## SQL COMMANDS
### sqlcmd cli
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C

### INSERT new user
```sql
INSERT INTO dbo.users (name, email) VALUES ('debezium', 'test@debezium.io');
```

### Update user
```sql
UPDATE dbo.users
SET name = 'persona_updated', email = 'updated@debezium.io'
WHERE name = 'persona';
GO
```

### Delete User
```sql
DELETE FROM dbo.users
WHERE name = 'persona_updated' AND email = 'updated@debezium.io';
GO
```