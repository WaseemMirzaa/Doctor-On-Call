/// Text formatting utilities for the Dr. OnCall application
///
/// This file contains common text formatting functions that should be used
/// throughout the application for consistent text capitalization and formatting.
class TextUtils {
  /// Formats text to proper title case following medical/clinical text conventions
  ///
  /// Rules applied:
  /// - Capitalizes the first letter of each word
  /// - Capitalizes letters after hyphens (-)
  /// - Capitalizes letters after periods (.)
  /// - Capitalizes letters after colons (:)
  /// - Capitalizes letters after semicolons (;)
  /// - Capitalizes letters after question marks (?)
  /// - Capitalizes letters after exclamation marks (!)
  /// - Keeps only "and" lowercase in the middle of titles
  /// - Always capitalizes the first and last word regardless of size
  /// - Preserves existing capitalization for medical abbreviations in parentheses
  /// - Handles common medical terminology properly
  ///
  /// Examples:
  /// - "chest pain" -> "Chest Pain"
  /// - "pain in the chest" -> "Pain In The Chest"
  /// - "heart and lung disease" -> "Heart and Lung Disease"
  /// - "post-operative care" -> "Post-Operative Care"
  /// - "covid-19 symptoms" -> "Covid-19 Symptoms"
  /// - "patient's history" -> "Patient's History"
  /// - "ECG findings" -> "ECG Findings"
  /// - "diagnosis of the condition" -> "Diagnosis Of The Condition"
  ///
  /// [text] The input text to format
  /// Returns the formatted text in proper title case
  static String formatTitleCase(String text) {
    if (text.isEmpty) return text;

    // Handle single space case
    if (text == ' ') return text;

    // Handle null or empty cases
    final String cleanText = text.trim();
    if (cleanText.isEmpty) return cleanText;

    // Define small words that should remain lowercase (except at beginning/end)
    // Only "and" should remain lowercase in the middle of titles
    final Set<String> smallWords = {'and'};

    // Split by spaces while preserving the spaces
    final List<String> parts = cleanText.split(' ');
    final List<String> formattedParts = [];

    for (int i = 0; i < parts.length; i++) {
      final String part = parts[i];
      if (part.isEmpty) {
        formattedParts.add(part);
        continue;
      }

      // Check if this word (without punctuation) is a small word
      final String wordWithoutPunctuation =
          part.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      final bool isSmallWord = smallWords.contains(wordWithoutPunctuation);
      final bool isFirstWord = i == 0;
      final bool isLastWord = i == parts.length - 1;

      // Apply title case formatting to each part
      String formattedPart;
      if (isSmallWord && !isFirstWord && !isLastWord) {
        // Keep small words lowercase, but still handle internal capitalization (after hyphens, etc.)
        formattedPart =
            _formatWordTitleCase(part, keepSmallWordLowercase: true);
      } else {
        // Normal title case for other words
        formattedPart =
            _formatWordTitleCase(part, keepSmallWordLowercase: false);
      }

      formattedParts.add(formattedPart);
    }

    return formattedParts.join(' ');
  }

  /// Formats a single word to title case, handling punctuation and special cases
  static String _formatWordTitleCase(String word,
      {bool keepSmallWordLowercase = false}) {
    if (word.isEmpty) return word;

    // Handle special medical abbreviations that should remain uppercase
    final Set<String> medicalAbbreviations = {
      'ECG',
      'EKG',
      'MRI',
      'CT',
      'HIV',
      'AIDS',
      'COVID',
      'DNA',
      'RNA',
      'BP',
      'HR',
      'RR',
      'CPR',
      'ICU',
      'ER',
      'IV',
      'IM',
      'PO',
      'BID',
      'TID',
      'QID',
      'PRN',
      'STAT',
      'ASAP',
      'BMI',
      'CBC',
      'LFT',
      'ABG',
      'CXR',
      'UTI',
      'CHF',
      'COPD',
      'DM',
      'HTN',
      'CAD',
      'MI',
      'PE',
      'DVT',
      'GI',
      'GU',
      'CNS',
      'PNS',
      'HEENT',
      'CVS',
      'RS',
      'MSK',
      'NEURO',
      'PSYCH',
      'OB',
      'GYN',
      'PEDS',
      'DERM',
      'ENT',
      'OPHTH',
      'ORTHO',
      'UROLOGY',
      'CARDIO',
      'PULM',
      'GASTRO',
      'ENDO',
      'RHEUM',
      'HEME',
      'ONCO',
      'NEPHRO',
      'ID',
      'ALLERGY',
      'IMMUNO',
      'NAI',
      'CRAO',
      'CRVO',
      'RAAA',
      'SVT',
      'VT',
      'AF',
      'RVR',
      'NCSE',
      'ICH',
      'GCA',
      'CVST',
      'ICP',
      'CO',
      'SAH'
    };

    // Check if the word (without punctuation) is a medical abbreviation
    final String wordWithoutPunctuation = word.replaceAll(RegExp(r'[^\w]'), '');
    if (medicalAbbreviations.contains(wordWithoutPunctuation.toUpperCase())) {
      return word.toUpperCase();
    }

    // Characters that should trigger capitalization of the following letter
    // Note: Apostrophes should NOT trigger capitalization for possessives like "patient's"
    final Set<String> capitalizationTriggers = {
      '-',
      '.',
      ':',
      ';',
      '?',
      '!',
      '(',
      '[',
      '"'
    };

    final StringBuffer result = StringBuffer();
    bool shouldCapitalize =
        !keepSmallWordLowercase; // First character capitalization depends on word type

    for (int i = 0; i < word.length; i++) {
      final String char = word[i];

      if (shouldCapitalize && char.toLowerCase() != char.toUpperCase()) {
        // It's a letter and we should capitalize it
        result.write(char.toUpperCase());
        shouldCapitalize = false;
      } else {
        result.write(char.toLowerCase());
      }

      // Check if this character should trigger capitalization of the next letter
      // Always capitalize after certain punctuation, even for small words
      if (capitalizationTriggers.contains(char)) {
        shouldCapitalize = true;
      }
    }

    return result.toString();
  }

  /// Alternative method that provides the same functionality as GetX's capitalize
  /// but with enhanced formatting rules for medical terminology
  ///
  /// This is a drop-in replacement for string.capitalize!
  static String capitalizeEnhanced(String text) {
    return formatTitleCase(text);
  }

  /// Formats category names with special handling for medical categories
  /// This is specifically for main/sub categories in the medical app
  static String formatCategoryName(String categoryName) {
    if (categoryName.isEmpty) return categoryName;

    // Handle special category formatting rules
    String formatted = formatTitleCase(categoryName);

    // Special cases for medical categories
    final Map<String, String> specialCategories = {
      'covid-19': 'COVID-19',
      'h1n1': 'H1N1',
      'ecg': 'ECG',
      'ekg': 'EKG',
      'mri': 'MRI',
      'ct scan': 'CT Scan',
      'x-ray': 'X-Ray',
      'lab values': 'Lab Values',
      'vital signs': 'Vital Signs',
      'blood pressure': 'Blood Pressure',
      'heart rate': 'Heart Rate',
      'respiratory rate': 'Respiratory Rate',
      'oxygen saturation': 'Oxygen Saturation',
    };

    // Check for exact matches first
    final String lowerFormatted = formatted.toLowerCase();
    if (specialCategories.containsKey(lowerFormatted)) {
      return specialCategories[lowerFormatted]!;
    }

    return formatted;
  }
}

/// Extension on String to provide easy access to the formatting methods
extension StringFormattingExtension on String {
  /// Formats the string using the enhanced title case formatting
  /// This replaces the basic capitalize! method with advanced formatting
  String get formatTitleCase => TextUtils.formatTitleCase(this);

  /// Formats the string as a category name with medical terminology handling
  String get formatCategoryName => TextUtils.formatCategoryName(this);

  /// Enhanced capitalize method that handles punctuation and medical terms
  String get capitalizeEnhanced => TextUtils.capitalizeEnhanced(this);
}
