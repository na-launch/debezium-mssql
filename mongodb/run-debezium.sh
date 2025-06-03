#!/bin/bash
set -e

# This script sets up a Debezium MONGODB connector to capture changes from a MONGO database.
curl -i -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "mongodb-connector",
    "config": {
      "connector.class": "io.debezium.connector.mongodb.MongoDbConnector",
      "mongodb.connection.string": "mongodb://mongodb:27017/?replicaSet=rs0",
      "mongodb.name": "mongo",
      "database.include.list": "testdb",
      "collection.include.list": "testdb.users",
      "tasks.max": "1",
      "snapshot.mode": "initial",
      "topic.prefix": "mongo",
      "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
      "schema.history.internal.kafka.topic": "schema-changes.mongo"
    }
  }'