# Medicare Guide (메디케어 길라잡이) — Google Play build

Free app. Application ID `com.hakoya.medicareguide`. Publisher: HAKOYA LLC. Target audience 18+.

The Google Play build is made from the repository's `index.html` by `scripts/build-store.py`.
The web app in the repository root is not modified. The store build:

- is **offline**: the "Translate & ask" tab (AI letter translation and AI Q&A through the
  Supabase edge function `medicare-ai`) is left out, with its script, endpoint and key. The app
  makes no network request. Links to medicare.gov, cms.gov and ssa.gov open in the system browser.
- bundles Gowun Batang and Noto Sans KR from @fontsource (SIL OFL 1.1) instead of Google Fonts.
- shows an independence notice (Korean and English) at the top of Basics and in the footer: not
  affiliated with or endorsed by Medicare, CMS, the Social Security Administration or any
  government agency, with links to the official sources.
- labels the 2027 Part B premium and deductible as estimates where the cost calculator uses them
  (they were already labelled "Projected" in the key-amounts table). No number is changed.
- keeps every other feature and both languages.

Every replacement in `build-store.py` must match exactly once, so a change to `index.html` that
breaks one stops the build instead of shipping a half-converted app.

The bundle's `capacitor.js` is the Android project's own @capacitor/core (8.x), so the JavaScript
runtime matches the native bridge.

## Before each release: check the figures
CMS announces the 2027 Part A and Part B amounts in November. When it does, update `index.html`
on main (2027 Part B premium ≈$209.50 and deductible ≈$292 are Trustees Report projections; the
2027 Part A deductible is not shown yet; the calculator uses the 2026 Part A deductible $1,736),
then rebuild.

## Build
GitHub Actions → "Android build (Google Play)". Runs on a push to `android-build` or by manual
dispatch. Produces an **unsigned** App Bundle, kept as a workflow artifact and committed to the
`android-artifacts` branch at `dist/medicare-guide-<version>-<code>-unsigned.aab` (`dist/LATEST`
names the newest). versionCode = workflow run number.

Local check of the store web bundle:

    cd android && npm ci && npm run build:www && python3 -m http.server -d www 8000

## Sign
HAKOYA LLC upload key (same key as TOXCARD and Silent Medic Vet; kept by the account holder,
backed up in Google Drive 00_CLAUDE_HQ/TOXCARD_Android_UploadKey):

    jarsigner -keystore toxcard-upload.jks -signedjar out-signed.aab in-unsigned.aab toxcard-upload
    jarsigner -verify out-signed.aab

## Files
- `scripts/build-store.py` — offline store web bundle (android/www)
- `scripts/native-setup.py` — launcher and adaptive icons, splash, version, ID and targetSdk checks
- `scripts/make-icon.py` → `icons/icon-1024.png` — app icon source (signpost on the app's green)
- `capacitor.config.json`, `package.json`, `package-lock.json`
- `listing/` — Play Console listing kit (text, data safety, content rating, graphics, screenshots)
