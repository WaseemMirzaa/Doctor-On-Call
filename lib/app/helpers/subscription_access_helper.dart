import 'package:dr_on_call/app/widgets/access_limit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../services/subscription_manager_service.dart';

/// Helper class to check subscription access before navigating to detail pages
class SubscriptionAccessHelper {
  /// Check if user can access content and navigate accordingly
  /// Returns true if access granted, false if blocked
  static Future<bool> checkAccessAndNavigate({
    required String routeName,
    dynamic arguments,
    required String
        contentType, // 'clinical_presentation', 'biochemical', 'clinical'
  }) async {
    // Print detailed status for debugging
    await SubscriptionManagerService.printCurrentStatus();

    // Get current status for debugging
    final isPremium = await SubscriptionManagerService.isPremiumUser();
    final isInTrial = await SubscriptionManagerService.isInFreeTrial();
    final dailyCount = await SubscriptionManagerService.getDailyAccessCount();

    print(
        '🔍 Access Check: Premium=$isPremium, InTrial=$isInTrial, DailyCount=$dailyCount');

    // Check if user can access content
    final canAccess = await SubscriptionManagerService.canAccessContent();
    print('🔍 Can Access: $canAccess');

    if (canAccess) {
      // Increment daily access count for trial users BEFORE navigation
      if (!isPremium && isInTrial) {
        await SubscriptionManagerService.incrementDailyAccessCount();
        final newCount = await SubscriptionManagerService.getDailyAccessCount();
        print('✅ Daily access count incremented: $dailyCount → $newCount');
      }

      // Navigate to the detail page
      Get.toNamed(routeName, arguments: arguments);

      return true;
    } else {
      // Access denied - show subscription prompt
      print('🚫 Access DENIED - showing subscription prompt');
      _showSubscriptionPrompt(contentType);
      return false;
    }
  }

  /// Show subscription prompt dialog
  static void _showSubscriptionPrompt(String contentType) async {
    await SubscriptionManagerService.getRemainingTrialDays();

    showAccessLimitDialog();
  }

  /// Show trial expiry warning (when trial is about to expire)
  static Future<void> showTrialExpiryWarning() async {
    final remainingDays =
        await SubscriptionManagerService.getRemainingTrialDays();

    if (remainingDays > 0 && remainingDays <= 2) {
      Get.snackbar(
        'Trial Expiring Soon',
        'Your free trial expires in $remainingDays day${remainingDays > 1 ? 's' : ''}. Subscribe now for unlimited access!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.toNamed(Routes.SUBSCRIPTIONS);
          },
          child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  /// Show remaining views warning
  static Future<void> showRemainingViewsWarning() async {
    final isPremium = await SubscriptionManagerService.isPremiumUser();
    final isInTrial = await SubscriptionManagerService.isInFreeTrial();

    if (!isPremium && isInTrial) {
      final remainingToday =
          await SubscriptionManagerService.getRemainingDailyAccesses();

      if (remainingToday > 0 && remainingToday <= 2) {
        Get.snackbar(
          'Limited Items Remaining Today',
          'You have $remainingToday item${remainingToday > 1 ? 's' : ''} remaining today. Subscribe for unlimited access!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              Get.toNamed(Routes.SUBSCRIPTIONS);
            },
            child:
                const Text('Subscribe', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  /// Get access status for display
  static Future<Map<String, dynamic>> getAccessStatus() async {
    final isPremium = await SubscriptionManagerService.isPremiumUser();
    final isInTrial = await SubscriptionManagerService.isInFreeTrial();
    final remainingDays =
        await SubscriptionManagerService.getRemainingTrialDays();
    final remainingToday =
        await SubscriptionManagerService.getRemainingDailyAccesses();
    final statusMessage =
        await SubscriptionManagerService.getAccessStatusMessage();

    return {
      'isPremium': isPremium,
      'isInTrial': isInTrial,
      'remainingDays': remainingDays,
      'remainingToday': remainingToday,
      'statusMessage': statusMessage,
      'canAccess': await SubscriptionManagerService.canAccessContent(),
    };
  }
}
