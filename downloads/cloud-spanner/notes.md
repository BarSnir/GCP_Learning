## SQL to execute

```sql

-- 1. Create the table
CREATE TABLE users   (
    id INT PRIMARY KEY, 
    username VARCHAR(30)
);

-- 2. Insert the data
INSERT INTO users (id, username) VALUES 
(1, 'Ranga');

INSERT INTO users (id, username) VALUES 
(2, 'Ravi');

INSERT INTO users (id, username) VALUES 
(3, 'John');

INSERT INTO users (id, username) VALUES 
(4, 'Jane');

-- 3. Select the data
SELECT * FROM users;

```

