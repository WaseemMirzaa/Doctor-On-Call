# RevenueCat Offerings Setup Guide

## Overview
This project now uses **RevenueCat Offerings** to handle platform-specific products (Play Store and App Store) with the same offering identifier. This allows you to have different product IDs for Android and iOS while managing them through a single offering.

## What Changed

### Before
- Direct product ID purchase using `purchaseProduct(productId)`
- Manual product loading by ID
- No offering-based structure

### After
- **Offering-based purchases** using `purchaseLifetime()` and packages
- Automatic platform detection and correct product selection
- Same offering identifier (`lifetime`) contains different products for each platform
- Fallback support for direct product purchases (backwards compatible)

## RevenueCat Dashboard Configuration

### Step 1: Create Products

#### For Android (Play Store)
1. Go to your Google Play Console
2. Create an in-app product (e.g., `one_time_fee`, `lifetime_android`, etc.)
3. Note the **Product ID**

#### For iOS (App Store)
1. Go to App Store Connect
2. Create an in-app purchase product (e.g., `one_time_fee`, `lifetime_ios`, etc.)
3. Note the **Product ID**

**Note:** The product IDs can be the same (e.g., both `one_time_fee`) or different (e.g., `one_time_fee_android` and `one_time_fee_ios`).

### Step 2: Configure Products in RevenueCat

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Go to your project
3. Navigate to **Products** section
4. Click **+ New** to add products

#### Add Android Product
- **Store**: Google Play Store
- **Product Identifier**: Your Play Store product ID (e.g., `one_time_fee`)
- **Type**: Non-consumable / Non-subscription
- Click **Save**

#### Add iOS Product
- **Store**: Apple App Store  
- **Product Identifier**: Your App Store product ID (e.g., `one_time_fee`)
- **Type**: Non-consumable / Non-subscription
- Click **Save**

### Step 3: Create an Offering

1. In RevenueCat Dashboard, go to **Offerings** section
2. Click **+ New Offering**
3. Set the **Offering Identifier**: `lifetime` (or any name you prefer)
4. Add a **Package**:
   - **Package Identifier**: `lifetime` or `$rc_lifetime` (use RevenueCat's built-in lifetime package type)
   - **Package Type**: Lifetime
   - **Android Product**: Select your Android product (e.g., `one_time_fee`)
   - **iOS Product**: Select your iOS product (e.g., `one_time_fee`)
5. Click **Save**

### Step 4: Set as Current Offering (Optional)
- Mark your offering as **Current** so it's automatically loaded
- Or specify the offering identifier in code

### Step 5: Configure Entitlements

1. Go to **Entitlements** section
2. Create or edit the `premium` entitlement
3. Attach both products (Android and iOS) to this entitlement
4. Save

## Code Implementation

### Constants (revenuecat_service.dart)
```dart
// Offering identifier - same for both platforms
static const String lifetimeOfferingId = 'lifetime';

// Product IDs - Platform specific
static const String oneTimePurchaseId = 'one_time_fee';

// Entitlement identifier
static const String premiumEntitlementId = 'premium';
```

### Key Methods

#### 1. Get Lifetime Package
```dart
// Automatically selects the correct platform-specific product
final package = await RevenueCatService.getLifetimePackage();
```

This method:
- Fetches offerings from RevenueCat
- Looks for the offering with identifier `lifetime`
- Returns the package with the correct product for current platform
- Handles both Android and iOS automatically

#### 2. Purchase Lifetime
```dart
// Purchases using the offering/package system
final info = await RevenueCatService.purchaseLifetime();
```

This method:
- Gets the lifetime package
- Initiates purchase using RevenueCat's package system
- Automatically uses correct product ID for the platform
- Returns CustomerInfo on success

### Controller Flow

1. **Load offerings** → `loadOfferings()`
2. **Load lifetime package** → `loadLifetimePackage()`
   - Gets package from offering
   - Extracts product and price information
   - Has fallback to direct product loading
3. **Purchase** → `purchaseLifetime()`
   - Uses package if available
   - Falls back to offering-based purchase
   - Final fallback to direct product purchase

## Testing

### Test on Android
```bash
flutter run -d <android-device>
```
- Open subscription screen
- Check console logs for: `Platform: Android, Product ID: <android-product-id>`
- Attempt purchase
- Verify correct Android product is used

### Test on iOS
```bash
flutter run -d <ios-device>
```
- Open subscription screen
- Check console logs for: `Platform: iOS, Product ID: <ios-product-id>`
- Attempt purchase
- Verify correct iOS product is used

### Debug Logs
The implementation includes detailed logging:
- `✅ Found lifetime offering by identifier: lifetime`
- `📦 Available package: lifetime - one_time_fee`
- `✅ Selected lifetime package: lifetime - $9.99`
- `   Platform: Android, Product ID: one_time_fee`

## Benefits

### 1. **Multi-Platform Support**
- Single codebase handles both platforms
- RevenueCat automatically selects correct product

### 2. **Flexibility**
- Different pricing for different platforms (if needed)
- Different product IDs for different stores
- Easy to add more products/packages

### 3. **Centralized Management**
- All offering configuration in RevenueCat Dashboard
- No code changes needed to update products
- Easy A/B testing with multiple offerings

### 4. **Backwards Compatibility**
- Fallback to direct product purchase if offerings not configured
- Legacy code still works

## Updating Product IDs

If you need to use different product IDs for each platform:

### In RevenueCat Dashboard:
1. Update Android product ID in Products section
2. Update iOS product ID in Products section
3. Update the offering to reference the new products

### In Code (if needed):
Update the constant in `revenuecat_service.dart`:
```dart
// For Android
static const String oneTimePurchaseIdAndroid = 'lifetime_android';

// For iOS
static const String oneTimePurchaseIdIOS = 'lifetime_ios';
```

But with offerings, you typically don't need separate constants since RevenueCat handles it.

## Troubleshooting

### "No lifetime package found"
- Verify offering is created in RevenueCat Dashboard
- Check offering identifier matches: `lifetime`
- Ensure products are attached to the offering
- Verify products are created for both platforms

### "Product not found"
- Check product IDs match between stores and RevenueCat
- Ensure products are approved in Play Store / App Store
- Wait for RevenueCat to sync (can take a few minutes)

### Different prices showing
- Verify products have prices set in respective stores
- Check RevenueCat product configuration
- Clear app data and reload offerings

### Purchase not working
- Check entitlement configuration
- Verify products are attached to `premium` entitlement
- Test with test user accounts
- Check sandbox environment is properly configured

## Best Practices

1. **Always use offerings** for new implementations
2. **Set descriptive offering identifiers** (e.g., `lifetime`, `monthly`, `annual`)
3. **Use package types** (`PackageType.lifetime`, `PackageType.monthly`, etc.)
4. **Test on both platforms** before release
5. **Monitor logs** during testing to verify correct products are loaded
6. **Keep fallbacks** for backwards compatibility

## Migration Checklist

- [x] Updated `RevenueCatService` with offering methods
- [x] Added `getLifetimePackage()` method
- [x] Added `purchaseLifetime()` method with offering support
- [x] Updated `SubscriptionsController` to use packages
- [x] Added `lifetimePackage` observable
- [x] Updated `loadLifetimePackage()` with fallback
- [x] Updated `purchaseLifetime()` with multi-tier fallback
- [x] Added detailed logging for debugging
- [ ] Create offerings in RevenueCat Dashboard
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Verify both platforms use correct products
- [ ] Test purchase flow end-to-end

## References

- [RevenueCat Offerings Documentation](https://docs.revenuecat.com/docs/entitlements)
- [RevenueCat Packages Documentation](https://docs.revenuecat.com/docs/offerings)
- [Flutter SDK Documentation](https://docs.revenuecat.com/docs/flutter)
