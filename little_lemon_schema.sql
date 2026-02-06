
-- Little Lemon Database Schema (MySQL)
CREATE DATABASE IF NOT EXISTS little_lemon;
USE little_lemon;

-- Lookup tables
CREATE TABLE IF NOT EXISTS countries (
  country_id INT PRIMARY KEY,
  country_name VARCHAR(100) NOT NULL,
  country_code VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id INT PRIMARY KEY,
  customer_ext_id VARCHAR(20) UNIQUE,
  customer_name VARCHAR(100) NOT NULL,
  city VARCHAR(100),
  postal_code VARCHAR(30),
  country_id INT,
  CONSTRAINT fk_customers_country FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

CREATE TABLE IF NOT EXISTS courses (
  course_id INT PRIMARY KEY,
  course_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS cuisines (
  cuisine_id INT PRIMARY KEY,
  cuisine_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS starters (
  starter_id INT PRIMARY KEY,
  starter_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS desserts (
  dessert_id INT PRIMARY KEY,
  dessert_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS drinks (
  drink_id INT PRIMARY KEY,
  drink_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS sides (
  side_id INT PRIMARY KEY,
  side_name VARCHAR(100) UNIQUE
);

-- Orders fact
CREATE TABLE IF NOT EXISTS orders (
  order_id VARCHAR(20) PRIMARY KEY,
  order_date DATE,
  delivery_date DATE,
  customer_id INT,
  cost DECIMAL(10,2),
  sales DECIMAL(10,2),
  quantity INT,
  discount DECIMAL(10,2),
  delivery_cost DECIMAL(10,2),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order menu mapping
CREATE TABLE IF NOT EXISTS order_menu (
  order_id VARCHAR(20) PRIMARY KEY,
  course_id INT,
  cuisine_id INT,
  starter_id INT,
  dessert_id INT,
  drink_id INT,
  side_id INT,
  CONSTRAINT fk_om_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_om_course FOREIGN KEY (course_id) REFERENCES courses(course_id),
  CONSTRAINT fk_om_cuisine FOREIGN KEY (cuisine_id) REFERENCES cuisines(cuisine_id),
  CONSTRAINT fk_om_starter FOREIGN KEY (starter_id) REFERENCES starters(starter_id),
  CONSTRAINT fk_om_dessert FOREIGN KEY (dessert_id) REFERENCES desserts(dessert_id),
  CONSTRAINT fk_om_drink FOREIGN KEY (drink_id) REFERENCES drinks(drink_id),
  CONSTRAINT fk_om_side FOREIGN KEY (side_id) REFERENCES sides(side_id)
);

-- Bookings derived table
CREATE TABLE IF NOT EXISTS bookings (
  booking_id INT PRIMARY KEY,
  order_id VARCHAR(20) UNIQUE,
  booking_date DATE NOT NULL,
  guests INT NOT NULL,
  table_no INT NULL,
  status ENUM('Pending','Confirmed','Cancelled','Completed') DEFAULT 'Pending',
  notes TEXT,
  CONSTRAINT fk_booking_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Changes log
CREATE TABLE IF NOT EXISTS change_log (
  change_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  entity VARCHAR(50),
  entity_id VARCHAR(50),
  action ENUM('INSERT','UPDATE','DELETE')
);

DELIMITER $$
-- Stored procedure: GetMaxQuantity
CREATE OR REPLACE PROCEDURE GetMaxQuantity(OUT max_qty INT)
BEGIN
  SELECT COALESCE(MAX(quantity),0) INTO max_qty FROM orders;
END $$

-- AddBooking
CREATE OR REPLACE PROCEDURE AddBooking(
  IN in_order_id VARCHAR(20),
  IN in_booking_date DATE,
  IN in_guests INT,
  IN in_table_no INT,
  IN in_status ENUM('Pending','Confirmed','Cancelled','Completed'),
  OUT out_booking_id INT
)
BEGIN
  INSERT INTO bookings(booking_id, order_id, booking_date, guests, table_no, status)
  VALUES ((SELECT COALESCE(MAX(booking_id),0)+1 FROM bookings), in_order_id, in_booking_date, in_guests, in_table_no, in_status);
  SELECT MAX(booking_id) INTO out_booking_id FROM bookings;
END $$

-- UpdateBooking
CREATE OR REPLACE PROCEDURE UpdateBooking(
  IN in_booking_id INT,
  IN in_booking_date DATE,
  IN in_guests INT,
  IN in_table_no INT,
  IN in_status ENUM('Pending','Confirmed','Cancelled','Completed')
)
BEGIN
  UPDATE bookings
     SET booking_date = COALESCE(in_booking_date, booking_date),
         guests = COALESCE(in_guests, guests),
         table_no = COALESCE(in_table_no, table_no),
         status = COALESCE(in_status, status)
   WHERE booking_id = in_booking_id;
END $$

-- CancelBooking
CREATE OR REPLACE PROCEDURE CancelBooking(
  IN in_booking_id INT
)
BEGIN
  UPDATE bookings SET status = 'Cancelled' WHERE booking_id = in_booking_id;
END $$

-- ManageBooking : simple upsert-like manager
CREATE OR REPLACE PROCEDURE ManageBooking(
  IN in_order_id VARCHAR(20),
  IN in_booking_date DATE,
  IN in_guests INT,
  IN in_table_no INT,
  IN in_status ENUM('Pending','Confirmed','Cancelled','Completed'),
  OUT out_booking_id INT
)
BEGIN
  DECLARE existing_id INT;
  SELECT booking_id INTO existing_id FROM bookings WHERE order_id = in_order_id LIMIT 1;
  IF existing_id IS NULL THEN
    CALL AddBooking(in_order_id, in_booking_date, in_guests, in_table_no, in_status, out_booking_id);
  ELSE
    CALL UpdateBooking(existing_id, in_booking_date, in_guests, in_table_no, in_status);
    SET out_booking_id = existing_id;
  END IF;
END $$

-- Triggers to log changes on bookings
CREATE TRIGGER trg_bookings_insert AFTER INSERT ON bookings
FOR EACH ROW BEGIN
  INSERT INTO change_log(entity, entity_id, action) VALUES ('bookings', NEW.booking_id, 'INSERT');
END $$

CREATE TRIGGER trg_bookings_update AFTER UPDATE ON bookings
FOR EACH ROW BEGIN
  INSERT INTO change_log(entity, entity_id, action) VALUES ('bookings', NEW.booking_id, 'UPDATE');
END $$

CREATE TRIGGER trg_bookings_delete AFTER DELETE ON bookings
FOR EACH ROW BEGIN
  INSERT INTO change_log(entity, entity_id, action) VALUES ('bookings', OLD.booking_id, 'DELETE');
END $$
DELIMITER ;

-- Views to support Tableau
CREATE OR REPLACE VIEW vw_sales_by_country AS
SELECT c.country_name, SUM(o.sales) AS total_sales, COUNT(*) AS order_count
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id
JOIN countries c ON c.country_id = cu.country_id
GROUP BY c.country_name;

CREATE OR REPLACE VIEW vw_menu_popularity AS
SELECT co.course_name, cu.cuisine_name, st.starter_name, de.dessert_name, dr.drink_name, si.side_name,
       COUNT(*) AS orders_count
FROM order_menu om
LEFT JOIN courses co ON co.course_id = om.course_id
LEFT JOIN cuisines cu ON cu.cuisine_id = om.cuisine_id
LEFT JOIN starters st ON st.starter_id = om.starter_id
LEFT JOIN desserts de ON de.dessert_id = om.dessert_id
LEFT JOIN drinks dr ON dr.drink_id = om.drink_id
LEFT JOIN sides si ON si.side_id = om.side_id
GROUP BY 1,2,3,4,5,6;

CREATE OR REPLACE VIEW vw_monthly_trends AS
SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month,
       SUM(sales) AS total_sales,
       SUM(cost) AS total_cost,
       SUM(quantity) AS total_qty,
       COUNT(*) AS orders_count
FROM orders
GROUP BY 1
ORDER BY 1;
