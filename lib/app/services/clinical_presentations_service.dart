import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicalPresentationsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'clinical_presentations';
  // The single document that stores the entire presentations array (following existing practice)
  static const String _documentId = 'icpSWM9Unsgx7esHSB4x';

  /// Fetch all clinical presentations from Firestore
  static Future<List<Map<String, dynamic>>>
      getAllClinicalPresentations() async {
    try {
      // Fetch the specific document that contains all presentations
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      List<Map<String, dynamic>> presentations = [];

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          // Check if the document has a 'presentations' field
          if (data.containsKey('presentations')) {
            final presentationsData = data['presentations'];

            if (presentationsData is List) {
              // Presentations is already a parsed List

              for (int i = 0; i < presentationsData.length; i++) {
                dynamic item = presentationsData[i];

                if (item is Map<String, dynamic>) {
                  // Item is already a Map

                  presentations.add({
                    'id': '${docSnapshot.id}_$i',
                    ...item,
                  });
                } else if (item is String) {
                  // Item is a JSON string, need to parse it
                  try {
                    // Clean the JSON string to remove malformed cite markers
                    String cleanedJson = item.toString();
                    cleanedJson =
                        cleanedJson.replaceAll(RegExp(r'\[cite_start\]'), '');

                    final parsedItem =
                        jsonDecode(cleanedJson) as Map<String, dynamic>;

                    presentations.add({
                      'id': '${docSnapshot.id}_$i',
                      ...parsedItem,
                    });
                  } catch (e) {}
                } else {}
              }
            } else if (presentationsData is String) {
              // Presentations is a JSON string, need to parse it
              try {
                // Clean the JSON string to remove malformed cite markers
                String jsonString = presentationsData.toString();

                // Remove [cite_start] markers that appear before quotes
                jsonString =
                    jsonString.replaceAll(RegExp(r'\[cite_start\]"'), '"');

                final List<dynamic> parsedPresentations =
                    jsonDecode(jsonString);

                // Add each presentation with an ID
                for (int i = 0; i < parsedPresentations.length; i++) {
                  final presentation =
                      parsedPresentations[i] as Map<String, dynamic>;

                  presentations.add({
                    'id': '${docSnapshot.id}_$i', // Create unique ID
                    ...presentation,
                  });
                }
              } catch (e) {}
            } else if (presentationsData is Map<String, dynamic>) {
              // Presentations is a Map with numeric string keys (like "0", "1", "2", etc.)

              // Sort keys numerically to maintain order
              final sortedKeys = presentationsData.keys.toList()
                ..sort((a, b) {
                  final aNum = int.tryParse(a) ?? 0;
                  final bNum = int.tryParse(b) ?? 0;
                  return aNum.compareTo(bNum);
                });

              for (String key in sortedKeys) {
                dynamic item = presentationsData[key];

                if (item is String) {
                  // Item is a JSON string, need to parse it
                  try {
                    final parsedItem = jsonDecode(item) as Map<String, dynamic>;

                    presentations.add({
                      'id': '${docSnapshot.id}_$key',
                      ...parsedItem,
                    });
                  } catch (e) {}
                } else if (item is Map<String, dynamic>) {
                  // Item is already a Map

                  presentations.add({
                    'id': '${docSnapshot.id}_$key',
                    ...item,
                  });
                } else {}
              }
            } else {}
          } else {}
        }
      } else {}

      return presentations;
    } catch (e) {
      throw Exception('Failed to fetch clinical presentations: $e');
    }
  }

  /// Upsert a dropdown-style category with multiple titles into the single
  /// presentations document. This mirrors the existing practice used by
  /// `clinical_diagnosis` (one document containing an array of items).
  ///
  /// Example usage (call locally in the app):
  /// await ClinicalPresentationsService.upsertDropdownCategory(
  ///   'Chest Pain - Causes (Dropdown List)',
  ///   [
  ///     'Acute Coronary Syndrome (ACS)',
  ///     'Aortic Dissection',
  ///     'Pulmonary Embolism (PE)',
  ///     'Pericarditis',
  ///     'Tension Pneumothorax',
  ///     'Oesophageal Rupture (Boerhaave\'s)'
  ///   ],
  /// );
  static Future<void> upsertDropdownCategory(
      String category, List<String> titles) async {
    try {
      final DocumentReference docRef =
          _firestore.collection(_collectionName).doc(_documentId);

      final docSnapshot = await docRef.get();

      Map<String, dynamic> data = {};
      if (docSnapshot.exists) {
        data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      }

      List<dynamic> presentations = [];

      if (data.containsKey('presentations')) {
        final presentationsData = data['presentations'];

        if (presentationsData is List) {
          presentations = List<dynamic>.from(presentationsData);
        } else if (presentationsData is String) {
          try {
            presentations = jsonDecode(presentationsData) as List<dynamic>;
          } catch (e) {
            presentations = [];
          }
        }
      }

      // Append each title as a presentation item with the same category.
      for (final title in titles) {
        presentations.add({
          'category': category,
          'title': title,
        });
      }

      // Write back (merge to preserve other top-level keys if present)
      await docRef
          .set({'presentations': presentations}, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Get presentation by document ID
  static Future<Map<String, dynamic>?> getPresentationById(
      String documentId) async {
    try {
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(documentId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          return {
            'id': docSnapshot.id,
            ...data,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all unique categories from presentations
  static Future<List<String>> getCategories() async {
    try {
      final presentations = await getAllClinicalPresentations();
      final Set<String> categories = {};

      for (var presentation in presentations) {
        final category = presentation['category'];
        if (category != null && category.toString().isNotEmpty) {
          categories.add(category.toString());
        }
      }

      final sortedCategories = categories.toList()..sort();
      return sortedCategories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Search presentations by category or title
  static Future<List<Map<String, dynamic>>> searchPresentations(
      String query) async {
    try {
      final allPresentations = await getAllClinicalPresentations();
      final String lowerQuery = query.toLowerCase();

      final searchResults = allPresentations.where((presentation) {
        final category =
            (presentation['category']?.toString() ?? '').toLowerCase();
        final title = (presentation['title']?.toString() ?? '').toLowerCase();

        return category.contains(lowerQuery) || title.contains(lowerQuery);
      }).toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search presentations: $e');
    }
  }

  /// Extract red flags from presentation data
  static List<String> extractRedFlags(Map<String, dynamic> presentationData) {
    List<String> redFlags = [];

    try {
      // Check for red_flags field directly
      if (presentationData.containsKey('red_flags')) {
        final redFlagsData = presentationData['red_flags'];

        if (redFlagsData is List) {
          redFlags = redFlagsData.map((flag) => flag.toString()).toList();
        } else if (redFlagsData is String) {
          // Try to parse as JSON if it's a string
          try {
            final parsed = jsonDecode(redFlagsData);
            if (parsed is List) {
              redFlags = parsed.map((flag) => flag.toString()).toList();
            }
          } catch (e) {
            // If parsing fails, treat as single string
            redFlags = [redFlagsData];
          }
        }
      }

      // Also check for other possible red flag keys
      final possibleKeys = ['redFlags', 'red-flags', 'warnings', 'alerts'];
      for (String key in possibleKeys) {
        if (presentationData.containsKey(key) && redFlags.isEmpty) {
          final data = presentationData[key];
          if (data is List) {
            redFlags = data.map((flag) => flag.toString()).toList();
            break;
          } else if (data is String) {
            redFlags = [data];
            break;
          }
        }
      }
    } catch (e) {}

    return redFlags;
  }

  /// Get formatted presentation data for display
  static Map<String, dynamic> formatPresentationForDisplay(
      Map<String, dynamic> rawData) {
    return {
      'id': rawData['id'],
      'category': rawData['category'] ?? 'Unknown Category',
      'title': rawData['title'] ?? 'Unknown Title',
      'red_flags': extractRedFlags(rawData),
      'raw_data': rawData, // Keep original data for detail view
    };
  }

  /// Test connection to Firestore
  static Future<void> testConnection() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(_collectionName).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
        final data = firstDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {}
  }

  static Future<Map<String, dynamic>?> getPresentationByTitle(
      String title) async {
    try {
      final List<Map<String, dynamic>> presentations =
          await getAllClinicalPresentations();

      final Map<String, dynamic>? presentation = presentations
          .where((presentation) => presentation.containsValue(title))
          .firstOrNull;

      if (presentation != null) {
      } else {}

      return presentation;
    } catch (e) {
      return null;
    }
  }
}
