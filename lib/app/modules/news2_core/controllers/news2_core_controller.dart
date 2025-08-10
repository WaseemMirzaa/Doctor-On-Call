import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/news2_calculator.dart';
import '../../../widgets/custom_snack_bar.dart';

class News2CoreController extends GetxController {
  // Text controllers for each input field
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
    // 'New Confusion': 3,
  };

  // Observable for oxygen requirement
  final onSupplementalOxygen = false.obs;

  // Observable for calculation results
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
    // Dispose controllers to prevent memory leaks
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

  /// Toggle oxygen requirement state
  void toggleOxygenRequirement() {
    onSupplementalOxygen.value = !onSupplementalOxygen.value;
  }

  /// Validate all input fields and calculate NEWS2 score
  bool calculateNews2Score() {
    // Validate respiratory rate
    final respiratoryRateText = respiratoryRateController.text.trim();
    if (respiratoryRateText.isEmpty) {
      CustomSnackBar.error("Respiratory Rate is required");
      return false;
    }

    final respiratoryRate = int.tryParse(respiratoryRateText);
    if (respiratoryRate == null ||
        respiratoryRate < 1 ||
        respiratoryRate > 60) {
      CustomSnackBar.error(
          "Respiratory Rate must be between 1-60 breaths per minute");
      return false;
    }

    // Validate oxygen saturation
    final oxygenSaturationText = oxygenSaturationController.text.trim();
    if (oxygenSaturationText.isEmpty) {
      CustomSnackBar.error("Oxygen Saturation is required");
      return false;
    }

    final oxygenSaturation = int.tryParse(oxygenSaturationText);
    if (oxygenSaturation == null ||
        oxygenSaturation < 70 ||
        oxygenSaturation > 100) {
      CustomSnackBar.error("Oxygen Saturation must be between 70-100%");
      return false;
    }

    // Validate temperature
    final temperatureText = temperatureController.text.trim();
    if (temperatureText.isEmpty) {
      CustomSnackBar.error("Temperature is required");
      return false;
    }

    final temperature = double.tryParse(temperatureText);
    if (temperature == null || temperature < 30.0 || temperature > 45.0) {
      CustomSnackBar.error("Temperature must be between 30.0-45.0°C");
      return false;
    }

    // Validate systolic blood pressure
    final systolicBPText = systolicBPController.text.trim();
    if (systolicBPText.isEmpty) {
      CustomSnackBar.error("Systolic Blood Pressure is required");
      return false;
    }

    final systolicBP = int.tryParse(systolicBPText);
    if (systolicBP == null || systolicBP < 50 || systolicBP > 300) {
      CustomSnackBar.error(
          "Systolic Blood Pressure must be between 50-300 mmHg");
      return false;
    }

    // Validate heart rate
    final heartRateText = heartRateController.text.trim();
    if (heartRateText.isEmpty) {
      CustomSnackBar.error("Heart Rate is required");
      return false;
    }

    final heartRate = int.tryParse(heartRateText);
    if (heartRate == null || heartRate < 20 || heartRate > 200) {
      CustomSnackBar.error("Heart Rate must be between 20-200 bpm");
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

      // Create enhanced calculator with AVPU scoring
      final enhancedCalculator = EnhancedNews2Calculator(
        baseCalculator: calculator,
        consciousnessScore: getConsciousnessScore(),
      );

      calculationResult.value = enhancedCalculator;
      return true;
    } catch (e) {
      CustomSnackBar.error("Error calculating NEWS2 score: ${e.toString()}");
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
    calculationResult.value = null;
  }
}
