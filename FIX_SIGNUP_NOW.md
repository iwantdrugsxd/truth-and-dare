# Fix Signup Error - Quick Guide

## The Problem
The signup is failing because:
1. **Backend server is not running** (ngrok returns 502 error)
2. **ngrok tunnel may not be active** or pointing to wrong port

## Quick Fix (5 minutes)

### Step 1: Start Backend Server
Open Terminal 1:
```bash
cd /Users/vishnu/Desktop/PARTIZO/backend
npm start
```

You should see:
```
Server running on port 3000
Loaded 200 questions
```

**Keep this terminal open!**

### Step 2: Start ngrok Tunnel
Open Terminal 2:
```bash
cd /Users/vishnu/Desktop/PARTIZO
ngrok http 3000
```

You'll see output like:
```
Forwarding  https://abc123-def456.ngrok-free.app -> http://localhost:3000
```

**Copy the HTTPS URL** (the one starting with `https://`)

**Keep this terminal open too!**

### Step 3: Update API Config
Edit `lib/config/api_config.dart`:
```dart
static const String production = 'https://YOUR_NEW_NGROK_URL.ngrok-free.app/api';
static const bool useProduction = true;
```

Replace `YOUR_NEW_NGROK_URL` with the URL from Step 2.

### Step 4: Rebuild and Deploy
```bash
cd /Users/vishnu/Desktop/PARTIZO
flutter build web
git add -A
git commit -m "Update ngrok URL for signup"
git push
```

### Step 5: Wait and Test
- Wait 1-2 minutes for Vercel to redeploy
- Try signing up again
- Should work now! ✅

## Alternative: Use the Helper Script

```bash
cd /Users/vishnu/Desktop/PARTIZO
./START_EVERYTHING.sh
```

This will:
- Check if backend is running, start it if not
- Start ngrok tunnel
- Show you the URL to update

## Important Notes

⚠️ **ngrok free tier:**
- URL changes every time you restart ngrok
- You must keep both terminals open (backend + ngrok)
- If you close them, signup will stop working

✅ **For permanent solution:** Deploy backend to Railway/Heroku (see `DEPLOY_BACKEND.md`)

## Verify It's Working

Test the backend directly:
```bash
curl https://YOUR_NGROK_URL.ngrok-free.app/api/health
```

Should return: `{"status":"ok"}`

If you get 502, the backend isn't running or ngrok isn't connected.

