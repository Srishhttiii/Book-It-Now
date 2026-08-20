const cors = require('cors');
const express = require('express');
require('dotenv').config();

const pool = require('./db');

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json({ limit: '1mb' }));

async function ensureUser(connection, { firebaseUid, email = null, username = null }) {
  if (!firebaseUid) {
    const error = new Error('firebaseUid is required.');
    error.statusCode = 400;
    throw error;
  }

  await connection.query(
    `INSERT INTO users (firebase_uid, email, display_name, wallet_balance, credits)
     VALUES (:firebaseUid, :email, :username, 1000.00, 500)
     ON DUPLICATE KEY UPDATE
       email = COALESCE(VALUES(email), email),
       display_name = COALESCE(VALUES(display_name), display_name)`,
    { firebaseUid, email, username }
  );

  const [rows] = await connection.query(
    'SELECT id, firebase_uid, display_name, email, wallet_balance, credits FROM users WHERE firebase_uid = :firebaseUid LIMIT 1',
    { firebaseUid }
  );

  return rows[0];
}

function parseJsonList(value) {
  if (!value) return [];
  if (Array.isArray(value)) return value;

  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : [];
    } catch (_error) {
      return value
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean);
    }
  }

  return [];
}

function mapBooking(row) {
  return {
    id: row.id,
    bookingId: row.booking_code,
    movieId: row.movie_id,
    movieTitle: row.movie_title,
    cinemaName: row.cinema_name,
    cinemaLocation: row.cinema_location,
    showTime: row.show_time_text,
    selectedSeats: row.selected_seats ? row.selected_seats.split(',') : [],
    totalPrice: Number(row.total_price),
    posterUrl: row.poster_url || '',
    castList: parseJsonList(row.cast_list_json),
    reviewed: Boolean(row.reviewed),
    createdAt: row.created_at
  };
}

function mapReview(row) {
  return {
    id: row.id,
    bookingId: row.booking_code,
    movieId: row.movie_id,
    movieTitle: row.movie_title,
    userId: row.firebase_uid,
    username: row.display_name || 'Anonymous',
    rating: row.rating,
    story: row.story,
    acting: row.acting,
    visuals: row.visuals,
    music: row.music,
    recommendTo: row.recommend_to,
    emoji: row.emoji,
    favoriteCharacter: row.favorite_character,
    expectation: row.expectation,
    comments: row.comments || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

app.get('/health', async (_req, res, next) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'mysql-connected' });
  } catch (error) {
    next(error);
  }
});

app.post('/users/sync', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.get('/users/:firebaseUid/wallet', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    res.json({
      walletBalance: Number(user.wallet_balance),
      credits: Number(user.credits)
    });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/wallet/add', async (req, res, next) => {
  const amount = Number(req.body.amount || 0);
  if (amount <= 0) return res.status(400).json({ error: 'amount must be greater than 0.' });

  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    await connection.query(
      'UPDATE users SET wallet_balance = wallet_balance + :amount WHERE id = :userId',
      { amount, userId: user.id }
    );
    await connection.query(
      `INSERT INTO wallet_transactions (user_id, amount, transaction_type, reference_type)
       VALUES (:userId, :amount, 'credit', 'wallet_top_up')`,
      { userId: user.id, amount }
    );
    const [rows] = await connection.query('SELECT wallet_balance, credits FROM users WHERE id = :userId', { userId: user.id });
    res.json({ walletBalance: Number(rows[0].wallet_balance), credits: Number(rows[0].credits) });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/wallet/purchase', async (req, res, next) => {
  const amount = Number(req.body.amount || 0);
  if (amount <= 0) return res.status(400).json({ error: 'amount must be greater than 0.' });

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query('SELECT wallet_balance FROM users WHERE id = :userId FOR UPDATE', { userId: user.id });
    const balance = Number(rows[0].wallet_balance);

    if (balance < amount) {
      await connection.rollback();
      return res.status(400).json({ error: 'Insufficient wallet balance.' });
    }

    await connection.query(
      'UPDATE users SET wallet_balance = wallet_balance - :amount WHERE id = :userId',
      { amount, userId: user.id }
    );
    await connection.query(
      `INSERT INTO wallet_transactions (user_id, amount, transaction_type, reference_type)
       VALUES (:userId, :amount, 'debit', 'booking')`,
      { userId: user.id, amount }
    );
    await connection.commit();
    res.json({ success: true, walletBalance: balance - amount });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/credits/add', async (req, res, next) => {
  const amount = Number.parseInt(req.body.amount || 0, 10);
  if (amount <= 0) return res.status(400).json({ error: 'amount must be greater than 0.' });

  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    await connection.query('UPDATE users SET credits = credits + :amount WHERE id = :userId', { amount, userId: user.id });
    const [rows] = await connection.query('SELECT wallet_balance, credits FROM users WHERE id = :userId', { userId: user.id });
    res.json({ walletBalance: Number(rows[0].wallet_balance), credits: Number(rows[0].credits) });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/credits/spend', async (req, res, next) => {
  const amount = Number.parseInt(req.body.amount || 0, 10);
  if (amount <= 0) return res.status(400).json({ error: 'amount must be greater than 0.' });

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query('SELECT credits FROM users WHERE id = :userId FOR UPDATE', { userId: user.id });
    const credits = Number(rows[0].credits);

    if (credits < amount) {
      await connection.rollback();
      return res.status(400).json({ error: 'Not enough credits.' });
    }

    await connection.query('UPDATE users SET credits = credits - :amount WHERE id = :userId', { amount, userId: user.id });
    await connection.commit();
    res.json({ credits: credits - amount });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/credits/convert', async (req, res, next) => {
  const creditsToConvert = Number.parseInt(req.body.credits || 500, 10);
  const moneyToReceive = Number(req.body.money || 100);

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query('SELECT credits, wallet_balance FROM users WHERE id = :userId FOR UPDATE', { userId: user.id });
    const currentCredits = Number(rows[0].credits);

    if (currentCredits < creditsToConvert) {
      await connection.rollback();
      return res.status(400).json({ error: 'Not enough credits to convert.' });
    }

    await connection.query(
      `UPDATE users
       SET credits = credits - :creditsToConvert,
           wallet_balance = wallet_balance + :moneyToReceive
       WHERE id = :userId`,
      { creditsToConvert, moneyToReceive, userId: user.id }
    );
    await connection.query(
      `INSERT INTO wallet_transactions (user_id, amount, transaction_type, reference_type)
       VALUES (:userId, :moneyToReceive, 'credit', 'credits_redemption')`,
      { userId: user.id, moneyToReceive }
    );
    await connection.commit();

    const [updatedRows] = await connection.query('SELECT credits, wallet_balance FROM users WHERE id = :userId', { userId: user.id });
    res.json({
      credits: Number(updatedRows[0].credits),
      walletBalance: Number(updatedRows[0].wallet_balance)
    });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.get('/users/:firebaseUid/bookings', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query(
      `SELECT b.*,
              GROUP_CONCAT(bs.seat_label ORDER BY bs.seat_label SEPARATOR ',') AS selected_seats
       FROM bookings b
       LEFT JOIN booking_seats bs ON bs.booking_id = b.id
       WHERE b.user_id = :userId
       GROUP BY b.id
       ORDER BY b.created_at DESC`,
      { userId: user.id }
    );
    res.json(rows.map(mapBooking));
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.get('/users/:firebaseUid/bookings/:bookingCode', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query(
      `SELECT b.*,
              GROUP_CONCAT(bs.seat_label ORDER BY bs.seat_label SEPARATOR ',') AS selected_seats
       FROM bookings b
       LEFT JOIN booking_seats bs ON bs.booking_id = b.id
       WHERE b.user_id = :userId AND b.booking_code = :bookingCode
       GROUP BY b.id
       LIMIT 1`,
      { userId: user.id, bookingCode: req.params.bookingCode }
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Booking not found.' });
    res.json(mapBooking(rows[0]));
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/users/:firebaseUid/bookings/:bookingCode/reviewed', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    await connection.query(
      'UPDATE bookings SET reviewed = true WHERE user_id = :userId AND booking_code = :bookingCode',
      { userId: user.id, bookingCode: req.params.bookingCode }
    );
    res.json({ reviewed: true });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/bookings', async (req, res, next) => {
  const {
    firebaseUid,
    bookingId,
    movieId,
    movieTitle,
    cinemaName,
    cinemaLocation,
    showTime,
    selectedSeats,
    totalPrice,
    posterUrl = '',
    castList = []
  } = req.body;

  if (!firebaseUid || !bookingId || !movieId || !movieTitle || !Array.isArray(selectedSeats) || selectedSeats.length === 0) {
    return res.status(400).json({ error: 'firebaseUid, bookingId, movieId, movieTitle, and selectedSeats are required.' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const user = await ensureUser(connection, { firebaseUid });

    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (
         booking_code, user_id, movie_id, movie_title, cinema_name, cinema_location,
         show_time_text, total_price, poster_url, cast_list_json, reviewed, status
       ) VALUES (
         :bookingId, :userId, :movieId, :movieTitle, :cinemaName, :cinemaLocation,
         :showTime, :totalPrice, :posterUrl, :castListJson, false, 'confirmed'
       )
       ON DUPLICATE KEY UPDATE booking_code = booking_code`,
      {
        bookingId,
        userId: user.id,
        movieId,
        movieTitle,
        cinemaName,
        cinemaLocation,
        showTime,
        totalPrice,
        posterUrl,
        castListJson: JSON.stringify(castList)
      }
    );

    const bookingDbId = bookingResult.insertId || (await connection.query(
      'SELECT id FROM bookings WHERE booking_code = :bookingId LIMIT 1',
      { bookingId }
    ))[0][0].id;

    if (bookingResult.insertId) {
      const seatRows = selectedSeats.map((seatLabel) => [bookingDbId, seatLabel]);
      await connection.query('INSERT INTO booking_seats (booking_id, seat_label) VALUES ?', [seatRows]);
    }

    await connection.commit();
    res.status(201).json({ bookingId, status: 'confirmed' });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.get('/movies/:movieId/reviews', async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT r.*, b.booking_code, u.firebase_uid, u.display_name
       FROM reviews r
       JOIN users u ON u.id = r.user_id
       LEFT JOIN bookings b ON b.id = r.booking_id
       WHERE r.movie_id = :movieId
       ORDER BY r.updated_at DESC`,
      { movieId: req.params.movieId }
    );
    res.json(rows.map(mapReview));
  } catch (error) {
    next(error);
  }
});

app.get('/users/:firebaseUid/reviews/:bookingCode', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const user = await ensureUser(connection, { firebaseUid: req.params.firebaseUid });
    const [rows] = await connection.query(
      `SELECT r.*, b.booking_code, u.firebase_uid, u.display_name
       FROM reviews r
       JOIN bookings b ON b.id = r.booking_id
       JOIN users u ON u.id = r.user_id
       WHERE r.user_id = :userId AND b.booking_code = :bookingCode
       LIMIT 1`,
      { userId: user.id, bookingCode: req.params.bookingCode }
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Review not found.' });
    res.json(mapReview(rows[0]));
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
});

app.post('/reviews', async (req, res, next) => {
  const {
    firebaseUid,
    bookingId,
    movieId,
    movieTitle,
    rating,
    story,
    acting,
    visuals,
    music,
    recommendTo,
    emoji,
    favoriteCharacter,
    expectation,
    comments
  } = req.body;

  if (!firebaseUid || !bookingId || !movieId || !rating) {
    return res.status(400).json({ error: 'firebaseUid, bookingId, movieId, and rating are required.' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const user = await ensureUser(connection, { firebaseUid });
    const [bookingRows] = await connection.query(
      'SELECT id FROM bookings WHERE user_id = :userId AND booking_code = :bookingId LIMIT 1',
      { userId: user.id, bookingId }
    );

    if (bookingRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ error: 'Booking not found.' });
    }

    const bookingDbId = bookingRows[0].id;
    const [existingRows] = await connection.query(
      'SELECT id FROM reviews WHERE user_id = :userId AND booking_id = :bookingDbId LIMIT 1',
      { userId: user.id, bookingDbId }
    );
    const isNewReview = existingRows.length === 0;

    await connection.query(
      `INSERT INTO reviews (
         user_id, booking_id, movie_id, movie_title, rating, story, acting, visuals,
         music, recommend_to, emoji, favorite_character, expectation, comments
       ) VALUES (
         :userId, :bookingDbId, :movieId, :movieTitle, :rating, :story, :acting, :visuals,
         :music, :recommendTo, :emoji, :favoriteCharacter, :expectation, :comments
       )
       ON DUPLICATE KEY UPDATE
         rating = VALUES(rating),
         story = VALUES(story),
         acting = VALUES(acting),
         visuals = VALUES(visuals),
         music = VALUES(music),
         recommend_to = VALUES(recommend_to),
         emoji = VALUES(emoji),
         favorite_character = VALUES(favorite_character),
         expectation = VALUES(expectation),
         comments = VALUES(comments),
         updated_at = CURRENT_TIMESTAMP`,
      {
        userId: user.id,
        bookingDbId,
        movieId,
        movieTitle,
        rating,
        story,
        acting,
        visuals,
        music,
        recommendTo,
        emoji,
        favoriteCharacter,
        expectation,
        comments
      }
    );

    await connection.query('UPDATE bookings SET reviewed = true WHERE id = :bookingDbId', { bookingDbId });

    if (isNewReview) {
      await connection.query('UPDATE users SET credits = credits + 100 WHERE id = :userId', { userId: user.id });
    }

    await connection.commit();
    res.status(isNewReview ? 201 : 200).json({ success: true, earnedCredits: isNewReview ? 100 : 0 });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(error.statusCode || 500).json({ error: error.message || 'Internal server error' });
});

app.listen(port, () => {
  console.log(`Book It Now API listening on port ${port}`);
});
