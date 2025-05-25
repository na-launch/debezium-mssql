-- init_debezium.sql
CREATE ROLE debezium WITH LOGIN REPLICATION PASSWORD 'dbz';

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO users (name, email)
VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com')
ON CONFLICT DO NOTHING;

CREATE PUBLICATION dbz_pub FOR TABLE users;