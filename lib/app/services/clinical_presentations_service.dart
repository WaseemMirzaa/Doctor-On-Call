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
      print('Fetching clinical presentations from Firestore...');

      // Fetch the specific document that contains all presentations
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      List<Map<String, dynamic>> presentations = [];

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          print('Document data keys: ${data.keys.toList()}');

          // Check if the document has a 'presentations' field
          if (data.containsKey('presentations')) {
            final presentationsData = data['presentations'];
            print('presentations field type: ${presentationsData.runtimeType}');
            print(
                'presentations data: ${presentationsData.toString().substring(0, 100)}...');

            if (presentationsData is List) {
              // Presentations is already a parsed List
              print(
                  'Presentations is already a List with ${presentationsData.length} items');

              for (int i = 0; i < presentationsData.length; i++) {
                dynamic item = presentationsData[i];

                if (item is Map<String, dynamic>) {
                  // Item is already a Map
                  print('Processing presentation $i: ${item.keys.toList()}');
                  print(
                      'Title: "${item['title']}", Category: "${item['category']}"');

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
                    print(
                        'Processing parsed presentation $i: ${parsedItem.keys.toList()}');
                    print(
                        'Title: "${parsedItem['title']}", Category: "${parsedItem['category']}"');

                    presentations.add({
                      'id': '${docSnapshot.id}_$i',
                      ...parsedItem,
                    });
                  } catch (e) {
                    print('Error parsing presentation item $i: $e');
                  }
                } else {
                  print('Unknown presentation item type: ${item.runtimeType}');
                }
              }
            } else if (presentationsData is String) {
              // Presentations is a JSON string, need to parse it
              try {
                // Clean the JSON string to remove malformed cite markers
                String jsonString = presentationsData.toString();

                // Remove [cite_start] markers that appear before quotes
                jsonString =
                    jsonString.replaceAll(RegExp(r'\[cite_start\]"'), '"');

                print('Cleaned JSON string length: ${jsonString.length}');
                final List<dynamic> parsedPresentations =
                    jsonDecode(jsonString);
                print(
                    'Parsed presentations count: ${parsedPresentations.length}');

                // Add each presentation with an ID
                for (int i = 0; i < parsedPresentations.length; i++) {
                  final presentation =
                      parsedPresentations[i] as Map<String, dynamic>;
                  print(
                      'Processing presentation $i: ${presentation.keys.toList()}');
                  print(
                      'Title: "${presentation['title']}", Category: "${presentation['category']}"');

                  presentations.add({
                    'id': '${docSnapshot.id}_$i', // Create unique ID
                    ...presentation,
                  });
                  print(
                      'Found presentation: ${presentation['title'] ?? 'Unknown Title'} - Category: ${presentation['category'] ?? 'Unknown Category'}');
                }
              } catch (e) {
                print('Error parsing presentations JSON: $e');
                print(
                    'JSON content preview: ${presentationsData.toString().substring(0, 500)}...');
              }
            } else if (presentationsData is Map<String, dynamic>) {
              // Presentations is a Map with numeric string keys (like "0", "1", "2", etc.)
              print(
                  'Presentations is a Map with keys: ${presentationsData.keys.toList()}');

              // Sort keys numerically to maintain order
              final sortedKeys = presentationsData.keys.toList()
                ..sort((a, b) {
                  final aNum = int.tryParse(a) ?? 0;
                  final bNum = int.tryParse(b) ?? 0;
                  return aNum.compareTo(bNum);
                });

              print('Sorted keys: $sortedKeys');

              for (String key in sortedKeys) {
                dynamic item = presentationsData[key];

                if (item is String) {
                  // Item is a JSON string, need to parse it
                  try {
                    final parsedItem = jsonDecode(item) as Map<String, dynamic>;
                    print(
                        'Processing parsed presentation $key: ${parsedItem.keys.toList()}');
                    print(
                        'Title: "${parsedItem['title']}", Category: "${parsedItem['category']}"');

                    presentations.add({
                      'id': '${docSnapshot.id}_$key',
                      ...parsedItem,
                    });
                  } catch (e) {
                    print('Error parsing presentation item $key: $e');
                  }
                } else if (item is Map<String, dynamic>) {
                  // Item is already a Map
                  print('Processing presentation $key: ${item.keys.toList()}');
                  print(
                      'Title: "${item['title']}", Category: "${item['category']}"');

                  presentations.add({
                    'id': '${docSnapshot.id}_$key',
                    ...item,
                  });
                } else {
                  print(
                      'Unknown presentation item type for key $key: ${item.runtimeType}');
                }
              }
            } else {
              print(
                  'presentations field is neither List, String, nor Map. Type: ${presentationsData.runtimeType}');
            }
          } else {
            print(
                'No presentations field found. Available fields: ${data.keys.toList()}');
          }
        }
      } else {
        print('Document icpSWM9Unsgx7esHSB4x does not exist');
      }

      print('Total presentations loaded: ${presentations.length}');
      return presentations;
    } catch (e) {
      print('Error fetching clinical presentations: $e');
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
            print('Could not parse presentations string, starting fresh: $e');
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

      print('Upserted ${titles.length} titles into category: $category');
    } catch (e) {
      print('Error upserting dropdown category: $e');
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
      print('Error fetching presentation by ID: $e');
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
      print('Found categories: $sortedCategories');
      return sortedCategories;
    } catch (e) {
      print('Error fetching categories: $e');
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

      print(
          'Found ${searchResults.length} presentations matching query: $query');
      return searchResults;
    } catch (e) {
      print('Error searching presentations: $e');
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
    } catch (e) {
      print('Error extracting red flags: $e');
    }

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
      print('Testing connection to clinical presentations...');

      final QuerySnapshot snapshot =
          await _firestore.collection(_collectionName).limit(1).get();

      print(
          'Connection successful. Documents available: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
        final data = firstDoc.data() as Map<String, dynamic>?;
        print('Sample document structure: ${data?.keys.toList()}');
      }
    } catch (e) {
      print('Connection test failed: $e');
    }
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
        print('Found presentation: ${presentation['title']}');
      } else {
        print('No presentation found with title: $title');
      }

      return presentation;
    } catch (e) {
      print('Error fetching presentation by title: $e');
      return null;
    }
  }
}
