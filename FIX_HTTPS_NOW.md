# Fix HTTPS Error - Step by Step

## The Problem
Your app on Vercel uses HTTPS, but backend is HTTP. Browsers block this.

## Solution: Use ngrok (5 minutes)

### Step 1: Install ngrok
```bash
brew install ngrok
```

### Step 2: Start Backend (if not running)
```bash
cd backend
npm start
```

### Step 3: Start ngrok Tunnel
```bash
./START_NGROK.sh
```

Or manually:
```bash
ngrok http 3000
```

You'll see:
```
Forwarding  https://abc123-def456.ngrok.io -> http://localhost:3000
```

### Step 4: Update API Config
Edit `lib/config/api_config.dart`:

```dart
static const String production = 'https://abc123-def456.ngrok.io/api'; // Your ngrok URL
static const bool useProduction = true; // Change to true
```

### Step 5: Rebuild and Push
```bash
flutter build web
git add -A
git commit -m "Use HTTPS backend via ngrok"
git push
```

### Step 6: Test
- Wait for Vercel to redeploy
- Try signing up again
- Should work now! ✅

## Important Notes

⚠️ **ngrok free tier:**
- URL changes every time you restart ngrok
- Has rate limits
- Good for testing only

✅ **For production:** Deploy backend to Railway/Heroku (see DEPLOY_BACKEND.md)

## Alternative: Deploy Backend (Permanent Solution)

See `DEPLOY_BACKEND.md` for deploying to Railway (free, permanent HTTPS).


