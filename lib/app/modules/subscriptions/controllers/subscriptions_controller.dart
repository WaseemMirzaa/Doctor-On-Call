import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../services/revenuecat_service.dart';
import '../../../services/subscription_manager_service.dart';

class SubscriptionsController extends GetxController {
  // Observable states
  final isLoading = false.obs;
  final isPremiumUser = false.obs;
  final offerings = Rxn<Offerings>();
  final lifetimeProduct = Rxn<StoreProduct>();
  final lifetimePackage = Rxn<Package>();
  final customerInfo = Rxn<CustomerInfo>();

  // Price display
  final lifetimePrice = '\$0'.obs;

  // Current plan display
  final currentPlan = 'Free Trial'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRevenueCat();
  }

  @override
  void onReady() {
    super.onReady();
    checkPremiumStatus();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize RevenueCat and load offerings
  Future<void> _initializeRevenueCat() async {
    try {
      isLoading.value = true;

      // Load offerings and package info
      await loadOfferings();
      await loadLifetimePackage();
      await checkPremiumStatus();

      // Set default price if package not loaded
      if (lifetimePrice.value.isEmpty || lifetimePrice.value == '\$9.99') {
        lifetimePrice.value = '\$9.99';
      }
    } catch (e) {
      // Fallback to default price on error
      lifetimePrice.value = '\$0';
      isPremiumUser.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load available offerings
  Future<void> loadOfferings() async {
    try {
      final availableOfferings = await RevenueCatService.getOfferings();
      offerings.value = availableOfferings;

      if (availableOfferings != null) {}
    } catch (e) {}
  }

  /// Load lifetime package from offerings
  /// This automatically handles platform-specific products
  Future<void> loadLifetimePackage() async {
    try {
      final package = await RevenueCatService.getLifetimePackage();

      if (package != null) {
        lifetimePackage.value = package;
        lifetimeProduct.value = package.storeProduct;
        lifetimePrice.value = package.storeProduct.priceString;
      } else {
        // Fallback to direct product loading if offering not configured
        await loadLifetimeProductFallback();
      }
    } catch (e) {
      // Try fallback method
      await loadLifetimeProductFallback();
    }
  }

  /// Fallback method to load lifetime product directly (legacy support)
  Future<void> loadLifetimeProductFallback() async {
    try {
      final product = await RevenueCatService.getProductById(
        RevenueCatService.oneTimePurchaseId,
      );

      if (product != null) {
        lifetimeProduct.value = product;
        lifetimePrice.value = product.priceString;
      }
    } catch (e) {}
  }

  /// Check if user has premium access
  Future<void> checkPremiumStatus() async {
    try {
      // Force sync from RevenueCat servers to get latest status
      await RevenueCatService.syncCustomerInfo();

      final hasPremium = await RevenueCatService.isPremiumUser();
      isPremiumUser.value = hasPremium;

      // Also get customer info
      final info = await RevenueCatService.getCustomerInfo();
      customerInfo.value = info;

      // Save premium status to local storage
      await SubscriptionManagerService.setPremiumStatus(hasPremium);

      // Update current plan display
      currentPlan.value = await SubscriptionManagerService.getCurrentPlan();
    } catch (e) {
      // Fallback to local storage
      final localPremiumStatus =
          await SubscriptionManagerService.isPremiumUser();
      isPremiumUser.value = localPremiumStatus;
      currentPlan.value = await SubscriptionManagerService.getCurrentPlan();
    }
  }

  /// Purchase lifetime access
  Future<void> purchaseLifetime() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Processing',
        'Please wait while we process your purchase...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      CustomerInfo? info;

      // Try package-based purchase first (recommended approach)
      if (lifetimePackage.value != null) {
        info = await RevenueCatService.purchasePackage(lifetimePackage.value!);
      } else {
        // Fallback to new offering-based method
        info = await RevenueCatService.purchaseLifetime();

        // If that fails, try legacy direct product purchase
        if (info == null && lifetimeProduct.value != null) {
          info = await RevenueCatService.purchaseProduct(
            RevenueCatService.oneTimePurchaseId,
          );
        }
      }

      if (info != null) {
        customerInfo.value = info;
        await checkPremiumStatus();

        Get.snackbar(
          'Success',
          'Thank you for your purchase! You now have lifetime access.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Purchase Failed',
          'Unable to complete purchase. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during purchase. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Restoring',
        'Checking for previous purchases...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final info = await RevenueCatService.restorePurchases();

      if (info != null) {
        customerInfo.value = info;
        await checkPremiumStatus();

        if (isPremiumUser.value) {
          Get.snackbar(
            'Success',
            'Your purchases have been restored!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'No Purchases Found',
            'No previous purchases were found for this account.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Unable to restore purchases. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while restoring purchases.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh offerings and status
  Future<void> refresh() async {
    await _initializeRevenueCat();
  }

  /// Force sync with RevenueCat (for debugging/manual refresh)
  Future<void> forceSyncWithRevenueCat() async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Syncing',
        'Refreshing subscription status...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      await checkPremiumStatus();

      if (isPremiumUser.value) {
        Get.snackbar(
          'Success',
          'You have premium access!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Status',
          'No premium subscription found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Get platform-specific product information
  String getPlatformInfo() {
    if (lifetimePackage.value != null) {
      final pkg = lifetimePackage.value!;
      final platform = GetPlatform.isAndroid ? 'Play Store' : 'App Store';
      return 'Platform: $platform\nProduct: ${pkg.storeProduct.identifier}\nPrice: ${pkg.storeProduct.priceString}';
    }
    return 'No package loaded';
  }

  /// Expire trial for testing purposes
  Future<void> expireTrialForTesting() async {
    try {
      await SubscriptionManagerService.expireTrial();

      // Update current plan display
      currentPlan.value = await SubscriptionManagerService.getCurrentPlan();

      // Get current status
      // final viewCount = await SubscriptionManagerService.getContentViewCount();
      // final isInTrial = await SubscriptionManagerService.isInFreeTrial();
      // final dailyCount = await SubscriptionManagerService.getDailyAccessCount();
      final remainingToday =
          await SubscriptionManagerService.getRemainingDailyAccesses();

      Get.snackbar(
        'Trial Expired',
        'Your free trial has been expired for testing. You now have ${remainingToday >= 0 ? "$remainingToday/3" : "unlimited"} accesses today.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to expire trial',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
