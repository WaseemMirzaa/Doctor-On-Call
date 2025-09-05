import 'package:dr_on_call/app/modules/clinical_presentations/views/mini_widgets/clinical_header.dart';
import 'package:dr_on_call/app/modules/clinical_presentations/views/mini_widgets/clinical_list.dart';
import 'package:dr_on_call/app/widgets/background_container.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/clinical_presentations_controller.dart';

class ClinicalPresentationsView
    extends GetView<ClinicalPresentationsController> {
  const ClinicalPresentationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshPresentations(),
          color: Colors.white,
          backgroundColor: Colors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const ClinicalHeader(),
                const SizedBox(height: 30),
                const ClinicalList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
