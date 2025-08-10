import 'package:dr_on_call/app/modules/bio_chemical_diagnosis/views/mini_widgets/bio_chemical_diagnosis_header.dart';
import 'package:dr_on_call/app/modules/bio_chemical_diagnosis/views/mini_widgets/bio_chemical_list.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/background_container.dart';
import '../controllers/bio_chemical_diagnosis_controller.dart';

class BioChemicalDiagnosisView extends GetView<BioChemicalDiagnosisController> {
  const BioChemicalDiagnosisView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            BioChemicalDiagnosisHeader(),
            SizedBox(
              height: 50,
            ),
            Expanded(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: BioChemicalList(),
            )),
          ],
        ),
      ),
    );
  }
}
