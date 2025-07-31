import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/bio_chemical_diagnosis_controller.dart';

class BioChemicalDiagnosisHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const BioChemicalDiagnosisHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BioChemicalDiagnosisController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Determine the title based on the current view state
        String title = AppText.biochemicalEmergencies2; // Default title

        if (controller.isInCategoryView.value &&
            controller.selectedCategory.value.isNotEmpty) {
          // Show category name when viewing titles within a category
          title = controller.selectedCategory.value;
        }

        print(
            'DEBUG Diagnosis Header: isInCategoryView: ${controller.isInCategoryView.value}');
        print(
            'DEBUG Diagnosis Header: selectedCategory: ${controller.selectedCategory.value}');
        print('DEBUG Diagnosis Header: Using title: $title');

        return CommonTitleSection(
          title: title,
        );
      }),
    );
  }
}
