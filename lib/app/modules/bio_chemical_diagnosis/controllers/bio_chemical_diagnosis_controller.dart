import 'package:get/get.dart';
import '../../../services/biochemical_emergency_service.dart';
import '../model/biochemical_emergencies.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadMainListItems();
  }

  /// Load main list items (categories + standalone titles)
  Future<void> loadMainListItems() async {
    try {
      isLoadingMainList.value = true;
      errorMessage.value = '';

      final List<String> fetchedItems =
          await BiochemicalEmergencyService.getMainListItems();
      mainListItems.assignAll(fetchedItems);
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
}
