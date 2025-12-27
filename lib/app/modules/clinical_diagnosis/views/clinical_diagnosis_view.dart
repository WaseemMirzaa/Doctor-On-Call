import 'package:dr_on_call/app/modules/clinical_diagnosis/views/mini_widgets/clinical_diagnosis_header.dart';
import 'package:dr_on_call/app/modules/clinical_diagnosis/views/mini_widgets/clinical_diagnosis_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/background_container.dart';
import '../controllers/clinical_diagnosis_controller.dart';

class ClinicalDiagnosisView extends GetView<ClinicalDiagnosisController> {
  const ClinicalDiagnosisView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            ClinicalDiagnosisHeader(),
            SizedBox(
              height: 50,
            ),
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ClinicalDiagnosisList(),
            )),
          ],
        ),
      ),
    );
  }
}
