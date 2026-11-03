-- 1. Create the replication user for Debezium
CREATE USER replicator WITH REPLICATION LOGIN PASSWORD 'repl_password';

-- 2. Unlock the doors (Database -> Schema -> Tables)
GRANT CONNECT ON DATABASE shop TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;

-- 3. Create an 'orders' table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product VARCHAR(100) NOT NULL,
    amount INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending'
);

-- 4. Tell Postgres to include BOTH old and new values on UPDATE/DELETE
ALTER TABLE orders REPLICA IDENTITY FULL;

-- 5. Create the Publication (the "channel" Debezium will subscribe to)
CREATE PUBLICATION dbz_publication FOR TABLE orders;

-- 6. Insert 1 initial row
INSERT INTO orders (product, amount) VALUES ('Mechanical Keyboard', 120);
