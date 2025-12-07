import 'package:dr_on_call/app/modules/about_view/views/mini_widgets/about_header.dart';
import 'package:dr_on_call/app/modules/about_view/views/mini_widgets/legal_section.dart';
import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../config/AppImages.dart';
import '../controllers/about_view_controller.dart';
import 'mini_widgets/subscription_card.dart';

class AboutViewView extends GetView<AboutViewController> {
  const AboutViewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AboutHeader(),
            SubscriptionCard(),
            LegalSection(),
          ],
        ),
      ),
    ));
  }
}
