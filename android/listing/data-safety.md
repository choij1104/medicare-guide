# Data safety form — Medicare Guide (com.hakoya.medicareguide)

Basis: the store build (android/www) makes no network request (verified with Playwright: zero
requests to any other host) and has no analytics, ads or crash-reporting SDK. The Capacitor
project adds no plugins beyond @capacitor/core. Numbers typed into the calculators stay on the
page and are not saved. The only thing stored is the chosen language (`mg-lang`) in the app's
local storage on the device.

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable (no data collected) |
| Do you provide a way for users to request that their data is deleted? | Not applicable (no data collected). Uninstalling the app removes the saved language setting. |
| Data shared with third parties | None |
| Data collected | None |

Resulting label: "No data collected · No data shared with third parties".

Other Play Console declarations:
- Ads: **No, my app does not contain ads**
- App access: **All functionality is available without special access** (no login)
- Government apps: **No** — not developed by or on behalf of a government
- Financial features: **None**
- Health apps declaration: the app gives general health-insurance information and education only. It is not a medical device, gives no diagnosis or treatment, and collects no health data. Pick the closest education/reference option the form offers.
- News app: No

## Privacy policy text (to publish at a HAKOYA URL)

```
Medicare Guide (메디케어 길라잡이) — Privacy Policy
HAKOYA LLC · admin@hakoyallc.com · Effective <date of publication>

Medicare Guide does not collect, store, or share any personal information. The app works
entirely offline and does not send any data to HAKOYA LLC or to anyone else. It has no
accounts, advertising, analytics, or tracking. Numbers you enter in the calculators stay on
your device and are not saved. The app stores only your language choice (Korean or English)
on your device; uninstalling the app deletes it. Links to medicare.gov, cms.gov and ssa.gov
open in your web browser, where those sites' own privacy policies apply.

Medicare Guide is an independent educational app. It is not affiliated with or endorsed by
Medicare, CMS, the Social Security Administration, or any government agency.

Questions: admin@hakoyallc.com
```
