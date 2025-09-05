import 'package:get/get.dart';
import '../../../services/clinical_presentations_service.dart';
import '../../../services/recents_service.dart';
import '../../../services/favorites_service.dart';
import '../../../routes/app_pages.dart';

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
  final isLoading = false.obs;
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
    loadFavoriteStates();
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

      // Extract unique categories
      final uniqueCategories =
          await ClinicalPresentationsService.getCategories();
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

      // Store in recent activities
      await RecentsService.addRecentActivity(
        title: title,
        category: category,
        type: 'clinical_presentation',
      );

      // Navigate to detail page with the presentation data
      Get.toNamed(
        Routes.CLINICAL_PRESENTATION_DETAIL,
        arguments: presentation,
      );
    } catch (e) {
      print('Error handling presentation tap: $e');
    }
  }

  /// Handle main category tap
  void onMainCategoryTap(String category) {
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
      currentView.value = 'subcategories';
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

  /// Load favorite states for all items
  Future<void> loadFavoriteStates() async {
    try {
      favoriteStates.clear();
      for (String item in mainCategories) {
        final itemId = FavoritesService.generateItemId(
            item,
            selectedCategory.value.isNotEmpty
                ? selectedCategory.value
                : 'Standalone',
            FavoriteType.clinicalPresentations);
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
          selectedCategory.value.isNotEmpty
              ? selectedCategory.value
              : 'Standalone',
          FavoriteType.clinicalPresentations);

      final isFavorite = favoriteStates[item] ?? false;

      if (isFavorite) {
        // Remove from favorites
        final success = await FavoritesService.removeFromFavorites(itemId);
        if (success) {
          favoriteStates[item] = false;
        }
      } else {
        // Add to favorites
        final success = await FavoritesService.addToFavorites(
          itemId: itemId,
          title: item,
          category: selectedCategory.value.isNotEmpty
              ? selectedCategory.value
              : 'Standalone',
          type: FavoriteType.clinicalPresentations,
          additionalData: {'viewType': currentView.value},
        );
        if (success) {
          favoriteStates[item] = true;
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
