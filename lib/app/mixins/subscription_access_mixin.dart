import 'package:dr_on_call/app/services/subscription_manager_service.dart';
import 'package:dr_on_call/app/widgets/access_limit_dialog.dart';

/// Mixin to add subscription access control to controllers
mixin SubscriptionAccessMixin {
  /// Check if user can access content and handle accordingly
  /// Returns true if access is granted, false if denied
  Future<bool> checkAndIncrementAccess({
    required Function onAccessGranted,
    bool showDialogOnDenied = true,
  }) async {
    if (await SubscriptionManagerService.canAccessContent()) {
      // Increment access count for trial users
      await SubscriptionManagerService.incrementDailyAccessCount();

      // Execute the callback
      await onAccessGranted();
      return true;
    } else {
      // Show access limit dialog
      if (showDialogOnDenied) {
        showAccessLimitDialog();
      }
      return false;
    }
  }

  /// Check access without incrementing (for checking before navigation)
  Future<bool> canAccess() async {
    return await SubscriptionManagerService.canAccessContent();
  }

  /// Get access status message
  Future<String> getAccessStatus() async {
    return await SubscriptionManagerService.getAccessStatusMessage();
  }

  /// Check if user has active subscription
  Future<bool> hasSubscription() async {
    return await SubscriptionManagerService.isPremiumUser();
  }

  /// Get remaining daily accesses
  Future<int> getRemainingAccesses() async {
    return await SubscriptionManagerService.getRemainingDailyAccesses();
  }
}
