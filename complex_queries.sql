-- ============================================================
-- COMPLEX SQL QUERIES - Bus Reservation System
-- ============================================================

-- ============================================================
-- QUERY 1: Trip occupancy report with available seat count
-- Uses: JOIN, GROUP BY, subquery, HAVING
-- Purpose: Show all scheduled trips with how many seats remain
-- ============================================================
SELECT
    t.trip_id,
    r.source,
    r.destination,
    b.bus_name,
    b.bus_type,
    b.operator,
    t.departure_time,
    t.arrival_time,
    t.fare,
    b.total_seats,
    -- Count booked seats for this trip (only confirmed bookings)
    COALESCE(booked.booked_count, 0) AS booked_seats,
    (b.total_seats - COALESCE(booked.booked_count, 0)) AS available_seats,
    ROUND(COALESCE(booked.booked_count, 0) * 100.0 / b.total_seats, 1) AS occupancy_pct
FROM Trips t
JOIN Buses  b ON b.bus_id   = t.bus_id
JOIN Routes r ON r.route_id = t.route_id
-- Subquery: count confirmed booked seats per trip
LEFT JOIN (
    SELECT bs.trip_id, COUNT(*) AS booked_count
    FROM Booking_Seats bs
    JOIN Bookings bk ON bk.booking_id = bs.booking_id
    WHERE bk.status = 'Confirmed'
    GROUP BY bs.trip_id
) booked ON booked.trip_id = t.trip_id
WHERE t.status = 'Scheduled'
  AND t.departure_time >= NOW()
ORDER BY t.departure_time;


-- ============================================================
-- QUERY 2: Top passengers by total spending
-- Uses: JOIN, GROUP BY, ORDER BY, aggregate functions
-- Purpose: Revenue analytics & loyalty ranking
-- ============================================================
SELECT
    u.user_id,
    u.full_name,
    u.email,
    COUNT(DISTINCT bk.booking_id)           AS total_bookings,
    COUNT(bs.bs_id)                          AS total_seats_booked,
    SUM(CASE WHEN bk.status='Confirmed' THEN bk.total_amount ELSE 0 END) AS total_spent,
    SUM(CASE WHEN bk.status='Cancelled' THEN 1 ELSE 0 END)               AS cancellations,
    -- Most used payment mode per user using a correlated subquery
    (SELECT payment_mode FROM Bookings
     WHERE user_id = u.user_id AND status = 'Confirmed'
     GROUP BY payment_mode ORDER BY COUNT(*) DESC LIMIT 1) AS preferred_payment
FROM Users u
LEFT JOIN Bookings     bk ON bk.user_id    = u.user_id
LEFT JOIN Booking_Seats bs ON bs.booking_id = bk.booking_id
WHERE u.role = 'passenger'
GROUP BY u.user_id, u.full_name, u.email
HAVING total_bookings > 0
ORDER BY total_spent DESC;


-- ============================================================
-- QUERY 3: Route-wise revenue summary
-- Uses: JOIN, GROUP BY, aggregate, conditional SUM
-- Purpose: Identify most profitable routes
-- ============================================================
SELECT
    r.route_id,
    r.source,
    r.destination,
    r.distance_km,
    COUNT(DISTINCT t.trip_id)                AS total_trips,
    COUNT(DISTINCT bk.booking_id)            AS total_bookings,
    SUM(CASE WHEN bk.status='Confirmed' THEN bk.total_amount ELSE 0 END)  AS total_revenue,
    SUM(CASE WHEN bk.status='Cancelled' THEN bk.total_amount ELSE 0 END)  AS cancelled_revenue,
    AVG(CASE WHEN bk.status='Confirmed' THEN bk.total_amount END)         AS avg_booking_value,
    -- Revenue per km (efficiency metric)
    ROUND(SUM(CASE WHEN bk.status='Confirmed' THEN bk.total_amount ELSE 0 END) / r.distance_km, 2) AS revenue_per_km
FROM Routes r
JOIN Trips    t  ON t.route_id    = r.route_id
JOIN Bookings bk ON bk.trip_id   = t.trip_id
GROUP BY r.route_id, r.source, r.destination, r.distance_km
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 4: Find available seats for a specific trip
-- Uses: LEFT JOIN, NOT IN subquery, WHERE
-- Purpose: Show which seats are still bookable on trip_id=1
-- ============================================================
SELECT
    s.seat_id,
    s.seat_number,
    s.seat_type,
    s.deck,
    CASE
        WHEN s.seat_id IN (
            -- Seats already booked on this trip (confirmed only)
            SELECT bs.seat_id
            FROM Booking_Seats bs
            JOIN Bookings bk ON bk.booking_id = bs.booking_id
            WHERE bs.trip_id = 1 AND bk.status = 'Confirmed'
        ) THEN 'Booked'
        ELSE 'Available'
    END AS seat_status
FROM Seats s
JOIN Trips t  ON t.bus_id = s.bus_id
WHERE t.trip_id = 1
ORDER BY s.deck, s.seat_number;


-- ============================================================
-- QUERY 5: Booking history with full trip details for a user
-- Uses: Multiple JOINs, GROUP_CONCAT, subquery
-- Purpose: User's "My Bookings" page data
-- ============================================================
SELECT
    bk.booking_id,
    bk.booking_date,
    bk.status        AS booking_status,
    bk.total_amount,
    bk.payment_mode,
    r.source,
    r.destination,
    b.bus_name,
    b.bus_type,
    b.bus_number,
    t.departure_time,
    t.arrival_time,
    -- Concatenate all booked seat numbers for this booking
    GROUP_CONCAT(s.seat_number ORDER BY s.seat_number SEPARATOR ', ') AS seats_booked,
    COUNT(bs.bs_id) AS num_seats,
    -- Time until departure (or elapsed)
    TIMESTAMPDIFF(HOUR, NOW(), t.departure_time) AS hours_to_departure
FROM Bookings bk
JOIN Trips          t  ON t.trip_id    = bk.trip_id
JOIN Routes         r  ON r.route_id   = t.route_id
JOIN Buses          b  ON b.bus_id     = t.bus_id
LEFT JOIN Booking_Seats bs ON bs.booking_id = bk.booking_id
LEFT JOIN Seats     s  ON s.seat_id    = bs.seat_id
WHERE bk.user_id = 1   -- replace with :user_id param
GROUP BY bk.booking_id, bk.booking_date, bk.status, bk.total_amount,
         bk.payment_mode, r.source, r.destination, b.bus_name,
         b.bus_type, b.bus_number, t.departure_time, t.arrival_time
ORDER BY bk.booking_date DESC;


-- ============================================================
-- QUERY 6 (BONUS): Buses with highest cancellation rate
-- Uses: JOIN, GROUP BY, HAVING, subquery in SELECT
-- Purpose: Operations report - identify problem services
-- ============================================================
SELECT
    b.bus_id,
    b.bus_name,
    b.operator,
    COUNT(DISTINCT bk.booking_id) AS total_bookings,
    SUM(CASE WHEN bk.status='Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(
        SUM(CASE WHEN bk.status='Cancelled' THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT bk.booking_id), 2
    ) AS cancellation_rate_pct
FROM Buses b
JOIN Trips    t  ON t.bus_id     = b.bus_id
JOIN Bookings bk ON bk.trip_id  = t.trip_id
GROUP BY b.bus_id, b.bus_name, b.operator
HAVING total_bookings >= 2
ORDER BY cancellation_rate_pct DESC;
