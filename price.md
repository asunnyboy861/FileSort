# Pricing Configuration

## Monetization Model: Subscription (Freemium)

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
- ✅ One-tap sort (basic)
- ✅ Sort result preview
- ✅ Undo last sort batch
- ✅ Celebration & stats
- ❌ Custom rules (limit: 1 rule)
- ❌ Duplicate detection
- ❌ Widget
- ❌ Siri Shortcuts
- ❌ Unlimited undo history (free: 1 batch)
- ❌ iCloud Drive access

## Premium Tier Features
- ✅ All free features
- ✅ Unlimited custom rules
- ✅ Duplicate file detection (SHA256)
- ✅ Home screen widget
- ✅ Siri Shortcuts integration
- ✅ Unlimited undo history (50 batches)
- ✅ iCloud Drive deep integration
- ✅ Priority support

## Free Trial
- **Duration**: 3 days
- **Type**: Free trial (auto-converts to monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free trial terms included
- [x] Restore purchases functionality implemented

## StoreKit 2 Implementation Plan
- `PurchaseManager.swift`: Product fetching, purchase, restore, status tracking
- `PaywallView.swift`: Subscription UI with feature comparison
- Product IDs: com.zzoutuo.FileSort.monthly, com.zzoutuo.FileSort.yearly, com.zzoutuo.FileSort.lifetime
- Use `Transaction.currentEntitlements` for status checking
- Use `AppStore.sync()` for restore
