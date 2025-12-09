# Backend Setup Guide for Reveal Me Game

The Reveal Me game now uses a PostgreSQL backend for multiplayer functionality. Follow these steps to set it up.

## Prerequisites

1. **Node.js** (v14 or higher)
2. **PostgreSQL** (v12 or higher)
3. **npm** (comes with Node.js)

## Setup Steps

### 1. Install Backend Dependencies

```bash
cd backend
npm install
```

### 2. Set Up PostgreSQL Database

1. Create a PostgreSQL database:
   ```bash
   createdb partizo
   ```

2. Or using psql:
   ```sql
   CREATE DATABASE partizo;
   ```

3. Run the schema to create tables:
   ```bash
   psql -U your_username -d partizo -f database/schema.sql
   ```

### 3. Configure Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your database credentials:
   ```
   PORT=3000
   DATABASE_URL=postgresql://username:password@localhost:5432/partizo
   NODE_ENV=development
   ```

### 4. Start the Backend Server

```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The server will run on `http://localhost:3000`

### 5. Update Flutter App API URL

The Flutter app is configured to use `http://localhost:3000/api` by default.

**For local development:**
- If running Flutter web locally, this should work
- If testing on a device, use your computer's IP address:
  - Update `lib/services/reveal_me_api.dart`:
    ```dart
    static const String baseUrl = 'http://YOUR_IP:3000/api';
    ```

**For production:**
- Deploy the backend to a hosting service (Heroku, Railway, Render, etc.)
- Update `lib/services/reveal_me_api.dart`:
    ```dart
    static const String baseUrl = 'https://your-backend-url.com/api';
    ```

## API Endpoints

- `POST /api/games/create` - Create a new game
- `POST /api/games/join` - Join an existing game  
- `GET /api/games/:gameId` - Get game state
- `POST /api/games/:gameId/start` - Start the game (host only)
- `GET /api/games/:gameId/question` - Get current question
- `POST /api/games/:gameId/rate` - Submit a rating
- `POST /api/games/:gameId/next` - Move to next question/player
- `GET /api/health` - Health check

## Testing

1. Start the backend server
2. Open the Flutter app
3. Create a game as host
4. Join the game from another device/browser using the game code
5. Start the game and play!

## Troubleshooting

**Connection refused:**
- Make sure the backend server is running
- Check the PORT in `.env` matches what you're connecting to
- For device testing, ensure firewall allows connections

**Database errors:**
- Verify PostgreSQL is running: `pg_isready`
- Check database credentials in `.env`
- Ensure schema.sql was run successfully

**CORS errors:**
- The server has CORS enabled for all origins
- If issues persist, check the `cors` middleware in `server.js`

## Production Deployment

### Backend (Node.js/Express)

Deploy to:
- **Heroku**: Add PostgreSQL addon, set DATABASE_URL
- **Railway**: Auto-detects Node.js, add PostgreSQL service
- **Render**: Connect GitHub repo, add PostgreSQL database

### Frontend (Flutter Web)

Deploy to:
- **Vercel**: Already configured (see `vercel.json`)
- **Netlify**: Similar setup
- **Firebase Hosting**: Use `flutter build web` then deploy

**Important:** Update the API URL in `lib/services/reveal_me_api.dart` to point to your production backend!


