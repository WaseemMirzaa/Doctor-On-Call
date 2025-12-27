import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../widgets/back_icon_button.dart';
import '../../../../widgets/custom_header.dart';

class SignupHeaderSection extends StatelessWidget {
  final VoidCallback? onBackTap;

  const SignupHeaderSection({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTitleSection(
      title: AppText.createAnAccount,
      description: AppText.joinUsToday,
      spacing: true,
    );
  }
}
