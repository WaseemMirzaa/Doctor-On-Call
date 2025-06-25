import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import 'mini_widgets/bottom_text.dart';
import 'mini_widgets/log_header_section.dart';
import 'mini_widgets/login_form.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  LoginHeaderSection(),
                  LoginForm(
                    onLoginTap: () {
                      controller.login();
                    },
                    onForgotPasswordTap: () {
                      Get.toNamed(Routes.FORGOTVIEW);
                    },
                  ),
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: LoginBottomText(onSignUpTap: () {
                    Get.offNamed(Routes.SIGNUP);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
