#!/bin/bash
set -e

# This script sets up a Debezium MSSQL connector to capture changes from a MSSQL database.
curl --fail -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
  "name": "sqlserver-connector",
  "config": {
    "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
    "database.hostname": "sqlserver",
    "database.port": "1433",
    "database.user": "sa",
    "database.password": "YourStrong!Passw0rd",
    "topic.prefix": "sqlserver",
    "database.names": "testdb",
    "table.include.list": "dbo.users",
    "database.encrypt": "false",
    "database.trustServerCertificate": "true",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.testdb",
    "snapshot.mode": "always"
  }
}' | jq .