import 'dart:convert';
import 'package:dr_on_call/app/services/clinical_presentations_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/clinical_diagnosis.dart';
import '../../../services/biochemical_emergency_service.dart';
import '../../../routes/app_pages.dart';
import '../../../helpers/subscription_access_helper.dart';

enum SearchFilter {
  all,
  clinicalDiagnosis,
  biochemicalEmergency,
  clinicalPresentations
}

class SearchResultItem {
  final String id;
  final String title;
  final String category;
  final SearchFilter type;
  final DateTime? lastSearched;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    this.lastSearched,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'type': type.toString(),
      'lastSearched': lastSearched?.millisecondsSinceEpoch,
    };
  }

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      type: SearchFilter.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SearchFilter.all,
      ),
      lastSearched: json['lastSearched'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSearched'])
          : null,
    );
  }
}

class SearchController extends GetxController {
  // Search functionality
  final searchController = TextEditingController();
  final searchResults = <SearchResultItem>[].obs;
  final searchHistory = <SearchResultItem>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Filter functionality
  final selectedFilter = SearchFilter.all.obs;
  final isFilterApplied = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();

    // Listen to search text changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      if (searchController.text.isEmpty) {
        searchResults.clear();
      } else {
        performSearch(searchController.text);
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Set search filter
  void setFilter(SearchFilter filter) {
    selectedFilter.value = filter;
    isFilterApplied.value = filter != SearchFilter.all;

    // Re-perform search if there's a query
    if (searchController.text.isNotEmpty) {
      performSearch(searchController.text);
    }
  }

  /// Clear all filters
  void clearFilters() {
    selectedFilter.value = SearchFilter.all;
    isFilterApplied.value = false;

    // Re-perform search if there's a query
    if (searchController.text.isNotEmpty) {
      performSearch(searchController.text);
    }
  }

  /// Load search history from SharedPreferences
  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('search_history') ?? [];

      searchHistory.value = historyJson
          .map((json) => SearchResultItem.fromJson(Map<String, dynamic>.from(
              jsonDecode(json) as Map<String, dynamic>)))
          .toList();

      // Sort by last searched date
      searchHistory.sort((a, b) => (b.lastSearched ?? DateTime(0))
          .compareTo(a.lastSearched ?? DateTime(0)));
    } catch (e) {}
  }

  /// Save search history to SharedPreferences
  Future<void> saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          searchHistory.map((item) => jsonEncode(item.toJson())).toList();

      await prefs.setStringList('search_history', historyJson);
    } catch (e) {}
  }

  /// Perform search across clinical diagnosis and biochemical emergencies
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    searchResults.clear();

    try {
      List<SearchResultItem> results = [];

      // Search in clinical diagnosis if filter allows
      if (selectedFilter.value == SearchFilter.all ||
          selectedFilter.value == SearchFilter.clinicalDiagnosis) {
        final clinicalResults = await _searchClinicalDiagnosis(query);
        results.addAll(clinicalResults);
      }

      // Search in biochemical emergencies if filter allows
      if (selectedFilter.value == SearchFilter.all ||
          selectedFilter.value == SearchFilter.biochemicalEmergency) {
        final biochemicalResults = await _searchBiochemicalEmergencies(query);
        results.addAll(biochemicalResults);
      }
      if (selectedFilter.value == SearchFilter.all ||
          selectedFilter.value == SearchFilter.clinicalPresentations) {
        final clinicalPresentationResults =
            await _searchClinicalPresentations(query);
        results.addAll(clinicalPresentationResults);
      }
      searchResults.value = results;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Search in clinical diagnosis data
  Future<List<SearchResultItem>> _searchClinicalDiagnosis(String query) async {
    try {
      final allDiagnosis =
          await ClinicalDiagnosisServices.getAllClinicalDiagnosis();
      final results = <SearchResultItem>[];
      final addedCategories = <String>{};

      for (final diagnosis in allDiagnosis) {
        // Add individual diagnosis items
        if (diagnosis.title.toLowerCase().contains(query.toLowerCase())) {
          results.add(SearchResultItem(
            id: '${diagnosis.category}_${diagnosis.title}',
            title: diagnosis.title,
            category: diagnosis.category,
            type: SearchFilter.clinicalDiagnosis,
          ));
        }

        // Add category items if category name matches and not already added
        if (diagnosis.category.toLowerCase().contains(query.toLowerCase()) &&
            !addedCategories.contains(diagnosis.category)) {
          results.add(SearchResultItem(
            id: 'category_clinical_${diagnosis.category}',
            title: diagnosis.category,
            category: 'Category',
            type: SearchFilter.clinicalDiagnosis,
          ));
          addedCategories.add(diagnosis.category);
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Search in biochemical emergencies data
  Future<List<SearchResultItem>> _searchBiochemicalEmergencies(
      String query) async {
    try {
      final allEmergencies =
          await BiochemicalEmergencyService.getAllBiochemicalEmergencies();
      final results = <SearchResultItem>[];
      final addedCategories = <String>{};

      for (final emergency in allEmergencies) {
        // Add individual emergency items
        if (emergency.title.toLowerCase().contains(query.toLowerCase())) {
          results.add(SearchResultItem(
            id: '${emergency.category}_${emergency.title}',
            title: emergency.title,
            category: emergency.category,
            type: SearchFilter.biochemicalEmergency,
          ));
        }

        // Add category items if category name matches and not already added
        if (emergency.category.toLowerCase().contains(query.toLowerCase()) &&
            !addedCategories.contains(emergency.category)) {
          results.add(SearchResultItem(
            id: 'category_biochemical_${emergency.category}',
            title: emergency.category,
            category: 'Category',
            type: SearchFilter.biochemicalEmergency,
          ));
          addedCategories.add(emergency.category);
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Search in clinical presentations data
  Future<List<SearchResultItem>> _searchClinicalPresentations(
      String query) async {
    try {
      final allPresentations =
          await ClinicalPresentationsService.getAllClinicalPresentations();
      final results = <SearchResultItem>[];
      final addedCategories = <String>{};

      for (final presentation in allPresentations) {
        // Add individual presentation items
        if ((presentation['title']?.toString() ?? '')
            .toLowerCase()
            .contains(query.toLowerCase())) {
          results.add(SearchResultItem(
            id: '${presentation['category']}_${presentation['title']}',
            title: presentation['title']?.toString() ?? 'Unknown',
            category: presentation['category']?.toString() ?? 'Unknown',
            type: SearchFilter.clinicalPresentations,
          ));
        }

        // Add category items if category name matches and not already added
        final categoryName = presentation['category']?.toString() ?? '';
        if (categoryName.toLowerCase().contains(query.toLowerCase()) &&
            !addedCategories.contains(categoryName)) {
          results.add(SearchResultItem(
            id: 'category_clinical_presentations_$categoryName',
            title: categoryName,
            category: 'Category',
            type: SearchFilter.clinicalPresentations,
          ));
          addedCategories.add(categoryName);
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Add item to search history
  Future<void> addToSearchHistory(SearchResultItem item) async {
    // Remove if already exists
    searchHistory.removeWhere((historyItem) => historyItem.id == item.id);

    // Add to beginning with current timestamp
    final historyItem = SearchResultItem(
      id: item.id,
      title: item.title,
      category: item.category,
      type: item.type,
      lastSearched: DateTime.now(),
    );

    searchHistory.insert(0, historyItem);

    // Keep only last 20 items
    if (searchHistory.length > 20) {
      searchHistory.removeRange(20, searchHistory.length);
    }

    await saveSearchHistory();
  }

  /// Navigate to item details based on type
  Future<void> navigateToItemDetails(SearchResultItem item) async {
    // Add to search history
    await addToSearchHistory(item);

    try {
      switch (item.type) {
        case SearchFilter.clinicalDiagnosis:
          await _navigateToClinicalDetails(item);
          break;
        case SearchFilter.biochemicalEmergency:
          await _navigateToBiochemicalDetails(item);
          break;
        case SearchFilter.clinicalPresentations:
          await _navigateToClinicalPresentationsDetails(item);
          break;
        case SearchFilter.all:
          // This shouldn't happen for individual items
          break;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load details');
    }
  }

  /// Navigate to clinical diagnosis details
  Future<void> _navigateToClinicalDetails(SearchResultItem item) async {
    try {
      // Check if this is a category item
      if (item.id.startsWith('category_clinical_')) {
        // Navigate to clinical diagnosis screen with category
        Get.toNamed(
          Routes.CLINICAL_DIAGNOSIS,
          arguments: {
            'selectedCategory': item.title,
            'showCategoryView': true,
          },
        );
        return;
      }

      // Load diagnosis data by title
      final diagnosis =
          await ClinicalDiagnosisServices.getEmergencyByTitle(item.title);

      if (diagnosis != null) {
        await SubscriptionAccessHelper.checkAccessAndNavigate(
          routeName: Routes.CLINICAL_DETAILS,
          arguments: {
            'title': item.title,
            'category': item.category,
            'diagnoses': [diagnosis],
          },
          contentType: 'clinical',
        );
      } else {
        // Navigate to clinical diagnosis screen with category
        Get.toNamed(
          Routes.CLINICAL_DIAGNOSIS,
          arguments: {
            'selectedCategory': item.category,
            'showCategoryView': true,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clinical diagnosis details');
    }
  }

  /// Navigate to biochemical emergency details
  Future<void> _navigateToBiochemicalDetails(SearchResultItem item) async {
    try {
      // Check if this is a category item
      if (item.id.startsWith('category_biochemical_')) {
        // Navigate to biochemical diagnosis screen with category
        Get.toNamed(
          Routes.BIO_CHEMICAL_DIAGNOSIS,
          arguments: {
            'selectedCategory': item.title,
            'showCategoryView': true,
          },
        );
        return;
      }

      // Load biochemical emergency data by title
      final emergency =
          await BiochemicalEmergencyService.getEmergencyByTitle(item.title);

      if (emergency != null) {
        await SubscriptionAccessHelper.checkAccessAndNavigate(
          routeName: Routes.BIO_CHEMICAL_DETAIL_PAGE,
          arguments: {
            'title': item.title,
            'category': item.category,
            'emergencies': [emergency],
          },
          contentType: 'biochemical',
        );
      } else {
        // Navigate to biochemical diagnosis screen with category
        Get.toNamed(
          Routes.BIO_CHEMICAL_DIAGNOSIS,
          arguments: {
            'selectedCategory': item.category,
            'showCategoryView': true,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load biochemical emergency details');
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    searchQuery.value = '';
  }

  /// Navigate to clinical presentations details
  Future<void> _navigateToClinicalPresentationsDetails(
      SearchResultItem item) async {
    try {
      // Check if this is a category item
      if (item.id.startsWith('category_clinical_presentations_')) {
        // Navigate to clinical presentations screen with category
        Get.toNamed(
          Routes.CLINICAL_PRESENTATIONS,
          arguments: {
            'selectedCategory': item.title,
            'showCategoryView': true,
          },
        );
        return;
      }

      // Load presentation data by title
      final presentation =
          await ClinicalPresentationsService.getPresentationByTitle(item.title);

      if (presentation != null) {
        await SubscriptionAccessHelper.checkAccessAndNavigate(
          routeName: Routes.CLINICAL_PRESENTATION_DETAIL,
          arguments: {
            'presentation': presentation,
            'from': 'search',
          },
          contentType: 'clinical_presentation',
        );
      } else {
        // Navigate to clinical presentations screen with category
        Get.toNamed(
          Routes.CLINICAL_PRESENTATIONS,
          arguments: {
            'selectedCategory': item.category,
            'showCategoryView': true,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clinical presentations details');
    }
  }

  /// Get display items (search results or history)
  List<SearchResultItem> get displayItems {
    if (searchQuery.value.isNotEmpty) {
      return searchResults;
    } else {
      return searchHistory;
    }
  }
}
