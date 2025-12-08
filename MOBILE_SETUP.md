# Mobile Testing Setup Guide

## Problem
When testing on mobile devices, `localhost:3000` doesn't work because:
- `localhost` on mobile refers to the mobile device itself, not your computer
- The backend is running on your computer, not on the mobile device

## Solution Options

### Option 1: Use Your Computer's IP Address (Quick Fix for Testing)

1. **Find your computer's local IP address:**

   **Mac/Linux:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   # Or
   ipconfig getifaddr en0
   ```

   **Windows:**
   ```cmd
   ipconfig
   # Look for "IPv4 Address" under your active network adapter
   ```

   Example IP: `192.168.1.100`

2. **Update the API config:**
   
   Edit `lib/config/api_config.dart`:
   ```dart
   static const String localNetwork = 'http://192.168.1.100:3000/api'; // Your IP here
   ```

3. **Make sure your computer and mobile device are on the same WiFi network**

4. **Update the config to use localNetwork:**
   ```dart
   static String get baseUrl {
     return localNetwork; // Use this for mobile testing
   }
   ```

5. **Rebuild the app:**
   ```bash
   flutter build web
   ```

### Option 2: Deploy Backend to Production (Recommended for Real Use)

Deploy your backend to a cloud service:

#### Heroku (Free Tier Available)
```bash
cd backend
heroku create your-app-name
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

#### Railway (Free Tier)
1. Go to railway.app
2. New Project → Deploy from GitHub
3. Select your backend folder
4. Add PostgreSQL service
5. Set environment variables

#### Render (Free Tier)
1. Go to render.com
2. New Web Service
3. Connect GitHub repo
4. Set root directory to `backend`
5. Add PostgreSQL database

Then update `lib/config/api_config.dart`:
```dart
static const String production = 'https://your-app.herokuapp.com/api';
static const bool useProduction = true;
```

### Option 3: Use ngrok (Quick Testing Tunnel)

1. **Install ngrok:**
   ```bash
   brew install ngrok  # Mac
   # Or download from ngrok.com
   ```

2. **Start your backend:**
   ```bash
   cd backend
   npm start
   ```

3. **Create tunnel:**
   ```bash
   ngrok http 3000
   ```

4. **Copy the HTTPS URL** (e.g., `https://abc123.ngrok.io`)

5. **Update API config:**
   ```dart
   static const String production = 'https://abc123.ngrok.io/api';
   static const bool useProduction = true;
   ```

## Current Status

- ✅ Backend code is ready
- ✅ Database schema is set up
- ⚠️ Need to configure API URL for mobile access

## Quick Fix Right Now

1. Find your IP: Run `ifconfig` or `ipconfig`
2. Edit `lib/config/api_config.dart` line 15:
   ```dart
   static const String localNetwork = 'http://YOUR_IP_HERE:3000/api';
   ```
3. Change line 25 to:
   ```dart
   return localNetwork; // Instead of localhost
   ```
4. Rebuild: `flutter build web`
5. Make sure backend is running: `cd backend && npm start`

## Testing Checklist

- [ ] Backend running on your computer (`npm start` in backend folder)
- [ ] Computer and mobile on same WiFi
- [ ] Firewall allows connections on port 3000
- [ ] API URL updated in `api_config.dart`
- [ ] App rebuilt after config change

