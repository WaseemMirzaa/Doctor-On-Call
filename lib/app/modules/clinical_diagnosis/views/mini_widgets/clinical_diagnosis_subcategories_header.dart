import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/clinical_diagnosis_controller.dart';

class ClinicalDiagnosisSubcategoriesHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalDiagnosisSubcategoriesHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalDiagnosisController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Use the selected category title as the header
        final title = controller.selectedCategory.value.isNotEmpty
            ? controller.selectedCategory.value
            : 'Clinical Diagnosis';

        return CommonTitleSection(
          title: title,
          onBackTap: onBackTap ?? () => Get.back(),
        );
      }),
    );
  }
}
