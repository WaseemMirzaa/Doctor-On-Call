import 'package:dr_on_call/app/modules/subscriptions/views/mini_widgets/subscriptions_header.dart';
import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:dr_on_call/config/AppText.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

                        // For Premium Users: Only show Pro benefits
                        // For Non-Premium Users: Show Free Trial as current + Pro plan to purchase
                        Obx(() {
                          if (controller.isPremiumUser.value) {
                            // Premium user: Show only the Pro plan benefits (no button)
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 10),
                                  child: Text(
                                    'You have Lifetime Access! 🎉',
                                    style: AppTextStyles.bold.copyWith(
                                      fontSize: 18,
                                      color: const Color(0xFFEEC643),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                PlanCard(
                                  title: controller.lifetimePrice.value,
                                  subtitle: 'Lifetime Access',
                                  features: [
                                    'Access to all emergency conditions',
                                    'All scoring tools',
                                    'NEWS2 Calculator',
                                    'One-time fee, no recurring fees',
                                  ],
                                  buttonText: 'Active',
                                  isSelected: true,
                                  isCurrent: true,
                                  onPressed: null,
                                ),
                              ],
                            );
                          } else {
                            // Non-premium user: Show both plans
                            return Column(
                              children: [
                                // Free Trial Card (Current Plan)
                                PlanCard(
                                  title: controller.currentPlan.value,
                                  subtitle: AppText.plan,
                                  features: [
                                    AppText.sevenDayFreeTrial,
                                    AppText.accessToEmergencyCondition,
                                    AppText.news2Calculator,
                                  ],
                                  buttonText: AppText.currentPlan,
                                  isCurrent: true,
                                  isSelected: true,
                                ),
                                // Lifetime Plan Card
                                PlanCard(
                                  title: controller.lifetimePrice.value,
                                  subtitle: 'Lifetime Access',
                                  features: [
                                    'Access to all emergency conditions',
                                    'All scoring tools',
                                    'NEWS2 Calculator',
                                    'One-time fee, no recurring fees',
                                  ],
                                  buttonText: AppText.buyPlan,
                                  isSelected: false,
                                  isCurrent: false,
                                  onPressed: () =>
                                      controller.purchaseLifetime(),
                                ),
                              ],
                            );
                          }
                        }),

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
                        // Obx(() => !controller.isPremiumUser.value
                        //     ? Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //             horizontal: 30.0),
                        //         child: OutlinedButton(
                        //           onPressed: () =>
                        //               controller.expireTrialForTesting(),
                        //           style: OutlinedButton.styleFrom(
                        //             foregroundColor: Colors.orange,
                        //             side: BorderSide(color: Colors.orange),
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 20, vertical: 12),
                        //           ),
                        //           child: Row(
                        //             mainAxisSize: MainAxisSize.min,
                        //             children: [
                        //               Icon(Icons.warning_amber_rounded,
                        //                   size: 18),
                        //               SizedBox(width: 8),
                        //               Text(
                        //                 'Expire Trial (Testing)',
                        //                 style: AppTextStyles.medium.copyWith(
                        //                   fontSize: 13,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       )
                        //     : SizedBox.shrink()),

                        const SizedBox(height: 10),

                        // Terms and Privacy
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'By purchasing, you agree to our ',
                                  style: AppTextStyles.regular.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTextStyles.regular.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          "https://dr-oncall-c3b6b.web.app/#/terms-of-service"));
                                    },
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: AppTextStyles.regular.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.regular.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://dr-oncall-c3b6b.web.app/#/privacy-policy'));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ))));
  }
}
