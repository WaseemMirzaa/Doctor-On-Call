import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/bio_chemical_diagnosis/model/biochemical_emergencies.dart';

class BiochemicalEmergencyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'biochemical_emergencies';
  static const String _documentId =
      'ASrxuNaqxzYTNyPaDeqn'; // Your specific document ID

  /// Fetch all biochemical emergencies from the specific Firestore document
  static Future<List<BiochemicalEmergency>>
      getAllBiochemicalEmergencies() async {
    try {
      // Fetch the specific document instead of querying all documents
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      if (!docSnapshot.exists) {
        return [];
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return [];
      }

      List<BiochemicalEmergency> emergencies = [];

      // Check if the document has an 'emergencies' array field
      if (data.containsKey('emergencies') && data['emergencies'] is List) {
        final List<dynamic> emergenciesArray = data['emergencies'];

        for (int i = 0; i < emergenciesArray.length; i++) {
          var emergencyData = emergenciesArray[i];

          try {
            if (emergencyData is String) {
              // Parse JSON string - this is your case
              final Map<String, dynamic> parsedData = jsonDecode(emergencyData);
              final emergency = BiochemicalEmergency.fromJson(parsedData);
              emergencies.add(emergency);
            } else if (emergencyData is Map<String, dynamic>) {
              // If it's already a map, create BiochemicalEmergency directly
              final emergency = BiochemicalEmergency.fromJson(emergencyData);
              emergencies.add(emergency);
            } else {}
          } catch (e) {
            if (emergencyData is String && emergencyData.length > 100) {
            } else {}
            continue;
          }
        }
      } else {}

      // Print categories found for debugging
      final categories = emergencies.map((e) => e.category).toSet().toList();

      return emergencies;
    } catch (e) {
      throw Exception('Failed to fetch biochemical emergencies: $e');
    }
  }

  /// Get unique categories from all biochemical emergencies
  static Future<List<String>> getUniqueCategories() async {
    try {
      final List<BiochemicalEmergency> emergencies =
          await getAllBiochemicalEmergencies();

      // Extract unique categories (excluding empty ones)
      final Set<String> uniqueCategories = emergencies
          .map((emergency) => emergency.category)
          .where((category) => category.isNotEmpty)
          .toSet();

      final List<String> sortedCategories = uniqueCategories.toList()..sort();

      return sortedCategories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get items for the main list (categories + standalone titles)
  static Future<List<String>> getMainListItems() async {
    try {
      final List<BiochemicalEmergency> emergencies =
          await getAllBiochemicalEmergencies();

      // Get unique categories
      final Set<String> categories = emergencies
          .map((emergency) => emergency.category)
          .where((category) => category.isNotEmpty)
          .toSet();

      // Get standalone titles (items without categories)
      final List<String> standaloneTitles = emergencies
          .where((emergency) => emergency.category.isEmpty)
          .map((emergency) => emergency.title)
          .toList();

      // Combine categories and standalone titles
      final List<String> allItems = [...categories, ...standaloneTitles];
      allItems.sort();

      return allItems;
    } catch (e) {
      throw Exception('Failed to fetch main list items: $e');
    }
  }

  /// Check if an item is a category or a standalone title
  static Future<bool> isCategory(String item) async {
    try {
      final List<BiochemicalEmergency> emergencies =
          await getAllBiochemicalEmergencies();

      // Check if any emergency has this as a category
      final bool hasCategory =
          emergencies.any((emergency) => emergency.category == item);

      return hasCategory;
    } catch (e) {
      return false;
    }
  }

  /// Get titles within a specific category
  static Future<List<String>> getTitlesInCategory(String category) async {
    try {
      final List<BiochemicalEmergency> emergencies =
          await getAllBiochemicalEmergencies();

      final List<String> titles = emergencies
          .where((emergency) => emergency.category == category)
          .map((emergency) => emergency.title)
          .toList();

      return titles;
    } catch (e) {
      throw Exception('Failed to fetch titles in category: $e');
    }
  }

  /// Get emergency by title (for both categorized and standalone items)
  static Future<BiochemicalEmergency?> getEmergencyByTitle(String title) async {
    try {
      final List<BiochemicalEmergency> emergencies =
          await getAllBiochemicalEmergencies();

      final BiochemicalEmergency? emergency = emergencies
          .where((emergency) => emergency.title == title)
          .firstOrNull;

      if (emergency != null) {
      } else {}

      return emergency;
    } catch (e) {
      return null;
    }
  }

  /// Get emergencies by category
  static Future<List<BiochemicalEmergency>> getEmergenciesByCategory(
      String category) async {
    try {
      final List<BiochemicalEmergency> allEmergencies =
          await getAllBiochemicalEmergencies();

      final filteredEmergencies = allEmergencies
          .where((emergency) =>
              emergency.category.toLowerCase() == category.toLowerCase())
          .toList();

      return filteredEmergencies;
    } catch (e) {
      throw Exception('Failed to fetch emergencies by category: $e');
    }
  }

  /// Search emergencies by title or category
  static Future<List<BiochemicalEmergency>> searchEmergencies(
      String query) async {
    try {
      final List<BiochemicalEmergency> allEmergencies =
          await getAllBiochemicalEmergencies();

      final String lowerQuery = query.toLowerCase();

      final searchResults = allEmergencies.where((emergency) {
        return emergency.title.toLowerCase().contains(lowerQuery) ||
            emergency.category.toLowerCase().contains(lowerQuery);
      }).toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search emergencies: $e');
    }
  }

  /// Test connection to Firestore and verify document structure
  static Future<void> testConnection() async {
    try {
      final DocumentSnapshot docSnapshot =
          await _firestore.collection(_collectionName).doc(_documentId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;

        if (data?.containsKey('emergencies') == true) {
          final emergenciesArray = data!['emergencies'] as List?;

          if (emergenciesArray != null && emergenciesArray.isNotEmpty) {
            final firstItem = emergenciesArray.first;
            if (firstItem is String) {}
          }
        }
      } else {}
    } catch (e) {}
  }
}
