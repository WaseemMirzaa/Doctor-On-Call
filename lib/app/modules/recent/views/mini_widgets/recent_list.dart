import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/symptom_selection_widget.dart';
import '../../controllers/recent_controller.dart';

class RecentList extends GetView<RecentController> {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SymptomSelectionWidget(
          symptoms: controller.recentSymptoms
              .map((item) => "${item['category']} - ${item['symptom']}")
              .toList(),
          onSelectionChanged: (selectedSymptoms) {
            print('Selected symptoms: $selectedSymptoms');
          },
          showRecentIcon: true,
          padding: const EdgeInsets.all(16.0),
          spacing: 8.0,
          onSymptomTap: controller.onSymptomTap,
        ));
  }
}
