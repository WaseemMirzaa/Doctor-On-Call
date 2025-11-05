import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Service for managing in-app purchases and subscriptions
class RevenueCatService {
  // RevenueCat API Keys
  static const String _apiKeyAndroid =
      'goog_oBJqPqJNJqJqJqJqJqJqJqJqJq'; // TODO: Replace with your actual Android API key
  static const String _apiKeyIOS = 'appl_SfXmqqesrJRUNocKMMTqjbcyHjV';

  // Product IDs - These must match what you configure in RevenueCat Dashboard
  static const String oneTimePurchaseId = 'dr_oncall_lifetime_999';

  // Entitlement identifier (configured in RevenueCat Dashboard)
  static const String premiumEntitlementId = 'premium';

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    try {
      // Check if API keys are configured
      if (_apiKeyAndroid.startsWith('goog_oBJ') ||
          _apiKeyAndroid == 'YOUR_ANDROID_API_KEY_HERE') {
        print(
            '⚠️ RevenueCat Android API key not configured - running in limited mode');
        // Continue with iOS if available
        if (GetPlatform.isAndroid) {
          return;
        }
      }

      PurchasesConfiguration configuration;

      if (GetPlatform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      } else if (GetPlatform.isIOS) {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      } else {
        print('⚠️ Platform not supported for RevenueCat');
        return;
      }

      await Purchases.configure(configuration);

      // Enable debug logs in development
      await Purchases.setLogLevel(LogLevel.debug);

      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      print('❌ Error initializing RevenueCat: $e');
    }
  }

  /// Set user ID for RevenueCat
  static Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      print('✅ User logged in to RevenueCat: $userId');
    } catch (e) {
      print('❌ Error logging in user to RevenueCat: $e');
    }
  }

  /// Log out user from RevenueCat
  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
      print('✅ User logged out from RevenueCat');
    } catch (e) {
      print('❌ Error logging out user from RevenueCat: $e');
    }
  }

  /// Get available offerings (products)
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        print(
            '✅ Available offerings: ${offerings.current!.availablePackages.length}');
        return offerings;
      } else {
        print('⚠️ No offerings available');
        return null;
      }
    } catch (e) {
      print('❌ Error getting offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      print('✅ Purchase successful');
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('⚠️ User cancelled the purchase');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print('❌ User is not allowed to make purchases');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print('⏳ Payment is pending');
      } else {
        print('❌ Purchase error: ${e.message}');
      }
      return null;
    } catch (e) {
      print('❌ Unexpected purchase error: $e');
      return null;
    }
  }

  /// Restore purchases
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      print('✅ Purchases restored successfully');
      return customerInfo;
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      return null;
    }
  }

  /// Check if user has premium access
  static Future<bool> isPremiumUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
              false;
      print('Premium status: $hasPremium');
      return hasPremium;
    } catch (e) {
      print('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      print('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Get product by ID
  static Future<StoreProduct?> getProductById(String productId) async {
    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isNotEmpty) {
        return products.first;
      }
      return null;
    } catch (e) {
      print('❌ Error getting product: $e');
      return null;
    }
  }

  /// Purchase product by ID (for one-time purchases)
  static Future<CustomerInfo?> purchaseProduct(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        print('❌ Product not found: $productId');
        return null;
      }

      final purchaserInfo = await Purchases.purchaseStoreProduct(product);
      print('✅ Product purchased successfully');
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('⚠️ User cancelled the purchase');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print('❌ User is not allowed to make purchases');
      } else {
        print('❌ Purchase error: ${e.message}');
      }
      return null;
    } catch (e) {
      print('❌ Unexpected purchase error: $e');
      return null;
    }
  }

  /// Format price for display
  static String formatPrice(StoreProduct product) {
    return product.priceString;
  }

  /// Get localized price
  static String getLocalizedPrice(StoreProduct product) {
    return '${product.priceString}';
  }
}
