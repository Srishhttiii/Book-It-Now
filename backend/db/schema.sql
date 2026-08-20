CREATE DATABASE IF NOT EXISTS book_it_now
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE book_it_now;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  firebase_uid VARCHAR(128) NOT NULL,
  display_name VARCHAR(120) NULL,
  email VARCHAR(190) NULL,
  wallet_balance DECIMAL(10, 2) NOT NULL DEFAULT 1000.00,
  credits INT NOT NULL DEFAULT 500,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_firebase_uid (firebase_uid),
  UNIQUE KEY uq_users_email (email)
);

CREATE TABLE IF NOT EXISTS bookings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_code VARCHAR(64) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  movie_id BIGINT UNSIGNED NOT NULL,
  movie_title VARCHAR(255) NOT NULL,
  cinema_name VARCHAR(190) NULL,
  cinema_location VARCHAR(255) NULL,
  show_time_text VARCHAR(120) NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  poster_url VARCHAR(500) NULL,
  cast_list_json JSON NULL,
  reviewed BOOLEAN NOT NULL DEFAULT FALSE,
  status ENUM('pending', 'confirmed', 'cancelled') NOT NULL DEFAULT 'confirmed',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_bookings_booking_code (booking_code),
  KEY idx_bookings_user_id (user_id),
  KEY idx_bookings_movie_id (movie_id),
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS booking_seats (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_id BIGINT UNSIGNED NOT NULL,
  seat_label VARCHAR(20) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_booking_seat (booking_id, seat_label),
  CONSTRAINT fk_booking_seats_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  transaction_type ENUM('credit', 'debit') NOT NULL,
  reference_type VARCHAR(50) NULL,
  reference_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wallet_transactions_user_id (user_id),
  CONSTRAINT fk_wallet_transactions_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  booking_id BIGINT UNSIGNED NOT NULL,
  movie_id BIGINT UNSIGNED NOT NULL,
  movie_title VARCHAR(255) NULL,
  rating TINYINT UNSIGNED NOT NULL,
  story VARCHAR(255) NULL,
  acting VARCHAR(255) NULL,
  visuals VARCHAR(255) NULL,
  music VARCHAR(255) NULL,
  recommend_to VARCHAR(120) NULL,
  emoji VARCHAR(16) NULL,
  favorite_character VARCHAR(190) NULL,
  expectation VARCHAR(255) NULL,
  comments TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reviews_user_booking (user_id, booking_id),
  KEY idx_reviews_movie_id (movie_id),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE,
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);
