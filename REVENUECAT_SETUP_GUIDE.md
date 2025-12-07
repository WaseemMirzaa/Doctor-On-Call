# RevenueCat Setup Guide for Dr On Call

## 📋 Overview
This guide will help you set up RevenueCat for in-app purchases in the Dr On Call app with a **€9.99 one-time lifetime purchase**.

---

## 🔑 Product IDs and SKUs

### **Product Information:**
- **Product ID**: `dr_oncall_lifetime_999`
- **Price**: €9.99 EUR
- **Type**: Non-consumable (One-time purchase)
- **Description**: Lifetime access to all premium features

### **Entitlement:**
- **Entitlement ID**: `premium`
- **Description**: Premium access to all features

---

## 🚀 Step 1: RevenueCat Dashboard Setup

### 1.1 Create RevenueCat Account
1. Go to [https://www.revenuecat.com/](https://www.revenuecat.com/)
2. Sign up for a free account
3. Create a new project named "Dr On Call"

### 1.2 Get API Keys
1. In RevenueCat Dashboard, go to **Settings** → **API Keys**
2. Copy your **Public SDK Keys**:
   - **Android Public SDK Key** (starts with `goog_`)
   - **iOS Public SDK Key** (starts with `appl_`)

### 1.3 Update API Keys in Code
Open `lib/app/services/revenuecat_service.dart` and replace:
```dart
static const String _apiKeyAndroid = 'YOUR_ANDROID_API_KEY_HERE';
static const String _apiKeyIOS = 'YOUR_IOS_API_KEY_HERE';
```

With your actual keys:
```dart
static const String _apiKeyAndroid = 'goog_xxxxxxxxxxxxxxxxx';
static const String _apiKeyIOS = 'appl_xxxxxxxxxxxxxxxxx';
```

---

## 📱 Step 2: Google Play Console Setup (Android)

### 2.1 Create In-App Product
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app "Dr On Call"
3. Navigate to **Monetize** → **In-app products**
4. Click **Create product**

### 2.2 Product Configuration
Fill in the following details:

| Field | Value |
|-------|-------|
| **Product ID** | `dr_oncall_lifetime_999` |
| **Name** | Dr On Call - Lifetime Access |
| **Description** | Get lifetime access to all premium features of Dr On Call with a one-time payment. |
| **Status** | Active |
| **Price** | €9.99 EUR |

### 2.3 Set Pricing
1. Click **Set price**
2. Select **€9.99** as base price
3. Google will auto-convert to other currencies
4. Click **Apply prices**

### 2.4 Activate Product
1. Review all details
2. Click **Activate** to make the product live

---

## 🍎 Step 3: App Store Connect Setup (iOS)

### 3.1 Create In-App Purchase
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app "Dr On Call"
3. Go to **Features** → **In-App Purchases**
4. Click the **+** button to create a new in-app purchase

### 3.2 Select Type
- Choose **Non-Consumable** (one-time purchase)

### 3.3 Product Configuration
Fill in the following details:

| Field | Value |
|-------|-------|
| **Reference Name** | Dr On Call Lifetime Access |
| **Product ID** | `dr_oncall_lifetime_999` |

### 3.4 Pricing
1. Click **Add Pricing**
2. Select **€9.99 EUR** as the price
3. Apple will auto-convert to other currencies
4. Click **Next**

### 3.5 Localization
Add at least one localization (English):

| Field | Value |
|-------|-------|
| **Display Name** | Lifetime Access |
| **Description** | Get lifetime access to all premium features of Dr On Call with a one-time payment. No recurring fees. |

### 3.6 Review Information
1. Upload a screenshot (optional but recommended)
2. Click **Save**

### 3.7 Submit for Review
1. Click **Submit for Review**
2. Wait for Apple approval (usually 24-48 hours)

---

## 🔗 Step 4: Connect Stores to RevenueCat

### 4.1 Connect Google Play
1. In RevenueCat Dashboard, go to **Project Settings** → **Integrations**
2. Click **Google Play**
3. Follow the instructions to:
   - Create a service account in Google Cloud Console
   - Grant necessary permissions
   - Upload the JSON key file to RevenueCat
4. Click **Save**

### 4.2 Connect App Store
1. In RevenueCat Dashboard, go to **Project Settings** → **Integrations**
2. Click **App Store Connect**
3. Follow the instructions to:
   - Generate an App Store Connect API Key
   - Enter the Issuer ID, Key ID, and upload the .p8 file
4. Click **Save**

---

## 🎯 Step 5: Configure Products in RevenueCat

### 5.1 Create Entitlement
1. In RevenueCat Dashboard, go to **Entitlements**
2. Click **+ New**
3. Enter:
   - **Identifier**: `premium`
   - **Display Name**: Premium Access
4. Click **Save**

### 5.2 Add Product
1. Go to **Products** in RevenueCat Dashboard
2. Click **+ New**
3. Enter:
   - **Identifier**: `dr_oncall_lifetime_999`
   - **Store**: Select both Google Play and App Store
   - **Product ID (Google)**: `dr_oncall_lifetime_999`
   - **Product ID (Apple)**: `dr_oncall_lifetime_999`
4. Click **Save**

### 5.3 Attach Product to Entitlement
1. Go to **Entitlements**
2. Click on **premium**
3. Click **Attach Products**
4. Select `dr_oncall_lifetime_999`
5. Click **Save**

---

## 🧪 Step 6: Testing

### 6.1 Android Testing
1. Add test users in Google Play Console:
   - Go to **Setup** → **License testing**
   - Add test Gmail accounts
2. Install the app on a test device
3. Sign in with the test account
4. Test the purchase flow

### 6.2 iOS Testing (Sandbox)
1. Create a Sandbox Tester in App Store Connect:
   - Go to **Users and Access** → **Sandbox Testers**
   - Click **+** to add a new tester
   - Use a unique email (doesn't need to be real)
2. On your iOS device:
   - Go to **Settings** → **App Store** → **Sandbox Account**
   - Sign in with the sandbox tester account
3. Install the app and test the purchase

### 6.3 Test Restore Purchases
1. Make a test purchase
2. Uninstall and reinstall the app
3. Tap "Restore Purchases" button
4. Verify that premium access is restored

---

## 📊 Step 7: Verify Integration

### 7.1 Check RevenueCat Dashboard
1. Go to **Overview** in RevenueCat Dashboard
2. Make a test purchase
3. Verify that the transaction appears in the dashboard
4. Check that the user has the `premium` entitlement

### 7.2 Check Logs
Monitor the app logs for:
- ✅ RevenueCat initialized successfully
- ✅ Loaded offerings
- ✅ Purchase successful
- ❌ Any error messages

---

## 🔐 Security Best Practices

1. **Never commit API keys to version control**
   - Use environment variables or secure storage
   - Add `revenuecat_service.dart` to `.gitignore` if needed

2. **Enable Receipt Validation**
   - RevenueCat automatically validates receipts
   - Ensure integrations are properly configured

3. **Monitor for Fraud**
   - Check RevenueCat Dashboard regularly
   - Set up webhooks for suspicious activity

---

## 📝 Product Summary

### **SKU/Product IDs to Configure:**

#### Google Play Console:
- **Product ID**: `dr_oncall_lifetime_999`
- **Type**: In-app product (non-consumable)
- **Price**: €9.99

#### App Store Connect:
- **Product ID**: `dr_oncall_lifetime_999`
- **Type**: Non-Consumable
- **Price**: €9.99

#### RevenueCat Dashboard:
- **Product Identifier**: `dr_oncall_lifetime_999`
- **Entitlement ID**: `premium`

---

## 🆘 Troubleshooting

### Issue: "No products available"
**Solution**: 
- Verify product IDs match exactly in all platforms
- Check that products are active in both stores
- Ensure RevenueCat integrations are connected

### Issue: "Purchase failed"
**Solution**:
- Check that test accounts are properly configured
- Verify billing is enabled in Google Play Console
- Ensure App Store Connect agreements are signed

### Issue: "Restore purchases not working"
**Solution**:
- Verify the user is signed in with the same account
- Check that RevenueCat user ID is set correctly
- Ensure products are non-consumable type

---

## 📞 Support

- **RevenueCat Docs**: https://docs.revenuecat.com/
- **RevenueCat Support**: https://community.revenuecat.com/
- **Google Play Support**: https://support.google.com/googleplay/android-developer
- **App Store Support**: https://developer.apple.com/support/

---

## ✅ Checklist

Before going live, ensure:

- [ ] RevenueCat account created and configured
- [ ] API keys added to the app
- [ ] Product created in Google Play Console (€9.99)
- [ ] Product created in App Store Connect (€9.99)
- [ ] Both stores connected to RevenueCat
- [ ] Entitlement created in RevenueCat
- [ ] Product attached to entitlement
- [ ] Tested purchase flow on Android
- [ ] Tested purchase flow on iOS
- [ ] Tested restore purchases
- [ ] Verified transactions in RevenueCat Dashboard
- [ ] App Store in-app purchase approved by Apple

---

## 🎉 You're All Set!

Once all steps are completed, your app will be ready to accept €9.99 lifetime purchases on both Android and iOS!

