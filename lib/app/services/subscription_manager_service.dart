import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage subscription status, free trial, and content access limits
/// Uses SharedPreferences for local caching - RevenueCat handles cloud sync
class SubscriptionManagerService {
  // SharedPreferences keys
  static const String _keyIsPremium = 'is_premium_user';
  static const String _keyTrialStartDate = 'trial_start_date';
  static const String _keyContentViewCount = 'content_view_count';
  static const String _keyCurrentPlan = 'current_plan';
  static const String _keyLastAccessDate = 'last_access_date';
  static const String _keyDailyAccessCount = 'daily_access_count';

  // Constants
  static const int freeTrialDays = 7; // Full unlimited access for 7 days
  static const int dailyAccessLimitAfterTrial =
      3; // 3 items per day AFTER trial expires

  /// Check if user is a premium subscriber
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  /// Set premium status (local cache only - RevenueCat is source of truth)
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
    }
  }

  /// Check if user is still in free trial period
  static Future<bool> isInFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartDateStr = prefs.getString(_keyTrialStartDate);

    if (trialStartDateStr == null) {
      // No trial started yet
      return false;
    }

    final trialStartDate = DateTime.parse(trialStartDateStr);
    final now = DateTime.now();
    final daysSinceStart = now.difference(trialStartDate).inDays;
    final inTrial = daysSinceStart < freeTrialDays;

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

  /// Reset daily access count if it's a new day
  static Future<void> _resetDailyAccessIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccessDateStr = prefs.getString(_keyLastAccessDate);

    if (lastAccessDateStr == null) {
      await prefs.setString(
          _keyLastAccessDate, DateTime.now().toIso8601String());
      await prefs.setInt(_keyDailyAccessCount, 0);
      return;
    }

    final lastAccessDate = DateTime.parse(lastAccessDateStr);
    final now = DateTime.now();

    // Check if it's a new day
    if (now.year != lastAccessDate.year ||
        now.month != lastAccessDate.month ||
        now.day != lastAccessDate.day) {
      await prefs.setString(_keyLastAccessDate, now.toIso8601String());
      await prefs.setInt(_keyDailyAccessCount, 0);
    }
  }

  /// Get current daily access count
  static Future<int> getDailyAccessCount() async {
    await _resetDailyAccessIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyAccessCount) ?? 0;
  }

  /// Increment daily access count
  static Future<void> incrementDailyAccessCount() async {
    await _resetDailyAccessIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyDailyAccessCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyDailyAccessCount, newCount);

    final remaining = dailyAccessLimitAfterTrial - newCount;
  }

  /// Get remaining daily accesses
  static Future<int> getRemainingDailyAccesses() async {
    if (await isPremiumUser()) {
      return -1; // Unlimited
    }

    // During 7-day trial: unlimited access
    if (await isInFreeTrial()) {
      return -1; // Unlimited during trial
    }

    // After trial: 3 per day limit
    final dailyCount = await getDailyAccessCount();
    final remaining = dailyAccessLimitAfterTrial - dailyCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if user can access content (detail pages)
  /// Returns true if user can access, false if blocked
  /// Trial Days 1-7: Unlimited access
  /// After Day 7: 3 items per day limit
  static Future<bool> canAccessContent() async {
    // Premium users have unlimited access
    final premium = await isPremiumUser();
    if (premium) {
      return true;
    }

    // Check if still in free trial (days 1-7)
    final inTrial = await isInFreeTrial();
    if (inTrial) {
      return true; // Unlimited during 7-day trial
    }

    // Trial expired - check daily limit (3 per day)
    final dailyCount = await getDailyAccessCount();
    final canAccess = dailyCount < dailyAccessLimitAfterTrial;
    return canAccess;
  }

  /// Get access status message for UI
  static Future<String> getAccessStatusMessage() async {
    if (await isPremiumUser()) {
      return 'Premium - Unlimited Access';
    }

    if (await isInFreeTrial()) {
      final remainingDays = await getRemainingTrialDays();
      return 'Trial: $remainingDays days left • Unlimited Access';
    }

    // After trial: show daily limit
    final remainingToday = await getRemainingDailyAccesses();
    return 'Trial Ended • $remainingToday/$dailyAccessLimitAfterTrial free today';
  }

  /// Reset trial and view count (for testing purposes only)
  static Future<void> resetTrialAndViews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTrialStartDate);
    await prefs.remove(_keyContentViewCount);
    await prefs.remove(_keyIsPremium);
    await prefs.remove(_keyCurrentPlan);
    await prefs.remove(_keyLastAccessDate);
    await prefs.remove(_keyDailyAccessCount);
  }

  /// Debug: Print current subscription status
  static Future<void> printCurrentStatus() async {
    final prefs = await SharedPreferences.getInstance();
  }
}
