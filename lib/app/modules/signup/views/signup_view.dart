import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/background_container.dart';
import '../controllers/signup_controller.dart';
import 'mini_widgets/bottom_text.dart';
import 'mini_widgets/signup_header_section.dart';
import 'mini_widgets/signup_form.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

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
                  SignupHeaderSection(),
                  SignUpForm(
                    onLoginTap: () {
                      Get.toNamed(Routes.LOGIN);
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
                  child: SignupBottomText(
                    onLogInTap: () {
                      Get.offAndToNamed(Routes.LOGIN);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
