import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../config/AppText.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../utils/text_utils.dart';

import '../../controllers/search_controller.dart' as search;

class SearchList extends StatelessWidget {
  const SearchList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<search.SearchController>();

    return Obx(() {
      final items = controller.displayItems;

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.txtOrangeColor,
          ),
        );
      }

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.searchQuery.value.isNotEmpty
                    ? Icons.search_off
                    : Icons.history,
                size: 64,
                color: AppColors.txtWhiteColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No results found'
                    : 'No search history',
                style: AppTextStyles.medium.copyWith(
                  fontSize: 16,
                  color: AppColors.txtWhiteColor.withValues(alpha: 0.7),
                ),
              ),
              if (controller.searchQuery.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 14,
                    color: AppColors.txtWhiteColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: items
              .map((item) => _buildSearchResultItem(item, controller))
              .toList(),
        ),
      );
    });
  }

  Widget _buildSearchResultItem(
      search.SearchResultItem item, search.SearchController controller) {
    final isCategory = item.category == 'Category';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: GestureDetector(
        onTap: () {
          controller.navigateToItemDetails(item);
        },
        child: Container(
          // height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFEEC643),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                // Icon based on type
                // Icon(
                //   isCategory
                //       ? Icons.folder_outlined
                //       : (item.type == search.SearchFilter.clinicalDiagnosis
                //           ? Icons.local_hospital
                //           : Icons.science),
                //   color: AppColors.txtOrangeColor,
                //   size: 24,
                // ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        item.title.formatTitleCase,
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.txtWhiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Category (if not a category item itself)
                      if (!isCategory && item.category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.category,
                          style: AppTextStyles.medium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color:
                                AppColors.txtWhiteColor.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Type indicator for categories
                      if (isCategory) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.type == search.SearchFilter.clinicalDiagnosis
                              ? 'Clinical Diagnosis'
                              : 'Biochemical Emergency',
                          style: AppTextStyles.medium.copyWith(
                            // fontSize: 2,
                            color:
                                AppColors.txtOrangeColor.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.txtWhiteColor.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
