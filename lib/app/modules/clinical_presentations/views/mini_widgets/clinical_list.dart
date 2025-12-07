import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/symptom_selection_widget.dart';
import '../../controllers/clinical_presentations_controller.dart';

class ClinicalList extends StatelessWidget {
  const ClinicalList({super.key});

  @override
  Widget build(BuildContext context) {
    final ClinicalPresentationsController controller = Get.find();

    return Obx(() {
      // Force observation of favoriteStates changes by accessing the map
      controller.favoriteStates.length; // This forces GetX to track changes

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (controller.presentations.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No clinical presentations found',
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

      // Show different views based on current navigation state
      switch (controller.currentView.value) {
        case 'subcategories':
          return _buildSubcategoriesView(controller);
        case 'categories':
        default:
          return _buildMainCategoriesView(controller);
      }
    });
  }

  /// Build main categories view
  Widget _buildMainCategoriesView(ClinicalPresentationsController controller) {
    return Column(
      children: [
        // Show main categories
        SymptomSelectionWidget(
          symptoms: controller.mainCategories,
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
          onSymptomTap: (category) {
            controller.onMainCategoryTap(category);
          },
        ),
      ],
    );
  }

  /// Build subcategories view
  Widget _buildSubcategoriesView(ClinicalPresentationsController controller) {
    final subcategories = controller.getCurrentSubcategories();

    return SymptomSelectionWidget(
      symptoms: subcategories,
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
      onSymptomTap: (subcategory) {
        controller.onSubcategoryTap(subcategory);
      },
    );
  }
}
