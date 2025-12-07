import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/back_icon_button.dart';
import '../../../../widgets/custom_header.dart';

class LoginHeaderSection extends StatelessWidget {
  final VoidCallback? onBackTap;

  const LoginHeaderSection({
    Key? key,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTitleSection(
      title: AppText.loginWelcome,
      description: AppText.plzlogIn,
      spacing: true,
    );
  }
}
