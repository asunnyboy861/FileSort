# Pricing Configuration

## Monetization Model: Freemium with Monthly Free Usage

## Subscription Group
- **Group Name**: FileSort Premium
- **Group ID**: FileSort_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.FileSort.monthly`
- **Price**: $3.99 per month
- **Display Name**: FileSort Premium Monthly
- **Description**: Unlock unlimited rules & smart features
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.FileSort.yearly`
- **Price**: $19.99 per year (58% savings vs monthly)
- **Display Name**: FileSort Premium Yearly
- **Description**: Best value — save 58% annually
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.FileSort.lifetime`
- **Price**: $39.99 one-time
- **Display Name**: FileSort Lifetime Access
- **Description**: Pay once, own forever
- **Localization**: English (US)

## Free Tier Features
- ✅ Scan files (unlimited)
- ✅ Smart recommendations (default category rules)
- ✅ Sort files (3 per month, resets monthly)
- ✅ Sort result preview
- ✅ Duplicate detection (1 scan per month, resets monthly)
- ✅ Undo last sort batch (1 batch)
- ✅ Celebration & stats
- ❌ Custom rules (limit: 1 rule)
- ❌ Widget
- ❌ Siri Shortcuts
- ❌ Unlimited undo history (free: 1 batch)
- ❌ Unlimited monthly sorts

## Premium Tier Features
- ✅ All free features
- ✅ Unlimited custom rules
- ✅ Unlimited monthly sorts
- ✅ Duplicate file detection (unlimited, SHA256)
- ✅ Home screen widget
- ✅ Siri Shortcuts integration
- ✅ Unlimited undo history (50 batches)
- ✅ Priority support

## Monthly Free Usage
- **Free Sorts**: 3 per calendar month (resets on the 1st)
- **Free Duplicate Scans**: 1 per calendar month (resets on the 1st)
- **Tracking**: Stored locally via UserDefaults with month key
- **Premium Override**: Premium users bypass all usage limits

## Policy Pages Required
- Support Page: ✅ (Must include subscription management & free usage info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free usage limits clearly disclosed
- [x] Lifetime purchase option disclosed
- [x] Restore purchases functionality implemented

## StoreKit 2 Implementation Plan
- `PurchaseManager.swift`: Product fetching, purchase, restore, status tracking, free usage tracking
- `PaywallView.swift`: Subscription UI with feature comparison
- Product IDs: com.zzoutuo.FileSort.monthly, com.zzoutuo.FileSort.yearly, com.zzoutuo.FileSort.lifetime
- Use `Transaction.currentEntitlements` for status checking
- Use `AppStore.sync()` for restore
- Free usage tracked via `AppConstants.FreeUsage` keys in UserDefaults
