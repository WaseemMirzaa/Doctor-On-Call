import 'package:dr_on_call/app/widgets/background_container.dart';
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
            height: 20,
          ),
          InkWell(
            onTap: () {
              Get.to(() => DetailView(
                  title: AppText.disclaimer,
                  content: AppText.disclaimerContent));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppText.disclaimer,
                  style: AppTextStyles.regular.copyWith(fontSize: 15),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                  size: 25,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Get.to(() => DetailView(
                  title: AppText.copyRight, content: AppText.copyRightContent));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppText.copyRight,
                  style: AppTextStyles.regular.copyWith(fontSize: 15),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                  size: 25,
                ),
              ],
            ),
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

class DetailView extends StatelessWidget {
  const DetailView({super.key, required this.title, required this.content});
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold.copyWith(fontSize: 25),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildDisclaimerSection(
                      content: content,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection({
    required String content,
  }) {
    return Text(
      content,
      style: AppTextStyles.regular.copyWith(
        fontSize: 14,
        height: 1.4,
      ),
    );
  }
}
