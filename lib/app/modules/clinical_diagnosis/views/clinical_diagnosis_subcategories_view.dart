import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/symptom_selection_widget.dart';
import '../controllers/clinical_diagnosis_controller.dart';
import 'mini_widgets/clinical_diagnosis_subcategories_header.dart';

class ClinicalDiagnosisSubcategoriesView
    extends GetView<ClinicalDiagnosisController> {
  const ClinicalDiagnosisSubcategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the main category from arguments
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final String mainCategory = arguments['mainCategory'] ?? '';

    // Load titles for this category when the screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainCategory.isNotEmpty) {
        controller.selectedCategory.value = mainCategory;
        controller.loadTitlesInCategory(mainCategory);
      }
    });

    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            const ClinicalDiagnosisSubcategoriesHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: _buildSubcategoriesList(mainCategory),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesList(String mainCategory) {
    return Obx(() {
      // Force observation of favoriteStates changes
      controller.favoriteStates.length;

      if (controller.isLoadingTitles.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      // Get titles for the main category
      final titles = controller.categoryTitles;

      if (titles.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No subcategories found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ),
        );
      }

      return SymptomSelectionWidget(
        symptoms: titles,
        onSelectionChanged: (selectedSymptoms) {
          // Optional: handle multiple selection if needed
        },
        favoriteStates: controller.favoriteStates,
        onFavoriteToggle: (item) {
          controller.toggleFavorite(item);
        },
        showHeartIcon: true,
        padding: const EdgeInsets.all(16.0),
        spacing: 8.0,
        onSymptomTap: (title) async {
          // Navigate to detail view
          await controller.loadDiagnosisByTitle(title);
          if (controller.diagnoses.isNotEmpty) {
            await controller.navigateToDetailPage(title);
          }
        },
      );
    });
  }
}
