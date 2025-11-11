import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:dr_on_call/app/services/subscription_manager_service.dart';
import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialog to show when access limit is reached
class AccessLimitDialog extends StatefulWidget {
  const AccessLimitDialog({Key? key}) : super(key: key);

  @override
  State<AccessLimitDialog> createState() => _AccessLimitDialogState();
}

class _AccessLimitDialogState extends State<AccessLimitDialog> {
  bool _isTrialExpired = false;
  int _remainingDays = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expired = !await SubscriptionManagerService.isInFreeTrial();
    final remaining = await SubscriptionManagerService.getRemainingTrialDays();
    setState(() {
      _isTrialExpired = expired;
      _remainingDays = remaining;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        backgroundColor: const Color(0xFF00132B),
        content: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF00132B),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.txtOrangeColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      content: Stack(
        children: [
          // Close Button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20.0).copyWith(top: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.txtOrangeColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isTrialExpired ? Icons.lock_outline : Icons.info_outline,
                    size: 48,
                    color: AppColors.txtOrangeColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  _isTrialExpired
                      ? 'Trial Period Ended'
                      : 'Daily Limit Reached',
                  style: AppTextStyles.bold.copyWith(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Message
                Text(
                  _isTrialExpired
                      ? 'Your 7-day trial has expired. Subscribe now to continue accessing all features.'
                      : 'You\'ve reached your daily limit of ${SubscriptionManagerService.dailyAccessLimit} items.\n\n${_remainingDays > 0 ? "$_remainingDays days left in your trial." : ""}\n\nSubscribe for unlimited access!',
                  style: AppTextStyles.regular.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Subscribe button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.SUBSCRIPTIONS);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEC643),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Subscribe Now',
                      style: AppTextStyles.bold
                          .copyWith(color: AppColors.txtBlackColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Show access limit dialog
void showAccessLimitDialog() {
  Get.dialog(
    const AccessLimitDialog(),
    barrierDismissible: false,
  );
}
