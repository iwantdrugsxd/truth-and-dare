# Authentication Setup Guide

The app now requires users to sign up/login before playing games. User credentials are saved and used automatically when joining games.

## Backend Setup

1. **Install new dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Update database schema:**
   ```bash
   psql -U your_username -d partizo -f database/schema.sql
   ```
   This will create the `users` table and add `user_id` to the `players` table.

3. **Set JWT Secret (optional but recommended):**
   Add to your `.env` file:
   ```
   JWT_SECRET=your-super-secret-key-here
   ```

4. **Start the backend:**
   ```bash
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create new account
  - Body: `{ "email": "user@example.com", "password": "password123", "name": "User Name" }`
  - Returns: `{ "token": "...", "user": { "id": "...", "email": "...", "name": "..." } }`

- `POST /api/auth/login` - Login
  - Body: `{ "email": "user@example.com", "password": "password123" }`
  - Returns: `{ "token": "...", "user": { "id": "...", "email": "...", "name": "..." } }`

- `GET /api/auth/me` - Get current user (requires auth token)
  - Headers: `Authorization: Bearer <token>`
  - Returns: `{ "user": { "id": "...", "email": "...", "name": "..." } }`

### Protected Game Endpoints
All game endpoints now require authentication:
- `POST /api/games/create` - Requires auth, uses logged-in user's name
- `POST /api/games/join` - Requires auth, uses logged-in user's name
- `GET /api/games/:gameId` - Requires auth
- `POST /api/games/:gameId/start` - Requires auth
- `GET /api/games/:gameId/question` - Requires auth
- `POST /api/games/:gameId/rate` - Requires auth
- `POST /api/games/:gameId/next` - Requires auth

## Flutter App Changes

1. **Login/Signup Screens:**
   - Users must sign up or login when they first open the app
   - Credentials are saved using `shared_preferences`
   - Token is automatically included in all API requests

2. **Game Flow:**
   - When creating a game, the user's name from their account is used automatically
   - When joining a game, the user's name is used automatically
   - No need to enter name separately anymore

3. **Logout:**
   - Users can logout from the game selection screen
   - Logout clears saved credentials and returns to login screen

## Testing with Postman

### Sign Up
```
POST http://localhost:3000/api/auth/signup
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User"
}
```

### Login
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

### Get Current User
```
GET http://localhost:3000/api/auth/me
Authorization: Bearer <token_from_login>
```

### Create Game (Protected)
```
POST http://localhost:3000/api/games/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "questionsPerPlayer": 3,
  "timerSeconds": 30
}
```

### Join Game (Protected)
```
POST http://localhost:3000/api/games/join
Authorization: Bearer <token>
Content-Type: application/json

{
  "code": "ABC123"
}
```

## Security Notes

- Passwords are hashed using bcrypt (10 salt rounds)
- JWT tokens expire after 30 days
- All game endpoints require valid authentication
- User IDs are linked to players to prevent duplicate joins


