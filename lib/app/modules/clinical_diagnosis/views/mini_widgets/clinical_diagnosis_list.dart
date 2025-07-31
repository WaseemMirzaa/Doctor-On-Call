import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/symptom_selection_widget.dart';
import '../../controllers/clinical_diagnosis_controller.dart';

class ClinicalDiagnosisList extends StatelessWidget {
  const ClinicalDiagnosisList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalDiagnosisController>();

    return Obx(() {
      // Check if we're in category view (showing titles within a category)
      if (controller.isInCategoryView.value) {
        return _buildCategoryTitlesView(controller);
      }

      // Main list view (categories + standalone titles)
      return _buildMainListView(controller);
    });
  }

  Widget _buildMainListView(ClinicalDiagnosisController controller) {
    if (controller.isLoadingMainList.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadMainListItems(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.mainListItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No data found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadMainListItems(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return SymptomSelectionWidget(
      symptoms: controller.mainListItems,
      onSelectionChanged: (selectedItems) {
        print('Selected items: $selectedItems');
      },
      padding: const EdgeInsets.all(16.0),
      spacing: 8.0,
      onSymptomTap: (item) {
        controller.onMainListItemTap(item).then((_) {
          // Check if it was a standalone title (diagnosis loaded)
          if (controller.diagnoses.isNotEmpty &&
              !controller.isInCategoryView.value) {
            // Navigate to detail page for standalone diagnosis
            Get.toNamed(
              Routes.CLINICAL_DETAILS,
              arguments: {
                'title': item,
                'diagnoses': controller.diagnoses.toList(),
              },
            );
          }
          // If it was a category, the view will automatically update to show titles
        });
      },
    );
  }

  Widget _buildCategoryTitlesView(ClinicalDiagnosisController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with back button and category name
        // Container(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     children: [
        //       IconButton(
        //         onPressed: () => controller.goBackToMainList(),
        //         icon: const Icon(Icons.arrow_back),
        //       ),
        //       Expanded(
        //         child: Text(
        //           controller.selectedCategory.value,
        //           style: const TextStyle(
        //             fontSize: 18,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Titles list
        _buildTitlesList(controller),
      ],
    );
  }

  Widget _buildTitlesList(ClinicalDiagnosisController controller) {
    if (controller.isLoadingTitles.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.categoryTitles.isEmpty) {
      return const Center(
        child: Text('No titles found in this category'),
      );
    }

    return SymptomSelectionWidget(
      symptoms: controller.categoryTitles,
      onSelectionChanged: (selectedTitles) {
        print('Selected titles: $selectedTitles');
      },
      padding: const EdgeInsets.all(16.0),
      spacing: 8.0,
      onSymptomTap: (title) {
        controller.loadDiagnosisByTitle(title).then((_) {
          if (controller.diagnoses.isNotEmpty) {
            Get.toNamed(
              Routes.CLINICAL_DETAILS,
              arguments: {
                'title': title,
                'category': controller.selectedCategory.value,
                'diagnoses': controller.diagnoses.toList(),
              },
            );
          }
        });
      },
    );
  }
}
