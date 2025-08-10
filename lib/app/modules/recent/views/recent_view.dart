import 'package:dr_on_call/app/modules/recent/views/mini_widgets/recent_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/background_container.dart';

import '../controllers/recent_controller.dart';
import 'mini_widgets/recent_header.dart';

class RecentView extends GetView<RecentController> {
  const RecentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
          child: Column(
            children: [
              RecentHeader(),
              SizedBox(
                height: 50,
              ),
                Expanded(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: RecentList(),
              )),
            ],
          )),
    );
  }
}
