import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/bio_chemical_diagnosis/model/biochemical_emergencies.dart';

class BiochemicalEmergencyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'biochemical_emergencies';
  static const String _documentId = 'ASrxuNaqxzYTNyPaDeqn'; // Your specific document ID

  /// Fetch all biochemical emergencies from the specific Firestore document
  static Future<List<BiochemicalEmergency>> getAllBiochemicalEmergencies() async {
    try {
      print('Fetching data from Firestore document: $_collectionName/$_documentId');

      // Fetch the specific document instead of querying all documents
      final DocumentSnapshot docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

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

      List<BiochemicalEmergency> emergencies = [];

      // Check if the document has an 'emergencies' array field
      if (data.containsKey('emergencies') && data['emergencies'] is List) {
        final List<dynamic> emergenciesArray = data['emergencies'];
        print('Found emergencies array with ${emergenciesArray.length} items');

        for (int i = 0; i < emergenciesArray.length; i++) {
          var emergencyData = emergenciesArray[i];
          print('Processing emergency item $i: ${emergencyData.runtimeType}');

          try {
            if (emergencyData is String) {
              // Parse JSON string - this is your case
              print('Attempting to parse JSON string...');
              final Map<String, dynamic> parsedData = jsonDecode(emergencyData);
              final emergency = BiochemicalEmergency.fromJson(parsedData);
              emergencies.add(emergency);
              print('Successfully parsed emergency from JSON string: ${emergency.category} - ${emergency.title}');
            } else if (emergencyData is Map<String, dynamic>) {
              // If it's already a map, create BiochemicalEmergency directly
              final emergency = BiochemicalEmergency.fromJson(emergencyData);
              emergencies.add(emergency);
              print('Successfully parsed emergency from map: ${emergency.category} - ${emergency.title}');
            } else {
              print('Skipping unknown data type: ${emergencyData.runtimeType}');
            }
          } catch (e) {
            print('Error parsing emergency data at index $i: $e');
            if (emergencyData is String && emergencyData.length > 100) {
              print('Emergency data preview: ${emergencyData.substring(0, 100)}...');
            } else {
              print('Emergency data: $emergencyData');
            }
            continue;
          }
        }
      } else {
        print('Document does not contain emergencies array or it is not a List');
        print('Available fields: ${data.keys.toList()}');
      }

      print('Total emergencies parsed: ${emergencies.length}');
      
      // Print categories found for debugging
      final categories = emergencies.map((e) => e.category).toSet().toList();
      print('Categories found: $categories');
      
      return emergencies;
    } catch (e) {
      print('Error fetching biochemical emergencies: $e');
      throw Exception('Failed to fetch biochemical emergencies: $e');
    }
  }

  /// Get unique categories from all biochemical emergencies
  static Future<List<String>> getUniqueCategories() async {
    try {
      final List<BiochemicalEmergency> emergencies = await getAllBiochemicalEmergencies();
      
      // Extract unique categories
      final Set<String> uniqueCategories = emergencies
          .map((emergency) => emergency.category)
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

  /// Get emergencies by category
  static Future<List<BiochemicalEmergency>> getEmergenciesByCategory(String category) async {
    try {
      final List<BiochemicalEmergency> allEmergencies = await getAllBiochemicalEmergencies();
      
      final filteredEmergencies = allEmergencies
          .where((emergency) => emergency.category.toLowerCase() == category.toLowerCase())
          .toList();
          
      print('Found ${filteredEmergencies.length} emergencies for category: $category');
      
      return filteredEmergencies;
    } catch (e) {
      print('Error fetching emergencies by category: $e');
      throw Exception('Failed to fetch emergencies by category: $e');
    }
  }

  /// Search emergencies by title or category
  static Future<List<BiochemicalEmergency>> searchEmergencies(String query) async {
    try {
      final List<BiochemicalEmergency> allEmergencies = await getAllBiochemicalEmergencies();
      
      final String lowerQuery = query.toLowerCase();
      
      final searchResults = allEmergencies.where((emergency) {
        return emergency.title.toLowerCase().contains(lowerQuery) ||
               emergency.category.toLowerCase().contains(lowerQuery);
      }).toList();
      
      print('Found ${searchResults.length} emergencies matching query: $query');
      
      return searchResults;
    } catch (e) {
      print('Error searching emergencies: $e');
      throw Exception('Failed to search emergencies: $e');
    }
  }

  /// Test connection to Firestore and verify document structure
  static Future<void> testConnection() async {
    try {
      print('Testing connection to Firestore...');
      
      final DocumentSnapshot docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        print('Document exists with keys: ${data?.keys.toList()}');
        
        if (data?.containsKey('emergencies') == true) {
          final emergenciesArray = data!['emergencies'] as List?;
          print('Emergencies array length: ${emergenciesArray?.length}');
          
          if (emergenciesArray != null && emergenciesArray.isNotEmpty) {
            final firstItem = emergenciesArray.first;
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
