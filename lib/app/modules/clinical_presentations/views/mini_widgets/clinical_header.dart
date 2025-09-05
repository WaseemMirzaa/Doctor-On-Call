import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/custom_header.dart';
import '../../controllers/clinical_presentations_controller.dart';

class ClinicalHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalHeader({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ClinicalPresentationsController controller = Get.find();

    return Obx(() {
      // Dynamic title based on current view
      String title;
      switch (controller.currentView.value) {
        case 'subcategories':
          title = controller.selectedMainCategory.value;
          break;
        case 'categories':
        default:
          title = AppText.clinicalPresentation;
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            CommonTitleSection(
              title: title,
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
