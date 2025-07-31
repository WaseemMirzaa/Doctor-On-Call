import 'package:dr_on_call/config/AppText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/medical_expension_tile.dart';
import '../../controllers/bio_chemical_detail_page_controller.dart';
import '../../../bio_chemical_diagnosis/model/biochemical_emergencies.dart';

class BioChemicalSection extends StatelessWidget {
  const BioChemicalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BioChemicalDetailPageController>();

    return Obx(() {
      final emergency = controller.currentEmergency;

      if (emergency == null) {
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
                  'No emergency data available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please go back and select an emergency.',
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
          // Definition
          MedicalExpansionTile(
            title: AppText.definition,
            content: _buildDefinitionContent(emergency.definition),
          ),

          // Symptoms
          if (emergency.symptoms.isNotEmpty)
            MedicalExpansionTile(
              title: AppText.symptoms,
              content: _buildListContent(emergency.symptoms),
            ),

          // Signs
          if (emergency.signs.isNotEmpty)
            MedicalExpansionTile(
              title: AppText.signs,
              content: _buildListContent(emergency.signs),
            ),

          // Investigations
          if (emergency.investigations.isNotEmpty)
            MedicalExpansionTile(
              title: 'Investigations',
              content: _buildListContent(emergency.investigations),
            ),

          // Diagnosis
          if (emergency.diagnosis.isNotEmpty)
            MedicalExpansionTile(
              title: 'Diagnosis',
              content: _buildListContent(emergency.diagnosis),
            ),

          // Management (Non-Emergency)
          if (emergency.managementNonEmergency.isNotEmpty)
            MedicalExpansionTile(
              title: 'Management (Non-Emergency)',
              content:
                  _buildDynamicListContent(emergency.managementNonEmergency),
            ),

          // Management (Emergency)
          if (emergency.managementEmergency.isNotEmpty)
            MedicalExpansionTile(
              title: 'Management (Emergency)',
              content: _buildDynamicListContent(emergency.managementEmergency),
            ),

          // Red Flags
          if (emergency.redFlags.isNotEmpty)
            MedicalExpansionTile(
              title: 'Red Flags',
              content: _buildListContent(emergency.redFlags),
            ),

          // Prognosis & Disposition
          if (emergency.prognosisDisposition.isNotEmpty)
            MedicalExpansionTile(
              title: 'Prognosis & Disposition',
              content: _buildListContent(emergency.prognosisDisposition),
            ),
        ],
      );
    });
  }

  String _buildDefinitionContent(Definition definition) {
    List<String> parts = [];

    if (definition.serumCorrectedCalcium != null) {
      parts.add('Serum Corrected Calcium: ${definition.serumCorrectedCalcium}');
    }
    if (definition.serumPotassium != null) {
      parts.add('Serum Potassium: ${definition.serumPotassium}');
    }
    if (definition.serumSodium != null) {
      parts.add('Serum Sodium: ${definition.serumSodium}');
    }
    if (definition.criteria != null) {
      parts.add('Criteria: ${definition.criteria}');
    }
    if (definition.source != null) {
      parts.add('Source: ${definition.source}');
    }

    if (definition.notes.isNotEmpty) {
      parts.add('\nNotes:');
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
