import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppIcons.dart';
import 'package:dr_on_call/config/AppText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../config/AppTextStyle.dart';
import '../../../../modules/home/controllers/home_controller.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(AppText.subscription,
              style: AppTextStyles.medium
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.baseColor.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Image.asset(
                      AppIcons.calender,
                      width: 20,
                      height: 25,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              homeController.isPremiumUser.value
                                  ? 'Lifetime Access'
                                  : AppText.trial,
                              style: AppTextStyles.bold
                                  .copyWith(color: AppColors.txtWhiteColor)),
                          Text(
                              homeController.isPremiumUser.value
                                  ? 'Pro'
                                  : AppText.plan,
                              style:
                                  AppTextStyles.regular.copyWith(fontSize: 12)),
                        ],
                      )),
                  Spacer(),
                  // Show "Manage" for premium users, "Change Plan" for non-premium
                  Obx(() => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.SUBSCRIPTIONS);
                          },
                          child: Container(
                              height: 29,
                              width: 90,
                              decoration: BoxDecoration(
                                  color: AppColors.baseColor,
                                  borderRadius:
                                      BorderRadiusDirectional.circular(25),
                                  border: Border.all(
                                    color: AppColors.txtWhiteColor,
                                    width: 0.5,
                                  )),
                              child: Center(
                                child: Text(
                                    textAlign: TextAlign.center,
                                    homeController.isPremiumUser.value
                                        ? 'Manage'
                                        : AppText.changePlan,
                                    style: AppTextStyles.bold.copyWith(
                                        fontSize: 10,
                                        color: AppColors.txtBlackColor)),
                              )),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
