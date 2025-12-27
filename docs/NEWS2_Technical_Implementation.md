# NEWS2 Calculator - Technical Implementation Guide

## Architecture Overview

The NEWS2 calculator is implemented using a clean architecture pattern with separation of concerns:

```
├── Services Layer (Business Logic)
│   └── news2_calculator.dart
├── Controller Layer (State Management)
│   └── news2_core_controller.dart
├── View Layer (UI Components)
│   ├── news2_core_view.dart
│   ├── news2_list.dart
│   └── news2_tiles.dart
└── Tests
    └── news2_calculator_test.dart
```

## Core Components

### 1. News2Calculator Service (`lib/app/services/news2_calculator.dart`)

**Purpose**: Pure business logic for NEWS2 calculations

**Key Methods**:
- `calculateTotalScore()`: Returns the total NEWS2 score
- `interpretScore()`: Returns risk category string
- `getActionRecommendation()`: Returns clinical action guidance
- `getScoreBreakdown()`: Returns detailed score breakdown

**Example Usage**:
```dart
final calculator = News2Calculator(
  respiratoryRate: 22,
  oxygenSaturation: 94,
  onSupplementalOxygen: true,
  systolicBP: 95,
  heartRate: 105,
  temperature: 38.5,
  isConfusedOrUnresponsive: false,
);

final score = calculator.calculateTotalScore(); // Returns: 9
final risk = calculator.interpretScore(); // Returns: "High risk"
```

### 2. News2CoreController (`lib/app/modules/news2_core/controllers/news2_core_controller.dart`)

**Purpose**: State management and validation logic

**Key Features**:
- Input validation with user-friendly error messages
- Reactive state management using GetX
- Text controller management for form inputs
- Boolean state management for toggles

**Key Methods**:
- `calculateNews2Score()`: Validates inputs and creates calculator instance
- `toggleLevelOfConsciousness()`: Toggles AVPU state
- `toggleOxygenRequirement()`: Toggles oxygen requirement state
- `clearAllFields()`: Resets all inputs and state

### 3. UI Components

#### News2Tiles (`lib/app/modules/news2_core/views/mini_widgets/news2_tiles.dart`)
- Renders input fields for vital signs
- Handles both numeric inputs and boolean toggles
- Provides real-time validation feedback

#### News2List (`lib/app/modules/news2_core/views/mini_widgets/news2_list.dart`)
- Orchestrates the overall NEWS2 interface
- Handles calculate button logic
- Displays results in a modal dialog

## Data Flow

```
User Input → Validation → Calculation → Result Display
     ↓            ↓            ↓            ↓
News2Tiles → Controller → Calculator → Dialog
```

1. **Input Collection**: User enters vital signs through News2Tiles
2. **Validation**: Controller validates each input with specific rules
3. **Calculation**: News2Calculator computes score and risk level
4. **Display**: Results shown in formatted dialog with color coding

## Validation Rules

### Respiratory Rate
```dart
if (respiratoryRate == null || respiratoryRate < 1 || respiratoryRate > 60) {
  CustomSnackBar.error("Respiratory Rate must be between 1-60 breaths per minute");
  return false;
}
```

### Oxygen Saturation
```dart
if (oxygenSaturation == null || oxygenSaturation < 70 || oxygenSaturation > 100) {
  CustomSnackBar.error("Oxygen Saturation must be between 70-100%");
  return false;
}
```

### Temperature
```dart
if (temperature == null || temperature < 30.0 || temperature > 45.0) {
  CustomSnackBar.error("Temperature must be between 30.0-45.0°C");
  return false;
}
```

### Systolic Blood Pressure
```dart
if (systolicBP == null || systolicBP < 50 || systolicBP > 300) {
  CustomSnackBar.error("Systolic Blood Pressure must be between 50-300 mmHg");
  return false;
}
```

### Heart Rate
```dart
if (heartRate == null || heartRate < 20 || heartRate > 200) {
  CustomSnackBar.error("Heart Rate must be between 20-200 bpm");
  return false;
}
```

## Scoring Implementation

Each vital sign has a dedicated private method for scoring:

```dart
int _getRespiratoryRateScore(int rate) {
  if (rate <= 8) return 3;
  if (rate >= 9 && rate <= 11) return 1;
  if (rate >= 12 && rate <= 20) return 0;
  if (rate >= 21 && rate <= 24) return 2;
  if (rate >= 25) return 3;
  return 0;
}
```

## UI State Management

### Reactive Boolean States
```dart
// Observable for level of consciousness (AVPU)
final isConfusedOrUnresponsive = false.obs;

// Observable for oxygen requirement
final onSupplementalOxygen = false.obs;

// Observable for calculation results
final calculationResult = Rxn<News2Calculator>();
```

### Text Controllers
```dart
final respiratoryRateController = TextEditingController();
final oxygenSaturationController = TextEditingController();
final temperatureController = TextEditingController();
final systolicBPController = TextEditingController();
final heartRateController = TextEditingController();
```

## Result Display

### Risk Color Coding
```dart
Color getRiskColor() {
  if (totalScore == 0) return Colors.green;      // Normal
  if (totalScore >= 1 && totalScore <= 4) return Colors.yellow;  // Low risk
  if (totalScore >= 5 && totalScore <= 6) return Colors.orange;  // Medium risk
  return Colors.red;  // High risk
}
```

### Dialog Structure
- **Header**: "NEWS2 Score" title
- **Score Display**: Total score with color coding
- **Risk Level**: Risk category with color coding
- **Action**: Clinical recommendation
- **Close Button**: Dismisses dialog

## Testing Strategy

### Unit Tests (`test/news2_calculator_test.dart`)

**Test Categories**:
1. **Normal Patient**: Score 0, all normal values
2. **Low Risk Patient**: Score 1-4, mild abnormalities
3. **Medium Risk Patient**: Score 5-6, moderate abnormalities
4. **High Risk Patient**: Score ≥7, severe abnormalities
5. **Edge Cases**: Boundary value testing
6. **Score Breakdown**: Detailed component scoring

**Example Test**:
```dart
test('should calculate correct score for high risk patient', () {
  final calculator = News2Calculator(
    respiratoryRate: 26,     // 3 points
    oxygenSaturation: 90,    // 3 points
    onSupplementalOxygen: true, // 2 points
    systolicBP: 85,          // 3 points
    heartRate: 135,          // 3 points
    temperature: 35.0,       // 3 points
    isConfusedOrUnresponsive: true, // 3 points
  );

  expect(calculator.calculateTotalScore(), equals(20));
  expect(calculator.interpretScore(), equals("High risk"));
});
```

## Error Handling

### Input Validation
- All fields required before calculation
- Range validation with clear error messages
- Type validation (int vs double)

### Calculation Safety
- Try-catch blocks around calculator creation
- Null checks for calculator instance
- Graceful degradation on errors

### User Feedback
- CustomSnackBar for validation errors
- Visual feedback for successful calculations
- Clear action recommendations

## Performance Considerations

### Efficient State Management
- Minimal rebuilds using GetX observables
- Lazy evaluation of calculations
- Proper disposal of controllers

### Memory Management
```dart
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
```

## Future Enhancements

### Potential Improvements
1. **Trending**: Store and display score history
2. **Alerts**: Push notifications for high scores
3. **Export**: PDF/CSV export of calculations
4. **Customization**: Adjustable thresholds for special populations
5. **Integration**: FHIR compatibility for EHR systems

### Accessibility
- Screen reader support
- High contrast mode
- Keyboard navigation
- Voice input capabilities

## Deployment Notes

### Build Requirements
- Flutter SDK 3.0+
- Dart 3.0+
- Android API level 21+
- iOS 13.0+

### Dependencies
- GetX for state management
- Flutter Material Design
- Custom UI components (AppColors, AppTextStyles)

### Testing Commands
```bash
# Run unit tests
flutter test test/news2_calculator_test.dart

# Run all tests
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```
