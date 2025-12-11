# PARTIZO Backend Server

Backend server for PARTIZO game platform using Node.js, Express, and PostgreSQL.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up PostgreSQL database:**
   - Create a PostgreSQL database named `partizo`
   - Update `.env` file with your database connection string:
     ```
     DATABASE_URL=postgresql://username:password@localhost:5432/partizo
     PORT=3000
     NODE_ENV=development
     ```

3. **Run database migrations:**
   ```bash
   psql -U username -d partizo -f database/schema.sql
   ```

4. **Copy questions data:**
   - Copy `questions_for_reveal_me` file to `backend/data/questions.json`
   - Or create a JSON file with the questions structure

5. **Start the server:**
   ```bash
   npm start
   # Or for development with auto-reload:
   npm run dev
   ```

## API Endpoints

### Games
- `POST /api/games/create` - Create a new game
- `POST /api/games/join` - Join an existing game
- `GET /api/games/:gameId` - Get game state
- `POST /api/games/:gameId/start` - Start the game (host only)
- `GET /api/games/:gameId/question` - Get current question
- `POST /api/games/:gameId/rate` - Submit a rating
- `POST /api/games/:gameId/next` - Move to next question/player

### Health
- `GET /api/health` - Health check

## Environment Variables

- `PORT` - Server port (default: 3000)
- `DATABASE_URL` - PostgreSQL connection string
- `NODE_ENV` - Environment (development/production)

## Deployment

For production deployment:
1. Set `NODE_ENV=production`
2. Use a production PostgreSQL database (e.g., Heroku Postgres, AWS RDS)
3. Update CORS settings if needed
4. Set up environment variables on your hosting platform


