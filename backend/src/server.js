const cors = require('cors');
const express = require('express');
require('dotenv').config();

const pool = require('./db');

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

app.get('/health', async (_req, res, next) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    next(error);
  }
});

app.get('/movies', async (_req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT id, tmdb_id, title, poster_path, release_date, rating
       FROM movies
       ORDER BY release_date DESC, title ASC`
    );
    res.json(rows);
  } catch (error) {
    next(error);
  }
});

app.post('/bookings', async (req, res, next) => {
  const { userId, movieId, showtimeId, selectedSeats, totalPrice } = req.body;

  if (!userId || !movieId || !showtimeId || !Array.isArray(selectedSeats) || selectedSeats.length === 0) {
    return res.status(400).json({ error: 'userId, movieId, showtimeId, selectedSeats, and totalPrice are required.' });
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (user_id, movie_id, showtime_id, total_price, status)
       VALUES (:userId, :movieId, :showtimeId, :totalPrice, 'confirmed')`,
      { userId, movieId, showtimeId, totalPrice }
    );

    const bookingId = bookingResult.insertId;
    const seatRows = selectedSeats.map((seatLabel) => [bookingId, seatLabel]);

    await connection.query(
      'INSERT INTO booking_seats (booking_id, seat_label) VALUES ?',
      [seatRows]
    );

    await connection.commit();
    res.status(201).json({ id: bookingId, status: 'confirmed' });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(port, () => {
  console.log(`Book It Now API listening on port ${port}`);
});
