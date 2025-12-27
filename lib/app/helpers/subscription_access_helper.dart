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
    // Get current status for debugging
    final isPremium = await SubscriptionManagerService.isPremiumUser();
    final isInTrial = await SubscriptionManagerService.isInFreeTrial();
    final currentViewCount =
        await SubscriptionManagerService.getContentViewCount();

    print(
        '🔍 Access Check: Premium=$isPremium, InTrial=$isInTrial, ViewCount=$currentViewCount');

    // Check if user can access content
    final canAccess = await SubscriptionManagerService.canAccessContent();
    print('🔍 Can Access: $canAccess');

    if (canAccess) {
      // Navigate to the detail page first
      Get.toNamed(routeName, arguments: arguments);

      // Increment view count for non-premium users AFTER navigation
      if (!isPremium && !isInTrial) {
        // User is using free views - increment counter
        await SubscriptionManagerService.incrementViewCount();
      }

      return true;
    } else {
      // Access denied - show subscription prompt
      print('🚫 Access DENIED - showing subscription prompt');
      _showSubscriptionPrompt(contentType);
      return false;
    }
  }

  /// Show subscription prompt dialog
  static void _showSubscriptionPrompt(String contentType) {
    Get.dialog(
      AlertDialog(
        title: const Text('Subscription Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your free trial has expired and you\'ve used all 3 free views.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subscribe now to get:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Unlimited access to all content'),
            const Text('• All clinical presentations'),
            const Text('• All biochemical emergencies'),
            const Text('• All clinical diagnosis'),
            const Text('• NEWS2 Calculator'),
            const SizedBox(height: 8),
            const Text(
              'One-time payment of \$9.99 - No recurring fees!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.toNamed(
                  Routes.SUBSCRIPTIONS); // Navigate to subscription page
            },
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
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

    if (!isPremium && !isInTrial) {
      final remainingViews =
          await SubscriptionManagerService.getRemainingFreeViews();

      if (remainingViews > 0 && remainingViews <= 2) {
        Get.snackbar(
          'Limited Views Remaining',
          'You have $remainingViews view${remainingViews > 1 ? 's' : ''} remaining. Subscribe for unlimited access!',
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
    final remainingViews =
        await SubscriptionManagerService.getRemainingFreeViews();
    final statusMessage =
        await SubscriptionManagerService.getAccessStatusMessage();

    return {
      'isPremium': isPremium,
      'isInTrial': isInTrial,
      'remainingDays': remainingDays,
      'remainingViews': remainingViews,
      'statusMessage': statusMessage,
      'canAccess': await SubscriptionManagerService.canAccessContent(),
    };
  }
}
