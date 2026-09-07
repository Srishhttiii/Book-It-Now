# Book It Now

Book It Now is a full-stack movie-ticket booking application built with Flutter. It combines movie discovery, cinema and show-time selection, interactive seat selection, booking management, authenticated reviews and a reward-points wallet in one mobile-first experience.

## Highlights

- Browse trending, new-release, upcoming and genre-based movie collections powered by TMDB.
- Open detailed movie pages with cast, ratings, synopsis and audience reviews.
- Select a cinema and show time, then choose seats from a 2D seat-layout preview.
- Review a booking summary before payment and receive a QR-enabled digital ticket after a successful booking.
- View booking history, ticket details, selected seats and QR codes in My Bookings.
- Submit a review only after the show has started, helping ensure reviews are based on real ticket holders.
- Reopen an existing review with Edit Review and update it later without receiving reward credits twice.
- Earn 100 credits for a first authentic review, then redeem credits into wallet balance.
- Use Firebase Authentication for account access while keeping bookings, reviews, seats, wallet balances and credits in MySQL.

## User Workflow

1. Sign up or sign in with Firebase Authentication.
2. Discover a movie from the carousel, genre collections, new releases or upcoming movies.
3. Open the movie details page and select a cinema, show time and available seats.
4. Preview selected seats, review the booking summary and confirm payment.
5. Receive an animated ticket with a QR code, booking details and quick access to My Bookings or Home.
6. After the show begins, submit an authentic review to earn credits once.
7. Edit the same review whenever needed; the existing record is updated and no duplicate credits are added.

## Technology Stack

| Area | Technologies |
| --- | --- |
| Mobile app | Flutter, Dart, Material UI |
| Authentication | Firebase Authentication, Firebase Core |
| Backend API | Node.js, Express.js |
| Database | MySQL, mysql2 |
| Movie data | TMDB API |
| Ticketing | Syncfusion Flutter Barcodes for QR tickets |
| Development tools | Android Studio / Android Emulator, VS Code, Git, GitHub, npm |

## Architecture

```text
Flutter app
    |
    |-- Firebase Authentication for sign-up and sign-in
    |
    |-- Express API for application data and TMDB requests
            |
            |-- MySQL for users, wallets, credits, bookings, seats, and reviews
            |
            |-- TMDB API for movie metadata, posters, cast, and ratings
```

The Flutter app never connects directly to MySQL. The Express backend owns database access and transactions, keeping credentials on the server and allowing bookings, seat records, wallet updates and review rewards to be handled consistently.

## Review and Credits Rules

- A user can review only a booked show after its start time.
- Each booking can have one review record.
- The first submitted review earns 100 credits.
- An edited review updates that same record and earns 0 additional credits.
- Credits can be converted to wallet balance through the in-app rewards flow.

## Local Setup

### 1. Create the MySQL schema

```bash
mysql -u root -p < backend/db/schema.sql
```

### 2. Configure and start the backend

```bash
cd backend
cp .env.example .env
# Add your MySQL and TMDB values to .env
npm install
npm run dev
```

Confirm that the backend and database are connected:

```bash
curl http://localhost:3000/health
```

### 3. Run the Flutter application

Open a second terminal in the repository root:

```bash
flutter pub get
flutter run
```

For an Android emulator, the application uses `http://10.0.2.2:3000` to reach the backend. For a physical Android device, provide your computer's local IP address:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAPTOP_IP:3000
```

## Useful API Endpoints

- `GET /health` checks the Express API and MySQL connection.
- `GET /tmdb/movie/:movieId/details` returns movie details, cast, and TMDB reviews.
- `POST /bookings` creates a booking and its seats in a database transaction.
- `GET /users/:firebaseUid/bookings` returns a user's booking history.
- `POST /reviews` creates or updates an authenticated review and awards credits only for a first submission.
- `POST /users/:firebaseUid/credits/convert` converts reward credits into wallet balance.

