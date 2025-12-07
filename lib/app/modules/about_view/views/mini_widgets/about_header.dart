import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/back_icon_button.dart';
import '../../../../widgets/custom_header.dart';

class AboutHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const AboutHeader({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: CommonTitleSection(
        title: AppText.about,
        description: AppText.aboutDesc,
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.only(top: 10.0),
    //   child: Column(
    //     // crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       GestureDetector(
    //         onTap: () {
    //           Get.back();
    //         },
    //         child: Padding(
    //           padding: const EdgeInsets.only(top: 40.0, left: 25),
    //           child: BackIconButton(
    //             onTap: onBackTap ?? () => Get.back(),
    //           ),
    //         ),
    //       ),
    //       const SizedBox(height: 20),
    //       Text(AppText.about, style: AppTextStyles.bold.copyWith(fontSize: 25)),
    //       const SizedBox(height: 4),
    //       Padding(
    //         padding: const EdgeInsets.only(right: 40, left: 40),
    //         child: Text(AppText.aboutDesc,
    //             textAlign: TextAlign.center,
    //             style: AppTextStyles.regular.copyWith(fontSize: 14.5)),
    //       ),
    //     ],
    //   ),
    // );
  }
}
