# Google Play Console - Beta Testing Upload Guide

## 📦 Build Information

**App Name:** Dr On Call  
**Package Name:** com.codetivelab.dr_on_call  
**Version:** 1.0.15 (Build 15)  
**AAB File Location:** `build/app/outputs/bundle/release/app-release.aab`  
**AAB File Size:** 34.3 MB  
**Build Date:** October 29, 2025

---

## 🔐 Keystore Information

**⚠️ IMPORTANT - SAVE THIS INFORMATION SECURELY!**

```
Keystore File: android/app/upload-keystore.jks
Key Alias: upload
Store Password: droncall2024
Key Password: droncall2024
Validity: 10,000 days
Algorithm: RSA 2048-bit
```

**🔴 CRITICAL:** 
- Keep the keystore file (`upload-keystore.jks`) and passwords in a secure location
- If you lose the keystore, you cannot update the app on Google Play
- Consider backing up the keystore to a secure cloud storage
- Never commit the keystore to Git (already added to .gitignore)

---

## 📋 Pre-Upload Checklist

Before uploading to Google Play Console, ensure you have:

- [ ] Google Play Developer Account (one-time $25 fee)
- [ ] App created in Google Play Console
- [ ] Privacy Policy URL (required for apps with user data)
- [ ] App screenshots (minimum 2 screenshots)
- [ ] Feature graphic (1024 x 500 px)
- [ ] App icon (512 x 512 px)
- [ ] Short description (max 80 characters)
- [ ] Full description (max 4000 characters)
- [ ] Content rating questionnaire completed
- [ ] Target audience selected

---

## 🚀 Step-by-Step Upload Process

### Step 1: Access Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your Google account
3. Select your app or create a new app

### Step 2: Create a New Release (Beta Testing)

1. In the left sidebar, click **Testing** → **Internal testing** or **Closed testing**
2. Click **Create new release**
3. Click **Upload** and select the AAB file:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

### Step 3: Release Details

1. **Release name:** Enter a name (e.g., "Beta v1.0.15")
2. **Release notes:** Add what's new in this version:
   ```
   - RevenueCat integration for in-app purchases
   - €9.99 lifetime subscription option
   - NEWS2 Calculator with AVPU+C scoring
   - Oxygen Therapy Type selection
   - Samsung device optimizations
   - Bug fixes and performance improvements
   ```

### Step 4: Review and Rollout

1. Review the release summary
2. Click **Review release**
3. If everything looks good, click **Start rollout to [Testing Track]**
4. Confirm the rollout

### Step 5: Set Up Testers (for Closed Testing)

1. Go to **Testing** → **Closed testing** → **Testers**
2. Create a new list or use an existing one
3. Add tester email addresses
4. Save the changes

---

## 📱 Testing the Beta Build

### For Internal Testing:
- Testers will receive an email invitation
- They can install the app via the Google Play Store
- Feedback can be provided through the Play Console

### For Closed Testing:
- Share the opt-in URL with testers
- Testers must opt-in before they can download
- Opt-in URL format: `https://play.google.com/apps/testing/com.codetivelab.dr_on_call`

---

## 🔧 App Configuration Requirements

### 1. App Content

**Privacy Policy:**
- Required for apps that handle user data
- Must be a publicly accessible URL
- Should explain data collection and usage

**Data Safety:**
- Complete the Data Safety form in Play Console
- Declare what data you collect (if any)
- Explain how data is used and shared

### 2. Content Rating

1. Go to **Policy** → **App content** → **Content rating**
2. Complete the questionnaire
3. Submit for rating
4. Apply the rating to your app

### 3. Target Audience

1. Go to **Policy** → **App content** → **Target audience**
2. Select age groups
3. Save the selection

### 4. Store Listing

**Required Assets:**

1. **App Icon** (512 x 512 px, PNG, 32-bit)
2. **Feature Graphic** (1024 x 500 px, JPG or PNG)
3. **Screenshots** (minimum 2, recommended 4-8)
   - Phone: 320-3840 px on the long side
   - Recommended: 1080 x 1920 px or 1440 x 2560 px

**Text Content:**

1. **App Name:** Dr On Call
2. **Short Description:** (max 80 characters)
   ```
   Medical emergency reference with NEWS2 calculator and clinical guidelines
   ```
3. **Full Description:** (max 4000 characters)
   ```
   Dr On Call is a comprehensive medical emergency reference app designed for healthcare professionals.

   KEY FEATURES:
   • NEWS2 Calculator with AVPU+C scoring
   • Oxygen Therapy Type selection
   • Clinical diagnosis reference
   • Biochemical emergency guidelines
   • Search functionality with filters
   • Favorites and recent items
   • Offline access to critical information

   SUBSCRIPTION:
   • Free trial with basic features
   • Lifetime access for €9.99 (one-time payment)
   • Access to all emergency conditions
   • All scoring tools included
   • No recurring fees

   Perfect for doctors, nurses, paramedics, and medical students who need quick access to emergency protocols and clinical guidelines.
   ```

---

## 🔄 Updating the App

### To Release a New Version:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.16+16  # Increment both version name and code
   ```

2. Build new AAB:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Google Play Console following the same steps above

---

## ⚠️ Common Issues and Solutions

### Issue 1: "App not signed"
**Solution:** Ensure the keystore is properly configured in `android/key.properties`

### Issue 2: "Version code already exists"
**Solution:** Increment the version code in `pubspec.yaml`

### Issue 3: "Missing required assets"
**Solution:** Complete all required fields in Store Listing

### Issue 4: "Content rating required"
**Solution:** Complete the content rating questionnaire

---

## 📊 Post-Upload Monitoring

### Track Your Beta:

1. **Pre-launch report:** Check for crashes and issues
2. **Feedback:** Monitor tester feedback
3. **Crashes & ANRs:** Review crash reports
4. **Statistics:** Track installs and uninstalls

### Before Production Release:

- [ ] All critical bugs fixed
- [ ] Positive feedback from beta testers
- [ ] No crashes in pre-launch report
- [ ] All store listing assets ready
- [ ] Privacy policy published
- [ ] Content rating approved

---

## 🎯 Next Steps After Beta

1. **Gather Feedback:** Collect feedback from beta testers
2. **Fix Issues:** Address any bugs or issues reported
3. **Update Build:** Create new version if needed
4. **Promote to Production:** When ready, promote the beta to production
5. **Monitor Reviews:** Keep track of user reviews and ratings

---

## 📞 Support Resources

- **Google Play Console Help:** https://support.google.com/googleplay/android-developer
- **App Signing:** https://developer.android.com/studio/publish/app-signing
- **Release Checklist:** https://developer.android.com/distribute/best-practices/launch/launch-checklist

---

## ✅ Quick Command Reference

```bash
# Build release AAB
flutter build appbundle --release

# Build release APK (for testing)
flutter build apk --release

# Check AAB file
ls -lh build/app/outputs/bundle/release/app-release.aab

# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze
```

---

**Good luck with your beta testing! 🚀**

