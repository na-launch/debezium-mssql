#!/bin/bash
curl -X PUT http://localhost:8083/connectors/jdbc-postgres-sink/config \
  -H "Content-Type: application/json" \
  -d '{
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "topics": "mysql.inventory.users",
    "connection.url": "jdbc:postgresql://postgres:5432/inventory",
    "connection.username": "postgres",
    "connection.password": "postgres",
    "insert.mode": "upsert",
    "primary.key.mode": "record_key",
    "primary.key.fields": "id",
    "table.name.format": "users",
    "auto.create.tables": "false",
    "auto.evolve.tables": "false",
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState"
  }'