import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/rounded_text_container.dart';
import '../../controllers/login_controller.dart';

class LoginForm extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  final VoidCallback onForgotPasswordTap;
  final VoidCallback onLoginTap;

  LoginForm({
    Key? key,
    required this.onForgotPasswordTap,
    required this.onLoginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTextField(
          hintText: 'Email',
          controller: controller.emailController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Password',
          isPassword: true,
          controller: controller.passwordController,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onForgotPasswordTap,
          child: Text(AppText.forgotPassword,
              style: AppTextStyles.medium.copyWith(fontSize: 14)),
        ),
        const SizedBox(height: 20),

        // TODO: just uncomment this calling method then the back will work

        Obx(() => controller.isLoading.value
            ? CircularProgressIndicator()
            : RoundedTextContainer(
                text: AppText.logIn,
                color: AppColors.baseColor,
                onTap: controller.login,
              )),

        // RoundedTextContainer(
        //   text: AppText.logIn,
        //   color: AppColors.baseColor,
        //   onTap: () {
        //     Get.toNamed(Routes.HOME);
        //   },
        // )
      ],
    );
  }
}
