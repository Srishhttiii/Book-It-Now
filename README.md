Book It Now Flutter App
=======================

A Flutter movie-ticket booking app. The app keeps Firebase Authentication for login, while bookings, wallet, credits, and user reviews are stored through the MySQL backend API.

## Repository

This working copy is connected to your GitHub repository:

```text
https://github.com/Srishhttiii/Book-It-Now.git
```

## MySQL Backend

The backend lives in `backend/` and is a small Express API that connects to MySQL. The Flutter app should call this API instead of connecting directly to MySQL, so database credentials stay on the server.

### Setup

1. Create the MySQL database and tables:

```bash
mysql -u root -p < backend/db/schema.sql
```

2. Configure backend environment variables:

```bash
cp backend/.env.example backend/.env
```

3. Edit `backend/.env` with your MySQL username and password.

4. Install and run the backend:

```bash
cd backend
npm install
npm run dev
```

5. Check the API:

```bash
curl http://localhost:3000/health
```

## API Starter Endpoints

- `GET /health` checks that the API and MySQL connection are working.
- `GET /movies` returns movies from MySQL.
- `POST /bookings` creates a booking and its selected seats inside one database transaction.

## Flutter

Run the app as usual:

```bash
flutter pub get
flutter run
```

The Flutter app sends booking, wallet, credits, and user review data to the MySQL backend API instead of Firestore.

### Running Flutter With The Backend

Start the backend first:

```bash
cd backend
npm install
cp .env.example .env
# edit .env with your MySQL username/password
npm run dev
```

Create the MySQL tables before using the app:

```bash
mysql -u root -p < backend/db/schema.sql
```

For desktop/web Flutter runs, the default backend URL is:

```text
http://localhost:3000
```

For an Android emulator, the app automatically uses `http://10.0.2.2:3000`. For a physical phone, replace the host with your laptop's local network IP address:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAPTOP_IP:3000
```

To use your own TMDB API key, run:

```bash
flutter run --dart-define=TMDB_API_KEY=YOUR_TMDB_KEY
```
