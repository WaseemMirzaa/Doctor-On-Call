import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../widgets/back_icon_button.dart';
import '../../../../widgets/custom_header.dart';

class ChestHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ChestHeader({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: CommonTitleSection(
        title: AppText.chestPain,
      ),
    );

    //   GestureDetector(
    //   onTap: () {
    //     Get.back();
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 10.0),
    //     child: Column(
    //       // crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.only(top: 35.0),
    //           child: BackIconButton(
    //             onTap: onBackTap ?? () => Get.back(),
    //           ),
    //         ),
    //         const SizedBox(height: 20),
    //         Text(AppText.chestPain,
    //             style: AppTextStyles.bold.copyWith(fontSize: 25)),
    //         const SizedBox(height: 4),
    //         // Padding(
    //         //   padding: const EdgeInsets.only(right: 23.0, left: 23.0),
    //         //   child: Text(
    //         //     Apptext.forgotDecs,
    //         //     textAlign: TextAlign.center,
    //         //     style: const TextStyle(
    //         //       color: AppColors.txtWhiteColor,
    //         //       fontSize: 13,
    //         //     ),
    //         //   ),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
