

CREATE TABLE source_orders_inc  (
    order_id INTEGER PRIMARY KEY,
    order_date DATE,
	amount DECIMAL,
    customer_id INTEGER
);


CREATE TABLE target_orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE,
	amount DECIMAL,
    customer_id INTEGER
);

CREATE TABLE etl_state (
    task_name VARCHAR,
    last_value INTEGER
);



INSERT INTO source_orders_inc (order_id, order_date, amount, customer_id)
VALUES 
    (1, '2026-01-15', 1500.50, 101),
    (2, '2026-01-16', 2500.00, 102),
    (3, '2026-01-17', 750.25, 101),
    (4, '2026-01-18', 3200.75, 103),
    (5, '2026-01-19', 890.00, 104)
;

INSERT INTO etl_state (task_name, last_value) 
VALUES ('load_orders', 0);



--- загрузка

INSERT INTO target_orders (order_id, order_date, amount, customer_id)
SELECT 
    s.order_id,
    s.order_date,
    s.amount,
    s.customer_id
FROM source_orders_inc s
WHERE s.order_id > (SELECT last_value FROM etl_state WHERE task_name = 'load_orders')
ON CONFLICT (order_id) DO UPDATE SET
    order_date = EXCLUDED.order_date,
    amount = EXCLUDED.amount,
    customer_id = EXCLUDED.customer_id;


UPDATE etl_state 
SET last_value = (SELECT MAX(order_id) FROM target_orders)
WHERE task_name = 'load_orders';


-- новые 
INSERT INTO source_orders_inc (order_id, order_date, amount, customer_id)
VALUES 
    (6, '2026-01-15', 1500.50, 101),
    (7, '2026-01-16', 2500.00, 102),
    (8, '2026-01-17', 750.25, 101),
    (9, '2026-01-18', 3200.75, 103),
    (10, '2026-01-19', 890.00, 104)
;

--- загрузка 2

INSERT INTO target_orders (order_id, order_date, amount, customer_id)
SELECT 
    s.order_id,
    s.order_date,
    s.amount,
    s.customer_id
FROM source_orders_inc s
WHERE s.order_id > (SELECT last_value FROM etl_state WHERE task_name = 'load_orders')
ON CONFLICT (order_id) DO UPDATE SET
    order_date = EXCLUDED.order_date,
    amount = EXCLUDED.amount,
    customer_id = EXCLUDED.customer_id;


UPDATE etl_state 
SET last_value = (SELECT MAX(order_id) FROM target_orders)
WHERE task_name = 'load_orders';

