# Quick Start Guide - Get Backend Running

## Step 1: Install Dependencies
```bash
cd backend
npm install
```

## Step 2: Set Up PostgreSQL Database

### Option A: Using PostgreSQL locally
1. Make sure PostgreSQL is installed and running
2. Create database:
   ```bash
   createdb partizo
   ```
3. Run schema:
   ```bash
   psql -U your_username -d partizo -f database/schema.sql
   ```

### Option B: Using a cloud database (for production)
- Use services like:
  - **Heroku Postgres** (free tier available)
  - **Railway** (free tier)
  - **Supabase** (free tier)
  - **Neon** (free tier)

## Step 3: Configure Environment

Create `.env` file in `backend/` directory:
```env
PORT=3000
DATABASE_URL=postgresql://username:password@localhost:5432/partizo
NODE_ENV=development
JWT_SECRET=your-super-secret-key-change-this-in-production
```

## Step 4: Start the Server

```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## Step 5: Test the API

Open Postman or use curl:

**Sign Up:**
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Troubleshooting

**"Cannot connect to database":**
- Make sure PostgreSQL is running: `pg_isready`
- Check DATABASE_URL in `.env` file
- Verify database exists: `psql -l | grep partizo`

**"Port 3000 already in use":**
- Change PORT in `.env` file
- Or kill the process using port 3000: `lsof -ti:3000 | xargs kill`

**"Module not found":**
- Run `npm install` again
- Make sure you're in the `backend/` directory


