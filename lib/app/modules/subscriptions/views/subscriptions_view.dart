import 'package:dr_on_call/app/modules/subscriptions/views/mini_widgets/subscriptions_header.dart';
import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:dr_on_call/config/AppText.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/subscriptions_controller.dart';
import 'mini_widgets/plan_card.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundContainer(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SubscriptionsHeader(),
                        const SizedBox(height: 15),

                        // Free Trial Card (Current Plan)
                        Obx(() => PlanCard(
                              title: controller.isPremiumUser.value
                                  ? AppText.trial
                                  : controller.currentPlan.value,
                              subtitle: AppText.plan,
                              features: [
                                AppText.accessToEmergencyCondition,
                                AppText.news2Calculator,
                              ],
                              buttonText: AppText.currentPlan,
                              isCurrent: !controller.isPremiumUser.value,
                              isSelected: !controller.isPremiumUser.value,
                            )),

                        // Lifetime Plan Card - €9.99 One-Time Fee
                        Obx(() => PlanCard(
                              title: controller.lifetimePrice.value,
                              subtitle: 'Lifetime Access',
                              features: [
                                'Access to all emergency conditions',
                                'All scoring tools',
                                'NEWS2 Calculator',
                                'One-time fee, no recurring fees',
                              ],
                              buttonText: controller.isPremiumUser.value
                                  ? 'Purchased'
                                  : AppText.buyPlan,
                              isSelected: controller.isPremiumUser.value,
                              isCurrent: controller.isPremiumUser.value,
                              onPressed: controller.isPremiumUser.value
                                  ? null
                                  : () => controller.purchaseLifetime(),
                            )),

                        const SizedBox(height: 20),

                        // Restore Purchases Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextButton(
                            onPressed: () => controller.restorePurchases(),
                            child: Text(
                              'Restore Purchases',
                              style: AppTextStyles.medium.copyWith(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Expire Trial Button (for testing)
                        Obx(() => !controller.isPremiumUser.value
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      controller.expireTrialForTesting(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: BorderSide(color: Colors.orange),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Expire Trial (Testing)',
                                        style: AppTextStyles.medium.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox.shrink()),

                        const SizedBox(height: 10),

                        // Terms and Privacy
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            'By purchasing, you agree to our Terms of Service and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regular.copyWith(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ))));
  }
}
