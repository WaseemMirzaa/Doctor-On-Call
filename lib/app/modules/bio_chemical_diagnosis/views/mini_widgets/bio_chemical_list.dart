import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/symptom_selection_widget.dart';
import '../../controllers/bio_chemical_diagnosis_controller.dart';

class BioChemicalList extends StatelessWidget {
  const BioChemicalList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BioChemicalDiagnosisController>();

    return Obx(() {
      // Force observation of favoriteStates changes by accessing the map
      controller.favoriteStates.length; // This forces GetX to track changes

      // Check if we're in category view (showing titles within a category)
      if (controller.isInCategoryView.value) {
        return _buildCategoryTitlesView(controller);
      }

      // Main list view (categories + standalone titles)
      return _buildMainListView(controller);
    });
  }

  Widget _buildMainListView(BioChemicalDiagnosisController controller) {
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
        // This is called when heart icons are toggled internally
        // We don't need this for external favorite management
      },
      favoriteStates: Map<String, bool>.from(controller.favoriteStates),
      onFavoriteToggle: (item) {
        controller.toggleFavorite(item);
      },
      showHeartIcon: true,
      padding: const EdgeInsets.all(16.0),
      spacing: 8.0,
      onSymptomTap: (item) {
        controller.onMainListItemTap(item).then((_) {
          // Check if it was a standalone title (emergency loaded)
          if (controller.emergencies.isNotEmpty &&
              !controller.isInCategoryView.value) {
            // Navigate to detail page with subscription check
            controller.navigateToDetailPage(item);
          }
          // If it was a category, the view will automatically update to show titles
        });
      },
    );
  }

  Widget _buildCategoryTitlesView(BioChemicalDiagnosisController controller) {
    print(
        'DEBUG UI: Building category titles view for: ${controller.selectedCategory.value}');
    print(
        'DEBUG UI: Category titles count: ${controller.categoryTitles.length}');
    print('DEBUG UI: Is loading titles: ${controller.isLoadingTitles.value}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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

        _buildTitlesList(controller),
      ],
    );
  }

  Widget _buildTitlesList(BioChemicalDiagnosisController controller) {
    if (controller.isLoadingTitles.value) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
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
        // This is called when heart icons are toggled internally
        // We don't need this for external favorite management
      },
      favoriteStates: Map<String, bool>.from(controller.favoriteStates),
      onFavoriteToggle: (title) {
        controller.toggleFavorite(title);
      },
      showHeartIcon: true,
      padding: const EdgeInsets.all(16.0),
      spacing: 8.0,
      onSymptomTap: (title) {
        controller.loadEmergencyByTitle(title).then((_) {
          if (controller.emergencies.isNotEmpty) {
            // Navigate with subscription check
            controller.navigateToDetailPage(title);
          }
        });
      },
    );
  }
}
