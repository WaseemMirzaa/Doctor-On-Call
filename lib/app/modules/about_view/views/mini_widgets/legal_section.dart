import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../config/AppTextStyle.dart';
import '../../controllers/about_view_controller.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutViewController>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppText.legal,
              style: AppTextStyles.medium
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppText.privacyAndPolicy,
                style: AppTextStyles.regular.copyWith(fontSize: 15),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppText.termsOfServices,
                style: AppTextStyles.regular.copyWith(fontSize: 15),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          // Logout Button
          GestureDetector(
            onTap: () {
              controller.showLogoutDialog();
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Logout',
                    style: AppTextStyles.bold.copyWith(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
