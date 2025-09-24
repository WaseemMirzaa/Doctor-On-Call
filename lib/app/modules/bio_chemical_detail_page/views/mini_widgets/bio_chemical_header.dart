import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/bio_chemical_detail_page_controller.dart';

class BioChemicalHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const BioChemicalHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BioChemicalDetailPageController>();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Obx(() {
        // Get the current emergency data
        final emergency = controller.currentEmergency;

        print('DEBUG Header: Emergency data: ${emergency?.title ?? 'null'}');
        print(
            'DEBUG Header: Emergencies count: ${controller.emergencies.length}');

        // Use the emergency title if available, otherwise show a default
        String title = 'Biochemical Emergency';
        if (emergency != null && emergency.title.isNotEmpty) {
          title = emergency.title;
        }

        print('DEBUG Header: Using title: $title');

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
