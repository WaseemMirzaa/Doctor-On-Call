import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/clinical_diagnosis_controller.dart';

class ClinicalDiagnosisHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalDiagnosisHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalDiagnosisController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Determine the title based on the current view state
        String title = AppText.clinicalDiagnosis2; // Default title

        if (controller.isInCategoryView.value &&
            controller.selectedCategory.value.isNotEmpty) {
          // Show category name when viewing titles within a category
          title = controller.selectedCategory.value;
        }

        return CommonTitleSection(
          title: title,
          onBackTap: () {
            // Smart navigation based on current view
            if (controller.isInCategoryView.value) {
              // From category view, go back to main list
              controller.goBackToMainList();
            } else {
              // From main list, go back to home
              Get.back();
            }
          },
        );
      }),
    );
  }
}
