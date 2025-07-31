import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final args = Get.arguments;
    final title = args?['title'];
    if (title != null) {
      _saveToRecent(title);
    }
  }

  /// Load data passed from the previous screen
  void _loadArgumentsData() {
    final arguments = Get.arguments;
    print('DEBUG Detail Controller: Arguments received: $arguments');

    if (arguments != null && arguments is Map<String, dynamic>) {
      selectedCategory.value = arguments['category'] ?? '';
      final String title = arguments['title'] ?? '';

      print('DEBUG Detail Controller: Category: ${selectedCategory.value}');
      print('DEBUG Detail Controller: Title: $title');

      if (arguments['emergencies'] != null &&
          arguments['emergencies'] is List<BiochemicalEmergency>) {
        emergencies.assignAll(arguments['emergencies']);
        print(
            'DEBUG Detail Controller: Loaded ${emergencies.length} emergencies');

        if (emergencies.isNotEmpty) {
          print(
              'DEBUG Detail Controller: First emergency title: ${emergencies.first.title}');
          print(
              'DEBUG Detail Controller: First emergency category: ${emergencies.first.category}');
        }
      } else {
        print('DEBUG Detail Controller: No emergencies found in arguments');
      }
    } else {
      print('DEBUG Detail Controller: No arguments or invalid format');
    }
  }

  Future<void> _saveToRecent(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final newItem = 'Biochemical|$title';
    List<String> recentList = prefs.getStringList('recentSymptoms') ?? [];
    recentList.removeWhere((item) => item == newItem);
    recentList.insert(0, newItem);
    if (recentList.length > 10) {
      recentList = recentList.take(10).toList();
    }
    await prefs.setStringList('recentSymptoms', recentList);
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
