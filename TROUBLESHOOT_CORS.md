# Troubleshooting CORS and 403 Errors

## Quick Fix Steps

1. **Restart the backend server:**
   ```bash
   cd /Users/vishnu/Desktop/PARTIZO/backend
   # Stop current server (Ctrl+C)
   npm start
   ```

2. **Verify ngrok is running:**
   ```bash
   # In another terminal
   ngrok http 3000
   ```
   Make sure the HTTPS URL matches your `api_config.dart` file.

3. **Check if backend is accessible:**
   ```bash
   curl https://tommye-favorless-geneva.ngrok-free.dev/api/health
   ```
   Should return: `{"status":"ok","message":"Backend is running"}`

4. **If you see 403 errors:**
   - Your authentication token may be expired
   - Try logging out and logging back in
   - Check browser console for token errors

5. **If CORS errors persist:**
   - Make sure backend is running (check terminal)
   - Make sure ngrok is active (check ngrok terminal)
   - Clear browser cache and hard refresh (Cmd+Shift+R on Mac)
   - Check backend terminal logs for request logs

## Common Issues

### Backend Not Running
- **Symptom:** All requests fail with network errors
- **Fix:** Start backend with `npm start` in backend folder

### ngrok Not Active
- **Symptom:** DNS resolution errors or connection refused
- **Fix:** Start ngrok with `ngrok http 3000` and update `api_config.dart` with new URL

### Expired Token
- **Symptom:** 403 Forbidden errors
- **Fix:** Log out and log back in to get a new token

### CORS Still Blocking
- **Symptom:** "No 'Access-Control-Allow-Origin' header" error
- **Fix:** 
  1. Restart backend to apply CORS changes
  2. Check backend terminal for request logs
  3. Verify CORS middleware is running first

