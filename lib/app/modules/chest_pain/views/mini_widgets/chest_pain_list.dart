import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../config/AppText.dart';
import '../../../../widgets/symptom_selection_widget.dart';

class ChestPainList extends StatelessWidget {
  const ChestPainList({super.key});

  @override
  Widget build(BuildContext context) {
    return SymptomSelectionWidget(
      symptoms: const [
        AppText.cardiacIschaemia,
        AppText.aorticDissection,
        AppText.gastrointestinal,
        AppText.nsk,
        AppText.psychological,
        AppText.headache,
      ],
      onSelectionChanged: (selectedSymptoms) {},
      padding: const EdgeInsets.all(16.0),
      spacing: 8.0,
      onSymptomTap: (symptom) {
        switch (symptom) {
          case 'Cardiac Ischaemia':
            Get.toNamed(Routes.MEDICAL_DETAILS);
            break;
          case 'Shortness of Breath':
            break;
          case 'Palpitations':
            break;
          case 'Syncope':
            break;
          case 'Abdominal Pain':
            break;
          case 'Headache':
            break;
          default:
        }
      },
    );
  }
}
