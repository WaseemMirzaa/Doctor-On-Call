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
      // Dynamic title based on current view and selection
      String title;
      switch (controller.currentView.value) {
        case 'subcategories':
          // Show the selected main category when viewing its subcategories
          title = controller.selectedMainCategory.value.isNotEmpty
              ? controller.selectedMainCategory.value
              : AppText.clinicalPresentation;
          break;
        case 'presentations':
          // Show subcategory if available, otherwise main category
          if (controller.selectedCategory.value.isNotEmpty) {
            title = controller.selectedCategory.value;
          } else if (controller.selectedMainCategory.value.isNotEmpty) {
            title = controller.selectedMainCategory.value;
          } else {
            title = AppText.clinicalPresentation;
          }
          break;
        case 'categories':
        default:
          // Show search results if searching, otherwise default title
          if (controller.searchQuery.value.isNotEmpty) {
            title = 'Search Results';
          } else {
            title = AppText.clinicalPresentation;
          }
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            CommonTitleSection(
              title: title,
              onBackTap: () {
                // Smart navigation based on current view
                switch (controller.currentView.value) {
                  case 'subcategories':
                    // From subcategories, go back to main categories
                    controller.backToMainCategories();
                    break;
                  case 'presentations':
                    // From presentations, go back to subcategories or main categories
                    if (controller.selectedMainCategory.value.isNotEmpty) {
                      controller.backToSubcategories();
                    } else {
                      controller.backToMainCategories();
                    }
                    break;
                  case 'categories':
                  default:
                    // From main categories, go back to home
                    Get.back();
                    break;
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
