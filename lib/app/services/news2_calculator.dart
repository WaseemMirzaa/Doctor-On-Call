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

/// Example usage:
/// ```dart
/// final calculator = News2Calculator(
///   respiratoryRate: 22,
///   oxygenSaturation: 94,
///   onSupplementalOxygen: true,
///   systolicBP: 95,
///   heartRate: 105,
///   temperature: 38.5,
///   isConfusedOrUnresponsive: false,
/// );
///
/// final score = calculator.calculateTotalScore(); // Returns total score
/// final risk = calculator.interpretScore(); // Returns risk category
/// final action = calculator.getActionRecommendation(); // Returns clinical action
/// ```
