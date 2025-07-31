import 'package:dr_on_call/app/services/biochemical_emergency_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';

class RecentController extends GetxController {
  final recentSymptoms = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSymptoms();
  }

  Future<void> loadRecentSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final recentList = prefs.getStringList('recentSymptoms') ?? [];
    recentSymptoms.value = recentList.map((item) {
      final parts = item.split('|');
      return {
        'category': parts[0],
        'symptom': parts[1],
      };
    }).toList();
  }

  void onSymptomTap(String symptom) async {
    final parts = symptom.split(' - ');
    if (parts.length == 2) {
      final category = parts[0];
      final symptomName = parts[1];

      // Only save to recent if this is a symptom, not a category
      if (symptomName != null &&
          symptomName.isNotEmpty &&
          category != symptomName) {
        final prefs = await SharedPreferences.getInstance();
        final newItem = '$category|$symptomName';
        List<String> recentList = prefs.getStringList('recentSymptoms') ?? [];
        recentList.removeWhere((item) => item == newItem);
        recentList.insert(0, newItem);
        if (recentList.length > 10) recentList = recentList.take(10).toList();
        await prefs.setStringList('recentSymptoms', recentList);
      }

      if (category == 'Biochemical') {
        // Fetch emergencies before navigating
        final emergencies =
            await BiochemicalEmergencyService.getEmergencyByTitle(symptomName);
        Get.toNamed(
          Routes.BIO_CHEMICAL_DETAIL_PAGE,
          arguments: {
            'title': symptomName,
            'category': category,
            'emergencies': emergencies != null ? [emergencies] : [],
          },
        );
      } else if (category == 'Clinical') {
        // Similar logic for clinical
        // final diagnoses = await ClinicalDiagnosisService.getDiagnosisByTitle(symptomName);
        Get.toNamed(
          Routes.CLINICAL_DETAILS,
          arguments: {
            'title': symptomName,
            'category': category,
            // 'diagnoses': diagnoses != null ? [diagnoses] : [],
          },
        );
      }
    }
  }
}
