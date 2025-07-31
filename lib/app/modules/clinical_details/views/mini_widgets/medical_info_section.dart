import 'package:dr_on_call/config/AppText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../config/AppColors.dart';
import '../../../../widgets/medical_expension_tile.dart';
import '../../controllers/clinical_details_controller.dart';
import '../../../clinical_diagnosis/model/clinical_diagnosis.dart';

class ClinicalInfoSection extends StatelessWidget {
  const ClinicalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicalDetailsController>();

    return Obx(() {
      final diagnosis = controller.currentDiagnosis;

      if (diagnosis == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No diagnosis data available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please go back and select a diagnosis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          // Title Card
          if (diagnosis.title.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosis.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (diagnosis.category.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          diagnosis.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Definition
          MedicalExpansionTile(
            title: AppText.definition,
            content: _buildDefinitionContent(diagnosis.definition),
          ),

          // Symptoms
          if (diagnosis.symptoms.isNotEmpty)
            MedicalExpansionTile(
              title: AppText.symptoms,
              content: _buildListContent(diagnosis.symptoms),
            ),

          // Signs
          if (diagnosis.signs.isNotEmpty)
            MedicalExpansionTile(
              title: AppText.signs,
              content: _buildListContent(diagnosis.signs),
            ),

          // Investigations
          if (diagnosis.investigations.isNotEmpty)
            MedicalExpansionTile(
              title: 'Investigations',
              content: _buildListContent(diagnosis.investigations),
            ),

          // Diagnosis
          if (diagnosis.diagnosis.isNotEmpty)
            MedicalExpansionTile(
              title: 'Diagnosis',
              content: _buildListContent(diagnosis.diagnosis),
            ),

          // Management (Emergency)
          if (diagnosis.managementEmergency.isNotEmpty)
            MedicalExpansionTile(
              title: 'Management (Emergency)',
              content: _buildDynamicListContent(diagnosis.managementEmergency),
            ),

          // CT Head Indications (for Head Injury cases)
          if (diagnosis.ctHeadIndications.isNotEmpty)
            MedicalExpansionTile(
              title: 'CT Head Indications',
              content: _buildListContent(diagnosis.ctHeadIndications),
            ),

          // Red Flags - Special styling
          if (diagnosis.redFlags.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.txtWhiteColor,
              ),
              child: MedicalExpansionTile(
                title: 'Red Flags',
                content: _buildListContent(diagnosis.redFlags),
                isRedFlag: true,
                isRedContent: true,
              ),
            ),

          // Prognosis & Disposition
          if (diagnosis.prognosisDisposition.isNotEmpty)
            MedicalExpansionTile(
              title: 'Prognosis & Disposition',
              content: _buildDynamicListContent(diagnosis.prognosisDisposition),
            ),
        ],
      );
    });
  }

  String _buildDefinitionContent(ClinicalDefinition definition) {
    List<String> parts = [];

    if (definition.criteria != null) {
      parts.add('${definition.criteria}');
    }

    if (definition.notes.isNotEmpty) {
      if (parts.isNotEmpty) parts.add('\nNotes:');
      for (int i = 0; i < definition.notes.length; i++) {
        parts.add('• ${definition.notes[i]}');
      }
    }

    return parts.isEmpty ? 'No definition available' : parts.join('\n');
  }

  String _buildListContent(List<String> items) {
    if (items.isEmpty) return 'No information available';

    return items.map((item) => '• $item').join('\n');
  }

  String _buildDynamicListContent(List<dynamic> items) {
    if (items.isEmpty) return 'No information available';

    List<String> stringItems = [];
    for (var item in items) {
      if (item is String) {
        stringItems.add(item);
      } else if (item is Map) {
        // Handle complex management items that might be objects
        if (item.containsKey('step') && item.containsKey('details')) {
          // Handle structured management steps
          String stepText = '${item['step']}';
          if (item['details'] is List) {
            List<String> details = List<String>.from(item['details']);
            stepText += ':\n  ${details.map((d) => '• $d').join('\n  ')}';
          }
          stringItems.add(stepText);
        } else {
          // Handle other map structures
          stringItems.add(item.toString());
        }
      } else {
        stringItems.add(item.toString());
      }
    }

    return stringItems.map((item) => '• $item').join('\n');
  }
}
