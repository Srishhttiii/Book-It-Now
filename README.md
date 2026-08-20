Book It Now Flutter App
=======================

A Flutter movie-ticket booking app. The current app uses Firebase for authentication and Firestore-backed app data; this repository now also includes a starter backend for moving database-managed features to MySQL.

## Repository

This working copy is already connected to:

```text
https://github.com/Sunidhi-Gautam/Book-It-Now-Flutter-App.git
```

To create a different GitHub repository, create the repo in GitHub first, then update the remote:

```bash
git remote set-url origin https://github.com/<your-user>/<new-repo>.git
git push -u origin main
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

The Flutter app now sends booking, wallet, credits, and user review data to the MySQL backend API instead of Firestore.

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

For an Android emulator, run Flutter with:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

For a physical phone, replace the host with your laptop's local network IP address.
