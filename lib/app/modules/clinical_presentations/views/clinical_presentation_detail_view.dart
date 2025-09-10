import 'package:dr_on_call/app/modules/clinical_presentations/views/mini_widgets/clinical_header.dart';
import 'package:dr_on_call/config/AppColors.dart';
import 'package:flutter/material.dart';
import '../../../widgets/background_container.dart';
import '../../../widgets/medical_expension_tile.dart';

class ClinicalPresentationDetailView extends StatefulWidget {
  final Map<String, dynamic> presentation;

  const ClinicalPresentationDetailView({
    super.key,
    required this.presentation,
  });

  @override
  State<ClinicalPresentationDetailView> createState() =>
      _ClinicalPresentationDetailViewState();
}

class _ClinicalPresentationDetailViewState
    extends State<ClinicalPresentationDetailView> {
  late Map<String, dynamic> presentation;

  @override
  void initState() {
    super.initState();
    presentation = widget.presentation;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const ClinicalHeader(),
              ..._buildDynamicSections(presentation)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicSections(Map<String, dynamic> presentation) {
    final sections = <Widget>[];

    // Use raw_data if available, otherwise use the presentation data directly
    final data =
        presentation['raw_data'] as Map<String, dynamic>? ?? presentation;

    // Skip certain keys that we don't want to display as sections
    final skipKeys = {'id', 'raw_data', 'title', 'category'};

    // Define common section patterns with their preferred order
    final sectionPriority = {
      // Presentation/Definition
      'definition_and_pain_character': 10,
      'character_of_presentation': 11,
      'definition': 12,
      'presentation': 13,

      // Clinical findings
      'clinical_examination': 20,
      'examination': 21,
      'clinical_findings': 22,
      'findings': 23,

      // Diagnosis
      'differential_diagnosis': 30,
      'diagnosis': 31,
      'differential': 32,

      // Investigations
      'investigations': 40,
      'tests': 41,
      'laboratory': 42,

      // Management/Treatment
      'management': 50,
      'management_plan_adults': 51,
      'management_adults': 52,
      'treatment': 53,
      'management_plan': 54,

      // Red flags (at the end)
      'red_flags': 900,
    };

    // Get all available keys and sort them by priority
    final availableKeys = data.keys
        .where((key) => !skipKeys.contains(key) && data[key] != null)
        .toList();

    // Sort keys by priority (lower numbers first), then alphabetically
    availableKeys.sort((a, b) {
      final priorityA = sectionPriority[a] ?? 999;
      final priorityB = sectionPriority[b] ?? 999;

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.compareTo(b);
    });

    // Add sections in sorted order
    for (final key in availableKeys) {
      final title = _formatSectionTitle(key);
      final content = _formatContent(data[key]);

      if (content.isNotEmpty) {
        // Special handling for red flags
        if (_isRedFlagKey(key)) {
          sections.add(
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.txtWhiteColor,
              ),
              child: MedicalExpansionTile(
                title: 'Red Flags',
                content: content,
                isRedFlag: true,
                isRedContent: true,
              ),
            ),
          );
        } else {
          sections.add(
            MedicalExpansionTile(
              title: title,
              content: content,
            ),
          );
        }
      }
    }

    return sections;
  }
}

bool _isRedFlagKey(String key) {
  final redFlagKeys = [
    'red_flags',
    'redFlags',
    'red-flags',
    'warnings',
    'alerts'
  ];
  return redFlagKeys.contains(key);
}

String _formatContent(dynamic value) {
  if (value is String) {
    // Clean any cite markers that might still be present
    String cleanedValue = value
        .replaceAll(RegExp(r'\[cite_start\]'), '')
        .replaceAll(RegExp(r'\[cite:\s*\d+(?:,\s*\d+)*\]'), '')
        .trim();
    return cleanedValue;
  } else if (value is List) {
    return value.map((item) {
      String itemStr = item
          .toString()
          .replaceAll(RegExp(r'\[cite_start\]'), '')
          .replaceAll(RegExp(r'\[cite:\s*\d+(?:,\s*\d+)*\]'), '')
          .trim();
      return '• $itemStr';
    }).join('\n');
  } else if (value is Map) {
    return (value as Map<String, dynamic>).entries.map((entry) {
      String content = entry.value
          .toString()
          .replaceAll(RegExp(r'\[cite_start\]'), '')
          .replaceAll(RegExp(r'\[cite:\s*\d+(?:,\s*\d+)*\]'), '')
          .trim();
      return '${_formatSectionTitle(entry.key)}:\n$content';
    }).join('\n\n');
  } else {
    String content = value
        .toString()
        .replaceAll(RegExp(r'\[cite_start\]'), '')
        .replaceAll(RegExp(r'\[cite:\s*\d+(?:,\s*\d+)*\]'), '')
        .trim();
    return content;
  }
}

String _formatSectionTitle(String key) {
  // Handle special medical terminology cases
  final specialCases = {
    'definition_and_pain_character': 'Definition & Pain Character',
    'character_of_presentation': 'Character of Presentation',
    'clinical_examination': 'Clinical Examination',
    'differential_diagnosis': 'Differential Diagnosis',
    'investigations': 'Investigations',
    'management': 'Management',
    'management_plan_adults': 'Management Plan (Adults)',
    'management_adults': 'Management (Adults)',
    'red_flags': 'Red Flags',
    'redFlags': 'Red Flags',
    'pain_character': 'Pain Character',
    'definition': 'Definition',
  };

  // Return special case if exists
  if (specialCases.containsKey(key)) {
    return specialCases[key]!;
  }

  // Convert snake_case or camelCase to Title Case
  return key
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}')
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}
