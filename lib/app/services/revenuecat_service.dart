import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Service for managing in-app purchases and subscriptions
class RevenueCatService {
  // RevenueCat API Keys
  static const String _apiKeyAndroid =
      'goog_jKOTlHYRGqPxhuqqOMWwyOEzdyZ'; // TODO: Replace with your actual Android API key
  static const String _apiKeyIOS = 'appl_SfXmqqesrJRUNocKMMTqjbcyHjV';

  // Offering identifier - same for both platforms
  static const String lifetimeOfferingId = 'lifetime';

  // Product IDs - Platform specific (configured in RevenueCat Dashboard)
  // These are the actual product IDs in Play Store and App Store
  static const String oneTimePurchaseId = 'one_time_fee';

  // Entitlement identifier (configured in RevenueCat Dashboard)
  static const String premiumEntitlementId = 'Pro';

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

  /// Get the lifetime package from offerings
  /// This handles the same offering identifier with different platform-specific products
  static Future<Package?> getLifetimePackage() async {
    try {
      final offerings = await Purchases.getOfferings();

      // First try to get the offering by identifier
      Offering? lifetimeOffering;

      // Check if there's a specific offering with our identifier
      if (offerings.all.containsKey(lifetimeOfferingId)) {
        lifetimeOffering = offerings.all[lifetimeOfferingId];
        print('✅ Found lifetime offering by identifier: $lifetimeOfferingId');
      } else if (offerings.current != null) {
        // Fallback to current offering
        lifetimeOffering = offerings.current;
        print('✅ Using current offering as lifetime offering');
      }

      if (lifetimeOffering == null ||
          lifetimeOffering.availablePackages.isEmpty) {
        print('⚠️ No lifetime offering found');
        return null;
      }

      // Get the lifetime package (usually the first or a specific package type)
      // RevenueCat will automatically provide the correct platform-specific product
      Package? lifetimePackage;

      // Try to find lifetime or annual package
      for (var package in lifetimeOffering.availablePackages) {
        print(
            '📦 Available package: ${package.identifier} - ${package.storeProduct.identifier}');

        // Look for lifetime package type first
        if (package.packageType == PackageType.lifetime) {
          lifetimePackage = package;
          break;
        }
        // Or match by product identifier
        if (package.storeProduct.identifier == oneTimePurchaseId) {
          lifetimePackage = package;
          break;
        }
      }

      // If no specific match, use the first package
      lifetimePackage ??= lifetimeOffering.availablePackages.first;

      print(
          '✅ Selected lifetime package: ${lifetimePackage.identifier} - ${lifetimePackage.storeProduct.priceString}');
      print(
          '   Platform: ${GetPlatform.isAndroid ? "Android" : "iOS"}, Product ID: ${lifetimePackage.storeProduct.identifier}');

      return lifetimePackage;
    } catch (e) {
      print('❌ Error getting lifetime package: $e');
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

      // Debug: Print all entitlements
      print('🔍 Checking entitlements...');
      print(
          '   All entitlements: ${customerInfo.entitlements.all.keys.toList()}');

      for (var entry in customerInfo.entitlements.all.entries) {
        print(
            '   - ${entry.key}: isActive=${entry.value.isActive}, willRenew=${entry.value.willRenew}');
      }

      // Debug: Print all active purchases
      print('🔍 Active purchases:');
      for (var entry in customerInfo.allPurchasedProductIdentifiers) {
        print('   - Product: $entry');
      }

      final hasPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
              false;
      print('✅ Premium status for "$premiumEntitlementId": $hasPremium');
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

  /// Force sync customer info from RevenueCat servers
  /// Use this when you suspect the local cache is out of sync
  static Future<CustomerInfo?> syncCustomerInfo() async {
    try {
      print('🔄 Syncing customer info from RevenueCat servers...');
      // Calling getCustomerInfo will fetch latest from server
      final customerInfo = await Purchases.getCustomerInfo();
      print('✅ Customer info synced');
      return customerInfo;
    } catch (e) {
      print('❌ Error syncing customer info: $e');
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

  /// Purchase lifetime access using the offering/package system
  /// This properly handles platform-specific products within the same offering
  static Future<CustomerInfo?> purchaseLifetime() async {
    try {
      final package = await getLifetimePackage();
      if (package == null) {
        print('❌ Lifetime package not found');
        return null;
      }

      print('🛒 Purchasing lifetime package: ${package.identifier}');
      final purchaserInfo = await purchasePackage(package);

      if (purchaserInfo != null) {
        print('✅ Lifetime purchase successful');
      }

      return purchaserInfo;
    } catch (e) {
      print('❌ Error purchasing lifetime: $e');
      return null;
    }
  }

  /// Purchase product by ID (for one-time purchases) - Legacy method
  /// Note: Consider using purchaseLifetime() for better offering support
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
