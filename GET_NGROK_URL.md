# Get Your ngrok HTTPS URL

## ngrok is now configured! ✅

Your auth token has been saved. Now get your HTTPS URL:

### Method 1: Check ngrok Web Interface
1. Open in browser: **http://localhost:4040**
2. You'll see the ngrok dashboard
3. Look for the **"Forwarding"** section
4. Copy the HTTPS URL (starts with `https://`)

### Method 2: Check Terminal
If ngrok is running, you should see:
```
Forwarding  https://abc123-def456.ngrok.io -> http://localhost:3000
```

### Method 3: Use API
Run this command:
```bash
curl http://localhost:4040/api/tunnels | python3 -m json.tool | grep public_url
```

## Once You Have the URL

1. **Update `lib/config/api_config.dart`:**
   ```dart
   static const String production = 'https://YOUR_NGROK_URL.ngrok.io/api';
   static const bool useProduction = true;
   ```

2. **Rebuild:**
   ```bash
   flutter build web
   git add -A
   git commit -m "Use ngrok HTTPS backend"
   git push
   ```

## Start ngrok Manually

If ngrok isn't running, start it:
```bash
ngrok http 3000
```

Keep this terminal window open!


