import 'package:dr_on_call/app/widgets/back_icon_button.dart';
import 'package:dr_on_call/config/AppImages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../controllers/onboardingscreen_controller.dart';
import 'mini_widgets/auth_buttons.dart';
import 'mini_widgets/on_call_header.dart';

class OnboardingscreenView extends GetView<OnboardingscreenController> {
  const OnboardingscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.dr),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF001631).withValues(alpha: 0.5),
          ),

          // ✅ This goes inside children
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                OnCallHeader(),
                AuthButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
