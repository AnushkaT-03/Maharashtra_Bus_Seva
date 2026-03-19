"""
Bus Reservation System - Flask Backend
Maharashtra Routes | MySQL Database
"""

import os
import json
from datetime import datetime, date
from functools import wraps

import bcrypt
import mysql.connector
from flask import Flask, request, jsonify, session, send_from_directory

app = Flask(__name__, static_folder='static', template_folder='templates')
app.secret_key = os.environ.get('SECRET_KEY', 'mh-bus-secret-2026')

# ─── Database Configuration ──────────────────────────────────────────────────
DB_CONFIG = {
    'host':     os.environ.get('DB_HOST',     'localhost'),
    'port':     int(os.environ.get('DB_PORT', 3306)),
    'user':     os.environ.get('DB_USER',     'root'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_NAME',     'bus_reservation'),
    'autocommit': False,
}

def get_db():
    """Return a new database connection."""
    return mysql.connector.connect(**DB_CONFIG)


# ─── Auth Helpers ─────────────────────────────────────────────────────────────
def login_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({'error': 'Authentication required'}), 401
        return f(*args, **kwargs)
    return wrapper

def admin_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if session.get('role') != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        return f(*args, **kwargs)
    return wrapper


# ─── Serialisation helper ─────────────────────────────────────────────────────
def serialize(row):
    """Convert MySQL row dict to JSON-serialisable dict."""
    out = {}
    for k, v in row.items():
        if isinstance(v, (datetime, date)):
            out[k] = v.isoformat()
        else:
            out[k] = v
    return out


# ═══════════════════════════════════════════════════════════════════════════════
# AUTH ROUTES
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/register', methods=['POST'])
def register():
    """Register a new passenger account."""
    data = request.get_json()
    required = ('full_name', 'email', 'phone', 'password')
    if not all(data.get(k) for k in required):
        return jsonify({'error': 'All fields are required'}), 400

    pw_hash = bcrypt.hashpw(data['password'].encode(), bcrypt.gensalt()).decode()

    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute(
            """INSERT INTO Users (full_name, email, phone, password_hash)
               VALUES (%s, %s, %s, %s)""",
            (data['full_name'], data['email'], data['phone'], pw_hash)
        )
        conn.commit()
        user_id = cur.lastrowid
        session['user_id']  = user_id
        session['full_name'] = data['full_name']
        session['role']      = 'passenger'
        return jsonify({'message': 'Registration successful', 'user_id': user_id}), 201
    except mysql.connector.IntegrityError as e:
        conn.rollback()
        return jsonify({'error': 'Email or phone already registered'}), 409
    finally:
        cur.close(); conn.close()


@app.route('/api/login', methods=['POST'])
def login():
    """Authenticate user and create session."""
    data = request.get_json()
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute(
            "SELECT * FROM Users WHERE email = %s", (data.get('email'),)
        )
        user = cur.fetchone()
        if not user or not bcrypt.checkpw(
            data.get('password', '').encode(), user['password_hash'].encode()
        ):
            return jsonify({'error': 'Invalid credentials'}), 401

        session['user_id']   = user['user_id']
        session['full_name'] = user['full_name']
        session['role']      = user['role']
        return jsonify({
            'message':   'Login successful',
            'user_id':   user['user_id'],
            'full_name': user['full_name'],
            'role':      user['role'],
        })
    finally:
        cur.close(); conn.close()


@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'message': 'Logged out'})


@app.route('/api/me')
def me():
    if 'user_id' not in session:
        return jsonify({'logged_in': False})
    return jsonify({
        'logged_in': True,
        'user_id':   session['user_id'],
        'full_name': session['full_name'],
        'role':      session['role'],
    })


# ═══════════════════════════════════════════════════════════════════════════════
# SEARCH ROUTES
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/search')
def search_trips():
    """
    Search available trips by source, destination and date.
    Returns trip details with available seat count.
    Uses COMPLEX QUERY 1 logic.
    """
    source      = request.args.get('source', '').strip()
    destination = request.args.get('destination', '').strip()
    travel_date = request.args.get('date', '')

    if not (source and destination and travel_date):
        return jsonify({'error': 'source, destination and date are required'}), 400

    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT
                t.trip_id,
                r.source,
                r.destination,
                r.distance_km,
                b.bus_name,
                b.bus_type,
                b.bus_number,
                b.operator,
                b.total_seats,
                t.departure_time,
                t.arrival_time,
                t.fare,
                t.status,
                /* available seat count via subquery */
                (b.total_seats - COALESCE((
                    SELECT COUNT(*)
                    FROM Booking_Seats bs
                    JOIN Bookings bk ON bk.booking_id = bs.booking_id
                    WHERE bs.trip_id = t.trip_id AND bk.status = 'Confirmed'
                ), 0)) AS available_seats
            FROM Trips  t
            JOIN Buses  b ON b.bus_id   = t.bus_id
            JOIN Routes r ON r.route_id = t.route_id
            WHERE r.source      = %s
              AND r.destination = %s
              AND DATE(t.departure_time) = %s
              AND t.status = 'Scheduled'
            ORDER BY t.departure_time
        """, (source, destination, travel_date))

        trips = [serialize(row) for row in cur.fetchall()]
        return jsonify(trips)
    finally:
        cur.close(); conn.close()


@app.route('/api/cities')
def get_cities():
    """Return list of all source cities for the search dropdowns."""
    conn = get_db()
    cur  = conn.cursor()
    try:
        cur.execute("""
            SELECT DISTINCT source FROM Routes
            UNION
            SELECT DISTINCT destination FROM Routes
            ORDER BY 1
        """)
        cities = [row[0] for row in cur.fetchall()]
        return jsonify(cities)
    finally:
        cur.close(); conn.close()


# ═══════════════════════════════════════════════════════════════════════════════
# SEATS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/trips/<int:trip_id>/seats')
def get_seats(trip_id):
    """
    Return seat map for a trip with availability status.
    Uses COMPLEX QUERY 4 logic.
    """
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT
                s.seat_id,
                s.seat_number,
                s.seat_type,
                s.deck,
                CASE
                    WHEN s.seat_id IN (
                        SELECT bs.seat_id
                        FROM Booking_Seats bs
                        JOIN Bookings bk ON bk.booking_id = bs.booking_id
                        WHERE bs.trip_id = %s AND bk.status = 'Confirmed'
                    ) THEN 'Booked'
                    ELSE 'Available'
                END AS status
            FROM Seats s
            JOIN Trips t ON t.bus_id = s.bus_id
            WHERE t.trip_id = %s
            ORDER BY s.deck, s.seat_number
        """, (trip_id, trip_id))

        seats = [serialize(row) for row in cur.fetchall()]

        # Get trip fare for price calculation
        cur.execute("SELECT fare FROM Trips WHERE trip_id = %s", (trip_id,))
        trip = cur.fetchone()
        fare = float(trip['fare']) if trip else 0

        return jsonify({'seats': seats, 'fare': fare})
    finally:
        cur.close(); conn.close()


# ═══════════════════════════════════════════════════════════════════════════════
# BOOKINGS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/bookings', methods=['POST'])
@login_required
def create_booking():
    """
    Book multiple seats on a trip.
    Prevents double-booking via the UNIQUE KEY on Booking_Seats(trip_id, seat_id).
    Uses a transaction for atomicity.
    """
    data       = request.get_json()
    trip_id    = data.get('trip_id')
    seat_ids   = data.get('seat_ids', [])
    pay_mode   = data.get('payment_mode', 'UPI')
    user_id    = session['user_id']

    if not trip_id or not seat_ids:
        return jsonify({'error': 'trip_id and seat_ids are required'}), 400

    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        # ── 1. Get fare ───────────────────────────────────────────────────────
        cur.execute(
            "SELECT fare, status FROM Trips WHERE trip_id = %s FOR UPDATE",
            (trip_id,)
        )
        trip = cur.fetchone()
        if not trip or trip['status'] != 'Scheduled':
            return jsonify({'error': 'Trip not available'}), 400

        total = float(trip['fare']) * len(seat_ids)

        # ── 2. Verify seats belong to this trip's bus ─────────────────────────
        placeholders = ','.join(['%s'] * len(seat_ids))
        cur.execute(f"""
            SELECT s.seat_id FROM Seats s
            JOIN Trips t ON t.bus_id = s.bus_id
            WHERE t.trip_id = %s AND s.seat_id IN ({placeholders})
        """, [trip_id] + seat_ids)
        valid = {row['seat_id'] for row in cur.fetchall()}
        if len(valid) != len(seat_ids):
            return jsonify({'error': 'Invalid seat selection'}), 400

        # ── 3. Create Booking header ──────────────────────────────────────────
        cur.execute("""
            INSERT INTO Bookings (user_id, trip_id, total_amount, payment_mode)
            VALUES (%s, %s, %s, %s)
        """, (user_id, trip_id, total, pay_mode))
        booking_id = cur.lastrowid

        # ── 4. Insert Booking_Seats (UNIQUE KEY prevents double-booking) ──────
        for sid in seat_ids:
            cur.execute("""
                INSERT INTO Booking_Seats (booking_id, seat_id, trip_id)
                VALUES (%s, %s, %s)
            """, (booking_id, sid, trip_id))

        conn.commit()
        return jsonify({
            'message':    'Booking confirmed!',
            'booking_id': booking_id,
            'total':      total,
        }), 201

    except mysql.connector.IntegrityError:
        conn.rollback()
        return jsonify({'error': 'One or more seats already booked. Please refresh.'}), 409
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close(); conn.close()


@app.route('/api/bookings/<int:booking_id>/cancel', methods=['POST'])
@login_required
def cancel_booking(booking_id):
    """Cancel a booking. Only the owner can cancel."""
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute(
            "SELECT * FROM Bookings WHERE booking_id = %s FOR UPDATE",
            (booking_id,)
        )
        booking = cur.fetchone()
        if not booking:
            return jsonify({'error': 'Booking not found'}), 404
        if booking['user_id'] != session['user_id'] and session.get('role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        if booking['status'] == 'Cancelled':
            return jsonify({'error': 'Already cancelled'}), 400

        cur.execute(
            "UPDATE Bookings SET status='Cancelled' WHERE booking_id=%s",
            (booking_id,)
        )
        conn.commit()
        return jsonify({'message': 'Booking cancelled successfully'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close(); conn.close()


@app.route('/api/my-bookings')
@login_required
def my_bookings():
    """
    Full booking history for the logged-in user.
    Uses COMPLEX QUERY 5 logic with GROUP_CONCAT.
    """
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT
                bk.booking_id,
                bk.booking_date,
                bk.status,
                bk.total_amount,
                bk.payment_mode,
                r.source,
                r.destination,
                b.bus_name,
                b.bus_type,
                b.bus_number,
                b.operator,
                t.departure_time,
                t.arrival_time,
                t.fare AS per_seat_fare,
                GROUP_CONCAT(s.seat_number ORDER BY s.seat_number SEPARATOR ', ') AS seats,
                COUNT(bs.bs_id) AS num_seats,
                TIMESTAMPDIFF(HOUR, NOW(), t.departure_time) AS hours_to_departure
            FROM Bookings bk
            JOIN Trips           t  ON t.trip_id    = bk.trip_id
            JOIN Routes          r  ON r.route_id   = t.route_id
            JOIN Buses           b  ON b.bus_id      = t.bus_id
            LEFT JOIN Booking_Seats bs ON bs.booking_id = bk.booking_id
            LEFT JOIN Seats      s  ON s.seat_id    = bs.seat_id
            WHERE bk.user_id = %s
            GROUP BY bk.booking_id, bk.booking_date, bk.status, bk.total_amount,
                     bk.payment_mode, r.source, r.destination, b.bus_name,
                     b.bus_type, b.bus_number, b.operator, t.departure_time,
                     t.arrival_time, t.fare
            ORDER BY bk.booking_date DESC
        """, (session['user_id'],))
        bookings = [serialize(row) for row in cur.fetchall()]
        return jsonify(bookings)
    finally:
        cur.close(); conn.close()


# ═══════════════════════════════════════════════════════════════════════════════
# ADMIN / ANALYTICS
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/admin/revenue')
@login_required
@admin_required
def revenue_report():
    """Route-wise revenue using COMPLEX QUERY 3."""
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    try:
        cur.execute("""
            SELECT
                r.source, r.destination, r.distance_km,
                COUNT(DISTINCT t.trip_id)   AS trips,
                COUNT(DISTINCT bk.booking_id) AS bookings,
                SUM(CASE WHEN bk.status='Confirmed' THEN bk.total_amount ELSE 0 END) AS revenue,
                AVG(CASE WHEN bk.status='Confirmed' THEN bk.total_amount END) AS avg_value
            FROM Routes r
            JOIN Trips    t  ON t.route_id  = r.route_id
            JOIN Bookings bk ON bk.trip_id = t.trip_id
            GROUP BY r.route_id, r.source, r.destination, r.distance_km
            ORDER BY revenue DESC
        """)
        return jsonify([serialize(r) for r in cur.fetchall()])
    finally:
        cur.close(); conn.close()


# ═══════════════════════════════════════════════════════════════════════════════
# STATIC FRONTEND
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/')
def index():
    return send_from_directory('templates', 'index.html')


if __name__ == '__main__':
    app.run(debug=True, port=5000)
