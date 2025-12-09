# How to Deploy to Vercel

## Problem
Vercel doesn't support Flutter builds natively. You need to build locally and commit the `build/web` folder.

## Solution: Build Locally and Deploy

### Step 1: Build Flutter Web App
```bash
cd /Users/vishnu/Desktop/PARTIZO
flutter build web --release
```

### Step 2: Verify Build Output
```bash
ls -la build/web/
```
You should see:
- `index.html`
- `main.dart.js`
- `flutter.js`
- `assets/` folder
- Other files

### Step 3: Commit Build Files
```bash
git add build/web/
git commit -m "Add Flutter web build for Vercel deployment"
git push
```

### Step 4: Vercel Will Auto-Deploy
- Vercel will detect the push
- It will use the `build/web` folder directly (no build needed)
- Your app will be live at `https://truth-and-dare-hxvo.vercel.app`

## Important Notes

⚠️ **You must rebuild and commit `build/web/` every time you make code changes:**
```bash
flutter build web --release
git add build/web/
git commit -m "Update build"
git push
```

✅ **Alternative:** Use GitHub Actions to auto-build on push (see `.github/workflows/deploy.yml` if created)

## Troubleshooting

**404 Error:**
- Make sure `build/web/index.html` exists
- Check that `vercel.json` has correct `outputDirectory`
- Verify rewrites are configured correctly

**Build Not Updating:**
- Clear Vercel cache
- Force redeploy in Vercel dashboard
- Make sure you committed `build/web/` folder

