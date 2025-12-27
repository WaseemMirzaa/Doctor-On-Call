import 'package:dr_on_call/app/services/news2_calculator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// NEWS2 (National Early Warning Score 2) Calculator
///
/// This class calculates the NEWS2 score based on vital signs and provides
/// risk assessment and clinical recommendations.
class News2Calculator {
  final int respiratoryRate;
  final int oxygenSaturation;
  final bool onSupplementalOxygen;
  final int systolicBP;
  final int heartRate;
  final double temperature;
  final bool isConfusedOrUnresponsive;

  News2Calculator({
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.onSupplementalOxygen,
    required this.systolicBP,
    required this.heartRate,
    required this.temperature,
    required this.isConfusedOrUnresponsive,
  });

  /// Calculate the total NEWS2 score
  int calculateTotalScore() {
    int totalScore = 0;

    // Respiratory Rate scoring
    totalScore += _getRespiratoryRateScore(respiratoryRate);

    // Oxygen Saturation scoring
    totalScore += _getOxygenSaturationScore(oxygenSaturation);

    // Systolic Blood Pressure scoring
    totalScore += _getSystolicBPScore(systolicBP);

    // Heart Rate scoring
    totalScore += _getHeartRateScore(heartRate);

    // Temperature scoring
    totalScore += _getTemperatureScore(temperature);

    // Level of Consciousness scoring
    totalScore += _getLevelOfConsciousnessScore(isConfusedOrUnresponsive);

    // Supplemental Oxygen scoring
    if (onSupplementalOxygen) {
      totalScore += 2;
    }

    return totalScore;
  }

  /// Interpret the NEWS2 score and return risk category
  String interpretScore() {
    final score = calculateTotalScore();

    if (score == 0) {
      return "Normal";
    } else if (score >= 1 && score <= 4) {
      return "Low risk";
    } else if (score >= 5 && score <= 6) {
      return "Medium risk";
    } else {
      return "High risk";
    }
  }

  /// Get clinical action recommendation based on score
  String getActionRecommendation() {
    final score = calculateTotalScore();

    if (score == 0) {
      return "Continue routine monitoring";
    } else if (score >= 1 && score <= 4) {
      return "Increase frequency of monitoring and consider clinical review";
    } else if (score >= 5 && score <= 6) {
      return "Urgent clinical review and consider higher-level care";
    } else {
      return "Urgent clinical review and transfer to higher-level care";
    }
  }

  /// Get detailed breakdown of scores for each parameter
  Map<String, int> getScoreBreakdown() {
    return {
      'Respiratory Rate': _getRespiratoryRateScore(respiratoryRate),
      'Oxygen Saturation': _getOxygenSaturationScore(oxygenSaturation),
      'Systolic BP': _getSystolicBPScore(systolicBP),
      'Heart Rate': _getHeartRateScore(heartRate),
      'Temperature': _getTemperatureScore(temperature),
      'Level of Consciousness':
          _getLevelOfConsciousnessScore(isConfusedOrUnresponsive),
      'Supplemental Oxygen': onSupplementalOxygen ? 2 : 0,
    };
  }

  // Private scoring methods for each vital sign

  int _getRespiratoryRateScore(int rate) {
    if (rate <= 8) return 3;
    if (rate >= 9 && rate <= 11) return 1;
    if (rate >= 12 && rate <= 20) return 0;
    if (rate >= 21 && rate <= 24) return 2;
    if (rate >= 25) return 3;
    return 0;
  }

  int _getOxygenSaturationScore(int saturation) {
    if (saturation <= 91) return 3;
    if (saturation >= 92 && saturation <= 93) return 2;
    if (saturation >= 94 && saturation <= 95) return 1;
    if (saturation >= 96) return 0;
    return 0;
  }

  int _getSystolicBPScore(int systolic) {
    if (systolic <= 90) return 3;
    if (systolic >= 91 && systolic <= 100) return 2;
    if (systolic >= 101 && systolic <= 110) return 1;
    if (systolic >= 111 && systolic <= 219) return 0;
    if (systolic >= 220) return 3;
    return 0;
  }

  int _getHeartRateScore(int rate) {
    if (rate <= 40) return 3;
    if (rate >= 41 && rate <= 50) return 1;
    if (rate >= 51 && rate <= 90) return 0;
    if (rate >= 91 && rate <= 110) return 1;
    if (rate >= 111 && rate <= 130) return 2;
    if (rate >= 131) return 3;
    return 0;
  }

  int _getTemperatureScore(double temp) {
    if (temp <= 35.0) return 3;
    if (temp >= 35.1 && temp <= 36.0) return 1;
    if (temp >= 36.1 && temp <= 38.0) return 0;
    if (temp >= 38.1 && temp <= 39.0) return 1;
    if (temp >= 39.1) return 2;
    return 0;
  }

  int _getLevelOfConsciousnessScore(bool isConfused) {
    return isConfused ? 3 : 0;
  }
}

/// Enhanced NEWS2 Calculator with AVPU+C and Oxygen Therapy scoring
class EnhancedNews2Calculator extends News2Calculator {
  final News2Calculator baseCalculator;
  final int consciousnessScore;
  final int oxygenScore;

  EnhancedNews2Calculator({
    required this.baseCalculator,
    required this.consciousnessScore,
    required this.oxygenScore,
  }) : super(
          respiratoryRate: baseCalculator.respiratoryRate,
          oxygenSaturation: baseCalculator.oxygenSaturation,
          onSupplementalOxygen: baseCalculator.onSupplementalOxygen,
          systolicBP: baseCalculator.systolicBP,
          heartRate: baseCalculator.heartRate,
          temperature: baseCalculator.temperature,
          isConfusedOrUnresponsive: baseCalculator.isConfusedOrUnresponsive,
        );

  @override
  int calculateTotalScore() {
    int totalScore = 0;

    // Respiratory Rate scoring
    totalScore += _getRespiratoryRateScore(respiratoryRate);

    // Oxygen Saturation scoring
    totalScore += _getOxygenSaturationScore(oxygenSaturation);

    // Systolic Blood Pressure scoring
    totalScore += _getSystolicBPScore(systolicBP);

    // Heart Rate scoring
    totalScore += _getHeartRateScore(heartRate);

    // Temperature scoring
    totalScore += _getTemperatureScore(temperature);

    // Enhanced Level of Consciousness scoring (AVPU+C)
    totalScore += consciousnessScore;

    // Enhanced Oxygen Therapy scoring
    totalScore += oxygenScore;

    return totalScore;
  }

  @override
  Map<String, int> getScoreBreakdown() {
    return {
      'Respiratory Rate': _getRespiratoryRateScore(respiratoryRate),
      'Oxygen Saturation': _getOxygenSaturationScore(oxygenSaturation),
      'Systolic BP': _getSystolicBPScore(systolicBP),
      'Heart Rate': _getHeartRateScore(heartRate),
      'Temperature': _getTemperatureScore(temperature),
      'Level of Consciousness (AVPU)': consciousnessScore,
      'Oxygen Therapy': oxygenScore,
    };
  }
}

class News2CoreController extends GetxController {
  // Text controllers for input fields
  final respiratoryRateController = TextEditingController();
  final oxygenSaturationController = TextEditingController();
  final temperatureController = TextEditingController();
  final systolicBPController = TextEditingController();
  final heartRateController = TextEditingController();

  // Observable for level of consciousness checkbox
  final isConfusedOrUnresponsive = false.obs;

  // Observable for AVPU+C level selection
  final selectedConsciousnessLevel = 'Alert'.obs;

  // AVPU+C options with their scores
  final consciousnessOptions = <String, int>{
    'Alert': 0,
    'Voice': 3,
    'Pain': 3,
    'Unresponsive': 3,
    'New Confusion': 3,
  };

  // Observable for oxygen requirement checkbox
  final onSupplementalOxygen = false.obs;

  // Observable for oxygen therapy type selection
  final selectedOxygenType = 'Room Air'.obs;

  // Oxygen therapy options with their scores
  final oxygenTypeOptions = <String, int>{
    'Room Air': 0,
    'Supplemental Oxygen': 2,
  };

  // Observable for calculation result
  final calculationResult = Rxn<News2Calculator>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    respiratoryRateController.dispose();
    oxygenSaturationController.dispose();
    temperatureController.dispose();
    systolicBPController.dispose();
    heartRateController.dispose();
    super.onClose();
  }

  /// Toggle level of consciousness checkbox
  void toggleLevelOfConsciousness() {
    isConfusedOrUnresponsive.value = !isConfusedOrUnresponsive.value;
    // Reset to Alert when unchecked
    if (!isConfusedOrUnresponsive.value) {
      selectedConsciousnessLevel.value = 'Alert';
    }
  }

  /// Set consciousness level
  void setConsciousnessLevel(String level) {
    selectedConsciousnessLevel.value = level;
    // Update the boolean based on the selected level
    isConfusedOrUnresponsive.value = level != 'Alert';
  }

  /// Get consciousness score based on AVPU+C
  int getConsciousnessScore() {
    if (!isConfusedOrUnresponsive.value) {
      return 0; // If checkbox not checked, score is 0 (Alert)
    }
    return consciousnessOptions[selectedConsciousnessLevel.value] ?? 0;
  }

  /// Toggle oxygen requirement checkbox
  void toggleOxygenRequirement() {
    onSupplementalOxygen.value = !onSupplementalOxygen.value;
    // Reset to Room Air when unchecked
    if (!onSupplementalOxygen.value) {
      selectedOxygenType.value = 'Room Air';
    }
  }

  /// Set oxygen therapy type
  void setOxygenType(String type) {
    selectedOxygenType.value = type;
    // Update the boolean based on the selected type
    onSupplementalOxygen.value = type != 'Room Air';
  }

  /// Get oxygen therapy score
  int getOxygenScore() {
    if (!onSupplementalOxygen.value) {
      return 0; // If checkbox not checked, score is 0 (Room Air)
    }
    return oxygenTypeOptions[selectedOxygenType.value] ?? 0;
  }

  /// Calculate NEWS2 score
  bool calculateNews2Score() {
    // Validate input fields
    if (respiratoryRateController.text.isEmpty ||
        oxygenSaturationController.text.isEmpty ||
        temperatureController.text.isEmpty ||
        systolicBPController.text.isEmpty ||
        heartRateController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return false;
    }

    try {
      final respiratoryRate = int.parse(respiratoryRateController.text);
      final oxygenSaturation = int.parse(oxygenSaturationController.text);
      final temperature = double.parse(temperatureController.text);
      final systolicBP = int.parse(systolicBPController.text);
      final heartRate = int.parse(heartRateController.text);

      // Validate ranges
      if (respiratoryRate < 0 || respiratoryRate > 60) {
        Get.snackbar('Error', 'Respiratory rate must be between 0-60');
        return false;
      }
      if (oxygenSaturation < 0 || oxygenSaturation > 100) {
        Get.snackbar('Error', 'Oxygen saturation must be between 0-100%');
        return false;
      }
      if (temperature < 30.0 || temperature > 45.0) {
        Get.snackbar('Error', 'Temperature must be between 30-45°C');
        return false;
      }
      if (systolicBP < 50 || systolicBP > 300) {
        Get.snackbar('Error', 'Systolic BP must be between 50-300 mmHg');
        return false;
      }
      if (heartRate < 30 || heartRate > 200) {
        Get.snackbar('Error', 'Heart rate must be between 30-200 bpm');
        return false;
      }

      // All validations passed, calculate NEWS2 score
      try {
        final calculator = News2Calculator(
          respiratoryRate: respiratoryRate,
          oxygenSaturation: oxygenSaturation,
          onSupplementalOxygen: onSupplementalOxygen.value,
          systolicBP: systolicBP,
          heartRate: heartRate,
          temperature: temperature,
          isConfusedOrUnresponsive: isConfusedOrUnresponsive.value,
        );

        // Create enhanced calculator with AVPU and oxygen therapy scoring
        final enhancedCalculator = EnhancedNews2Calculator(
          baseCalculator: calculator,
          consciousnessScore: getConsciousnessScore(),
          oxygenScore: getOxygenScore(),
        );

        calculationResult.value = enhancedCalculator;
        return true;
      } catch (e) {
        Get.snackbar('Error', 'Error calculating NEWS2 score: $e');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Please enter valid numeric values');
      return false;
    }
  }

  /// Clear all input fields and reset states
  void clearAllFields() {
    respiratoryRateController.clear();
    oxygenSaturationController.clear();
    temperatureController.clear();
    systolicBPController.clear();
    heartRateController.clear();
    isConfusedOrUnresponsive.value = false;
    selectedConsciousnessLevel.value = 'Alert';
    onSupplementalOxygen.value = false;
    selectedOxygenType.value = 'Room Air';
    calculationResult.value = null;
  }
}
