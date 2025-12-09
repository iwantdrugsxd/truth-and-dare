# ngrok Setup Guide

## Step 1: Complete ngrok Setup

You're on the MFA setup page. You have two options:

### Option A: Skip MFA (Faster)
1. Click **"Skip"** button at the bottom
2. Continue to ngrok dashboard

### Option B: Set Up MFA (More Secure)
1. Open an authenticator app on your phone:
   - Google Authenticator
   - Microsoft Authenticator
   - 1Password
   - Authy
2. Scan the QR code OR manually enter this code:
   ```
   7XLVLY47OZUK75CYWWTIKREGJ5TUJ3CH
   ```
3. Enter the 6-digit code from your app
4. Click **"Next"**

## Step 2: Get Your ngrok URL

After setup, you need to start ngrok tunnel:

### In Terminal:
```bash
cd /Users/vishnu/Desktop/PARTIZO
ngrok http 3000
```

You'll see output like:
```
Forwarding  https://abc123-def456.ngrok.io -> http://localhost:3000
```

**Copy the HTTPS URL** (the one starting with `https://`)

## Step 3: Update API Config

Edit `lib/config/api_config.dart`:

```dart
static const String production = 'https://YOUR_NGROK_URL.ngrok.io/api';
static const bool useProduction = true; // Change to true
```

Replace `YOUR_NGROK_URL` with your actual ngrok URL.

## Step 4: Rebuild and Deploy

```bash
flutter build web
git add -A
git commit -m "Use ngrok HTTPS backend"
git push
```

## Step 5: Keep ngrok Running

⚠️ **Important:** Keep the `ngrok http 3000` terminal window open!
- If you close it, the URL will stop working
- The URL changes each time you restart ngrok (free tier)

## Alternative: Deploy Backend (Permanent Solution)

For a permanent HTTPS URL that doesn't change:
- See `DEPLOY_BACKEND.md` for Railway/Heroku deployment
- Provides stable HTTPS URL
- No need to keep terminal open


