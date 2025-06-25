import 'package:dr_on_call/app/modules/forgotview/views/mini_widgets/bottom_text.dart';
import 'package:dr_on_call/app/modules/forgotview/views/mini_widgets/forgot_form.dart';
import 'package:dr_on_call/app/modules/forgotview/views/mini_widgets/forgot_header_section.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/background_container.dart';
import '../controllers/forgotview_controller.dart';

class ForgotviewView extends GetView<ForgotviewController> {
  const ForgotviewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundContainer(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ForgotHeaderSection(),
            ForgotForm(
                // onSendTap: () {
                //   Get.toNamed(Routes.LOGIN);
                // },
                ),
            Spacer(),
            ForgotBottomText(onLoginTap: () {
              Get.offAllNamed(Routes.LOGIN);
            }),
          ],
        ),
      ),
    ));
  }
}
