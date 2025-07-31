import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../modules/clinical_diagnosis/model/clinical_diagnosis.dart';

class ClinicalDiagnosisServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'clinical_diagnosis';
  static const String _documentId = '6iC8ReLGZxyL6jYFFx4K';

  /// Fetch all clinical diagnosis from the specific Firestore document
  static Future<List<ClinicalDiagnosis>> getAllClinicalDiagnosis() async {
    try {
      print(
          'Fetching data from Firestore document: $_collectionName/$_documentId');

      // Fetch the specific document instead of querying all documents
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      if (!docSnapshot.exists) {
        print('Document $_documentId does not exist');
        return [];
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        print('Document data is null');
        return [];
      }

      print('Document data keys: ${data.keys.toList()}');

      List<ClinicalDiagnosis> diagnosis = [];

      // Check if the document has an 'diagnosis' array field
      if (data.containsKey('diagnosis') && data['diagnosis'] is List) {
        final List<dynamic> diagnosisArray = data['diagnosis'];
        print(
            'Found clinical diagnosis array with ${diagnosisArray.length} items');

        int successCount = 0;
        int errorCount = 0;
        List<String> failedEntries = [];

        for (int i = 0; i < diagnosisArray.length; i++) {
          var diagnosisData = diagnosisArray[i];
          print(
              'Processing entry $i/${diagnosisArray.length - 1}: ${diagnosisData.runtimeType}');

          try {
            if (diagnosisData is String) {
              // Parse JSON string - this is your case
              final Map<String, dynamic> parsedData = jsonDecode(diagnosisData);
              final clinicalDiagnosis = ClinicalDiagnosis.fromJson(parsedData);
              diagnosis.add(clinicalDiagnosis);
              successCount++;
              print(
                  '✅ Entry $i: ${clinicalDiagnosis.category} - ${clinicalDiagnosis.title}');
            } else if (diagnosisData is Map<String, dynamic>) {
              // If it's already a map, create ClinicalDiagnosis directly
              final clinicalDiagnosis =
                  ClinicalDiagnosis.fromJson(diagnosisData);
              diagnosis.add(clinicalDiagnosis);
              successCount++;
              print(
                  '✅ Entry $i: ${clinicalDiagnosis.category} - ${clinicalDiagnosis.title}');
            } else {
              errorCount++;
              failedEntries.add(
                  'Entry $i: Unknown data type ${diagnosisData.runtimeType}');
              print(
                  '❌ Entry $i: Skipping unknown data type: ${diagnosisData.runtimeType}');
            }
          } catch (e) {
            errorCount++;
            failedEntries.add('Entry $i: Parse error - $e');
            print('❌ Entry $i: Error parsing diagnosis data: $e');

            // Show more detailed error info
            if (diagnosisData is String) {
              if (diagnosisData.length > 200) {
                print('   Data preview: ${diagnosisData.substring(0, 200)}...');
              } else {
                print('   Full data: $diagnosisData');
              }
            } else {
              print('   Data: $diagnosisData');
            }
            continue;
          }
        }

        print('=== PARSING SUMMARY ===');
        print('Total entries in Firestore: ${diagnosisArray.length}');
        print('Successfully parsed: $successCount');
        print('Failed to parse: $errorCount');
        if (failedEntries.isNotEmpty) {
          print('Failed entries:');
          for (String failure in failedEntries) {
            print('  - $failure');
          }
        }
        print('=== END SUMMARY ===');
      } else {
        print('Document does not contain diagnosis array or it is not a List');
        print('Available fields: ${data.keys.toList()}');
      }

      print('Total diagnosis parsed: ${diagnosis.length}');

      // Print categories found for debugging
      final categories = diagnosis.map((e) => e.category).toSet().toList();
      print('Categories found: $categories');

      // Debug: Print all loaded titles by category
      Map<String, List<String>> categorizedTitles = {};
      for (var clinicalDiagnosis in diagnosis) {
        if (!categorizedTitles.containsKey(clinicalDiagnosis.category)) {
          categorizedTitles[clinicalDiagnosis.category] = [];
        }
        categorizedTitles[clinicalDiagnosis.category]!
            .add(clinicalDiagnosis.title);
      }

      print('=== DEBUG: All loaded clinical diagnoses by category ===');
      categorizedTitles.forEach((category, titles) {
        print('$category (${titles.length} titles):');
        for (int i = 0; i < titles.length; i++) {
          print('  ${i + 1}. ${titles[i]}');
        }
      });
      print('=== End debug info ===');

      return diagnosis;
    } catch (e) {
      print('Error fetching biochemical diagnosis: $e');
      throw Exception('Failed to fetch biochemical diagnosis: $e');
    }
  }

  /// Get unique categories from all biochemical diagnosis
  static Future<List<String>> getUniqueCategories() async {
    try {
      final List<ClinicalDiagnosis> diagnosis = await getAllClinicalDiagnosis();

      // Extract unique categories (excluding empty ones)
      final Set<String> uniqueCategories = diagnosis
          .map((clinicalDiagnosis) => clinicalDiagnosis.category)
          .where((category) => category.isNotEmpty)
          .toSet();

      final List<String> sortedCategories = uniqueCategories.toList()..sort();
      print('Unique categories: $sortedCategories');

      return sortedCategories;
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get items for the main list (categories + standalone titles)
  static Future<List<String>> getMainListItems() async {
    try {
      final List<ClinicalDiagnosis> diagnosis = await getAllClinicalDiagnosis();

      // Get unique categories
      final Set<String> categories = diagnosis
          .map((clinicalDiagnosis) => clinicalDiagnosis.category)
          .where((category) => category.isNotEmpty)
          .toSet();

      // Get standalone titles (items without categories)
      final List<String> standaloneTitles = diagnosis
          .where((clinicalDiagnosis) => clinicalDiagnosis.category.isEmpty)
          .map((clinicalDiagnosis) => clinicalDiagnosis.title)
          .toList();

      // Combine categories and standalone titles
      final List<String> allItems = [...categories, ...standaloneTitles];
      allItems.sort();

      print('Main list items: $allItems');
      print(
          'Categories: ${categories.length}, Standalone titles: ${standaloneTitles.length}');

      return allItems;
    } catch (e) {
      print('Error fetching main list items: $e');
      throw Exception('Failed to fetch main list items: $e');
    }
  }

  /// Check if an item is a category or a standalone title
  static Future<bool> isCategory(String item) async {
    try {
      final List<ClinicalDiagnosis> diagnosis = await getAllClinicalDiagnosis();

      // Check if any diagnosis has this as a category
      final bool hasCategory = diagnosis
          .any((clinicalDiagnosis) => clinicalDiagnosis.category == item);

      return hasCategory;
    } catch (e) {
      print('Error checking if item is category: $e');
      return false;
    }
  }

  /// Get titles within a specific category
  static Future<List<String>> getTitlesInCategory(String category) async {
    try {
      final List<ClinicalDiagnosis> diagnosis = await getAllClinicalDiagnosis();

      final List<String> titles = diagnosis
          .where((clinicalDiagnosis) => clinicalDiagnosis.category == category)
          .map((clinicalDiagnosis) => clinicalDiagnosis.title)
          .toList();

      print('Found ${titles.length} titles in category: $category');

      return titles;
    } catch (e) {
      print('Error fetching titles in category: $e');
      throw Exception('Failed to fetch titles in category: $e');
    }
  }

  /// Get diagnosis by title (for both categorized and standalone items)
  static Future<ClinicalDiagnosis?> getEmergencyByTitle(String title) async {
    try {
      final List<ClinicalDiagnosis> diagnosis = await getAllClinicalDiagnosis();

      final ClinicalDiagnosis? clinicalDiagnosis = diagnosis
          .where((clinicalDiagnosis) => clinicalDiagnosis.title == title)
          .firstOrNull;

      if (clinicalDiagnosis != null) {
        print('Found diagnosis: ${clinicalDiagnosis.title}');
      } else {
        print('No diagnosis found with title: $title');
      }

      return clinicalDiagnosis;
    } catch (e) {
      print('Error fetching diagnosis by title: $e');
      return null;
    }
  }

  /// Get diagnosis by category
  static Future<List<ClinicalDiagnosis>> getdiagnosisByCategory(
      String category) async {
    try {
      final List<ClinicalDiagnosis> alldiagnosis =
          await getAllClinicalDiagnosis();

      final filtereddiagnosis = alldiagnosis
          .where((emergency) =>
              emergency.category.toLowerCase() == category.toLowerCase())
          .toList();

      print(
          'Found ${filtereddiagnosis.length} diagnosis for category: $category');

      return filtereddiagnosis;
    } catch (e) {
      print('Error fetching diagnosis by category: $e');
      throw Exception('Failed to fetch diagnosis by category: $e');
    }
  }

  /// Search diagnosis by title or category
  static Future<List<ClinicalDiagnosis>> searchdiagnosis(String query) async {
    try {
      final List<ClinicalDiagnosis> alldiagnosis =
          await getAllClinicalDiagnosis();

      final String lowerQuery = query.toLowerCase();

      final searchResults = alldiagnosis.where((emergency) {
        return emergency.title.toLowerCase().contains(lowerQuery) ||
            emergency.category.toLowerCase().contains(lowerQuery);
      }).toList();

      print('Found ${searchResults.length} diagnosis matching query: $query');

      return searchResults;
    } catch (e) {
      print('Error searching diagnosis: $e');
      throw Exception('Failed to search diagnosis: $e');
    }
  }

  /// Test connection to Firestore and verify document structure
  static Future<void> testConnection() async {
    try {
      print('Testing connection to Firestore...');

      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        print('Document exists with keys: ${data?.keys.toList()}');

        if (data?.containsKey('diagnosis') == true) {
          final diagnosisArray = data!['diagnosis'] as List?;
          print('diagnosis array length: ${diagnosisArray?.length}');

          if (diagnosisArray != null && diagnosisArray.isNotEmpty) {
            final firstItem = diagnosisArray.first;
            print('First item type: ${firstItem.runtimeType}');
            if (firstItem is String) {
              print('First item preview: ${firstItem.substring(0, 50)}...');
            }
          }
        }
      } else {
        print('Document does not exist!');
      }
    } catch (e) {
      print('Connection test failed: $e');
    }
  }
}
