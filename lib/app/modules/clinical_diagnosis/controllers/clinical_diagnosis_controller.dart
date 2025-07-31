import 'package:get/get.dart';
import '../../../services/clinical_diagnosis.dart';
import '../model/clinical_diagnosis.dart';

class ClinicalDiagnosisController extends GetxController {
  // Observable lists for data
  final RxList<String> mainListItems =
      <String>[].obs; // Categories + standalone titles
  final RxList<String> categoryTitles =
      <String>[].obs; // Titles within a category
  final RxList<ClinicalDiagnosis> diagnoses = <ClinicalDiagnosis>[].obs;

  // Loading states
  final RxBool isLoadingMainList = false.obs;
  final RxBool isLoadingTitles = false.obs;
  final RxBool isLoadingDiagnoses = false.obs;

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
          await ClinicalDiagnosisServices.getMainListItems();
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
      print('=== DEBUG Clinical: Item tapped: $item ===');

      // Check if this item is a category or standalone title
      final bool isCategory = await ClinicalDiagnosisServices.isCategory(item);

      print('DEBUG Clinical: Is category: $isCategory');

      if (isCategory) {
        // It's a category - load titles within this category
        print('DEBUG Clinical: Loading titles for category: $item');
        selectedCategory.value = item;
        isInCategoryView.value = true;
        await loadTitlesInCategory(item);
        print(
            'DEBUG Clinical: Category titles loaded: ${categoryTitles.length}');
        print('DEBUG Clinical: Category titles: ${categoryTitles.toList()}');
      } else {
        // It's a standalone title - load the diagnosis data directly
        print('DEBUG Clinical: Loading diagnosis for standalone title: $item');
        selectedTitle.value = item;
        await loadDiagnosisByTitle(item);
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
          await ClinicalDiagnosisServices.getTitlesInCategory(category);
      categoryTitles.assignAll(titles);
    } catch (e) {
      errorMessage.value = 'Failed to load titles: $e';
      print('Error loading titles in category: $e');
    } finally {
      isLoadingTitles.value = false;
    }
  }

  /// Load diagnosis data by title
  Future<void> loadDiagnosisByTitle(String title) async {
    try {
      isLoadingDiagnoses.value = true;
      errorMessage.value = '';

      final ClinicalDiagnosis? diagnosis =
          await ClinicalDiagnosisServices.getEmergencyByTitle(title);

      if (diagnosis != null) {
        diagnoses.clear();
        diagnoses.add(diagnosis);
      } else {
        errorMessage.value = 'Diagnosis not found: $title';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load diagnosis: $e';
      print('Error loading diagnosis by title: $e');
    } finally {
      isLoadingDiagnoses.value = false;
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
      await ClinicalDiagnosisServices.testConnection();
    } catch (e) {
      print('Connection test failed: $e');
    }
  }
}
