import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/symptom_selection_widget.dart';
import '../controllers/clinical_presentations_controller.dart';
import 'mini_widgets/clinical_subcategories_header.dart';

class ClinicalSubcategoriesView
    extends GetView<ClinicalPresentationsController> {
  const ClinicalSubcategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the main category from arguments
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final String mainCategory = arguments['mainCategory'] ?? '';

    // Set up the controller state when the screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainCategory.isNotEmpty) {
        controller.selectedMainCategory.value = mainCategory;
        controller.currentView.value = 'subcategories';
        // Load favorite states for subcategories
        controller.loadFavoriteStates();
      }
    });

    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            const ClinicalSubcategoriesHeader(),
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

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      // Get subcategories for the main category
      final subcategories =
          controller.subcategoriesForCategory[mainCategory] ?? [];

      if (subcategories.isEmpty) {
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
        onSymptomTap: (subcategory) async {
          // Navigate to detail view with access control
          final categoryPresentations =
              controller.groupedPresentations[mainCategory] ?? [];
          final presentation = categoryPresentations.firstWhere(
            (p) => p['title']?.toString() == subcategory,
            orElse: () => {},
          );

          if (presentation.isNotEmpty) {
            // Use the controller's method which includes access control
            await controller.onPresentationTap(presentation);
          }
        },
      );
    });
  }
}
