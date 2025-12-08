# Deploy Backend to Production (HTTPS Required)

## Problem
Your app is deployed on Vercel (HTTPS), but the backend is on HTTP. Browsers block mixed content (HTTPS page → HTTP API).

## Solution: Deploy Backend with HTTPS

### Option 1: Railway (Easiest - Free Tier)

1. **Go to railway.app** and sign up
2. **New Project** → **Deploy from GitHub repo**
3. **Select your repo** → **Add Service** → **Empty Service**
4. **Settings** → **Root Directory**: Set to `backend`
5. **Variables** tab → Add:
   - `PORT` = `3000` (Railway sets this automatically)
   - `DATABASE_URL` = (Railway will provide PostgreSQL)
   - `JWT_SECRET` = `your-secret-key-here`
   - `NODE_ENV` = `production`
6. **Add PostgreSQL**:
   - Click **+ New** → **Database** → **PostgreSQL**
   - Railway will auto-create `DATABASE_URL`
7. **Deploy** → Railway will build and deploy
8. **Copy your app URL** (e.g., `https://your-app.up.railway.app`)
9. **Run database migrations**:
   - Go to PostgreSQL → **Connect** → Copy connection string
   - Run: `psql "YOUR_CONNECTION_STRING" -f database/schema.sql`
10. **Update Flutter app**:
    - Edit `lib/config/api_config.dart`:
    ```dart
    static const String production = 'https://your-app.up.railway.app/api';
    static const bool useProduction = true;
    ```

### Option 2: Render (Free Tier)

1. **Go to render.com** and sign up
2. **New** → **Web Service**
3. **Connect GitHub** → Select your repo
4. **Settings**:
   - **Name**: `partizo-backend`
   - **Root Directory**: `backend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. **Add PostgreSQL Database**:
   - **New** → **PostgreSQL**
   - Copy the **Internal Database URL**
6. **Environment Variables**:
   - `DATABASE_URL` = (from PostgreSQL)
   - `JWT_SECRET` = `your-secret-key`
   - `NODE_ENV` = `production`
7. **Deploy** → Render provides HTTPS automatically
8. **Update Flutter app** with Render URL

### Option 3: Heroku (Free Tier Available)

```bash
cd backend
heroku create partizo-backend
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set JWT_SECRET=your-secret-key
heroku config:set NODE_ENV=production
git subtree push --prefix backend heroku main
```

Then run migrations:
```bash
heroku pg:psql < database/schema.sql
```

### Option 4: Quick Testing with ngrok (Temporary)

For quick testing only:

```bash
# Install ngrok
brew install ngrok  # Mac
# Or download from ngrok.com

# Start backend
cd backend
npm start

# In another terminal, create tunnel
ngrok http 3000

# Copy the HTTPS URL (e.g., https://abc123.ngrok.io)
# Update lib/config/api_config.dart:
# static const String production = 'https://abc123.ngrok.io/api';
# static const bool useProduction = true;
```

**Note:** ngrok free tier has limitations (URL changes on restart, rate limits)

## Recommended: Railway

Railway is the easiest and provides:
- ✅ Free PostgreSQL database
- ✅ Automatic HTTPS
- ✅ Easy GitHub integration
- ✅ Free tier sufficient for testing

## After Deployment

1. Update `lib/config/api_config.dart`:
   ```dart
   static const String production = 'https://your-backend-url.com/api';
   static const bool useProduction = true;
   ```

2. Rebuild app:
   ```bash
   flutter build web
   ```

3. Commit and push:
   ```bash
   git add -A
   git commit -m "Update API to production backend"
   git push
   ```

4. Vercel will auto-deploy with new backend URL

