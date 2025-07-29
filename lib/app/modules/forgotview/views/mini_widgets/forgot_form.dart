import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppColors.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/rounded_text_container.dart';
import '../../controllers/forgotview_controller.dart';

class ForgotForm extends StatelessWidget {
  final VoidCallback? onSendTap;
  ForgotForm({Key? key, this.onSendTap}) : super(key: key);

  final ForgotviewController controller = Get.put(ForgotviewController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: 'Email',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // TODO: just uncomment this calling method then the back will work

        Obx(() => controller.isLoading.value
            ? const CircularProgressIndicator()
            : RoundedTextContainer(
                text: AppText.send,
                color: AppColors.baseColor,
                onTap: () async {
                  await controller.sendResetLink();
                  onSendTap?.call(); // 👈 optional callback after success
                },
              )),

        // RoundedTextContainer(
        //   text: AppText.send,
        //   color: AppColors.baseColor,
        //   onTap: () {
        //     Get.toNamed(Routes.LOGIN);
        //   },
        // )
      ],
    );
  }
}
