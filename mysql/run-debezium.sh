#!/bin/bash
set -e

# This script sets up a Debezium MySQL connector to capture changes from a MySQL database.
curl --fail -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
  "name": "mysql-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "dbz",
    "database.server.id": "184054",
    "database.server.name": "mysql",
    "database.include.list": "inventory",
    "table.include.list": "inventory.users",
    "schema.history.internal.storage": "kafka",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.mysql",
    "topic.prefix": "mysql"
  }
}' | jq .