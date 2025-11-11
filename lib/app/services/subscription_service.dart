// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// /// Service to manage subscription and trial access
// class SubscriptionService extends GetxService {
//   final GetStorage _storage = GetStorage();

//   // Storage keys
//   static const String _keyTrialStartDate = 'trial_start_date';
//   static const String _keyDailyAccessCount = 'daily_access_count';
//   static const String _keyLastAccessDate = 'last_access_date';
//   static const String _keyHasSubscription = 'has_subscription';

//   // Trial configuration
//   static const int trialDurationDays = 7;
//   static const int dailyAccessLimit = 3;

//   /// Initialize the service
//   Future<SubscriptionService> init() async {
//     // Start trial if it hasn't been started yet
//     if (_storage.read(_keyTrialStartDate) == null) {
//       await startTrial();
//     }
//     return this;
//   }

//   /// Start the trial period
//   Future<void> startTrial() async {
//     await _storage.write(_keyTrialStartDate, DateTime.now().toIso8601String());
//     await _storage.write(_keyDailyAccessCount, 0);
//     await _storage.write(_keyLastAccessDate, DateTime.now().toIso8601String());
//   }

//   /// Check if user has an active subscription
//   bool hasActiveSubscription() {
//     return _storage.read(_keyHasSubscription) ?? false;
//   }

//   /// Activate subscription
//   Future<void> activateSubscription() async {
//     await _storage.write(_keyHasSubscription, true);
//   }

//   /// Deactivate subscription
//   Future<void> deactivateSubscription() async {
//     await _storage.write(_keyHasSubscription, false);
//   }

//   /// Check if trial is active
//   bool isTrialActive() {
//     if (hasActiveSubscription()) {
//       return false; // Subscription takes precedence
//     }

//     final trialStartDateString = _storage.read(_keyTrialStartDate);
//     if (trialStartDateString == null) {
//       return false;
//     }

//     final trialStartDate = DateTime.parse(trialStartDateString);
//     final daysSinceTrialStart =
//         DateTime.now().difference(trialStartDate).inDays;

//     return daysSinceTrialStart < trialDurationDays;
//   }

//   /// Check if trial has expired
//   bool isTrialExpired() {
//     if (hasActiveSubscription()) {
//       return false;
//     }

//     final trialStartDateString = _storage.read(_keyTrialStartDate);
//     if (trialStartDateString == null) {
//       return false;
//     }

//     final trialStartDate = DateTime.parse(trialStartDateString);
//     final daysSinceTrialStart =
//         DateTime.now().difference(trialStartDate).inDays;

//     return daysSinceTrialStart >= trialDurationDays;
//   }

//   /// Get remaining trial days
//   int getRemainingTrialDays() {
//     if (hasActiveSubscription()) {
//       return 0;
//     }

//     final trialStartDateString = _storage.read(_keyTrialStartDate);
//     if (trialStartDateString == null) {
//       return trialDurationDays;
//     }

//     final trialStartDate = DateTime.parse(trialStartDateString);
//     final daysSinceTrialStart =
//         DateTime.now().difference(trialStartDate).inDays;
//     final remainingDays = trialDurationDays - daysSinceTrialStart;

//     return remainingDays > 0 ? remainingDays : 0;
//   }

//   /// Reset daily access count if it's a new day
//   void _resetDailyAccessIfNeeded() {
//     final lastAccessDateString = _storage.read(_keyLastAccessDate);
//     if (lastAccessDateString == null) {
//       _storage.write(_keyLastAccessDate, DateTime.now().toIso8601String());
//       _storage.write(_keyDailyAccessCount, 0);
//       return;
//     }

//     final lastAccessDate = DateTime.parse(lastAccessDateString);
//     final today = DateTime.now();

//     // Check if it's a new day
//     if (today.year != lastAccessDate.year ||
//         today.month != lastAccessDate.month ||
//         today.day != lastAccessDate.day) {
//       _storage.write(_keyLastAccessDate, today.toIso8601String());
//       _storage.write(_keyDailyAccessCount, 0);
//     }
//   }

//   /// Get current daily access count
//   int getDailyAccessCount() {
//     _resetDailyAccessIfNeeded();
//     return _storage.read(_keyDailyAccessCount) ?? 0;
//   }

//   /// Get remaining daily accesses
//   int getRemainingDailyAccesses() {
//     if (hasActiveSubscription()) {
//       return -1; // Unlimited
//     }

//     final currentCount = getDailyAccessCount();
//     final remaining = dailyAccessLimit - currentCount;
//     return remaining > 0 ? remaining : 0;
//   }

//   /// Check if user can access content
//   bool canAccessContent() {
//     // If user has subscription, allow unlimited access
//     if (hasActiveSubscription()) {
//       return true;
//     }

//     // If trial is expired, deny access
//     if (isTrialExpired()) {
//       return false;
//     }

//     // If trial is active, check daily limit
//     if (isTrialActive()) {
//       return getDailyAccessCount() < dailyAccessLimit;
//     }

//     // Default: deny access
//     return false;
//   }

//   /// Increment access count (call this when user accesses restricted content)
//   Future<void> incrementAccessCount() async {
//     if (hasActiveSubscription()) {
//       return; // Don't count for subscribed users
//     }

//     _resetDailyAccessIfNeeded();
//     final currentCount = getDailyAccessCount();
//     await _storage.write(_keyDailyAccessCount, currentCount + 1);
//   }

//   /// Get access status message
//   String getAccessStatusMessage() {
//     if (hasActiveSubscription()) {
//       return 'Unlimited Access';
//     }

//     if (isTrialExpired()) {
//       return 'Trial Expired - Subscribe to Continue';
//     }

//     if (isTrialActive()) {
//       final remainingDays = getRemainingTrialDays();
//       final remainingAccesses = getRemainingDailyAccesses();
//       return 'Trial: $remainingDays days left • $remainingAccesses/${dailyAccessLimit} items today';
//     }

//     return 'No Access';
//   }

//   /// Clear all subscription data (for testing/reset)
//   Future<void> clearSubscriptionData() async {
//     await _storage.remove(_keyTrialStartDate);
//     await _storage.remove(_keyDailyAccessCount);
//     await _storage.remove(_keyLastAccessDate);
//     await _storage.remove(_keyHasSubscription);
//   }
// }
