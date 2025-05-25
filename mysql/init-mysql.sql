USE inventory;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255)
);

INSERT INTO users (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob', 'bob@example.com');

-- Grant necessary privileges for Debezium replication user
CREATE USER IF NOT EXISTS 'debezium'@'%' IDENTIFIED BY 'dbz';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, LOCK TABLES
ON *.* TO 'debezium'@'%';

GRANT ALL PRIVILEGES ON inventory.* TO 'debezium'@'%';

FLUSH PRIVILEGES;