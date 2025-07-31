// models/clinical_diagnosis_model.dart

class ClinicalDiagnosis {
  final String category;
  final String title;
  final ClinicalDefinition definition;
  final List<String> symptoms;
  final List<String> signs;
  final List<String> investigations;
  final List<String> diagnosis;
  final List<dynamic> managementEmergency;
  final List<String> redFlags;
  final List<dynamic> prognosisDisposition;
  final List<String> ctHeadIndications;

  ClinicalDiagnosis({
    required this.category,
    required this.title,
    required this.definition,
    required this.symptoms,
    required this.signs,
    required this.investigations,
    required this.diagnosis,
    required this.managementEmergency,
    required this.redFlags,
    required this.prognosisDisposition,
    required this.ctHeadIndications,
  });

  factory ClinicalDiagnosis.fromJson(Map<String, dynamic> json) {
    return ClinicalDiagnosis(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      definition: ClinicalDefinition.fromJson(json['definition'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      signs: List<String>.from(json['signs'] ?? []),
      investigations: List<String>.from(json['investigations'] ?? []),
      diagnosis: List<String>.from(json['diagnosis'] ?? []),
      managementEmergency: json['management_emergency'] is List
          ? List<dynamic>.from(json['management_emergency'] ?? [])
          : [],
      redFlags: List<String>.from(json['red_flags'] ?? []),
      prognosisDisposition: json['prognosis_disposition'] is List
          ? List<dynamic>.from(json['prognosis_disposition'] ?? [])
          : [],
      ctHeadIndications: List<String>.from(json['ct_head_indications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'definition': definition.toJson(),
      'symptoms': symptoms,
      'signs': signs,
      'investigations': investigations,
      'diagnosis': diagnosis,
      'management_emergency': managementEmergency,
      'red_flags': redFlags,
      'prognosis_disposition': prognosisDisposition,
      'ct_head_indications': ctHeadIndications,
    };
  }
}

class ClinicalDefinition {
  final String? criteria;
  final List<String> notes;

  ClinicalDefinition({
    this.criteria,
    required this.notes,
  });

  factory ClinicalDefinition.fromJson(Map<String, dynamic> json) {
    return ClinicalDefinition(
      criteria: json['criteria'],
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria,
      'notes': notes,
    };
  }
}
