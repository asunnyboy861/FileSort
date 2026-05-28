# FileSort — App Review Information

## For App Store Review Team

---

## 1. In-App Purchase Products (Guideline 2.1b)

All IAP products have been configured in App Store Connect and are ready for review:

| Product ID | Type | Price | Status |
|------------|------|-------|--------|
| `com.zzoutuo.FileSort.monthly` | Auto-Renewable Subscription | $3.99/month | Submitted for review |
| `com.zzoutuo.FileSort.yearly` | Auto-Renewable Subscription | $19.99/year | Submitted for review |
| `com.zzoutuo.FileSort.lifetime` | Non-Consumable | $39.99 one-time | Submitted for review |

**App Review Screenshot**: Please ensure an App Review screenshot is uploaded for each IAP product in App Store Connect.

---

## 2. Subscription Information (Guideline 3.1.2c)

The app clearly displays all required subscription information in the PaywallView:

### Required Info in App:

- **Title**: FileSort Pro
- **Subscription Lengths**:
  - Monthly — 1 Month
  - Yearly — 1 Year
  - Lifetime — Forever (one-time purchase)
- **Prices**:
  - Monthly: $3.99/month
  - Yearly: $19.99/year (~$1.67/month)
  - Lifetime: $39.99 one-time
- **Privacy Policy**: https://asunnyboy861.github.io/FileSort/privacy.html
- **Terms of Use**: https://asunnyboy861.github.io/FileSort/terms.html

### Required Info in App Store Connect Metadata:

- **Privacy Policy URL**: https://asunnyboy861.github.io/FileSort/privacy.html
- **Terms of Use (EULA)**: https://asunnyboy861.github.io/FileSort/terms.html
- **App Description** includes: "FileSort offers auto-renewable subscriptions. See Terms of Use for details."

---

## 3. Free Tier & Usage Limits

FileSort uses a freemium model with monthly free usage:

- **Free Sorts**: 3 per calendar month
- **Free Duplicate Scans**: 1 per calendar month
- **Free Custom Rules**: 1 rule (in addition to 6 default rules)
- **Free Undo**: 1 batch

All limits reset on the 1st of each month. Premium users get unlimited access.

---

## 4. How to Test

### Test Account (if needed)
No account required. The app works entirely on-device.

### Test Flow:
1. Launch app → Onboarding slides → Tap "Start Free"
2. Dashboard shows "3 free sorts left this month"
3. Tap "Select Folder" → Pick any folder with files
4. Tap "Sort Now" → Review sort plan → Tap "Execute Sort"
5. After 3 sorts, paywall appears with subscription options

### Test IAP (Sandbox):
- Monthly and Yearly subscriptions can be tested with Sandbox Apple ID
- Lifetime purchase can be tested with Sandbox Apple ID
- "Restore Purchases" button is available in PaywallView and Settings

---

## 5. Contact Information

- **Support Email**: iocompile67692@gmail.com
- **Support URL**: https://asunnyboy861.github.io/FileSort/support.html

---

## 6. Notes for Reviewer

- The app does NOT use iCloud, cloud sync, or any external data storage. All data stays on the user's device.
- The app requires folder access permission via iOS document picker (security-scoped bookmarks).
- Widget and Siri Shortcuts are Premium features and require subscription/purchase.
- The app is fully functional in English for the US market.
