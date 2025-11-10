import 'package:get/get.dart';
import '../../../services/biochemical_emergency_service.dart';
import '../../../services/recents_service.dart';
import '../../../services/favorites_service.dart';
import '../model/biochemical_emergencies.dart';
import '../../../helpers/subscription_access_helper.dart';
import '../../../routes/app_pages.dart';

class BioChemicalDiagnosisController extends GetxController {
  // Observable lists for data
  final RxList<String> mainListItems =
      <String>[].obs; // Categories + standalone titles
  final RxList<String> categoryTitles =
      <String>[].obs; // Titles within a category
  final RxList<BiochemicalEmergency> emergencies = <BiochemicalEmergency>[].obs;

  // Loading states
  final RxBool isLoadingMainList = false.obs;
  final RxBool isLoadingTitles = false.obs;
  final RxBool isLoadingEmergencies = false.obs;

  // Error handling
  final RxString errorMessage = ''.obs;

  // Navigation state
  final RxString selectedCategory = ''.obs;
  final RxString selectedTitle = ''.obs;
  final RxBool isInCategoryView =
      false.obs; // Track if we're viewing titles within a category

  // Favorites state
  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if we have arguments from favorites navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final selectedCategory = arguments['selectedCategory'] as String?;
      final showCategoryView = arguments['showCategoryView'] as bool?;

      if (selectedCategory != null && showCategoryView == true) {
        // Set up category view
        this.selectedCategory.value = selectedCategory;
        isInCategoryView.value = true;

        // Load the category titles
        loadTitlesInCategory(selectedCategory).then((_) {
          loadFavoriteStates();
        });
        return;
      }
    }

    // Default initialization
    loadMainListItems();
    loadFavoriteStates();
  }

  /// Load main list items (categories + standalone titles)
  Future<void> loadMainListItems() async {
    try {
      isLoadingMainList.value = true;
      errorMessage.value = '';

      final List<String> fetchedItems =
          await BiochemicalEmergencyService.getMainListItems();
      mainListItems.assignAll(fetchedItems);

      // Load favorite states for the main list items
      await loadFavoriteStates();
    } catch (e) {
      errorMessage.value = 'Failed to load items: $e';
      print('Error loading main list items: $e');
    } finally {
      isLoadingMainList.value = false;
    }
  }

  /// Handle item tap from main list
  Future<void> onMainListItemTap(String item) async {
    try {
      print('=== DEBUG: Item tapped: $item ===');

      // Check if this item is a category or standalone title
      final bool isCategory =
          await BiochemicalEmergencyService.isCategory(item);

      print('DEBUG: Is category: $isCategory');

      if (isCategory) {
        // It's a category - load titles within this category
        print('DEBUG: Loading titles for category: $item');
        selectedCategory.value = item;
        isInCategoryView.value = true;
        await loadTitlesInCategory(item);
        // Reload favorite states for category titles
        await loadFavoriteStates();
        print('DEBUG: Category titles loaded: ${categoryTitles.length}');
        print('DEBUG: Category titles: ${categoryTitles.toList()}');
      } else {
        // It's a standalone title - load the emergency data directly
        print('DEBUG: Loading emergency for standalone title: $item');
        selectedTitle.value = item;
        await loadEmergencyByTitle(item);
      }
    } catch (e) {
      errorMessage.value = 'Failed to process item: $e';
      print('Error handling main list item tap: $e');
    }
  }

  /// Load titles within a category
  Future<void> loadTitlesInCategory(String category) async {
    try {
      isLoadingTitles.value = true;
      errorMessage.value = '';

      final List<String> titles =
          await BiochemicalEmergencyService.getTitlesInCategory(category);
      categoryTitles.assignAll(titles);
    } catch (e) {
      errorMessage.value = 'Failed to load titles: $e';
      print('Error loading titles in category: $e');
    } finally {
      isLoadingTitles.value = false;
    }
  }

  /// Load emergency data by title
  Future<void> loadEmergencyByTitle(String title) async {
    try {
      isLoadingEmergencies.value = true;
      errorMessage.value = '';

      final BiochemicalEmergency? emergency =
          await BiochemicalEmergencyService.getEmergencyByTitle(title);

      if (emergency != null) {
        emergencies.clear();
        emergencies.add(emergency);

        // Store recent activity when emergency is loaded
        await _storeRecentActivity(title);
      } else {
        errorMessage.value = 'Emergency not found: $title';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load emergency: $e';
      print('Error loading emergency by title: $e');
    } finally {
      isLoadingEmergencies.value = false;
    }
  }

  /// Navigate to detail page with subscription check
  Future<bool> navigateToDetailPage(String title) async {
    final hasAccess = await SubscriptionAccessHelper.checkAccessAndNavigate(
      routeName: Routes.BIO_CHEMICAL_DETAIL_PAGE,
      arguments: {
        'title': title,
        'emergencies': emergencies.toList(),
      },
      contentType: 'biochemical',
    );

    if (hasAccess) {
      // Show warnings if needed
      await SubscriptionAccessHelper.showRemainingViewsWarning();
      await SubscriptionAccessHelper.showTrialExpiryWarning();
    }

    return hasAccess;
  }

  /// Store recent activity for biochemical emergency
  Future<void> _storeRecentActivity(String title) async {
    try {
      String category = selectedCategory.value.isNotEmpty
          ? selectedCategory.value
          : 'Standalone';

      await RecentsService.addRecentActivity(
        title: title,
        category: category,
        type: 'biochemical',
      );
    } catch (e) {
      print('Error storing recent activity: $e');
    }
  }

  /// Go back to main list from category view
  void goBackToMainList() {
    isInCategoryView.value = false;
    selectedCategory.value = '';
    categoryTitles.clear();
  }

  /// Refresh data
  Future<void> refreshData() async {
    if (isInCategoryView.value && selectedCategory.value.isNotEmpty) {
      await loadTitlesInCategory(selectedCategory.value);
    } else {
      await loadMainListItems();
    }
  }

  /// Test Firestore connection
  Future<void> testConnection() async {
    try {
      await BiochemicalEmergencyService.testConnection();
    } catch (e) {
      print('Connection test failed: $e');
    }
  }

  /// Load favorite states for all items
  Future<void> loadFavoriteStates() async {
    try {
      final items = isInCategoryView.value ? categoryTitles : mainListItems;
      favoriteStates.clear();

      for (String item in items) {
        final itemId = FavoritesService.generateItemId(
            item,
            selectedCategory.value.isEmpty ? 'General' : selectedCategory.value,
            FavoriteType.biochemicalEmergency);
        final isFav = await FavoritesService.isFavorite(itemId);
        favoriteStates[item] = isFav;
      }
    } catch (e) {
      print('Error loading favorite states: $e');
    }
  }

  /// Toggle favorite status for an item
  Future<void> toggleFavorite(String item) async {
    try {
      final itemId = FavoritesService.generateItemId(
          item,
          selectedCategory.value.isEmpty ? 'General' : selectedCategory.value,
          FavoriteType.biochemicalEmergency);

      final success = await FavoritesService.toggleFavorite(
        itemId: itemId,
        title: item,
        category:
            selectedCategory.value.isEmpty ? 'General' : selectedCategory.value,
        type: FavoriteType.biochemicalEmergency,
      );

      if (success) {
        // Force UI update by creating a new map
        final newStates = Map<String, bool>.from(favoriteStates);
        newStates[item] = !(favoriteStates[item] ?? false);
        favoriteStates.assignAll(newStates);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  /// Check if an item is favorite
  bool isFavorite(String item) {
    return favoriteStates[item] ?? false;
  }
}
