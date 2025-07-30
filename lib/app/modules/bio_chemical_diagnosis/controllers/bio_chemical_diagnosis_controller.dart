import 'package:get/get.dart';
import '../../../services/biochemical_emergency_service.dart';
import '../model/biochemical_emergencies.dart';

class BioChemicalDiagnosisController extends GetxController {
  // Observable lists for data
  final RxList<String> categories = <String>[].obs;
  final RxList<BiochemicalEmergency> emergencies = <BiochemicalEmergency>[].obs;

  // Loading states
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingEmergencies = false.obs;

  // Error handling
  final RxString errorMessage = ''.obs;

  // Selected category for filtering
  final RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Load all unique categories from Firestore
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      errorMessage.value = '';

      final List<String> fetchedCategories =
          await BiochemicalEmergencyService.getUniqueCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      errorMessage.value = 'Failed to load categories: $e';
      print('Error loading categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Load all emergencies from Firestore
  Future<void> loadAllEmergencies() async {
    try {
      isLoadingEmergencies.value = true;
      errorMessage.value = '';

      final List<BiochemicalEmergency> fetchedEmergencies =
          await BiochemicalEmergencyService.getAllBiochemicalEmergencies();
      emergencies.assignAll(fetchedEmergencies);
    } catch (e) {
      errorMessage.value = 'Failed to load emergencies: $e';
      print('Error loading emergencies: $e');
    } finally {
      isLoadingEmergencies.value = false;
    }
  }

  /// Load emergencies by specific category
  Future<void> loadEmergenciesByCategory(String category) async {
    try {
      isLoadingEmergencies.value = true;
      errorMessage.value = '';
      selectedCategory.value = category;

      final List<BiochemicalEmergency> fetchedEmergencies =
          await BiochemicalEmergencyService.getEmergenciesByCategory(category);
      emergencies.assignAll(fetchedEmergencies);
    } catch (e) {
      errorMessage.value = 'Failed to load emergencies for category: $e';
      print('Error loading emergencies by category: $e');
    } finally {
      isLoadingEmergencies.value = false;
    }
  }

  /// Search emergencies by query
  Future<void> searchEmergencies(String query) async {
    try {
      isLoadingEmergencies.value = true;
      errorMessage.value = '';

      final List<BiochemicalEmergency> searchResults =
          await BiochemicalEmergencyService.searchEmergencies(query);
      emergencies.assignAll(searchResults);
    } catch (e) {
      errorMessage.value = 'Failed to search emergencies: $e';
      print('Error searching emergencies: $e');
    } finally {
      isLoadingEmergencies.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadCategories();
    if (selectedCategory.value.isNotEmpty) {
      await loadEmergenciesByCategory(selectedCategory.value);
    } else {
      await loadAllEmergencies();
    }
  }

  /// Clear selected category and show all emergencies
  void clearCategoryFilter() {
    selectedCategory.value = '';
    loadAllEmergencies();
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
