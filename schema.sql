-- ============================================================
-- BUS RESERVATION SYSTEM - DATABASE SCHEMA
-- Maharashtra Routes & Data
-- ============================================================

DROP TABLE IF EXISTS Booking_Seats;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Seats;
DROP TABLE IF EXISTS Trips;
DROP TABLE IF EXISTS Routes;
DROP TABLE IF EXISTS Buses;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    user_id     INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role        ENUM('passenger','admin') NOT NULL DEFAULT 'passenger',
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Buses (
    bus_id      INT AUTO_INCREMENT PRIMARY KEY,
    bus_number  VARCHAR(20)  NOT NULL UNIQUE,
    bus_name    VARCHAR(100) NOT NULL,
    bus_type    ENUM('Sleeper','Semi-Sleeper','Seater','AC Sleeper','Volvo AC') NOT NULL,
    total_seats TINYINT UNSIGNED NOT NULL,
    operator    VARCHAR(100) NOT NULL
);

CREATE TABLE Routes (
    route_id    INT AUTO_INCREMENT PRIMARY KEY,
    source      VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    distance_km SMALLINT UNSIGNED NOT NULL,
    base_fare   DECIMAL(8,2) NOT NULL,
    UNIQUE KEY uq_route (source, destination)
);

CREATE TABLE Trips (
    trip_id         INT AUTO_INCREMENT PRIMARY KEY,
    bus_id          INT NOT NULL,
    route_id        INT NOT NULL,
    departure_time  DATETIME NOT NULL,
    arrival_time    DATETIME NOT NULL,
    fare            DECIMAL(8,2) NOT NULL,
    status          ENUM('Scheduled','Cancelled','Completed') NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (bus_id)   REFERENCES Buses(bus_id)  ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id) ON DELETE CASCADE
);

CREATE TABLE Seats (
    seat_id     INT AUTO_INCREMENT PRIMARY KEY,
    bus_id      INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    seat_type   ENUM('Window','Aisle','Middle') NOT NULL DEFAULT 'Window',
    deck        ENUM('Lower','Upper') NOT NULL DEFAULT 'Lower',
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id) ON DELETE CASCADE,
    UNIQUE KEY uq_bus_seat (bus_id, seat_number)
);

CREATE TABLE Bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    trip_id         INT NOT NULL,
    booking_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount    DECIMAL(10,2) NOT NULL,
    status          ENUM('Confirmed','Cancelled','Pending') NOT NULL DEFAULT 'Confirmed',
    payment_mode    ENUM('UPI','Card','Cash','Net Banking') NOT NULL DEFAULT 'UPI',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (trip_id) REFERENCES Trips(trip_id) ON DELETE CASCADE
);

CREATE TABLE Booking_Seats (
    bs_id       INT AUTO_INCREMENT PRIMARY KEY,
    booking_id  INT NOT NULL,
    seat_id     INT NOT NULL,
    trip_id     INT NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id)    REFERENCES Seats(seat_id)    ON DELETE CASCADE,
    FOREIGN KEY (trip_id)    REFERENCES Trips(trip_id)    ON DELETE CASCADE,
    UNIQUE KEY uq_trip_seat (trip_id, seat_id)
);

CREATE INDEX idx_trips_route     ON Trips(route_id);
CREATE INDEX idx_trips_departure ON Trips(departure_time);
CREATE INDEX idx_bookings_user   ON Bookings(user_id);
CREATE INDEX idx_bookings_trip   ON Bookings(trip_id);
CREATE INDEX idx_bseats_trip     ON Booking_Seats(trip_id);
