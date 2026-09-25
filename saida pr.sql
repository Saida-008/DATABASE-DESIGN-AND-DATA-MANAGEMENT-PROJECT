-- PART 4-13: SMART CITY TRANSPORTATION SYSTEM
-- Database: smart_city_transport

-- PART 4.1 CREATE DATABASE
-- CREATE DATABASE smart_city_transport;

-- After creating the database, connect to smart_city_transport
-- and run the rest of this script.

DROP SCHEMA IF EXISTS smart_transport CASCADE;
CREATE SCHEMA smart_transport;
SET search_path TO smart_transport;


-- PART 4.2-4.3 CREATE TABLES

CREATE TABLE passengers (
    passenger_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(30) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    hire_date DATE NOT NULL
);

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(30) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    driver_id INT,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_vehicle_status
        CHECK (status IN ('active', 'maintenance', 'inactive')),
    CONSTRAINT fk_vehicle_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
        ON DELETE SET NULL
);

CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_number VARCHAR(10) NOT NULL UNIQUE,
    route_name VARCHAR(100) NOT NULL,
    start_point VARCHAR(100) NOT NULL,
    end_point VARCHAR(100) NOT NULL,
    distance_km NUMERIC(6,2) NOT NULL CHECK (distance_km > 0)
);

CREATE TABLE stops (
    stop_id SERIAL PRIMARY KEY,
    stop_name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(200) NOT NULL,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
);

CREATE TABLE route_stops (
    route_id INT NOT NULL,
    stop_id INT NOT NULL,
    stop_order INT NOT NULL CHECK (stop_order > 0),
    PRIMARY KEY (route_id, stop_id),
    UNIQUE (route_id, stop_order),
    FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
        ON DELETE CASCADE,
    FOREIGN KEY (stop_id)
        REFERENCES stops(stop_id)
        ON DELETE CASCADE
);

CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    route_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    trip_date DATE NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    CHECK (arrival_time > departure_time),
    CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id)
        ON DELETE RESTRICT
);

CREATE TABLE tickets (
    ticket_id SERIAL PRIMARY KEY,
    passenger_id INT NOT NULL,
    trip_id INT NOT NULL,
    ticket_type VARCHAR(30) NOT NULL,
    price NUMERIC(8,2) NOT NULL CHECK (price > 0),
    purchase_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (passenger_id)
        REFERENCES passengers(passenger_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (trip_id)
        REFERENCES trips(trip_id)
        ON DELETE RESTRICT
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(20) NOT NULL,
    amount NUMERIC(8,2) NOT NULL CHECK (amount > 0),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'paid',
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (payment_method IN ('card', 'cash', 'qr_code')),
    CHECK (payment_status IN ('paid', 'refunded', 'pending')),
    FOREIGN KEY (ticket_id)
        REFERENCES tickets(ticket_id)
        ON DELETE RESTRICT
);

CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    description VARCHAR(255),
    FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id)
        ON DELETE RESTRICT
);

-- PART 5. INSERTING DATA
 
-- 10+ passengers
INSERT INTO passengers
(first_name, last_name, phone, email, registration_date)
VALUES
('Aruzhan','Sarsenova','87010000001','aruzhan.s@example.com','2026-01-10'),
('Dias','Nurgaliyev','87010000002','dias.n@example.com','2026-01-12'),
('Aigerim','Beketova','87010000003','aigerim.b@example.com','2026-01-15'),
('Alikhan','Orazbayev','87010000004','alikhan.o@example.com','2026-01-18'),
('Madina','Tulegenova','87010000005','madina.t@example.com','2026-01-20'),
('Nursultan','Kassenov','87010000006','nursultan.k@example.com','2026-01-22'),
('Dana','Serikova','87010000007','dana.s@example.com','2026-01-25'),
('Timur','Akhmetov','87010000008','timur.a@example.com','2026-01-28'),
('Kamila','Baurzhanova','87010000009','kamila.b@example.com','2026-02-01'),
('Miras','Zhaksybekov','87010000010','miras.z@example.com','2026-02-03'),
('Saniya','Iskakova','87010000011','saniya.i@example.com','2026-02-05'),
('Rauan','Kadyrov','87010000012','rauan.k@example.com','2026-02-07');

-- 10+ drivers
INSERT INTO drivers
(first_name, last_name, license_number, phone, hire_date)
VALUES
('Serik','Amanov','LIC-1001','87020000001','2023-02-10'),
('Marat','Bekenov','LIC-1002','87020000002','2023-04-15'),
('Kanat','Sadykov','LIC-1003','87020000003','2023-06-20'),
('Askar','Tursynov','LIC-1004','87020000004','2023-08-12'),
('Bolat','Niyazov','LIC-1005','87020000005','2024-01-18'),
('Erlan','Mukhanov','LIC-1006','87020000006','2024-03-22'),
('Dauren','Kaliyev','LIC-1007','87020000007','2024-05-10'),
('Rustem','Ospanov','LIC-1008','87020000008','2024-07-14'),
('Adil','Saparov','LIC-1009','87020000009','2024-09-01'),
('Yerlan','Khamitov','LIC-1010','87020000010','2024-11-05');

-- 10+ vehicles
INSERT INTO vehicles
(vehicle_number, vehicle_type, capacity, driver_id, status)
VALUES
('BUS-101','City Bus',45,1,'active'),
('BUS-102','City Bus',50,2,'active'),
('BUS-103','Electric Bus',40,3,'active'),
('BUS-104','City Bus',45,4,'active'),
('BUS-105','Electric Bus',40,5,'active'),
('BUS-106','City Bus',55,6,'active'),
('BUS-107','City Bus',45,7,'maintenance'),
('BUS-108','Electric Bus',50,8,'active'),
('BUS-109','City Bus',45,9,'active'),
('BUS-110','City Bus',55,10,'active');

-- 10+ routes
INSERT INTO routes
(route_number, route_name, start_point, end_point, distance_km)
VALUES
('1','Central - Railway Station','Central Square','Railway Station',8.50),
('2','Airport - Central','Airport','Central Square',12.40),
('3','University - Central','University','Central Square',7.80),
('4','Market - Hospital','Central Market','City Hospital',9.20),
('5','North District - Center','North District','Central Square',11.60),
('6','South District - Center','South District','Central Square',10.10),
('7','River Side - University','River Side','University',8.90),
('8','Airport - Market','Airport','Central Market',13.20),
('9','Railway - Hospital','Railway Station','City Hospital',9.80),
('10','East District - Center','East District','Central Square',10.70);

-- 12 stops
INSERT INTO stops
(stop_name, address, latitude, longitude)
VALUES
('Central Square','Main Square, 1',47.0945,51.9230),
('Railway Station','Railway Avenue, 1',47.1060,51.9235),
('Airport','Airport Road, 1',47.1210,51.8210),
('University','Student Street, 10',47.1015,51.9050),
('Central Market','Market Street, 5',47.0880,51.9400),
('City Hospital','Health Street, 12',47.0800,51.9180),
('North District','North Avenue, 20',47.1300,51.9300),
('South District','South Avenue, 15',47.0600,51.9200),
('River Side','River Road, 8',47.1000,51.9550),
('East District','East Avenue, 14',47.0950,51.9700),
('West District','West Avenue, 7',47.0900,51.8850),
('Sports Complex','Sports Street, 3',47.0750,51.9500);

-- 30 route-stop records
INSERT INTO route_stops (route_id, stop_id, stop_order) VALUES
(1,1,1),(1,2,2),(1,5,3),
(2,3,1),(2,1,2),(2,5,3),
(3,4,1),(3,1,2),(3,9,3),
(4,5,1),(4,6,2),(4,12,3),
(5,7,1),(5,1,2),(5,11,3),
(6,8,1),(6,1,2),(6,12,3),
(7,9,1),(7,4,2),(7,1,3),
(8,3,1),(8,5,2),(8,1,3),
(9,2,1),(9,6,2),(9,12,3),
(10,10,1),(10,1,2),(10,5,3);

-- 25 trips
INSERT INTO trips
(route_id, vehicle_id, trip_date, departure_time, arrival_time, status)
VALUES
(1,1,'2026-09-01','07:00','07:35','completed'),
(2,2,'2026-09-01','07:30','08:15','completed'),
(3,3,'2026-09-01','08:00','08:30','completed'),
(4,4,'2026-09-01','08:30','09:10','completed'),
(5,5,'2026-09-01','09:00','09:45','completed'),
(6,6,'2026-09-01','09:30','10:10','completed'),
(7,8,'2026-09-01','10:00','10:35','completed'),
(8,9,'2026-09-01','10:30','11:20','completed'),
(9,10,'2026-09-01','11:00','11:40','completed'),
(10,1,'2026-09-01','11:30','12:15','completed'),
(1,2,'2026-09-02','07:00','07:35','completed'),
(2,3,'2026-09-02','07:30','08:15','completed'),
(3,4,'2026-09-02','08:00','08:30','completed'),
(4,5,'2026-09-02','08:30','09:10','completed'),
(5,6,'2026-09-02','09:00','09:45','completed'),
(6,8,'2026-09-02','09:30','10:10','completed'),
(7,9,'2026-09-02','10:00','10:35','completed'),
(8,10,'2026-09-02','10:30','11:20','completed'),
(9,1,'2026-09-02','11:00','11:40','completed'),
(10,2,'2026-09-02','11:30','12:15','completed'),
(1,3,'2026-09-03','07:00','07:35','scheduled'),
(2,4,'2026-09-03','07:30','08:15','scheduled'),
(3,5,'2026-09-03','08:00','08:30','scheduled'),
(4,6,'2026-09-03','08:30','09:10','scheduled'),
(5,8,'2026-09-03','09:00','09:45','scheduled');

-- 25 tickets
INSERT INTO tickets
(passenger_id, trip_id, ticket_type, price)
VALUES
(1,1,'single',120.00),
(2,2,'single',150.00),
(3,3,'single',120.00),
(4,4,'student',100.00),
(5,5,'single',130.00),
(6,6,'student',100.00),
(7,7,'single',120.00),
(8,8,'single',150.00),
(9,9,'student',100.00),
(10,10,'single',140.00),
(11,11,'single',120.00),
(12,12,'student',100.00),
(1,13,'single',120.00),
(2,14,'single',130.00),
(3,15,'student',100.00),
(4,16,'single',120.00),
(5,17,'single',120.00),
(6,18,'student',100.00),
(7,19,'single',140.00),
(8,20,'single',150.00),
(9,21,'student',100.00),
(10,22,'single',150.00),
(11,23,'single',120.00),
(12,24,'student',100.00),
(1,25,'single',130.00);

-- 25 payments
INSERT INTO payments
(ticket_id, payment_method, amount, payment_status, payment_date)
SELECT
    ticket_id,
    CASE
        WHEN ticket_id % 3 = 0 THEN 'qr_code'
        WHEN ticket_id % 2 = 0 THEN 'card'
        ELSE 'cash'
    END,
    price,
    'paid',
    purchase_time + INTERVAL '5 minutes'
FROM tickets;

-- 20 maintenance records
INSERT INTO maintenance
(vehicle_id, maintenance_date, maintenance_type, cost, description)
VALUES
(1,'2026-01-15','Oil change',18000,'Routine engine service'),
(2,'2026-01-20','Brake inspection',25000,'Brake system inspection'),
(3,'2026-02-01','Battery check',30000,'Electric bus battery check'),
(4,'2026-02-10','Tire replacement',80000,'Front tires replaced'),
(5,'2026-02-15','Software diagnostics',22000,'Control system diagnostics'),
(6,'2026-02-20','Oil change',18000,'Routine engine service'),
(7,'2026-03-01','Brake repair',95000,'Brake components replaced'),
(8,'2026-03-05','Battery check',30000,'Battery performance check'),
(9,'2026-03-12','Air conditioning',45000,'Cooling system service'),
(10,'2026-03-18','Oil change',18000,'Routine engine service'),
(1,'2026-04-10','Tire inspection',12000,'Seasonal tire inspection'),
(2,'2026-04-15','Engine diagnostics',35000,'Engine diagnostic test'),
(3,'2026-05-01','Charging system',40000,'Charging system inspection'),
(4,'2026-05-07','Oil change',18000,'Routine engine service'),
(5,'2026-05-12','Battery check',30000,'Battery performance check'),
(6,'2026-05-20','Brake inspection',25000,'Brake system inspection'),
(8,'2026-06-01','Air conditioning',45000,'Cooling system service'),
(9,'2026-06-10','Tire replacement',80000,'Rear tires replaced'),
(10,'2026-06-15','Engine diagnostics',35000,'Engine diagnostic test'),
(7,'2026-06-20','Electrical repair',60000,'Electrical system repair');

-- PART 6. DATA MANIPULATION

-- INSERT example
-- INSERT example
INSERT INTO passengers
(first_name,last_name,phone,email,registration_date)
VALUES
('Amina','Kairatova','87010000013','amina.k@example.com','2026-09-10')
ON CONFLICT (phone) DO NOTHING;

-- UPDATE example
UPDATE vehicles
SET status = 'active'
WHERE vehicle_id = 7;

-- DELETE example: delete a passenger with no tickets
INSERT INTO passengers
(first_name,last_name,phone,email,registration_date)
VALUES
('Test','Passenger','87010000999','unused.passenger@example.com','2026-09-11');

DELETE FROM passengers
WHERE email = 'unused.passenger@example.com';

-- SELECT example
SELECT * FROM passengers;

-- PART 7. 15 SQL QUERIES

-- 1. SELECT all
SELECT * FROM vehicles;

-- 2. Specific columns
SELECT first_name, last_name, email
FROM passengers;

-- 3. WHERE
SELECT *
FROM vehicles
WHERE capacity > 45;

-- 4. ORDER BY
SELECT *
FROM routes
ORDER BY distance_km DESC;

-- 5. LIKE
SELECT *
FROM stops
WHERE stop_name LIKE '%Center%';

-- 6. BETWEEN
SELECT *
FROM maintenance
WHERE cost BETWEEN 20000 AND 50000;

-- 7. IN
SELECT *
FROM trips
WHERE status IN ('completed','scheduled');

-- 8. Aggregate COUNT/SUM/AVG/MIN/MAX
SELECT
    COUNT(*) AS total_tickets,
    SUM(price) AS total_sales,
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM tickets;

-- 9. GROUP BY
SELECT ticket_type, COUNT(*) AS ticket_count
FROM tickets
GROUP BY ticket_type;

-- 10. HAVING
SELECT vehicle_id, SUM(cost) AS maintenance_cost
FROM maintenance
GROUP BY vehicle_id
HAVING SUM(cost) > 80000;

-- 11. INNER JOIN
SELECT
    t.trip_id,
    r.route_number,
    r.route_name,
    t.trip_date,
    t.departure_time
FROM trips t
INNER JOIN routes r ON t.route_id = r.route_id;

-- 12. LEFT JOIN
SELECT
    v.vehicle_number,
    d.first_name,
    d.last_name
FROM vehicles v
LEFT JOIN drivers d ON v.driver_id = d.driver_id;

-- 13. Multiple-table JOIN
SELECT
    p.first_name,
    p.last_name,
    t.ticket_id,
    r.route_number,
    t.price,
    pay.payment_method
FROM passengers p
JOIN tickets t ON p.passenger_id = t.passenger_id
JOIN trips tr ON t.trip_id = tr.trip_id
JOIN routes r ON tr.route_id = r.route_id
JOIN payments pay ON t.ticket_id = pay.ticket_id;

-- 14. Subquery
SELECT *
FROM vehicles
WHERE capacity > (
    SELECT AVG(capacity)
    FROM vehicles
);

-- 15. Complex analytical query
SELECT
    r.route_number,
    r.route_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.price) AS revenue,
    AVG(t.price) AS average_ticket_price
FROM routes r
JOIN trips tr ON r.route_id = tr.route_id
JOIN tickets t ON tr.trip_id = t.trip_id
GROUP BY r.route_id, r.route_number, r.route_name
HAVING COUNT(t.ticket_id) >= 2
ORDER BY revenue DESC;

-- PART 8. DATA ANALYSIS

-- Analysis 1: Which routes generate the most ticket revenue?
SELECT COUNT(*) AS routes_count
FROM smart_transport.routes;

SELECT COUNT(*) AS trips_count
FROM smart_transport.trips;

SELECT COUNT(*) AS tickets_count
FROM smart_transport.tickets;

SELECT COUNT(*) AS completed_trips
FROM smart_transport.trips
WHERE status = 'completed';

SELECT
    ticket_type,
    AVG(price) AS average_price
FROM smart_transport.tickets
GROUP BY ticket_type;

SELECT
    v.vehicle_number,
    SUM(m.cost) AS total_maintenance_cost
FROM smart_transport.vehicles v
JOIN smart_transport.maintenance m
    ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_number
ORDER BY total_maintenance_cost DESC;

SELECT
    p.passenger_id,
    p.first_name,
    p.last_name,
    COUNT(t.ticket_id) AS ticket_count
FROM smart_transport.passengers p
JOIN smart_transport.tickets t
    ON p.passenger_id = t.passenger_id
GROUP BY p.passenger_id, p.first_name, p.last_name
ORDER BY ticket_count DESC;
-- PART 9. VIEWS

-- View 1: route performance summary
CREATE OR REPLACE VIEW route_performance AS
SELECT
    r.route_id,
    r.route_number,
    r.route_name,
    COUNT(DISTINCT tr.trip_id) AS total_trips,
    COUNT(t.ticket_id) AS tickets_sold,
    COALESCE(SUM(t.price),0) AS total_revenue
FROM routes r
LEFT JOIN trips tr ON r.route_id = tr.route_id
LEFT JOIN tickets t ON tr.trip_id = t.trip_id
GROUP BY r.route_id, r.route_number, r.route_name;

-- View 2: vehicle maintenance summary
CREATE OR REPLACE VIEW vehicle_maintenance_summary AS
SELECT
    v.vehicle_id,
    v.vehicle_number,
    v.vehicle_type,
    v.status,
    COUNT(m.maintenance_id) AS maintenance_count,
    COALESCE(SUM(m.cost),0) AS total_maintenance_cost
FROM vehicles v
LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_number, v.vehicle_type, v.status;

-- Test views
SELECT * FROM route_performance;
SELECT * FROM vehicle_maintenance_summary;

-- PART 10. DATA INTEGRITY

-- 1. Entity integrity:
-- PK cannot be NULL.
-- This operation must fail:
-- INSERT INTO passengers(passenger_id,first_name,last_name,phone,email)
-- VALUES (1,'Invalid','User','87019999999','invalid@example.com');

-- 2. Duplicate prevention:
-- This operation must fail because email is UNIQUE:
-- INSERT INTO passengers(first_name,last_name,phone,email)
-- VALUES ('Duplicate','User','87019999998','aruzhan.s@example.com');

-- 3. Invalid FK:
-- This operation must fail because passenger_id 9999 does not exist:
-- INSERT INTO tickets(passenger_id,trip_id,ticket_type,price)
-- VALUES (9999,1,'single',120.00);

-- 4. Domain integrity:
-- This operation must fail because capacity cannot be negative:
-- INSERT INTO vehicles(vehicle_number,vehicle_type,capacity)
-- VALUES ('BUS-999','City Bus',-10);

-- 5. Invalid payment method:
-- This operation must fail because of CHECK constraint:
-- INSERT INTO payments(ticket_id,payment_method,amount)
-- VALUES (1,'bitcoin',120.00);


-- PART 11. NORMALIZATION

-- The database is designed according to 1NF, 2NF and 3NF.

-- 1NF:
-- Each field contains one atomic value.
-- Example: passenger phone and email are stored separately.

-- 2NF:
-- Non-key attributes depend on the whole primary key.
-- route_stops uses the composite key (route_id, stop_id),
-- while stop_order depends on the complete relationship.

-- 3NF:
-- Non-key attributes depend only on the primary key.
-- Driver information is stored in drivers, vehicle information
-- is stored in vehicles, and route information is stored in routes.

-- Unnormalized example:
-- route(route_id, route_name, stop1, stop2, stop3, stop4)

-- Normalized structure:
-- routes(route_id, route_name, ...)
-- stops(stop_id, stop_name, ...)
-- route_stops(route_id, stop_id, stop_order)

-- PART 12. DATABASE MODIFICATION SCENARIOS

-- Scenario 1: Change a vehicle status
UPDATE vehicles
SET status = 'maintenance'
WHERE vehicle_id = 7;

-- Scenario 2: Change a driver's phone
UPDATE drivers
SET phone = '87029999991'
WHERE driver_id = 1;

-- Scenario 3: Add a new route
INSERT INTO routes
(route_number,route_name,start_point,end_point,distance_km)
VALUES
('11','West District - Market','West District','Central Market',9.40);

-- Scenario 4: Add a maintenance record
INSERT INTO maintenance
(vehicle_id,maintenance_date,maintenance_type,cost,description)
VALUES
(2,'2026-09-15','Scheduled inspection',28000,'Monthly technical inspection');

-- Scenario 5: Cancel a scheduled trip
UPDATE trips
SET status = 'cancelled'
WHERE trip_id = 21
  AND status = 'scheduled';

-- PART 13. REPORTING

-- Report 1: Ticket sales by route
SELECT
    r.route_number,
    r.route_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.price) AS revenue
FROM routes r
JOIN trips tr ON r.route_id = tr.route_id
JOIN tickets t ON tr.trip_id = t.trip_id
GROUP BY r.route_id, r.route_number, r.route_name
ORDER BY revenue DESC;

-- Report 2: Vehicle maintenance report
SELECT
    v.vehicle_number,
    v.vehicle_type,
    COUNT(m.maintenance_id) AS maintenance_count,
    SUM(m.cost) AS total_cost
FROM vehicles v
LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.vehicle_number, v.vehicle_type
ORDER BY total_cost DESC;

-- Report 3: Passenger activity report
SELECT
    p.passenger_id,
    p.first_name,
    p.last_name,
    COUNT(t.ticket_id) AS tickets_purchased,
    COALESCE(SUM(t.price),0) AS total_spent
FROM passengers p
LEFT JOIN tickets t ON p.passenger_id = t.passenger_id
GROUP BY p.passenger_id, p.first_name, p.last_name
ORDER BY total_spent DESC;

-- PART 14. FINAL DATABASE STRUCTURE CHECK

-- List all tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'smart_transport'
ORDER BY table_name;

-- Record counts
SELECT 'passengers' AS table_name, COUNT(*) AS record_count FROM passengers
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL
SELECT 'routes', COUNT(*) FROM routes
UNION ALL
SELECT 'stops', COUNT(*) FROM stops
UNION ALL
SELECT 'route_stops', COUNT(*) FROM route_stops
UNION ALL
SELECT 'trips', COUNT(*) FROM trips
UNION ALL
SELECT 'tickets', COUNT(*) FROM tickets
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'maintenance', COUNT(*) FROM maintenance;

-- List views
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'smart_transport';

-- END OF SMART CITY TRANSPORTATION DATABASE
