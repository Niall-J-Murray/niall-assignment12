-- Q2: Create your database based on your design in MySQL.
-- (DROP DATABASE IF EXISTS -> CREATE DATABASE -> USE) to make script re-runnable.
DROP DATABASE IF EXISTS pizza_restaurant;
CREATE DATABASE pizza_restaurant;
USE pizza_restaurant;

-- Q3: Populate your database with three orders.
-- Below is Q2 & Q3 as orders are populated after tables are created.
CREATE TABLE pizza (
	PRIMARY KEY (pizza_id),
    pizza_id    INT           NOT NULL,
    pizza_name  VARCHAR(50)   NOT NULL,
    price       DECIMAL(5,2)  NOT NULL
);

INSERT INTO pizza (pizza_id, pizza_name, price)
VALUES (1, 'Pepperoni & Cheese', 7.99),
	   (2, 'Vegetarian', 9.99),
       (3, 'Meat Lovers', 14.99),
       (4, 'Hawaiian', 12.99);

CREATE TABLE `order` (
	PRIMARY KEY (order_id),
    order_id    INT      NOT NULL AUTO_INCREMENT,
    `date`      DATETIME NOT NULL
);

INSERT INTO `order` (`date`)
VALUES ('2014-10-09 09:47:00'),
	   ('2014-10-09 13:20:00'),
       ('2014-10-09 09:47:00');

CREATE TABLE order_pizza (
	FOREIGN KEY (order_id) REFERENCES `order` (order_id),
	FOREIGN KEY (pizza_id) REFERENCES pizza (pizza_id),
	order_id INT NOT NULL,
	pizza_id INT NOT NULL,
	quantity INT NOT NULL
);

INSERT INTO order_pizza (`order_id`, `pizza_id`, `quantity`)
VALUES (1, 1, 1),
       (1, 3, 1),	
	   (2, 2, 1),
       (2, 3, 2),
       (3, 3, 1),
       (3, 4, 1);
       
CREATE TABLE customer (
	PRIMARY KEY (customer_id),
	customer_id  INT         NOT NULL AUTO_INCREMENT,
	full_name    VARCHAR(30) NOT NULL,
    phone		 VARCHAR(20) NOT NULL
);

INSERT INTO customer (full_name, phone)
VALUES ('Trevor Page', '226-555-4982'),
       ('John Doe', '555-555-9498');

CREATE TABLE customer_order (
	FOREIGN KEY (order_id)    REFERENCES `order` (order_id),
	FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
	order_id    INT NOT NULL,
    customer_id INT NOT NULL
);

INSERT INTO customer_order (order_id, customer_id)
VALUES (1, 1),
	   (2, 2),
       (3, 1);
       
-- Q4: Now the restaurant would like to know which customers are spending the most money at their establishment.
SELECT c.customer_id, full_name, SUM(op.quantity * p.price) AS total_spent 
  FROM customer_order co
  JOIN customer c     ON co.customer_id = c.customer_id
  JOIN `order` o      ON o.order_id = co.order_id
  JOIN order_pizza op ON op.order_id = o.order_id
  JOIN pizza p        ON op.pizza_id =p.pizza_id
  GROUP BY c.customer_id;

-- Q5: Modify the query from Q4 to separate the orders not just by customer, but also by date so they can see how much each customer is ordering on which date.
-- VIEW used so query can be recalled after additional test order added below.
CREATE VIEW spend_by_date AS
SELECT c.customer_id, full_name, `date`, SUM(op.quantity * p.price) AS total_spent 
  FROM customer_order co
  JOIN customer c     ON co.customer_id = c.customer_id
  JOIN `order` o      ON o.order_id = co.order_id
  JOIN order_pizza op ON op.order_id = o.order_id
  JOIN pizza p        ON op.pizza_id =p.pizza_id
  GROUP BY c.customer_id, o.`date`
  ORDER BY c.customer_id;

SELECT * FROM spend_by_date;
-- Since all orders in assignment are on same date, add extra order with different date 
-- to confirm that above query will show clearly each customer's spend by date.
 START TRANSACTION;
INSERT INTO `order` 
VALUES (4, '2014-10-11 11:33:00');
INSERT INTO order_pizza 
VALUES (4, 1, 1);
INSERT INTO customer_order 
VALUES (4, 1);
COMMIT;
 
SELECT * FROM spend_by_date;