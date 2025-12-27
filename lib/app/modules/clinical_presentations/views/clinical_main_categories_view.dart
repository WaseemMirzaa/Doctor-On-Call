import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/symptom_selection_widget.dart';
import '../controllers/clinical_presentations_controller.dart';
import 'mini_widgets/clinical_main_categories_header.dart';

class ClinicalMainCategoriesView
    extends GetView<ClinicalPresentationsController> {
  const ClinicalMainCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshPresentations(),
          color: Colors.white,
          backgroundColor: Colors.blue,
          child: Column(
            children: [
              const ClinicalMainCategoriesHeader(),
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

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (controller.mainCategories.isEmpty) {
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

      return SymptomSelectionWidget(
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
          // Check if this category has subcategories or should go directly to detail
          final categoryPresentations =
              controller.groupedPresentations[category] ?? [];

          // If there's only one presentation and its title matches the category,
          // or if there are multiple presentations but they all have the same title as category,
          // go directly to detail screen
          final sameTitlePresentations = categoryPresentations
              .where((p) => p['title']?.toString() == category)
              .toList();

          if (sameTitlePresentations.isNotEmpty) {
            // Navigate directly to detail screen
            Get.toNamed('/clinical-presentation-detail', arguments: {
              'presentation': sameTitlePresentations.first,
              'navigationContext': {
                'from': 'categories',
                'mainCategory': category,
              },
            });
          } else {
            // Navigate to subcategories screen
            controller.selectedMainCategory.value = category;
            Get.toNamed('/clinical-subcategories', arguments: {
              'mainCategory': category,
            });
          }
        },
      );
    });
  }
}
