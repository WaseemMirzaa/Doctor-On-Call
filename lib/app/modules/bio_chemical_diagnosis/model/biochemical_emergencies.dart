// models/biochemical_emergency_model.dart

class BiochemicalEmergency {
  final String category;
  final String title;
  final Definition definition;
  final List<String> symptoms;
  final List<String> signs;
  final List<String> investigations;
  final List<String> diagnosis;
  final List<dynamic> managementNonEmergency; // Can be String or Map
  final List<dynamic> managementEmergency; // Can be String or Map
  final List<String> redFlags;
  final List<String> prognosisDisposition;

  BiochemicalEmergency({
    required this.category,
    required this.title,
    required this.definition,
    required this.symptoms,
    required this.signs,
    required this.investigations,
    required this.diagnosis,
    required this.managementNonEmergency,
    required this.managementEmergency,
    required this.redFlags,
    required this.prognosisDisposition,
  });

  factory BiochemicalEmergency.fromJson(Map<String, dynamic> json) {
    return BiochemicalEmergency(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      definition: Definition.fromJson(json['definition'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      signs: List<String>.from(json['signs'] ?? []),
      investigations: List<String>.from(json['investigations'] ?? []),
      diagnosis: List<String>.from(json['diagnosis'] ?? []),
      managementNonEmergency: json['management_non_emergency'] is List
          ? List<dynamic>.from(json['management_non_emergency'] ?? [])
          : [],
      managementEmergency: json['management_emergency'] is List
          ? List<dynamic>.from(json['management_emergency'] ?? [])
          : [],
      redFlags: List<String>.from(json['red_flags'] ?? []),
      prognosisDisposition:
          List<String>.from(json['prognosis_disposition'] ?? []),
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
      'management_non_emergency': managementNonEmergency,
      'management_emergency': managementEmergency,
      'red_flags': redFlags,
      'prognosis_disposition': prognosisDisposition,
    };
  }
}

class Definition {
  final String? serumCorrectedCalcium;
  final String? serumPotassium;
  final String? serumSodium;
  final String? criteria;
  final String? source;
  final List<String> notes;

  Definition({
    this.serumCorrectedCalcium,
    this.serumPotassium,
    this.serumSodium,
    this.criteria,
    this.source,
    required this.notes,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      serumCorrectedCalcium: json['serum_corrected_calcium'],
      serumPotassium: json['serum_potassium'],
      serumSodium: json['serum_sodium'],
      criteria: json['criteria'],
      source: json['source'],
      notes: List<String>.from(json['notes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serum_corrected_calcium': serumCorrectedCalcium,
      'serum_potassium': serumPotassium,
      'serum_sodium': serumSodium,
      'criteria': criteria,
      'source': source,
      'notes': notes,
    };
  }
}
