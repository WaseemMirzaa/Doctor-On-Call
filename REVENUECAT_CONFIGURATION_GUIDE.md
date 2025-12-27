# RevenueCat Configuration Guide

## 📋 Current Status

**iOS API Key:** ✅ Configured (`appl_SfXmqqesrJRUNocKMMTqjbcyHjV`)  
**Android API Key:** ⚠️ Placeholder (needs to be replaced)  
**Product ID:** `dr_oncall_lifetime_999`  
**Entitlement ID:** `premium`  
**Price:** €9.99 (one-time purchase)

---

## 🔧 Step 1: Get Your Android API Key

1. **Go to RevenueCat Dashboard:**
   - Visit: https://app.revenuecat.com/
   - Sign in with your account

2. **Navigate to API Keys:**
   - Click on your project: **Dr On Call**
   - Go to **Settings** → **API Keys**

3. **Copy Android API Key:**
   - Find the **Google Play** section
   - Copy the API key (starts with `goog_`)
   - It should look like: `goog_XxXxXxXxXxXxXxXxXxXxXxXxXx`

4. **Update the Code:**
   - Open: `lib/app/services/revenuecat_service.dart`
   - Replace line 8-9:
   ```dart
   static const String _apiKeyAndroid = 'YOUR_ACTUAL_ANDROID_API_KEY_HERE';
   ```

---

## 🛍️ Step 2: Configure Products in RevenueCat Dashboard

### Create the Product:

1. **Go to Products:**
   - In RevenueCat Dashboard, click **Products**
   - Click **+ New** to create a new product

2. **Product Configuration:**
   ```
   Product Identifier: dr_oncall_lifetime_999
   Type: Non-consumable (one-time purchase)
   Description: Dr On Call Lifetime Access
   ```

3. **Link to Store Products:**
   - You need to create the product in both stores first
   - Then link them in RevenueCat

---

## 📱 Step 3: Configure Google Play Console Product

### Create In-App Product:

1. **Open Google Play Console:**
   - Go to: https://play.google.com/console
   - Select your app: **Dr On Call**

2. **Navigate to In-App Products:**
   - Left sidebar → **Monetize** → **In-app products**
   - Click **Create product**

3. **Product Details:**
   ```
   Product ID: dr_oncall_lifetime_999
   Name: Lifetime Access
   Description: Get lifetime access to all features of Dr On Call
   Status: Active
   Price: €9.99
   ```

4. **Save and Activate:**
   - Click **Save**
   - Click **Activate**

---

## 🍎 Step 4: Configure App Store Connect Product

### Create In-App Purchase:

1. **Open App Store Connect:**
   - Go to: https://appstoreconnect.apple.com/
   - Select your app: **Dr On Call**

2. **Navigate to In-App Purchases:**
   - Click **Features** → **In-App Purchases**
   - Click **+** to create new

3. **Select Type:**
   - Choose **Non-Consumable**

4. **Product Details:**
   ```
   Reference Name: Lifetime Access
   Product ID: dr_oncall_lifetime_999
   ```

5. **Pricing:**
   - Click **Add Pricing**
   - Select **€9.99** (Tier 10)
   - Save

6. **Localization:**
   - Add at least one localization (English)
   ```
   Display Name: Lifetime Access
   Description: Get lifetime access to all emergency conditions, scoring tools, and NEWS2 calculator. One-time payment, no recurring fees.
   ```

7. **Screenshot:**
   - Upload a screenshot showing the feature
   - This is required for review

8. **Submit for Review:**
   - Click **Submit**

---

## 🔗 Step 5: Link Products in RevenueCat

1. **Go to RevenueCat Products:**
   - Dashboard → **Products**
   - Find your product: `dr_oncall_lifetime_999`

2. **Add App Store Product:**
   - Click **+ Add App Store Product ID**
   - Enter: `dr_oncall_lifetime_999`
   - Save

3. **Add Google Play Product:**
   - Click **+ Add Google Play Product ID**
   - Enter: `dr_oncall_lifetime_999`
   - Save

---

## 🎯 Step 6: Configure Entitlements

### Create Entitlement:

1. **Go to Entitlements:**
   - Dashboard → **Entitlements**
   - Click **+ New**

2. **Entitlement Configuration:**
   ```
   Identifier: premium
   Display Name: Premium Access
   Description: Full access to all features
   ```

3. **Attach Products:**
   - Click on the `premium` entitlement
   - Click **Attach Products**
   - Select `dr_oncall_lifetime_999`
   - Save

---

## 📦 Step 7: Create Offering (Optional but Recommended)

### Create Default Offering:

1. **Go to Offerings:**
   - Dashboard → **Offerings**
   - Click **+ New**

2. **Offering Configuration:**
   ```
   Identifier: default
   Description: Default offering for Dr On Call
   ```

3. **Add Package:**
   - Click **+ Add Package**
   ```
   Identifier: lifetime
   Product: dr_oncall_lifetime_999
   ```

4. **Set as Current:**
   - Toggle **Current** to ON

---

## ✅ Step 8: Testing

### Test on iOS:

1. **Create Sandbox Tester:**
   - App Store Connect → **Users and Access** → **Sandbox Testers**
   - Create a test account

2. **Sign Out of App Store:**
   - On your iOS device: Settings → App Store → Sign Out

3. **Run the App:**
   ```bash
   flutter run
   ```

4. **Test Purchase:**
   - Go to Subscriptions screen
   - Tap "Get Lifetime Access"
   - Sign in with sandbox tester account
   - Complete purchase

### Test on Android:

1. **Add License Testers:**
   - Google Play Console → **Setup** → **License testing**
   - Add your Gmail account

2. **Install Internal Test Build:**
   - Upload AAB to internal testing
   - Install on device

3. **Test Purchase:**
   - Go to Subscriptions screen
   - Tap "Get Lifetime Access"
   - Complete test purchase

---

## 🔍 Step 9: Verify Configuration

### Check RevenueCat Dashboard:

1. **Customer View:**
   - Dashboard → **Customers**
   - You should see test purchases appear

2. **Charts:**
   - Dashboard → **Charts**
   - Verify events are being tracked

### Check App Logs:

Look for these messages in the console:
```
✅ RevenueCat initialized successfully
✅ Loaded lifetime product: €9.99
Premium status: false (before purchase)
✅ Purchase successful
Premium status: true (after purchase)
```

---

## 📝 Important Notes

1. **Product IDs Must Match:**
   - RevenueCat: `dr_oncall_lifetime_999`
   - Google Play: `dr_oncall_lifetime_999`
   - App Store: `dr_oncall_lifetime_999`

2. **Entitlement ID Must Match:**
   - Code: `premium`
   - RevenueCat Dashboard: `premium`

3. **Testing vs Production:**
   - Sandbox purchases don't charge real money
   - Always test before releasing to production

4. **Price Localization:**
   - €9.99 will be converted to local currency automatically
   - Google Play and App Store handle this

---

## 🚨 Troubleshooting

### "Product not found" Error:
- Verify product is created in both stores
- Check product ID matches exactly
- Wait 2-4 hours after creating product in stores

### "Unable to connect to iTunes Store" (iOS):
- Sign out of App Store on device
- Use sandbox tester account
- Check internet connection

### "Item not available for purchase" (Android):
- Ensure product is activated in Play Console
- Check app is signed with release key
- Verify license tester is added

### RevenueCat not initializing:
- Check API keys are correct
- Verify internet connection
- Check console for error messages

---

## 📞 Support Resources

- **RevenueCat Docs:** https://docs.revenuecat.com/
- **RevenueCat Support:** https://community.revenuecat.com/
- **Google Play Billing:** https://developer.android.com/google/play/billing
- **App Store In-App Purchase:** https://developer.apple.com/in-app-purchase/

---

**Next Step:** Get your Android API key and update the code!

