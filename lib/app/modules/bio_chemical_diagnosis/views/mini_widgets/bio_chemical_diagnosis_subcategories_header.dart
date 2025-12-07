import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/bio_chemical_diagnosis_controller.dart';

class BioChemicalDiagnosisSubcategoriesHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const BioChemicalDiagnosisSubcategoriesHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BioChemicalDiagnosisController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Use the selected category title as the header
        final title = controller.selectedCategory.value.isNotEmpty
            ? controller.selectedCategory.value
            : 'Biochemical Emergency';

        return CommonTitleSection(
          title: title,
          onBackTap: onBackTap ?? () => Get.back(),
        );
      }),
    );
  }
}
