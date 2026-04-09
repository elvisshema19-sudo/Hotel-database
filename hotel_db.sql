DROP DATABASE IF EXISTS hotel_reservation;
CREATE DATABASE hotel_reservation;
USE hotel_reservation;

CREATE TABLE Customers (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    country         VARCHAR(50)  NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE RoomTypes (
    room_type_id    INT AUTO_INCREMENT PRIMARY KEY,
    type_name       VARCHAR(50)  NOT NULL UNIQUE,
    base_price      DECIMAL(8,2) NOT NULL,
    max_occupancy   INT          NOT NULL
);

CREATE TABLE Rooms (
    room_id         INT AUTO_INCREMENT PRIMARY KEY,
    room_number     VARCHAR(10)  NOT NULL UNIQUE,
    room_type_id    INT          NOT NULL,
    floor           INT          NOT NULL,
    is_available    BOOLEAN      DEFAULT TRUE,
    FOREIGN KEY (room_type_id) REFERENCES RoomTypes(room_type_id)
);

CREATE TABLE Bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT          NOT NULL,
    room_id         INT          NOT NULL,
    check_in        DATE         NOT NULL,
    check_out       DATE         NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL,
    status          ENUM('Confirmed','Cancelled','Completed') DEFAULT 'Confirmed',
    booked_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_dates CHECK (check_out > check_in),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (room_id)     REFERENCES Rooms(room_id)
);

CREATE TABLE Payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT          NOT NULL UNIQUE,
    amount_paid     DECIMAL(10,2) NOT NULL,
    payment_method  ENUM('Credit Card','Debit Card','Cash','Bank Transfer') NOT NULL,
    payment_date    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE Staff (
    staff_id        INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    role            VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    hire_date       DATE         NOT NULL
);

CREATE TABLE Services (
    service_id      INT AUTO_INCREMENT PRIMARY KEY,
    service_name    VARCHAR(100) NOT NULL,
    price           DECIMAL(8,2) NOT NULL
);

CREATE TABLE BookingServices (
    booking_id      INT NOT NULL,
    service_id      INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    PRIMARY KEY (booking_id, service_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

CREATE INDEX idx_bookings_customer ON Bookings(customer_id);
CREATE INDEX idx_bookings_room      ON Bookings(room_id);
CREATE INDEX idx_bookings_status    ON Bookings(status);
CREATE INDEX idx_rooms_type         ON Rooms(room_type_id);

INSERT INTO RoomTypes (type_name, base_price, max_occupancy) VALUES
('Single',  89.00, 1),
('Double', 129.00, 2),
('Suite',  249.00, 4),
('Penthouse', 499.00, 6);

INSERT INTO Rooms (room_number, room_type_id, floor, is_available) VALUES
('101', 1, 1, TRUE),
('102', 1, 1, TRUE),
('201', 2, 2, TRUE),
('202', 2, 2, FALSE),
('301', 3, 3, TRUE),
('401', 4, 4, TRUE);

INSERT INTO Customers (first_name, last_name, email, phone, country) VALUES
('Patrice',   'Brown',  'patrice@example.com',  '+4915201263569', 'Germany'),
('Sofia',     'Smith',   'Sofia@example.com',    '+447911123456',  'UK'),
('Robert',  'Peter',  'robert@example.com', '+34612342670',   'Spain'),
('Savanah',   'Smith',     'savanah@example.com',  '+16536450634',   'USA'),
('Jose',    'Viera',  'emre@example.com',   '+905321254587',  'Turkey');

INSERT INTO Bookings (customer_id, room_id, check_in, check_out, total_amount, status) VALUES
(1, 1, '2026-04-01', '2026-04-05', 356.00,  'Completed'),
(2, 3, '2026-04-10', '2026-04-14', 516.00,  'Confirmed'),
(3, 5, '2026-04-12', '2026-04-15', 747.00,  'Confirmed'),
(4, 2, '2026-04-20', '2026-04-22', 178.00,  'Confirmed'),
(5, 6, '2026-05-01', '2026-05-05', 1996.00, 'Confirmed'),
(1, 3, '2026-03-01', '2026-03-03', 258.00,  'Cancelled');

INSERT INTO Payments (booking_id, amount_paid, payment_method, payment_date) VALUES
(1, 356.00,  'Credit Card',    '2026-04-05 10:00:00'),
(2, 516.00,  'Debit Card',     '2026-04-10 12:30:00'),
(3, 747.00,  'Bank Transfer',  '2026-04-12 09:15:00'),
(4, 178.00,  'Cash',           '2026-04-20 14:00:00');

INSERT INTO Staff (first_name, last_name, role, email, hire_date) VALUES
('Hans',   'Becker', 'Receptionist', 'hans@hotel.com',   '2022-01-15'),
('Sophie', 'Weber',  'Manager',      'sophie@hotel.com', '2020-06-01'),
('Lena',   'Braun',  'Housekeeping', 'lena@hotel.com',   '2023-03-10');

INSERT INTO Services (service_name, price) VALUES
('Breakfast',      15.00),
('Spa Access',     50.00),
('Airport Shuttle', 35.00),
('Room Service',   25.00);

INSERT INTO BookingServices (booking_id, service_id, quantity) VALUES
(1, 1, 4),
(2, 2, 1),
(3, 3, 2),
(5, 1, 4),
(5, 2, 2);

SELECT r.room_number, rt.type_name, rt.base_price, r.floor
FROM Rooms r
JOIN RoomTypes rt ON r.room_type_id = rt.room_type_id
WHERE r.is_available = TRUE
ORDER BY rt.base_price;

SELECT b.booking_id, CONCAT(c.first_name,' ',c.last_name) AS customer,
       r.room_number, rt.type_name, b.check_in, b.check_out, b.total_amount, b.status
FROM Bookings b
JOIN Customers c  ON b.customer_id = c.customer_id
JOIN Rooms r      ON b.room_id     = r.room_id
JOIN RoomTypes rt ON r.room_type_id = rt.room_type_id
WHERE b.status = 'Confirmed'
ORDER BY b.check_in;

SELECT rt.type_name,
       COUNT(b.booking_id)    AS total_bookings,
       SUM(b.total_amount)    AS total_revenue,
       AVG(b.total_amount)    AS avg_booking_value
FROM Bookings b
JOIN Rooms r      ON b.room_id      = r.room_id
JOIN RoomTypes rt ON r.room_type_id = rt.room_type_id
WHERE b.status != 'Cancelled'
GROUP BY rt.type_name
ORDER BY total_revenue DESC;

SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,
       c.country,
       COUNT(b.booking_id)  AS total_bookings,
       SUM(b.total_amount)  AS total_spent
FROM Customers c
JOIN Bookings b ON c.customer_id = b.customer_id
WHERE b.status != 'Cancelled'
GROUP BY c.customer_id
ORDER BY total_spent DESC;

SELECT b.booking_id,
       CONCAT(c.first_name,' ',c.last_name) AS customer,
       s.service_name,
       bs.quantity,
       (s.price * bs.quantity) AS service_cost
FROM BookingServices bs
JOIN Bookings  b ON bs.booking_id = b.booking_id
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Services  s ON bs.service_id = s.service_id
ORDER BY b.booking_id;

UPDATE Bookings SET status = 'Completed' WHERE booking_id = 2;

DELETE FROM Bookings WHERE status = 'Cancelled' AND booking_id = 6;

SELECT CONCAT(first_name,' ',last_name) AS customer, email
FROM Customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM Bookings WHERE status = 'Cancelled'
);

SELECT DATE_FORMAT(b.booked_at, '%Y-%m') AS month,
       COUNT(b.booking_id)               AS bookings,
       SUM(b.total_amount)               AS revenue
FROM Bookings b
WHERE b.status != 'Cancelled'
GROUP BY month
ORDER BY month;