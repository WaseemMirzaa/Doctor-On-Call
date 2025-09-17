import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/app/widgets/custom_header.dart';
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
    // Get the presentation title for the header
    final presentationTitle =
        presentation['title']?.toString() ?? 'Clinical Presentation';

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom header showing the subcategory (presentation title)
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: Column(
                children: [
                  CommonTitleSection(
                    title: presentationTitle,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        children: [..._buildDynamicSections(presentation)])))
          ],
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

    // Get all available keys and preserve their original order from JSON
    final availableKeys = data.keys
        .where((key) => !skipKeys.contains(key) && data[key] != null)
        .toList();

    // Use the natural order from JSON - no custom sorting
    // The data from Firebase already comes in the order you specified

    // Add sections in their natural JSON order
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
        }
        // Special handling for same day referral
        else if (_isReferralKey(key)) {
          sections.add(
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.txtWhiteColor,
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: MedicalExpansionTile(
                title: 'When to Refer Same Day',
                content: content,
                isRedFlag: false,
                isRedContent: false,
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

bool _isReferralKey(String key) {
  final referralKeys = [
    'when_to_refer_same_day',
    'same_day_referral',
    'urgent_referral',
    'referral',
    'refer_same_day',
    'when_to_refer'
  ];
  return referralKeys.contains(key);
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
    // Top priority sections
    'symptoms': 'Symptoms',
    'symptom': 'Symptoms',
    'definition': 'Definition',
    'definition_and_pain_character': 'Definition & Pain Character',
    'character_of_presentation': 'Character of Presentation',
    'presentation': 'Presentation',
    'pain_character': 'Pain Character',

    // Definition & Characterization
    'definition_characterization': 'Definition & Characterization',
    'characterization': 'Characterization',
    'character': 'Character',

    // Diagnosis
    'differential_diagnosis': 'Differential Diagnosis',
    'differential': 'Differential Diagnosis',
    'diagnosis': 'Diagnosis',

    // Clinical Examination
    'clinical_examination': 'Clinical Examination',
    'examination': 'Clinical Examination',
    'clinical_findings': 'Clinical Findings',
    'findings': 'Findings',
    'physical_examination': 'Physical Examination',

    // Investigations
    'investigations': 'Investigations',
    'tests': 'Tests',
    'laboratory': 'Laboratory Tests',
    'diagnostic_tests': 'Diagnostic Tests',
    'lab_tests': 'Laboratory Tests',

    // Management
    'management': 'Management',
    'management_plan': 'Management Plan',
    'management_plan_adults': 'Management Plan (Adults)',
    'management_adults': 'Management (Adults)',
    'treatment': 'Treatment',
    'therapy': 'Therapy',

    // Red Flags
    'red_flags': 'Red Flags',
    'redFlags': 'Red Flags',
    'red-flags': 'Red Flags',
    'warnings': 'Red Flags',
    'alerts': 'Red Flags',

    // Referral
    'when_to_refer_same_day': 'When to Refer Same Day',
    'same_day_referral': 'When to Refer Same Day',
    'urgent_referral': 'When to Refer Same Day',
    'referral': 'When to Refer Same Day',
    'refer_same_day': 'When to Refer Same Day',
    'when_to_refer': 'When to Refer Same Day',
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
