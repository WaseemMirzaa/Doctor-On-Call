import 'package:get/get.dart';
import '../../bio_chemical_diagnosis/model/biochemical_emergencies.dart';

class BioChemicalDetailPageController extends GetxController {
  // Observable data
  final RxString selectedCategory = ''.obs;
  final RxList<BiochemicalEmergency> emergencies = <BiochemicalEmergency>[].obs;
  final RxInt selectedEmergencyIndex = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsData();
  }

  /// Load data passed from the previous screen
  void _loadArgumentsData() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      selectedCategory.value = arguments['category'] ?? '';

      if (arguments['emergencies'] != null &&
          arguments['emergencies'] is List<BiochemicalEmergency>) {
        emergencies.assignAll(arguments['emergencies']);
      }
    }
  }

  /// Get the currently selected emergency
  BiochemicalEmergency? get currentEmergency {
    if (emergencies.isNotEmpty &&
        selectedEmergencyIndex.value < emergencies.length) {
      return emergencies[selectedEmergencyIndex.value];
    }
    return null;
  }

  /// Select a specific emergency by index
  void selectEmergency(int index) {
    if (index >= 0 && index < emergencies.length) {
      selectedEmergencyIndex.value = index;
    }
  }

  /// Navigate to next emergency
  void nextEmergency() {
    if (selectedEmergencyIndex.value < emergencies.length - 1) {
      selectedEmergencyIndex.value++;
    }
  }

  /// Navigate to previous emergency
  void previousEmergency() {
    if (selectedEmergencyIndex.value > 0) {
      selectedEmergencyIndex.value--;
    }
  }

  /// Check if there's a next emergency
  bool get hasNext => selectedEmergencyIndex.value < emergencies.length - 1;

  /// Check if there's a previous emergency
  bool get hasPrevious => selectedEmergencyIndex.value > 0;
}
