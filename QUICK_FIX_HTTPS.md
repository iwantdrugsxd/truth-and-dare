# Quick Fix for HTTPS Error

## The Problem
Your app on Vercel (HTTPS) can't connect to `http://192.168.1.2:3000` (HTTP) because browsers block mixed content.

## Fastest Solution: Use ngrok (5 minutes)

### Step 1: Install ngrok
```bash
brew install ngrok
# Or download from https://ngrok.com/download
```

### Step 2: Start Backend
```bash
cd backend
npm start
```

### Step 3: Create HTTPS Tunnel
In a new terminal:
```bash
ngrok http 3000
```

You'll see output like:
```
Forwarding  https://abc123-def456.ngrok.io -> http://localhost:3000
```

### Step 4: Update API Config
Edit `lib/config/api_config.dart`:
```dart
static const String production = 'https://abc123-def456.ngrok.io/api';
static const bool useProduction = true;
```

### Step 5: Rebuild and Deploy
```bash
flutter build web
git add -A
git commit -m "Use ngrok HTTPS tunnel for backend"
git push
```

## Permanent Solution: Deploy Backend

See `DEPLOY_BACKEND.md` for deploying to Railway/Heroku/Render (provides permanent HTTPS).

## Current Status
- ✅ Backend code ready
- ✅ Database schema ready  
- ⚠️ Need HTTPS endpoint (ngrok or deploy)


