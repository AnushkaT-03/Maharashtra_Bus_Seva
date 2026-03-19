-- ============================================================
-- SAMPLE DATA - Maharashtra Bus Reservation System
-- ============================================================

-- Users (passwords are bcrypt of "password123")
INSERT INTO Users (full_name, email, phone, password_hash, role) VALUES
('Rahul Patil',      'rahul.patil@gmail.com',    '9876543210', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Priya Deshmukh',   'priya.deshmukh@gmail.com', '9823456781', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Suresh Jadhav',    'suresh.jadhav@yahoo.com',  '9012345678', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Anita Kulkarni',   'anita.kulkarni@gmail.com', '9765432109', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Vijay Shinde',     'vijay.shinde@rediff.com',  '9654321098', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Meera Pawar',      'meera.pawar@gmail.com',    '9543210987', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'passenger'),
('Admin MSRTC',      'admin@msrtc.gov.in',        '9000000001', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBpj2B3n1N8Kbm', 'admin');

-- Buses (Maharashtra-style numbers)
INSERT INTO Buses (bus_number, bus_name, bus_type, total_seats, operator) VALUES
('MH-12-BT-1001', 'Shivneri Express',      'Volvo AC',      40, 'MSRTC'),
('MH-14-RT-2023', 'Sahyadri Deluxe',       'AC Sleeper',    36, 'MSRTC'),
('MH-04-NN-3045', 'Konkan Queen',          'Sleeper',       40, 'Paulo Travels'),
('MH-20-ZZ-4567', 'Deccan Warrior',        'Semi-Sleeper',  45, 'VRL Travels'),
('MH-01-AB-5890', 'Vidarbha Express',      'Seater',        50, 'MSRTC'),
('MH-31-CD-6712', 'Marathwada Cruiser',    'Volvo AC',      40, 'Neeta Tours'),
('MH-09-EF-7834', 'Pune-Mumbai Rocket',    'Volvo AC',      40, 'MSRTC'),
('MH-06-GH-8956', 'Nashik Vaibhav',        'Semi-Sleeper',  45, 'Orange Travels');

-- Routes (Maharashtra cities)
INSERT INTO Routes (source, destination, distance_km, base_fare) VALUES
('Mumbai',   'Pune',       149,  350.00),
('Pune',     'Mumbai',     149,  350.00),
('Mumbai',   'Nashik',     167,  400.00),
('Nashik',   'Mumbai',     167,  400.00),
('Pune',     'Kolhapur',   228,  520.00),
('Kolhapur', 'Pune',       228,  520.00),
('Mumbai',   'Aurangabad', 335,  750.00),
('Aurangabad','Mumbai',    335,  750.00),
('Pune',     'Nagpur',     700, 1200.00),
('Nagpur',   'Pune',       700, 1200.00),
('Mumbai',   'Nagpur',     832, 1400.00),
('Nashik',   'Pune',       210,  480.00),
('Pune',     'Nashik',     210,  480.00),
('Aurangabad','Pune',      235,  550.00),
('Mumbai',   'Kolhapur',   375,  800.00);

-- Trips (scheduled journeys)
INSERT INTO Trips (bus_id, route_id, departure_time, arrival_time, fare, status) VALUES
(1,  1,  '2026-03-20 06:00:00', '2026-03-20 09:30:00',  450.00, 'Scheduled'),
(7,  1,  '2026-03-20 08:00:00', '2026-03-20 11:30:00',  420.00, 'Scheduled'),
(7,  1,  '2026-03-20 22:00:00', '2026-03-21 01:30:00',  380.00, 'Scheduled'),
(2,  2,  '2026-03-20 07:00:00', '2026-03-20 10:30:00',  450.00, 'Scheduled'),
(1,  2,  '2026-03-20 18:00:00', '2026-03-20 21:30:00',  420.00, 'Scheduled'),
(3,  3,  '2026-03-20 09:00:00', '2026-03-20 12:30:00',  500.00, 'Scheduled'),
(8,  3,  '2026-03-20 21:00:00', '2026-03-21 00:30:00',  460.00, 'Scheduled'),
(4,  5,  '2026-03-20 07:30:00', '2026-03-20 11:30:00',  620.00, 'Scheduled'),
(6,  7,  '2026-03-20 20:00:00', '2026-03-21 04:00:00',  850.00, 'Scheduled'),
(5,  9,  '2026-03-20 17:00:00', '2026-03-21 05:00:00', 1350.00, 'Scheduled'),
(2,  9,  '2026-03-20 19:30:00', '2026-03-21 07:30:00', 1250.00, 'Scheduled'),
(3,  11, '2026-03-20 18:00:00', '2026-03-21 06:00:00', 1500.00, 'Scheduled'),
(4,  12, '2026-03-20 06:00:00', '2026-03-20 09:30:00',  580.00, 'Scheduled'),
(6,  13, '2026-03-20 08:00:00', '2026-03-20 11:30:00',  550.00, 'Scheduled'),
(8,  15, '2026-03-20 22:30:00', '2026-03-21 06:30:00',  900.00, 'Scheduled'),
-- Tomorrow trips
(1,  1,  '2026-03-21 06:00:00', '2026-03-21 09:30:00',  450.00, 'Scheduled'),
(7,  2,  '2026-03-21 07:00:00', '2026-03-21 10:30:00',  420.00, 'Scheduled'),
(2,  5,  '2026-03-21 08:00:00', '2026-03-21 12:00:00',  620.00, 'Scheduled');

-- Seats for Bus 1 (40 seats, Volvo AC)
INSERT INTO Seats (bus_id, seat_number, seat_type, deck) VALUES
(1,'A1','Window','Lower'),(1,'A2','Aisle','Lower'),(1,'A3','Aisle','Lower'),(1,'A4','Window','Lower'),
(1,'B1','Window','Lower'),(1,'B2','Aisle','Lower'),(1,'B3','Aisle','Lower'),(1,'B4','Window','Lower'),
(1,'C1','Window','Lower'),(1,'C2','Aisle','Lower'),(1,'C3','Aisle','Lower'),(1,'C4','Window','Lower'),
(1,'D1','Window','Lower'),(1,'D2','Aisle','Lower'),(1,'D3','Aisle','Lower'),(1,'D4','Window','Lower'),
(1,'E1','Window','Lower'),(1,'E2','Aisle','Lower'),(1,'E3','Aisle','Lower'),(1,'E4','Window','Lower'),
(1,'F1','Window','Upper'),(1,'F2','Aisle','Upper'),(1,'F3','Aisle','Upper'),(1,'F4','Window','Upper'),
(1,'G1','Window','Upper'),(1,'G2','Aisle','Upper'),(1,'G3','Aisle','Upper'),(1,'G4','Window','Upper'),
(1,'H1','Window','Upper'),(1,'H2','Aisle','Upper'),(1,'H3','Aisle','Upper'),(1,'H4','Window','Upper'),
(1,'I1','Window','Upper'),(1,'I2','Aisle','Upper'),(1,'I3','Aisle','Upper'),(1,'I4','Window','Upper'),
(1,'J1','Window','Upper'),(1,'J2','Aisle','Upper'),(1,'J3','Aisle','Upper'),(1,'J4','Window','Upper');

-- Seats for Bus 2 (36 seats, AC Sleeper)
INSERT INTO Seats (bus_id, seat_number, seat_type, deck) VALUES
(2,'L1','Window','Lower'),(2,'L2','Middle','Lower'),(2,'L3','Window','Lower'),
(2,'L4','Window','Lower'),(2,'L5','Middle','Lower'),(2,'L6','Window','Lower'),
(2,'L7','Window','Lower'),(2,'L8','Middle','Lower'),(2,'L9','Window','Lower'),
(2,'L10','Window','Lower'),(2,'L11','Middle','Lower'),(2,'L12','Window','Lower'),
(2,'L13','Window','Lower'),(2,'L14','Middle','Lower'),(2,'L15','Window','Lower'),
(2,'L16','Window','Lower'),(2,'L17','Middle','Lower'),(2,'L18','Window','Lower'),
(2,'U1','Window','Upper'),(2,'U2','Middle','Upper'),(2,'U3','Window','Upper'),
(2,'U4','Window','Upper'),(2,'U5','Middle','Upper'),(2,'U6','Window','Upper'),
(2,'U7','Window','Upper'),(2,'U8','Middle','Upper'),(2,'U9','Window','Upper'),
(2,'U10','Window','Upper'),(2,'U11','Middle','Upper'),(2,'U12','Window','Upper'),
(2,'U13','Window','Upper'),(2,'U14','Middle','Upper'),(2,'U15','Window','Upper'),
(2,'U16','Window','Upper'),(2,'U17','Middle','Upper'),(2,'U18','Window','Upper');

-- Seats for Bus 3 (40 seats)
INSERT INTO Seats (bus_id, seat_number, seat_type, deck) VALUES
(3,'A1','Window','Lower'),(3,'A2','Aisle','Lower'),(3,'A3','Aisle','Lower'),(3,'A4','Window','Lower'),
(3,'B1','Window','Lower'),(3,'B2','Aisle','Lower'),(3,'B3','Aisle','Lower'),(3,'B4','Window','Lower'),
(3,'C1','Window','Lower'),(3,'C2','Aisle','Lower'),(3,'C3','Aisle','Lower'),(3,'C4','Window','Lower'),
(3,'D1','Window','Lower'),(3,'D2','Aisle','Lower'),(3,'D3','Aisle','Lower'),(3,'D4','Window','Lower'),
(3,'E1','Window','Lower'),(3,'E2','Aisle','Lower'),(3,'E3','Aisle','Lower'),(3,'E4','Window','Lower'),
(3,'F1','Window','Upper'),(3,'F2','Aisle','Upper'),(3,'F3','Aisle','Upper'),(3,'F4','Window','Upper'),
(3,'G1','Window','Upper'),(3,'G2','Aisle','Upper'),(3,'G3','Aisle','Upper'),(3,'G4','Window','Upper'),
(3,'H1','Window','Upper'),(3,'H2','Aisle','Upper'),(3,'H3','Aisle','Upper'),(3,'H4','Window','Upper'),
(3,'I1','Window','Upper'),(3,'I2','Aisle','Upper'),(3,'I3','Aisle','Upper'),(3,'I4','Window','Upper'),
(3,'J1','Window','Upper'),(3,'J2','Aisle','Upper'),(3,'J3','Aisle','Upper'),(3,'J4','Window','Upper');

-- Seats for Bus 7 (40 seats - Pune-Mumbai Rocket)
INSERT INTO Seats (bus_id, seat_number, seat_type, deck) VALUES
(7,'A1','Window','Lower'),(7,'A2','Aisle','Lower'),(7,'A3','Aisle','Lower'),(7,'A4','Window','Lower'),
(7,'B1','Window','Lower'),(7,'B2','Aisle','Lower'),(7,'B3','Aisle','Lower'),(7,'B4','Window','Lower'),
(7,'C1','Window','Lower'),(7,'C2','Aisle','Lower'),(7,'C3','Aisle','Lower'),(7,'C4','Window','Lower'),
(7,'D1','Window','Lower'),(7,'D2','Aisle','Lower'),(7,'D3','Aisle','Lower'),(7,'D4','Window','Lower'),
(7,'E1','Window','Lower'),(7,'E2','Aisle','Lower'),(7,'E3','Aisle','Lower'),(7,'E4','Window','Lower'),
(7,'F1','Window','Upper'),(7,'F2','Aisle','Upper'),(7,'F3','Aisle','Upper'),(7,'F4','Window','Upper'),
(7,'G1','Window','Upper'),(7,'G2','Aisle','Upper'),(7,'G3','Aisle','Upper'),(7,'G4','Window','Upper'),
(7,'H1','Window','Upper'),(7,'H2','Aisle','Upper'),(7,'H3','Aisle','Upper'),(7,'H4','Window','Upper'),
(7,'I1','Window','Upper'),(7,'I2','Aisle','Upper'),(7,'I3','Aisle','Upper'),(7,'I4','Window','Upper'),
(7,'J1','Window','Upper'),(7,'J2','Aisle','Upper'),(7,'J3','Aisle','Upper'),(7,'J4','Window','Upper');

-- Sample Bookings
INSERT INTO Bookings (user_id, trip_id, total_amount, status, payment_mode) VALUES
(1, 1,  900.00,  'Confirmed', 'UPI'),
(2, 1,  450.00,  'Confirmed', 'Card'),
(3, 4,  900.00,  'Confirmed', 'UPI'),
(1, 9,  850.00,  'Confirmed', 'Net Banking'),
(4, 2,  840.00,  'Confirmed', 'UPI'),
(5, 10, 1350.00, 'Confirmed', 'Card'),
(2, 6,  500.00,  'Cancelled', 'UPI'),
(6, 3,  760.00,  'Confirmed', 'UPI');

-- Booking_Seats (which seats each booking reserved)
INSERT INTO Booking_Seats (booking_id, seat_id, trip_id) VALUES
(1, 1,  1),   -- Rahul: seat A1 on trip 1
(1, 2,  1),   -- Rahul: seat A2 on trip 1
(2, 3,  1),   -- Priya: seat A3 on trip 1
(3, 41, 4),   -- Suresh: seat L1 on trip 4
(3, 42, 4),   -- Suresh: seat L2 on trip 4
(4, 1,  9),   -- Rahul: seat A1 on trip 9
(5, 161,2),   -- Anita: seats on trip 2 (bus7 seats start at 161)
(5, 162,2),
(6, 1,  10),  -- Vijay: trip 10
(8, 1,  3),   -- Meera: trip 3
(8, 2,  3);
