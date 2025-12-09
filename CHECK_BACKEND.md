# Quick Backend Check

## Is your backend running?

1. **Check if backend process is running:**
   ```bash
   lsof -ti:3000
   ```
   If this returns a number, backend is running. If empty, it's not running.

2. **Test backend directly (bypass ngrok):**
   ```bash
   curl http://localhost:3000/api/health
   ```
   Should return: `{"status":"ok","message":"Backend is running",...}`

3. **Test through ngrok:**
   ```bash
   curl https://tommye-favorless-geneva.ngrok-free.dev/api/health
   ```
   Should return the same JSON.

4. **Test CORS:**
   ```bash
   curl -H "Origin: https://truth-and-dare-hxvo.vercel.app" \
        -H "Access-Control-Request-Method: GET" \
        -X OPTIONS \
        https://tommye-favorless-geneva.ngrok-free.dev/api/test-cors
   ```
   Should return 204 with CORS headers.

## If backend is NOT running:

```bash
cd /Users/vishnu/Desktop/PARTIZO/backend
npm start
```

## If you see 403 errors:

Your authentication token is expired or invalid. You need to:
1. Log out
2. Log back in
3. This will get you a new token

## If CORS errors persist:

1. Make sure backend is restarted (to pick up CORS changes)
2. Check backend terminal for request logs
3. Verify ngrok is running: `ngrok http 3000`

