#!/bin/bash
set -e

# This script sets up a Debezium POSTGRES connector to capture changes from a POSTGRES database.
curl --fail -X POST http://localhost:8083/connectors \
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
    "database.server.name": "pg",
    "topic.prefix": "pg",
    "schema.include.list": "public",
    "table.include.list": "public.users",
    "plugin.name": "pgoutput",
    "slot.name": "debezium",
    "publication.name": "dbz_pub",
    "slot.drop.on.stop": "true",
    "snapshot.mode": "initial",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.pg"
  }
}' | jq .