import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage subscription status, free trial, and content access limits
class SubscriptionManagerService {
  // SharedPreferences keys
  static const String _keyIsPremium = 'is_premium_user';
  static const String _keyTrialStartDate = 'trial_start_date';
  static const String _keyContentViewCount = 'content_view_count';
  static const String _keyCurrentPlan = 'current_plan';

  // Constants
  static const int freeTrialDays = 7;
  static const int maxFreeViews = 3;

  /// Check if user is a premium subscriber
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  /// Set premium status
  static Future<void> setPremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, isPremium);

    if (isPremium) {
      // Set current plan to "Lifetime Access"
      await prefs.setString(_keyCurrentPlan, 'Lifetime Access');
    } else {
      // Set current plan to "Free Trial"
      await prefs.setString(_keyCurrentPlan, 'Free Trial');
    }

    print('✅ Premium status set to: $isPremium');
  }

  /// Get current plan name
  static Future<String> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentPlan) ?? 'Free Trial';
  }

  /// Expire the trial immediately (for testing purposes)
  static Future<void> expireTrial() async {
    final prefs = await SharedPreferences.getInstance();
    // Set trial start date to 8 days ago
    final expiredDate =
        DateTime.now().subtract(Duration(days: freeTrialDays + 1));
    await prefs.setString(_keyTrialStartDate, expiredDate.toIso8601String());
    print('⚠️ Trial expired manually for testing');
  }

  /// Initialize trial start date (call this on first app launch or login)
  static Future<void> initializeTrialIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartDate = prefs.getString(_keyTrialStartDate);

    if (trialStartDate == null) {
      // First time user - start trial
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_keyTrialStartDate, now);
      await prefs.setInt(_keyContentViewCount, 0);
      await prefs.setString(_keyCurrentPlan, 'Free Trial');
      print('✅ Free trial started: $now');
    }
  }

  /// Check if user is still in free trial period
  static Future<bool> isInFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartDateStr = prefs.getString(_keyTrialStartDate);

    if (trialStartDateStr == null) {
      // No trial started yet
      print('⚠️ No trial start date found');
      return false;
    }

    final trialStartDate = DateTime.parse(trialStartDateStr);
    final now = DateTime.now();
    final daysSinceStart = now.difference(trialStartDate).inDays;
    final inTrial = daysSinceStart < freeTrialDays;

    print(
        '📅 Trial check: Started=$trialStartDateStr, DaysSince=$daysSinceStart, InTrial=$inTrial');
    return inTrial;
  }

  /// Get remaining trial days
  static Future<int> getRemainingTrialDays() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartDateStr = prefs.getString(_keyTrialStartDate);

    if (trialStartDateStr == null) {
      return freeTrialDays;
    }

    final trialStartDate = DateTime.parse(trialStartDateStr);
    final now = DateTime.now();
    final daysSinceStart = now.difference(trialStartDate).inDays;
    final remaining = freeTrialDays - daysSinceStart;

    return remaining > 0 ? remaining : 0;
  }

  /// Get current content view count
  static Future<int> getContentViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyContentViewCount) ?? 0;
  }

  /// Increment content view count
  static Future<void> incrementViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyContentViewCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyContentViewCount, newCount);

    // Show different emoji based on remaining views
    final remaining = maxFreeViews - newCount;
    String emoji = '📊';
    if (remaining == 0) {
      emoji = '🚫'; // No views left
    } else if (remaining == 1) {
      emoji = '⚠️'; // Last view warning
    } else if (remaining == 2) {
      emoji = '⏰'; // Running low
    }

    print(
        '$emoji View count updated: $currentCount → $newCount (Remaining: $remaining)');
  }

  /// Check if user can access content (detail pages)
  /// Returns true if user can access, false if blocked
  static Future<bool> canAccessContent() async {
    // Premium users have unlimited access
    final premium = await isPremiumUser();
    if (premium) {
      print('✅ Access granted: Premium user');
      return true;
    }

    // Check if still in free trial
    final inTrial = await isInFreeTrial();
    if (inTrial) {
      print('✅ Access granted: In free trial');
      return true;
    }

    // Trial expired - check view count
    final viewCount = await getContentViewCount();
    final canAccess = viewCount < maxFreeViews;
    print(
        '🔍 Trial expired. ViewCount=$viewCount, MaxViews=$maxFreeViews, CanAccess=$canAccess');
    return canAccess;
  }

  /// Get remaining free views
  static Future<int> getRemainingFreeViews() async {
    if (await isPremiumUser()) {
      return -1; // Unlimited
    }

    if (await isInFreeTrial()) {
      return -1; // Unlimited during trial
    }

    final viewCount = await getContentViewCount();
    final remaining = maxFreeViews - viewCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Get access status message for UI
  static Future<String> getAccessStatusMessage() async {
    if (await isPremiumUser()) {
      return 'Premium - Unlimited Access';
    }

    if (await isInFreeTrial()) {
      final remainingDays = await getRemainingTrialDays();
      return 'Free Trial - $remainingDays days remaining';
    }

    final remainingViews = await getRemainingFreeViews();
    if (remainingViews > 0) {
      return 'Free - $remainingViews views remaining';
    }

    return 'Trial Expired - Subscribe for Access';
  }

  /// Reset trial and view count (for testing purposes only)
  static Future<void> resetTrialAndViews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTrialStartDate);
    await prefs.remove(_keyContentViewCount);
    await prefs.remove(_keyIsPremium);
    await prefs.remove(_keyCurrentPlan);
    print('🔄 Trial and views reset');
  }
}
