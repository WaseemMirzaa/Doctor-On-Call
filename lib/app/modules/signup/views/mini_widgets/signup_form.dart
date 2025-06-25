import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../../config/AppTextStyle.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/rounded_text_container.dart';
import '../../controllers/signup_controller.dart';

class SignUpForm extends StatelessWidget {
  final VoidCallback onLoginTap;

  SignUpForm({Key? key, required this.onLoginTap}) : super(key: key);

  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTextField(
          hintText: 'Email',
          controller: controller.emailController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Username',
          controller: controller.usernameController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Phone',
          controller: controller.phoneController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Password',
          isPassword: true,
          controller: controller.passwordController,
        ),
        const SizedBox(height: 20),
        RoundedTextContainer(
          text: AppText.signUp,
          color: AppColors.baseColor,
          onTap: () {
            Get.toNamed(Routes.LOGIN);
          },
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // align checkbox with text top
          children: [
            // Obx(() => Padding(
            //       padding: const EdgeInsets.only(top: 2),
            //       child: Checkbox(
            //         value: controller.isChecked.value,
            //         onChanged: (value) {
            //           controller.isChecked.value = value ?? false;
            //         },
            //         visualDensity: VisualDensity.compact,
            //       ),
            //     )),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(
                  AppText.policyAgreement,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.regular.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
