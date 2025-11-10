import 'package:get/get.dart';
import '../../../services/clinical_presentations_service.dart';
import '../../../services/recents_service.dart';
import '../../../services/favorites_service.dart';
import '../../../routes/app_pages.dart';
import '../../../helpers/subscription_access_helper.dart';

class ClinicalPresentationsController extends GetxController {
  // Observable lists
  final presentations = <Map<String, dynamic>>[].obs;
  final categories = <String>[].obs;
  final filteredPresentations = <Map<String, dynamic>>[].obs;

  // Hierarchical data structure
  final groupedPresentations = <String, List<Map<String, dynamic>>>{}.obs;
  final mainCategories = <String>[].obs;
  final subcategoriesForCategory = <String, List<String>>{}.obs;
  Rx<Map<String, dynamic>> currentPresentation = Rx<Map<String, dynamic>>({});
  // Loading states
  final isLoading = true.obs;
  final isSearching = false.obs;

  // Search and selection
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;

  // Navigation state
  final currentView =
      'categories'.obs; // 'categories', 'subcategories', 'presentations'
  final selectedMainCategory = ''.obs;

  // Favorites state
  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if we have arguments from favorites navigation
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('fromFavorites') &&
          args['fromFavorites'] == true &&
          args.containsKey('title')) {
        // Load specific presentation from favorites
        final String title = args['title'];
        Future.delayed(Duration(milliseconds: 100), () {
          loadPresentationByTitle(title);
        });
      } else {
        loadPresentations();
      }
    } else {
      loadPresentations();
    }
    // Note: loadFavoriteStates() is already called within loadPresentations()
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Load all clinical presentations from Firebase
  Future<void> loadPresentations() async {
    try {
      isLoading.value = true;

      final fetchedPresentations =
          await ClinicalPresentationsService.getAllClinicalPresentations();

      // Format presentations for display
      final formattedPresentations = fetchedPresentations
          .map((presentation) =>
              ClinicalPresentationsService.formatPresentationForDisplay(
                  presentation))
          .toList();

      presentations.assignAll(formattedPresentations);

      // Group presentations hierarchically
      _groupPresentationsHierarchically();

      // Extract unique categories from the loaded presentations (avoid second Firebase call)
      final Set<String> categorySet = {};
      for (var presentation in presentations) {
        final category = presentation['category'];
        if (category != null && category.toString().isNotEmpty) {
          categorySet.add(category.toString());
        }
      }
      final uniqueCategories = categorySet.toList()..sort();
      categories.assignAll(uniqueCategories);

      // Load favorite states for the main list items
      await loadFavoriteStates();

      print('Loaded ${presentations.length} presentations');
      print('Found ${mainCategories.length} main categories');
      print('Grouped presentations: ${groupedPresentations.length}');
    } catch (e) {
      print('Error loading presentations: $e');
      Get.snackbar(
        'Error',
        'Failed to load clinical presentations: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Group presentations by category and title hierarchically
  void _groupPresentationsHierarchically() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final Map<String, List<String>> subcategories = {};
    final Set<String> mainCats = {};

    for (final presentation in presentations) {
      final category = presentation['category']?.toString() ?? 'Unknown';
      final title = presentation['title']?.toString() ?? 'Unknown';

      // Add to grouped presentations
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
        subcategories[category] = [];
      }
      grouped[category]!.add(presentation);

      // Add to main categories
      mainCats.add(category);

      // Track subcategories (titles under each category)
      if (!subcategories[category]!.contains(title)) {
        subcategories[category]!.add(title);
      }
    }

    groupedPresentations.assignAll(grouped);
    subcategoriesForCategory.assignAll(subcategories);
    mainCategories.assignAll(mainCats.toList()..sort());

    // Initialize filtered presentations with all presentations
    filteredPresentations.assignAll(presentations);
  }

  /// Search presentations
  void searchPresentations(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // Reset to main categories view
      currentView.value = 'categories';
      _groupPresentationsHierarchically(); // Rebuild hierarchy
    } else {
      // Filter presentations based on search query
      final filtered = presentations.where((presentation) {
        final category =
            (presentation['category']?.toString() ?? '').toLowerCase();
        final title = (presentation['title']?.toString() ?? '').toLowerCase();
        final lowerQuery = query.toLowerCase();

        return category.contains(lowerQuery) || title.contains(lowerQuery);
      }).toList();

      filteredPresentations.assignAll(filtered);

      // Update main categories based on filtered results
      final filteredCategories = filtered
          .map((p) => p['category']?.toString() ?? 'Unknown')
          .toSet()
          .toList()
        ..sort();
      mainCategories.assignAll(filteredCategories);

      // Stay in categories view for search results
      currentView.value = 'categories';
    }
  }

  /// Filter by category
  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category.isEmpty) {
      filteredPresentations.assignAll(presentations);
    } else {
      final filtered = presentations.where((presentation) {
        return presentation['category']?.toString() == category;
      }).toList();

      filteredPresentations.assignAll(filtered);
    }
  }

  /// Clear filters
  /// Clear all filters and return to main categories
  void clearFilters() {
    selectedCategory.value = '';
    searchQuery.value = '';
    currentView.value = 'categories';
    selectedMainCategory.value = '';
    _groupPresentationsHierarchically(); // Reset to full hierarchy
  }

  /// Handle presentation tap
  Future<void> onPresentationTap(Map<String, dynamic> presentation) async {
    try {
      final title = presentation['title']?.toString() ?? '';
      final category = presentation['category']?.toString() ?? '';

      // Check subscription access before navigating
      final hasAccess = await SubscriptionAccessHelper.checkAccessAndNavigate(
        routeName: Routes.CLINICAL_PRESENTATION_DETAIL,
        arguments: {
          'presentation': presentation,
          'fromView': currentView.value,
          'selectedMainCategory': selectedMainCategory.value,
          'selectedCategory': selectedCategory.value,
        },
        contentType: 'clinical_presentation',
      );

      // Only store in recent activities if access was granted
      if (hasAccess) {
        await RecentsService.addRecentActivity(
          title: title,
          category: category,
          type: 'clinical_presentation',
        );

        // Show warnings if needed
        await SubscriptionAccessHelper.showRemainingViewsWarning();
        await SubscriptionAccessHelper.showTrialExpiryWarning();
      }
    } catch (e) {
      print('Error handling presentation tap: $e');
    }
  }

  /// Handle main category tap
  Future<void> onMainCategoryTap(String category) async {
    selectedMainCategory.value = category;
    final subcategoriesInCategory = subcategoriesForCategory[category] ?? [];

    // Check if this category has only one title and it's the same as category
    // or if there's only one subcategory that matches the category name
    final hasDirectAccess = subcategoriesInCategory.length == 1 &&
        subcategoriesInCategory.first == category;

    if (hasDirectAccess) {
      // Find the presentation and navigate directly to details
      final categoryPresentations = groupedPresentations[category] ?? [];
      if (categoryPresentations.isNotEmpty) {
        final presentation = categoryPresentations.firstWhere(
          (p) => p['title']?.toString() == category,
          orElse: () => categoryPresentations.first,
        );
        onPresentationTap(presentation);
      }
    } else {
      // Show subcategories
      selectedCategory.value =
          category; // Set the selected category for subcategory context
      currentView.value = 'subcategories';
      // Load favorites for the subcategories
      await loadFavoriteStates();
    }
  }

  /// Handle subcategory tap
  void onSubcategoryTap(String subcategory) {
    final categoryPresentations =
        groupedPresentations[selectedMainCategory.value] ?? [];
    final presentation = categoryPresentations.firstWhere(
      (p) => p['title']?.toString() == subcategory,
      orElse: () => {},
    );

    if (presentation.isNotEmpty) {
      onPresentationTap(presentation);
    }
  }

  /// Navigate back to main categories
  void backToMainCategories() {
    currentView.value = 'categories';
    selectedMainCategory.value = '';
    selectedCategory.value = '';
    // Load favorites for main categories
    loadFavoriteStates();
  }

  /// Navigate back to subcategories from presentations view
  void backToSubcategories() {
    currentView.value = 'subcategories';
    selectedCategory.value = '';
    // Keep the selectedMainCategory to maintain subcategory context
  }

  /// Get subcategories for currently selected main category
  List<String> getCurrentSubcategories() {
    return subcategoriesForCategory[selectedMainCategory.value] ?? [];
  }

  /// Get presentations for a specific category and title
  List<Map<String, dynamic>> getPresentationsForCategoryAndTitle(
      String category, String title) {
    final categoryPresentations = groupedPresentations[category] ?? [];
    return categoryPresentations
        .where((p) => p['title']?.toString() == title)
        .toList();
  }

  /// Refresh presentations
  Future<void> refreshPresentations() async {
    await loadPresentations();
  }

  /// Get red flags for a presentation
  List<String> getRedFlags(Map<String, dynamic> presentation) {
    return ClinicalPresentationsService.extractRedFlags(presentation);
  }

  /// Test Firebase connection
  Future<void> testConnection() async {
    try {
      await ClinicalPresentationsService.testConnection();
    } catch (e) {
      print('Connection test failed: $e');
    }
  }

  Future<void> loadPresentationByTitle(String title) async {
    try {
      final presentation =
          await ClinicalPresentationsService.getPresentationByTitle(title);
      if (presentation != null) {
        presentations.clear();
        presentations.add(presentation);
        currentPresentation.value = presentation;
        // Store recent activity when presentation is loaded
        await _storeRecentActivity(title);
      } else {
        print('Presentation not found');
      }
    } catch (e) {
      print('Error loading presentation: $e');
    }
  }

  Future<void> _storeRecentActivity(String title) async {
    try {
      String category = selectedCategory.value.isNotEmpty
          ? selectedCategory.value
          : 'Standalone';

      await RecentsService.addRecentActivity(
        title: title,
        category: category,
        type: 'clinical_presentation',
      );
    } catch (e) {
      print('Error storing recent activity: $e');
      // Don't throw error here as it shouldn't affect the main functionality
    }
  }

  /// Load favorite states for current items
  Future<void> loadFavoriteStates() async {
    try {
      // Determine which items to load favorites for based on current view
      List<String> items;
      if (currentView.value == 'subcategories') {
        items = getCurrentSubcategories();
      } else {
        items = mainCategories;
      }

      favoriteStates.clear();

      print('=== Clinical Presentations loadFavoriteStates ===');
      print('Current view: ${currentView.value}');
      print('Selected category: ${selectedCategory.value}');
      print('Selected main category: ${selectedMainCategory.value}');
      print('Items to load favorites for: ${items.length} items');
      print('Items: $items');

      for (String item in items) {
        final category =
            selectedCategory.value.isEmpty ? 'General' : selectedCategory.value;
        final itemId = FavoritesService.generateItemId(
            item, category, FavoriteType.clinicalPresentations);
        print(
            'Loading favorite for "$item" with category "$category" -> ID: $itemId');
        final isFav = await FavoritesService.isFavorite(itemId);
        favoriteStates[item] = isFav;
        print('Favorite state for "$item": $isFav');
      }

      print('Total favorite states loaded: ${favoriteStates.length}');
      print('=== End loadFavoriteStates ===');
    } catch (e) {
      print('Error loading favorite states: $e');
    }
  }

  /// Toggle favorite status for an item
  Future<void> toggleFavorite(String item) async {
    try {
      final category =
          selectedCategory.value.isEmpty ? 'General' : selectedCategory.value;
      final itemId = FavoritesService.generateItemId(
          item, category, FavoriteType.clinicalPresentations);

      print('=== Clinical Presentations toggleFavorite ===');
      print('Item: "$item"');
      print('Category: "$category"');
      print('Item ID: "$itemId"');
      print('Current view: ${currentView.value}');

      final success = await FavoritesService.toggleFavorite(
        itemId: itemId,
        title: item,
        category: category,
        type: FavoriteType.clinicalPresentations,
      );

      if (success) {
        // Force UI update by creating a new map
        final newStates = Map<String, bool>.from(favoriteStates);
        newStates[item] = !(favoriteStates[item] ?? false);
        favoriteStates.assignAll(newStates);
        print('Successfully toggled favorite. New state: ${newStates[item]}');
      } else {
        print('Failed to toggle favorite');
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
