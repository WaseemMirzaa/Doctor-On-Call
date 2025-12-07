import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chest_pain_controller.dart';
import 'mini_widgets/chest_header.dart';
import 'mini_widgets/chest_pain_list.dart';

class ChestPainView extends GetView<ChestPainController> {
  const ChestPainView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ChestHeader(),
              SizedBox(
                height: 50,
              ),
              ChestPainList(),
            ],
          ),
        ),
      ),
    );
  }
}
