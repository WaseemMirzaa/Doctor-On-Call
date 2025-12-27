import 'package:dr_on_call/app/modules/news2_core/views/mini_widgets/news2_header.dart';
import 'package:dr_on_call/app/modules/news2_core/views/mini_widgets/news2_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/background_container.dart';
import '../controllers/news2_core_controller.dart';

class News2CoreView extends GetView<News2CoreController> {
  const News2CoreView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            News2Header(),
            SizedBox(
              height: 30,
            ),
            // News2List(),
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: News2List(),
            )),
          ],
        ),
      ),
    );
  }
}
