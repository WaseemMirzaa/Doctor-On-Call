import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage subscription status, free trial, and content access limits
class SubscriptionManagerService {
  // SharedPreferences keys
  static const String _keyIsPremium = 'is_premium_user';
  static const String _keyTrialStartDate = 'trial_start_date';
  static const String _keyContentViewCount = 'content_view_count';
  static const String _keyCurrentPlan = 'current_plan';
  static const String _keyLastAccessDate = 'last_access_date';
  static const String _keyDailyAccessCount = 'daily_access_count';

  // Constants
  static const int freeTrialDays = 7;
  static const int maxFreeViews = 3; // Legacy - kept for compatibility
  static const int dailyAccessLimit = 3; // New: 3 items per day during trial

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
      print('🔄 Daily access count reset for new day');
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

    final remaining = dailyAccessLimit - newCount;
    print(
        '📊 Daily access: $currentCount → $newCount (Remaining today: $remaining)');
  }

  /// Get remaining daily accesses
  static Future<int> getRemainingDailyAccesses() async {
    if (await isPremiumUser()) {
      return -1; // Unlimited
    }

    if (!await isInFreeTrial()) {
      return 0; // Trial expired, no access
    }

    final dailyCount = await getDailyAccessCount();
    final remaining = dailyAccessLimit - dailyCount;
    return remaining > 0 ? remaining : 0;
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
    if (!inTrial) {
      print('🚫 Access denied: Trial expired');
      return false;
    }

    // In trial - check daily limit
    final dailyCount = await getDailyAccessCount();
    final canAccess = dailyCount < dailyAccessLimit;
    print(
        '🔍 Trial active. Daily count=$dailyCount, Limit=$dailyAccessLimit, CanAccess=$canAccess');
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
      final remainingToday = await getRemainingDailyAccesses();
      return 'Trial: $remainingDays days • $remainingToday/$dailyAccessLimit items today';
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
    await prefs.remove(_keyLastAccessDate);
    await prefs.remove(_keyDailyAccessCount);
    print('🔄 Trial and views reset');
  }

  /// Debug: Print current subscription status
  static Future<void> printCurrentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 SUBSCRIPTION STATUS DEBUG');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Is Premium: ${await isPremiumUser()}');
    print('Trial Start: ${prefs.getString(_keyTrialStartDate)}');
    print('In Trial: ${await isInFreeTrial()}');
    print('Remaining Trial Days: ${await getRemainingTrialDays()}');
    print('Last Access Date: ${prefs.getString(_keyLastAccessDate)}');
    print('Daily Access Count: ${await getDailyAccessCount()}');
    print('Remaining Today: ${await getRemainingDailyAccesses()}');
    print('Can Access: ${await canAccessContent()}');
    print('Status Message: ${await getAccessStatusMessage()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
