import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/clinical_details_controller.dart';

class ClinicalHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalDetailsController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Get the current diagnosis data
        final diagnosis = controller.currentDiagnosis;

        print(
            'DEBUG Clinical Header: Diagnosis data: ${diagnosis?.title ?? 'null'}');
        print(
            'DEBUG Clinical Header: Diagnoses count: ${controller.diagnoses.length}');

        // Use the diagnosis title if available, otherwise show a default
        String title = 'Clinical Diagnosis';
        if (diagnosis != null && diagnosis.title.isNotEmpty) {
          title = diagnosis.title;
        }

        print('DEBUG Clinical Header: Using title: $title');

        return CommonTitleSection(
          title: title,
          onBackTap: () {
            // Smart back navigation - go back to the previous view
            Get.back();
          },
        );
      }),
    );
  }
}
