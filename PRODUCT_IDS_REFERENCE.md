# Product IDs Quick Reference

## 🎯 Product Configuration

### **Main Product**
```
Product ID: dr_oncall_lifetime_999
Price: €9.99 EUR
Type: Non-Consumable (One-time purchase)
```

### **RevenueCat Configuration**
```
Entitlement ID: premium
Product Identifier: dr_oncall_lifetime_999
```

---

## 📱 Google Play Console

### Create In-App Product:
1. Go to: **Monetize** → **In-app products** → **Create product**

2. Fill in:
   ```
   Product ID: dr_oncall_lifetime_999
   Name: Dr On Call - Lifetime Access
   Description: Get lifetime access to all premium features
   Price: €9.99 EUR
   Status: Active
   ```

---

## 🍎 App Store Connect

### Create In-App Purchase:
1. Go to: **Features** → **In-App Purchases** → **+**

2. Select: **Non-Consumable**

3. Fill in:
   ```
   Reference Name: Dr On Call Lifetime Access
   Product ID: dr_oncall_lifetime_999
   Price: €9.99 EUR
   
   Display Name: Lifetime Access
   Description: Get lifetime access to all premium features
   ```

---

## 🔑 API Keys Location

Update these in `lib/app/services/revenuecat_service.dart`:

```dart
// Line 6-7
static const String _apiKeyAndroid = 'goog_YOUR_KEY_HERE';
static const String _apiKeyIOS = 'appl_YOUR_KEY_HERE';
```

Get your keys from:
**RevenueCat Dashboard** → **Settings** → **API Keys**

---

## 🧪 Test Accounts

### Android (Google Play):
- Add test emails in: **Setup** → **License testing**

### iOS (App Store):
- Create sandbox tester in: **Users and Access** → **Sandbox Testers**

---

## ✅ Quick Checklist

```
□ RevenueCat account created
□ API keys copied to code
□ Google Play product created (dr_oncall_lifetime_999)
□ App Store product created (dr_oncall_lifetime_999)
□ RevenueCat entitlement created (premium)
□ Product linked to entitlement
□ Tested on Android
□ Tested on iOS
□ Restore purchases tested
```

---

## 🔗 Important Links

- RevenueCat Dashboard: https://app.revenuecat.com/
- Google Play Console: https://play.google.com/console
- App Store Connect: https://appstoreconnect.apple.com/
- RevenueCat Docs: https://docs.revenuecat.com/

---

## 📞 Need Help?

See the full setup guide in `REVENUECAT_SETUP_GUIDE.md`

