CREATE TABLE orders (
    order_id INTEGER,
    order_date DATE,
	amount DECIMAL,
    customer_id INT
);

CREATE TABLE source_orders  (
    order_id INTEGER,
    order_date DATE,
	amount DECIMAL,
    customer_id INT
);

INSERT INTO source_orders (order_id, order_date, amount, customer_id)
VALUES 
    (1, '2026-01-15', 1500.50, 101),
    (2, '2026-01-16', 2500.00, 102),
    (3, '2026-01-17', 750.25, 101),
    (4, '2026-01-18', 3200.75, 103),
    (5, '2026-01-19', 890.00, 104)
;

-- вставка 1
INSERT INTO orders (order_id, order_date, amount, customer_id)
SELECT 
    order_id,
    order_date,
    amount,
    customer_id
FROM source_orders;

-- вставка 2
INSERT INTO orders (order_id, order_date, amount, customer_id)
SELECT 
    order_id,
    order_date,
    amount,
    customer_id
FROM source_orders;

-- дубли
SELECT 
    order_id,
    order_date,
    amount,
    customer_id,
    COUNT(*) as cnt
FROM orders
GROUP BY order_id, order_date, amount, customer_id
HAVING COUNT(*) > 1;


-- Идемпотентный скрипт
TRUNCATE table orders;


-- 1 вставка
MERGE INTO orders AS t
USING source_orders AS s
ON t.order_id = s.order_id
WHEN MATCHED THEN
    UPDATE SET 
        t.order_date = s.order_date,
        t.amount = s.amount,
        t.customer_id = s.customer_id
WHEN NOT MATCHED THEN
    INSERT (order_id, order_date, amount, customer_id)
    VALUES (s.order_id, s.order_date, s.amount, s.customer_id);
-- 2 вставка 
MERGE INTO orders AS t
USING source_orders AS s
ON t.order_id = s.order_id
WHEN MATCHED THEN
    UPDATE SET 
        t.order_date = s.order_date,
        t.amount = s.amount,
        t.customer_id = s.customer_id
WHEN NOT MATCHED THEN
    INSERT (order_id, order_date, amount, customer_id)
    VALUES (s.order_id, s.order_date, s.amount, s.customer_id);

-- дубли после 2 идемпотентных вставок
SELECT 
    order_id,
    order_date,
    amount,
    customer_id,
    COUNT(*) as cnt
FROM orders
GROUP BY order_id, order_date, amount, customer_id
HAVING COUNT(*) > 1;
