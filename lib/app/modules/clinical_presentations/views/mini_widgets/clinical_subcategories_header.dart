import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/clinical_presentations_controller.dart';

class ClinicalSubcategoriesHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalSubcategoriesHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalPresentationsController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Use the selected main category title as the header
        final title = controller.selectedMainCategory.value.isNotEmpty
            ? controller.selectedMainCategory.value
            : 'Clinical Presentations';

        return CommonTitleSection(
          title: title,
          onBackTap: onBackTap ?? () => Get.back(),
        );
      }),
    );
  }
}
