
-- Data loading (adjust LOCAL INFILE permissions as needed)
USE little_lemon;
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE order_menu; TRUNCATE TABLE orders; TRUNCATE TABLE customers; TRUNCATE TABLE countries;
TRUNCATE TABLE courses; TRUNCATE TABLE cuisines; TRUNCATE TABLE starters; TRUNCATE TABLE desserts; TRUNCATE TABLE drinks; TRUNCATE TABLE sides; TRUNCATE TABLE bookings;
SET FOREIGN_KEY_CHECKS=1;

LOAD DATA LOCAL INFILE 'countries.csv' INTO TABLE countries
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(country_id, country_name, country_code);

LOAD DATA LOCAL INFILE 'customers.csv' INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(customer_id, customer_ext_id, customer_name, city, postal_code, country_id);

LOAD DATA LOCAL INFILE 'courses.csv' INTO TABLE courses
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(course_id, course_name);

LOAD DATA LOCAL INFILE 'cuisines.csv' INTO TABLE cuisines
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(cuisine_id, cuisine_name);

LOAD DATA LOCAL INFILE 'starters.csv' INTO TABLE starters
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(starter_id, starter_name);

LOAD DATA LOCAL INFILE 'desserts.csv' INTO TABLE desserts
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(dessert_id, dessert_name);

LOAD DATA LOCAL INFILE 'drinks.csv' INTO TABLE drinks
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(drink_id, drink_name);

LOAD DATA LOCAL INFILE 'sides.csv' INTO TABLE sides
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(side_id, side_name);

LOAD DATA LOCAL INFILE 'orders.csv' INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, order_date, delivery_date, customer_id, cost, sales, quantity, discount, delivery_cost);

LOAD DATA LOCAL INFILE 'order_menu.csv' INTO TABLE order_menu
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, course_id, cuisine_id, starter_id, dessert_id, drink_id, side_id);

LOAD DATA LOCAL INFILE 'bookings.csv' INTO TABLE bookings
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(booking_id, order_id, booking_date, guests, table_no, status, notes);
