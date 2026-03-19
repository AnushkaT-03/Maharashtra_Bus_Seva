# 🚌 Maharashtra Bus Reservation System

A complete full-stack Bus Reservation System for Maharashtra routes.

## Tech Stack
- **Backend**: Python / Flask
- **Database**: MySQL
- **Frontend**: Vanilla HTML/CSS/JS (Single Page App)

## Project Structure
```
bus-reservation/
├── app.py              ← Flask REST API (all endpoints)
├── schema.sql          ← CREATE TABLE statements (7 tables)
├── sample_data.sql     ← Maharashtra routes, buses, trips
├── complex_queries.sql ← 6 complex SQL queries
├── requirements.txt    ← Python dependencies
├── templates/
│   └── index.html      ← Single-page frontend
└── README.md
```

## Database Schema (7 Tables)

| Table | Relationships |
|-------|--------------|
| Users | 1 → N Bookings |
| Buses | 1 → N Trips, 1 → N Seats |
| Routes | 1 → N Trips |
| Trips | N ← Buses, N ← Routes; 1 → N Bookings |
| Seats | N ← Buses; M:N via Booking_Seats |
| Bookings | N ← Users, N ← Trips; 1 → N Booking_Seats |
| Booking_Seats | M:N resolution: Bookings ↔ Seats per Trip |

## Setup Instructions

### 1. MySQL Database
```sql
CREATE DATABASE bus_reservation;
USE bus_reservation;
SOURCE schema.sql;
SOURCE sample_data.sql;
```

### 2. Python Environment
```bash
pip install -r requirements.txt
```

### 3. Configure DB (environment variables or edit app.py)
```bash
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=yourpassword
export DB_NAME=bus_reservation
```

### 4. Run
```bash
python app.py
```
Visit: http://localhost:5000

## Features

### User Features
- ✅ Register / Login / Logout
- ✅ Search buses by source & destination & date
- ✅ View seat map (Lower/Upper deck, Window/Aisle/Middle)
- ✅ Book multiple seats in one transaction
- ✅ Booking summary with payment mode selection
- ✅ Cancel bookings
- ✅ Booking history with full trip details

### Technical Features
- ✅ No double-booking: UNIQUE KEY on Booking_Seats(trip_id, seat_id)
- ✅ Atomic transactions (rollback on failure)
- ✅ bcrypt password hashing
- ✅ Session-based authentication
- ✅ 6 complex SQL queries (JOIN, GROUP BY, subquery, GROUP_CONCAT)

## Maharashtra Routes Covered
Mumbai ↔ Pune | Mumbai ↔ Nashik | Pune ↔ Kolhapur
Mumbai ↔ Aurangabad | Pune ↔ Nagpur | Mumbai ↔ Nagpur
Nashik ↔ Pune | Aurangabad ↔ Pune | Mumbai ↔ Kolhapur

## Demo Login
- Email: `rahul.patil@gmail.com`
- Password: `password123`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/register | Create account |
| POST | /api/login | Authenticate |
| POST | /api/logout | End session |
| GET | /api/me | Current user |
| GET | /api/cities | All cities |
| GET | /api/search | Search trips |
| GET | /api/trips/:id/seats | Seat map |
| POST | /api/bookings | Create booking |
| POST | /api/bookings/:id/cancel | Cancel booking |
| GET | /api/my-bookings | Booking history |
| GET | /api/admin/revenue | Revenue report (admin) |
