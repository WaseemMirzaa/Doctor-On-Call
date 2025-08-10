import 'package:dr_on_call/app/modules/search/views/mini_widgets/search_header.dart';
import 'package:dr_on_call/app/modules/search/views/mini_widgets/search_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/background_container.dart';
import '../../../../config/AppColors.dart';
import '../../../../config/AppTextStyle.dart';
import '../../../../config/AppIcons.dart';
import '../controllers/search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 20, left: 20),
                child: const SearchHeader(),
              ),
              const SizedBox(height: 20),

              // Search field with filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSearchField(),
              ),
              const SizedBox(height: 20),

              // Search results/history list
              const SearchList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        // Search field
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          child: TextField(
                            controller: controller.searchController,
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 14,
                              // fontWeight: FontWeight.w500,
                              color: AppColors.darkBlue,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: AppTextStyles.regular.copyWith(
                                  fontSize: 14, color: AppColors.darkBlue),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      // Filter button
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 2),
              child: GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Obx(() => Stack(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 35,
                          color: controller.isFilterApplied.value
                              ? AppColors.txtWhiteColor
                              : AppColors.txtWhiteColor,
                        ),
                        if (controller.isFilterApplied.value)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    )),
              ),
            ),
          ],
        ),
        // Filter indicator
        Obx(() {
          if (!controller.isFilterApplied.value) return const SizedBox.shrink();

          String filterText = '';
          switch (controller.selectedFilter.value) {
            case search.SearchFilter.clinicalDiagnosis:
              filterText = 'Clinical Diagnosis';
              break;
            case search.SearchFilter.biochemicalEmergency:
              filterText = 'Biochemical Emergency';
              break;
            case search.SearchFilter.all:
              filterText = '';
              break;
          }

          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.txtOrangeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.txtOrangeColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter: $filterText',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 12,
                    color: AppColors.txtWhiteColor,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: controller.clearFilters,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.txtOrangeColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Image.asset(
                AppIcons.clinic,
                width: 30,
                height: 30,
                color: AppColors.txtBlackColor,
              ),
              title: const Text('All Categories'),
              onTap: () {
                controller.setFilter(search.SearchFilter.all);
                Get.back();
              },
            ),
            ListTile(
              leading: Image.asset(
                AppIcons.checkUp,
                width: 30,
                height: 30,
                color: AppColors.txtBlackColor,
              ),
              title: const Text('Clinical Diagnosis'),
              onTap: () {
                controller.setFilter(search.SearchFilter.clinicalDiagnosis);
                Get.back();
              },
            ),
            ListTile(
              leading: Image.asset(
                AppIcons.test,
                width: 30,
                height: 30,
                color: AppColors.txtBlackColor,
              ),
              title: const Text('Biochemical Emergencies'),
              onTap: () {
                controller.setFilter(search.SearchFilter.biochemicalEmergency);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cancel,
                weight: 35,
              ),
              title: const Text('Clear'),
              onTap: () {
                controller.clearFilters();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
