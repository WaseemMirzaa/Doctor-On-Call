import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/symptom_selection_widget.dart';
import '../../../services/clinical_diagnosis.dart';
import '../controllers/clinical_diagnosis_controller.dart';
import 'mini_widgets/clinical_diagnosis_main_categories_header.dart';

class ClinicalDiagnosisMainCategoriesView
    extends GetView<ClinicalDiagnosisController> {
  const ClinicalDiagnosisMainCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: Colors.white,
          backgroundColor: Colors.blue,
          child: Column(
            children: [
              const ClinicalDiagnosisMainCategoriesHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildMainCategoriesList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoriesList() {
    return Obx(() {
      // Force observation of favoriteStates changes
      controller.favoriteStates.length;

      if (controller.isLoadingMainList.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (controller.mainListItems.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No clinical diagnosis found',
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
        symptoms: controller.mainListItems,
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
        onSymptomTap: (item) async {
          // Check if this item is a category or standalone title
          final bool isCategory =
              await ClinicalDiagnosisServices.isCategory(item);

          if (isCategory) {
            // Navigate to subcategories screen
            controller.selectedCategory.value = item;
            Get.toNamed('/clinical-diagnosis-subcategories', arguments: {
              'mainCategory': item,
            });
          } else {
            // It's a standalone title - navigate directly to detail
            await controller.loadDiagnosisByTitle(item);
            if (controller.diagnoses.isNotEmpty) {
              await controller.navigateToDetailPage(item);
            }
          }
        },
      );
    });
  }
}
