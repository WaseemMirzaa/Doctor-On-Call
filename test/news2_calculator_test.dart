import 'package:flutter_test/flutter_test.dart';
import 'package:dr_on_call/app/services/news2_calculator.dart';

void main() {
  group('News2Calculator Tests', () {
    test('should calculate correct score for normal patient', () {
      final calculator = News2Calculator(
        respiratoryRate: 16,
        oxygenSaturation: 98,
        onSupplementalOxygen: false,
        systolicBP: 120,
        heartRate: 70,
        temperature: 37.0,
        isConfusedOrUnresponsive: false,
      );

      expect(calculator.calculateTotalScore(), equals(0));
      expect(calculator.interpretScore(), equals("Normal"));
      expect(calculator.getActionRecommendation(),
          equals("Continue routine monitoring"));
    });

    test('should calculate correct score for low risk patient', () {
      final calculator = News2Calculator(
        respiratoryRate: 10, // 1 point
        oxygenSaturation: 95, // 1 point
        onSupplementalOxygen: false,
        systolicBP: 105, // 1 point
        heartRate: 95, // 1 point
        temperature: 37.0, // 0 points
        isConfusedOrUnresponsive: false, // 0 points
      );

      expect(calculator.calculateTotalScore(), equals(4));
      expect(calculator.interpretScore(), equals("Low risk"));
      expect(
          calculator.getActionRecommendation(),
          equals(
              "Increase frequency of monitoring and consider clinical review"));
    });

    test('should calculate correct score for medium risk patient', () {
      final calculator = News2Calculator(
        respiratoryRate: 22, // 2 points
        oxygenSaturation: 94, // 1 point
        onSupplementalOxygen: true, // 2 points
        systolicBP: 120, // 0 points
        heartRate: 70, // 0 points
        temperature: 37.0, // 0 points
        isConfusedOrUnresponsive: false, // 0 points
      );

      expect(calculator.calculateTotalScore(), equals(5));
      expect(calculator.interpretScore(), equals("Medium risk"));
      expect(calculator.getActionRecommendation(),
          equals("Urgent clinical review and consider higher-level care"));
    });

    test('should calculate correct score for high risk patient', () {
      final calculator = News2Calculator(
        respiratoryRate: 26, // 3 points
        oxygenSaturation: 90, // 3 points
        onSupplementalOxygen: true, // 2 points
        systolicBP: 85, // 3 points
        heartRate: 135, // 3 points
        temperature: 35.0, // 3 points
        isConfusedOrUnresponsive: true, // 3 points
      );

      expect(calculator.calculateTotalScore(), equals(20));
      expect(calculator.interpretScore(), equals("High risk"));
      expect(calculator.getActionRecommendation(),
          equals("Urgent clinical review and transfer to higher-level care"));
    });

    test('should provide correct score breakdown', () {
      final calculator = News2Calculator(
        respiratoryRate: 10, // 1 point
        oxygenSaturation: 95, // 1 point
        onSupplementalOxygen: true, // 2 points
        systolicBP: 105, // 1 point
        heartRate: 95, // 1 point
        temperature: 38.5, // 1 point
        isConfusedOrUnresponsive: false, // 0 points
      );

      final breakdown = calculator.getScoreBreakdown();
      expect(breakdown['Respiratory Rate'], equals(1));
      expect(breakdown['Oxygen Saturation'], equals(1));
      expect(breakdown['Systolic BP'], equals(1));
      expect(breakdown['Heart Rate'], equals(1));
      expect(breakdown['Temperature'], equals(1));
      expect(breakdown['Level of Consciousness'], equals(0));
      expect(breakdown['Supplemental Oxygen'], equals(2));
    });

    test('should handle edge cases correctly', () {
      // Test respiratory rate boundaries
      expect(
          News2Calculator(
            respiratoryRate: 8,
            oxygenSaturation: 96,
            onSupplementalOxygen: false,
            systolicBP: 120,
            heartRate: 70,
            temperature: 37.0,
            isConfusedOrUnresponsive: false,
          ).calculateTotalScore(),
          equals(3)); // 8 breaths = 3 points

      expect(
          News2Calculator(
            respiratoryRate: 9,
            oxygenSaturation: 96,
            onSupplementalOxygen: false,
            systolicBP: 120,
            heartRate: 70,
            temperature: 37.0,
            isConfusedOrUnresponsive: false,
          ).calculateTotalScore(),
          equals(1)); // 9 breaths = 1 point

      // Test oxygen saturation boundaries
      expect(
          News2Calculator(
            respiratoryRate: 16,
            oxygenSaturation: 91,
            onSupplementalOxygen: false,
            systolicBP: 120,
            heartRate: 70,
            temperature: 37.0,
            isConfusedOrUnresponsive: false,
          ).calculateTotalScore(),
          equals(3)); // 91% = 3 points

      expect(
          News2Calculator(
            respiratoryRate: 16,
            oxygenSaturation: 92,
            onSupplementalOxygen: false,
            systolicBP: 120,
            heartRate: 70,
            temperature: 37.0,
            isConfusedOrUnresponsive: false,
          ).calculateTotalScore(),
          equals(2)); // 92% = 2 points
    });
  });
}
