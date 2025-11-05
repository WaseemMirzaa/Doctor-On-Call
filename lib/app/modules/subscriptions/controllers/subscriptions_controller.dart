import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../services/revenuecat_service.dart';

class SubscriptionsController extends GetxController {
  // Observable states
  final isLoading = false.obs;
  final isPremiumUser = false.obs;
  final offerings = Rxn<Offerings>();
  final lifetimeProduct = Rxn<StoreProduct>();
  final customerInfo = Rxn<CustomerInfo>();

  // Price display
  final lifetimePrice = '€9.99'.obs;

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

      // Load offerings and product info
      await loadOfferings();
      await loadLifetimeProduct();
      await checkPremiumStatus();

      // Set default price if product not loaded
      if (lifetimePrice.value.isEmpty || lifetimePrice.value == '€9.99') {
        lifetimePrice.value = '€9.99';
      }
    } catch (e) {
      print('❌ Error initializing RevenueCat: $e');
      // Fallback to default price on error
      lifetimePrice.value = '€9.99';
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

      if (availableOfferings != null) {
        print(
            '✅ Loaded ${availableOfferings.current?.availablePackages.length ?? 0} packages');
      }
    } catch (e) {
      print('❌ Error loading offerings: $e');
    }
  }

  /// Load lifetime product
  Future<void> loadLifetimeProduct() async {
    try {
      final product = await RevenueCatService.getProductById(
        RevenueCatService.oneTimePurchaseId,
      );

      if (product != null) {
        lifetimeProduct.value = product;
        lifetimePrice.value = product.priceString;
        print('✅ Loaded lifetime product: ${product.priceString}');
      }
    } catch (e) {
      print('❌ Error loading lifetime product: $e');
    }
  }

  /// Check if user has premium access
  Future<void> checkPremiumStatus() async {
    try {
      final hasPremium = await RevenueCatService.isPremiumUser();
      isPremiumUser.value = hasPremium;

      // Also get customer info
      final info = await RevenueCatService.getCustomerInfo();
      customerInfo.value = info;

      print('Premium status: $hasPremium');
    } catch (e) {
      print('❌ Error checking premium status: $e');
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

      final info = await RevenueCatService.purchaseProduct(
        RevenueCatService.oneTimePurchaseId,
      );

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
      print('❌ Purchase error: $e');
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
      print('❌ Restore error: $e');
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
}
