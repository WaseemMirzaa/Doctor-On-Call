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
        return;
      }

      await Purchases.configure(configuration);

      // Enable debug logs in development
      await Purchases.setLogLevel(LogLevel.debug);
    } catch (e) {}
  }

  /// Set user ID for RevenueCat
  static Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {}
  }

  /// Log out user from RevenueCat
  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {}
  }

  /// Get available offerings (products)
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings;
      } else {
        return null;
      }
    } catch (e) {
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
      } else if (offerings.current != null) {
        // Fallback to current offering
        lifetimeOffering = offerings.current;
      }

      if (lifetimeOffering == null ||
          lifetimeOffering.availablePackages.isEmpty) {
        return null;
      }

      // Get the lifetime package (usually the first or a specific package type)
      // RevenueCat will automatically provide the correct platform-specific product
      Package? lifetimePackage;

      // Try to find lifetime or annual package
      for (var package in lifetimeOffering.availablePackages) {
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

      return lifetimePackage;
    } catch (e) {
      return null;
    }
  }

  /// Purchase a package
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      // This will show the native App Store/Play Store purchase sheet
      final purchaserInfo = await Purchases.purchasePackage(package);
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled the purchase - this is normal, don't show error
        print('RevenueCat: Purchase cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print(
            'RevenueCat: Purchase not allowed - user may not be permitted to make payments');
        throw Exception('Purchases are not allowed on this device');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print('RevenueCat: Payment pending - waiting for user action');
        throw Exception(
            'Payment is pending. Please complete the purchase in the App Store.');
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        // Critical: User already owns this product
        print('RevenueCat: Product already purchased');
        // Try to restore purchases to sync the status
        final restoredInfo = await Purchases.restorePurchases();
        return restoredInfo;
      } else {
        print('RevenueCat: Purchase error - ${e.code}: ${e.message}');
      }
      return null;
    } catch (e) {
      print('RevenueCat: Unexpected purchase error - $e');
      return null;
    }
  }

  /// Restore purchases
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has premium access
  static Future<bool> isPremiumUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Debug: Print all entitlements

      for (var entry in customerInfo.entitlements.all.entries) {}

      // Debug: Print all active purchases
      for (var entry in customerInfo.allPurchasedProductIdentifiers) {}

      final hasPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
              false;
      return hasPremium;
    } catch (e) {
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      return null;
    }
  }

  /// Force sync customer info from RevenueCat servers
  /// Use this when you suspect the local cache is out of sync
  static Future<CustomerInfo?> syncCustomerInfo() async {
    try {
      // Calling getCustomerInfo will fetch latest from server
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
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
      return null;
    }
  }

  /// Purchase lifetime access using the offering/package system
  /// This properly handles platform-specific products within the same offering
  static Future<CustomerInfo?> purchaseLifetime() async {
    try {
      final package = await getLifetimePackage();
      if (package == null) {
        return null;
      }

      final purchaserInfo = await purchasePackage(package);

      if (purchaserInfo != null) {}

      return purchaserInfo;
    } catch (e) {
      return null;
    }
  }

  /// Purchase product by ID (for one-time purchases) - Legacy method
  /// Note: Consider using purchaseLifetime() for better offering support
  static Future<CustomerInfo?> purchaseProduct(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        return null;
      }

      final purchaserInfo = await Purchases.purchaseStoreProduct(product);
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
      } else {}
      return null;
    } catch (e) {
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
