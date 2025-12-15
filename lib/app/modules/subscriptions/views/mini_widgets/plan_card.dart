import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppIcons.dart';
import 'package:flutter/material.dart';

import '../../../../../config/AppTextStyle.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> features;
  final String buttonText;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback? onPressed;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.buttonText,
    this.isCurrent = false,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 30.0, left: 30),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color:
          //     isCurrent ? Colors.blueGrey.shade900 : Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.baseColor : AppColors.baseColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    AppIcons.calender,
                    width: 20,
                    height: 30,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.bold
                            .copyWith(color: AppColors.txtWhiteColor)),
                    // const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.regular.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_box,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(feature,
                            style:
                                AppTextStyles.regular.copyWith(fontSize: 12)),
                      )
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 43,
              child: AbsorbPointer(
                // Completely block any touch events if this is the current plan or onPressed is null
                absorbing: isCurrent || onPressed == null,
                child: GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.baseColor.withOpacity(0.5)
                            : AppColors.baseColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isCurrent
                                ? AppColors.txtWhiteColor.withOpacity(0.2)
                                : AppColors.txtWhiteColor)),
                    alignment: Alignment.center,
                    child: Text(isCurrent ? 'Current Plan' : buttonText,
                        style: AppTextStyles.bold.copyWith(
                            fontSize: 16, color: AppColors.txtBlackColor)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
