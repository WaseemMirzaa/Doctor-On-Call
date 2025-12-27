import 'package:dr_on_call/app/modules/bio_chemical_detail_page/views/mini_widgets/bio_chemical_header.dart';
import 'package:dr_on_call/app/modules/bio_chemical_detail_page/views/mini_widgets/bio_chemical_section.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../config/AppImages.dart';
import '../../../widgets/background_container.dart';
import '../controllers/bio_chemical_detail_page_controller.dart';

class BioChemicalDetailPageView
    extends GetView<BioChemicalDetailPageController> {
  const BioChemicalDetailPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
          child: Column(
        children: [
          BioChemicalHeader(),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: BioChemicalSection(),
          )),
        ],
      )),
    );
  }
}
