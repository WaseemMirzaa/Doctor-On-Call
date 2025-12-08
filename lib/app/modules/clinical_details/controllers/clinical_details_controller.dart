import 'package:get/get.dart';
import '../../clinical_diagnosis/model/clinical_diagnosis.dart';

class ClinicalDetailsController extends GetxController {
  // Observable data
  final RxString selectedCategory = ''.obs;
  final RxList<ClinicalDiagnosis> diagnoses = <ClinicalDiagnosis>[].obs;
  final RxInt selectedDiagnosisIndex = 0.obs;

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
      final String title = arguments['title'] ?? '';

      if (arguments['diagnoses'] != null &&
          arguments['diagnoses'] is List<ClinicalDiagnosis>) {
        diagnoses.assignAll(arguments['diagnoses']);

        if (diagnoses.isNotEmpty) {}
      } else {}
    } else {}
  }

  /// Get the currently selected diagnosis
  ClinicalDiagnosis? get currentDiagnosis {
    if (diagnoses.isNotEmpty &&
        selectedDiagnosisIndex.value < diagnoses.length) {
      return diagnoses[selectedDiagnosisIndex.value];
    }
    return null;
  }

  /// Select a specific diagnosis by index
  void selectDiagnosis(int index) {
    if (index >= 0 && index < diagnoses.length) {
      selectedDiagnosisIndex.value = index;
    }
  }

  /// Navigate to next diagnosis
  void nextDiagnosis() {
    if (selectedDiagnosisIndex.value < diagnoses.length - 1) {
      selectedDiagnosisIndex.value++;
    }
  }

  /// Navigate to previous diagnosis
  void previousDiagnosis() {
    if (selectedDiagnosisIndex.value > 0) {
      selectedDiagnosisIndex.value--;
    }
  }

  /// Check if there's a next diagnosis
  bool get hasNext => selectedDiagnosisIndex.value < diagnoses.length - 1;

  /// Check if there's a previous diagnosis
  bool get hasPrevious => selectedDiagnosisIndex.value > 0;
}
