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
      // Show loading indicator while categories are being fetched
      if (controller.isLoadingCategories.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show error message if there's an error
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
                  'Error loading categories',
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
                  onPressed: () => controller.loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      // Show message if no categories found
      if (controller.categories.isEmpty) {
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
                  'No categories found',
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
                  onPressed: () => controller.loadCategories(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        );
      }

      // Display categories using SymptomSelectionWidget
      return SymptomSelectionWidget(
        symptoms: controller.categories,
        onSelectionChanged: (selectedSymptoms) {
          // Handle multiple selection if needed
          print('Selected categories: $selectedSymptoms');
        },
        padding: const EdgeInsets.all(16.0),
        spacing: 8.0,
        onSymptomTap: (category) {
          // Load emergencies for this category first
          controller.loadEmergenciesByCategory(category).then((_) {
            // Navigate to detail page with the selected category
            Get.toNamed(
              Routes.BIO_CHEMICAL_DETAIL_PAGE,
              arguments: {
                'category': category,
                'emergencies': controller.emergencies.toList(),
              },
            );
          });
        },
      );
    });
  }
}
