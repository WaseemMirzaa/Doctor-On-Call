import 'package:get/get.dart';
import '../../../services/favorites_service.dart';
import '../../../services/clinical_diagnosis.dart';
import '../../../services/biochemical_emergency_service.dart';
import '../../../services/clinical_presentations_service.dart';
import '../../../routes/app_pages.dart';
import '../../../helpers/subscription_access_helper.dart';

class FavouritesController extends GetxController {
  final favorites = <FavoriteItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load all favorites
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final allFavorites = await FavoritesService.getAllFavorites();
      favorites.value = allFavorites;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load favorites');
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove item from favorites
  Future<void> removeFromFavorites(String itemId) async {
    final success = await FavoritesService.removeFromFavorites(itemId);
    if (success) {
      favorites.removeWhere((item) => item.itemId == itemId);
    }
  }

  /// Refresh favorites list
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  /// Navigate to item details based on type
  Future<void> navigateToItemDetails(FavoriteItem item) async {
    try {
      switch (item.type) {
        case FavoriteType.clinicalDiagnosis:
          // Load clinical diagnosis data and navigate
          await _navigateToClinicalDetails(item);
          break;
        case FavoriteType.biochemicalEmergency:
          // Load biochemical emergency data and navigate
          await _navigateToBiochemicalDetails(item);
          break;
        case FavoriteType.clinicalPresentations:
          // Load clinical presentation data and navigate
          await _navigateToClinicalPresentationDetails(item);
          break;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load details');
    }
  }

  /// Navigate to clinical diagnosis details
  Future<void> _navigateToClinicalDetails(FavoriteItem item) async {
    try {
      // First try to load diagnosis data by title
      final diagnosis =
          await ClinicalDiagnosisServices.getEmergencyByTitle(item.title);

      if (diagnosis != null) {
        await SubscriptionAccessHelper.checkAccessAndNavigate(
          routeName: Routes.CLINICAL_DETAILS,
          arguments: {
            'title': item.title,
            'category': item.category,
            'diagnoses': [diagnosis], // Wrap single diagnosis in a list
          },
          contentType: 'clinical',
        );
      } else {
        // If not found as individual item, search in categories and navigate to category view
        await _searchInClinicalCategories(item);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clinical diagnosis details');
    }
  }

  /// Search for item in clinical diagnosis categories and navigate to category view
  Future<void> _searchInClinicalCategories(FavoriteItem item) async {
    try {
      // Check if the item title is a category
      final isCategory = await ClinicalDiagnosisServices.isCategory(item.title);

      if (isCategory) {
        // Navigate to clinical diagnosis subcategories screen to show subcategories list
        Get.toNamed(
          Routes.CLINICAL_DIAGNOSIS_SUBCATEGORIES,
          arguments: {
            'mainCategory': item.title,
          },
        );
      } else {
        // Search for which category contains this item
        final categoryName = await _findCategoryContainingItem(
            item.title, FavoriteType.clinicalDiagnosis);

        if (categoryName != null) {
          // Navigate to clinical diagnosis subcategories screen with the found category
          Get.toNamed(
            Routes.CLINICAL_DIAGNOSIS_SUBCATEGORIES,
            arguments: {
              'mainCategory': categoryName,
              'highlightItem': item.title,
            },
          );
        } else {
          Get.snackbar('Error', 'No diagnosis data found for ${item.title}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search in clinical categories');
    }
  }

  /// Navigate to biochemical emergency details
  Future<void> _navigateToBiochemicalDetails(FavoriteItem item) async {
    try {
      // First try to load emergency data by title
      final emergency =
          await BiochemicalEmergencyService.getEmergencyByTitle(item.title);

      if (emergency != null) {
        await SubscriptionAccessHelper.checkAccessAndNavigate(
          routeName: Routes.BIO_CHEMICAL_DETAIL_PAGE,
          arguments: {
            'title': item.title,
            'category': item.category,
            'emergencies': [emergency], // Wrap single emergency in a list
          },
          contentType: 'biochemical',
        );
      } else {
        // If not found as individual item, search in categories and navigate to category view
        await _searchInBiochemicalCategories(item);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load biochemical emergency details');
    }
  }

  /// Search for item in biochemical emergency categories and navigate to category view
  Future<void> _searchInBiochemicalCategories(FavoriteItem item) async {
    try {
      // Check if the item title is a category
      final isCategory =
          await BiochemicalEmergencyService.isCategory(item.title);

      if (isCategory) {
        // Navigate to biochemical diagnosis subcategories screen to show subcategories list
        Get.toNamed(
          Routes.BIO_CHEMICAL_DIAGNOSIS_SUBCATEGORIES,
          arguments: {
            'mainCategory': item.title,
          },
        );
      } else {
        // Search for which category contains this item
        final categoryName = await _findCategoryContainingItem(
            item.title, FavoriteType.biochemicalEmergency);

        if (categoryName != null) {
          // Navigate to biochemical diagnosis subcategories screen with the found category
          Get.toNamed(
            Routes.BIO_CHEMICAL_DIAGNOSIS_SUBCATEGORIES,
            arguments: {
              'mainCategory': categoryName,
              'highlightItem': item.title,
            },
          );
        } else {
          Get.snackbar('Error', 'No emergency data found for ${item.title}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search in biochemical categories');
    }
  }

  /// Navigate to clinical presentation details
  Future<void> _navigateToClinicalPresentationDetails(FavoriteItem item) async {
    try {
      // FIRST check if the item is a main category - this takes priority
      final allCategories = await ClinicalPresentationsService.getCategories();

      final isMainCategory = allCategories.contains(item.title);

      if (isMainCategory) {
        // Navigate to subcategories screen to show subcategories list
        Get.toNamed(
          Routes.CLINICAL_SUBCATEGORIES,
          arguments: {
            'mainCategory': item.title,
          },
        );
      } else {
        // If not a main category, try to load presentation data by title
        final presentation =
            await ClinicalPresentationsService.getPresentationByTitle(
                item.title);

        if (presentation != null) {
          await SubscriptionAccessHelper.checkAccessAndNavigate(
            routeName: Routes.CLINICAL_PRESENTATION_DETAIL,
            arguments: {
              'presentation': presentation,
              'from': 'favourites',
            },
            contentType: 'clinical_presentation',
          );
        } else {
          // If not found as individual item or main category, search in categories
          await _searchInPresentationCategories(item);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clinical presentation details');
    }
  }

  /// Search for item in clinical presentation categories and navigate to category view
  Future<void> _searchInPresentationCategories(FavoriteItem item) async {
    try {
      // Search for which category contains this item
      final categoryName = await _findCategoryContainingItem(
          item.title, FavoriteType.clinicalPresentations);

      if (categoryName != null) {
        // Navigate to clinical presentations subcategories screen to show subcategories list
        Get.toNamed(
          Routes.CLINICAL_SUBCATEGORIES,
          arguments: {
            'mainCategory': categoryName,
            'highlightItem': item.title,
          },
        );
      } else {
        Get.snackbar('Error', 'No presentation data found for ${item.title}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search in presentation categories');
    }
  }

  /// Find which category contains the given item
  Future<String?> _findCategoryContainingItem(
      String itemTitle, FavoriteType type) async {
    try {
      List<String> categories;

      // Get all categories based on type
      if (type == FavoriteType.clinicalDiagnosis) {
        categories = await ClinicalDiagnosisServices.getMainListItems();
      } else if (type == FavoriteType.clinicalPresentations) {
        categories = await ClinicalPresentationsService.getCategories();
      } else {
        categories = await BiochemicalEmergencyService.getMainListItems();
      }

      // Check each category to see if it contains the item
      for (String category in categories) {
        bool isCategory;
        List<String> titlesInCategory;

        if (type == FavoriteType.clinicalDiagnosis) {
          isCategory = await ClinicalDiagnosisServices.isCategory(category);
          if (isCategory) {
            titlesInCategory =
                await ClinicalDiagnosisServices.getTitlesInCategory(category);
          } else {
            continue;
          }
        } else if (type == FavoriteType.clinicalPresentations) {
          // For clinical presentations, we need to get presentations by category
          final presentations =
              await ClinicalPresentationsService.searchPresentations(category);
          titlesInCategory = presentations
              .where((p) => p['category']?.toString() == category)
              .map((p) => p['title']?.toString() ?? '')
              .toList();
          isCategory = titlesInCategory.isNotEmpty;
        } else {
          isCategory = await BiochemicalEmergencyService.isCategory(category);
          if (isCategory) {
            titlesInCategory =
                await BiochemicalEmergencyService.getTitlesInCategory(category);
          } else {
            continue;
          }
        }

        // Check if the item is in this category
        if (titlesInCategory.contains(itemTitle)) {
          return category;
        }
      }

      return null; // Item not found in any category
    } catch (e) {
      return null;
    }
  }
}
