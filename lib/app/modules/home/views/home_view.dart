import 'package:dr_on_call/config/AppImages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../config/AppColors.dart';
import '../../../../config/AppIcons.dart';
import '../../../../config/AppText.dart';
import '../../../../config/AppTextStyle.dart';
import '../../../widgets/background_container.dart';
import '../controllers/home_controller.dart';
import 'widgets/feature_card.dart';
import 'widgets/custom_bottom_nav.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                // Header with Dr.OnCall title
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 75.0),
                    child: Image.asset(
                      AppImages.drOnCall,
                      // height: 45,
                      width: 200,
                      color: AppColors.txtOrangeColor,
                    )),

                // Bottom Navigation
                Obx(() => CustomBottomNav(
                      selectedIndex: controller.selectedBottomNavIndex.value,
                      onTap: controller.changeBottomNavIndex,
                    )),

                const SizedBox(height: 20),

                // Feature Cards Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // First row
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, right: 7.0, left: 7.0, bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: FeatureCard(
                                iconPath: AppIcons.clinic,
                                title: AppText.clinicalPresentations,
                                onTap: controller.onClinicalPresentationsTap,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: FeatureCard(
                                iconPath: AppIcons.test,
                                title: AppText.biochemicalEmergencies,
                                onTap: controller.onBiochemicalEmergenciesTap,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // const SizedBox(height: 16),

                      // Second row
                      Padding(
                        padding: const EdgeInsets.only(right: 7.0, left: 7.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: FeatureCard(
                                iconPath: AppIcons.report,
                                title: AppText.clinicalDiagnosis,
                                onTap: controller.onClinicalDiagnosisTap,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: FeatureCard(
                                iconPath: AppIcons.checkUp,
                                title: AppText.news2Score,
                                onTap: controller.onNews2ScoreTap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // About button
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: controller.onAboutTap,
                    child: Column(
                      children: [
                        Image.asset(
                          AppIcons.about,
                          width: 40,
                          height: 40,
                          color: AppColors.txtWhiteColor,
                        ),
                        const SizedBox(height: 5),
                        Text(AppText.about,
                            style: AppTextStyles.regular.copyWith(
                                fontSize: 14, color: AppColors.txtOrangeColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
