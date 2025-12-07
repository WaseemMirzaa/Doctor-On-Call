import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../config/AppText.dart';
import '../../../../widgets/custom_header.dart';

class ClinicalDiagnosisMainCategoriesHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ClinicalDiagnosisMainCategoriesHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: CommonTitleSection(
        title: AppText.clinicalDiagnosis2,
        onBackTap: onBackTap ?? () => Get.back(),
      ),
    );
  }
}
