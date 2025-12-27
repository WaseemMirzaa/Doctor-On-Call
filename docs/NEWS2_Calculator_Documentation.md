# NEWS2 Calculator Documentation

## Overview

The National Early Warning Score 2 (NEWS2) is a standardized clinical scoring system used to identify patients at risk of clinical deterioration. It was developed by the Royal College of Physicians (RCP) and is widely used in healthcare settings to provide early warning of patient deterioration.

## Purpose

NEWS2 helps healthcare professionals:
- Identify patients at risk of clinical deterioration
- Determine appropriate clinical response and escalation
- Standardize communication about patient acuity
- Guide frequency of monitoring and level of care

## Input Parameters

The NEWS2 calculator requires the following vital signs and clinical observations:

### 1. Respiratory Rate (breaths per minute)
- **Type**: Integer
- **Range**: Typically 1-60 bpm
- **Clinical Significance**: Abnormal respiratory rates indicate respiratory distress or failure

### 2. Oxygen Saturation (SpO₂)
- **Type**: Integer (percentage)
- **Range**: 70-100%
- **Clinical Significance**: Low oxygen saturation indicates hypoxemia

### 3. Supplemental Oxygen Requirement
- **Type**: Boolean (Yes/No)
- **Clinical Significance**: Patients requiring supplemental oxygen are at higher risk

### 4. Systolic Blood Pressure (mmHg)
- **Type**: Integer
- **Range**: Typically 50-300 mmHg
- **Clinical Significance**: Abnormal blood pressure indicates cardiovascular compromise

### 5. Heart Rate (beats per minute)
- **Type**: Integer
- **Range**: Typically 20-200 bpm
- **Clinical Significance**: Abnormal heart rates indicate cardiovascular stress

### 6. Temperature (°C)
- **Type**: Double
- **Range**: Typically 30.0-45.0°C
- **Clinical Significance**: Abnormal temperature indicates infection or metabolic dysfunction

### 7. Level of Consciousness (AVPU Scale)
- **Type**: Boolean
- **Options**: Alert vs. Confused/Unresponsive
- **Clinical Significance**: Altered consciousness indicates neurological compromise

## Scoring Algorithm

Each vital sign is assigned points based on how far it deviates from normal ranges:

### Respiratory Rate Scoring
```
≤ 8 breaths/min     → 3 points
9-11 breaths/min    → 1 point
12-20 breaths/min   → 0 points (normal)
21-24 breaths/min   → 2 points
≥ 25 breaths/min    → 3 points
```

### Oxygen Saturation Scoring
```
≤ 91%               → 3 points
92-93%              → 2 points
94-95%              → 1 point
≥ 96%               → 0 points (normal)
```

### Systolic Blood Pressure Scoring
```
≤ 90 mmHg           → 3 points
91-100 mmHg         → 2 points
101-110 mmHg        → 1 point
111-219 mmHg        → 0 points (normal)
≥ 220 mmHg          → 3 points
```

### Heart Rate Scoring
```
≤ 40 bpm            → 3 points
41-50 bpm           → 1 point
51-90 bpm           → 0 points (normal)
91-110 bpm          → 1 point
111-130 bpm         → 2 points
≥ 131 bpm           → 3 points
```

### Temperature Scoring
```
≤ 35.0°C            → 3 points
35.1-36.0°C         → 1 point
36.1-38.0°C         → 0 points (normal)
38.1-39.0°C         → 1 point
≥ 39.1°C            → 2 points
```

### Level of Consciousness Scoring
```
Alert               → 0 points (normal)
Confused/Unresponsive → 3 points
```

### Supplemental Oxygen Scoring
```
Room air            → 0 points
Supplemental oxygen → 2 points
```

## Total Score Calculation

The total NEWS2 score is the sum of all individual parameter scores:

**Total Score = Respiratory Rate Score + Oxygen Saturation Score + Systolic BP Score + Heart Rate Score + Temperature Score + Consciousness Score + Oxygen Requirement Score**

## Risk Stratification

Based on the total score, patients are categorized into risk levels:

### Score 0: Normal
- **Risk Level**: Normal
- **Action**: Continue routine monitoring
- **Frequency**: Standard ward monitoring

### Score 1-4: Low Risk
- **Risk Level**: Low risk
- **Action**: Increase frequency of monitoring and consider clinical review
- **Frequency**: Minimum 12-hourly monitoring

### Score 5-6: Medium Risk
- **Risk Level**: Medium risk
- **Action**: Urgent clinical review and consider higher-level care
- **Frequency**: Minimum 6-hourly monitoring
- **Response**: Registered nurse to inform medical team within 1 hour

### Score ≥7: High Risk
- **Risk Level**: High risk
- **Action**: Urgent clinical review and transfer to higher-level care
- **Frequency**: Continuous monitoring
- **Response**: Immediate medical team assessment and consider critical care

## Clinical Examples

### Example 1: Normal Patient
```
Respiratory Rate: 16 bpm        → 0 points
Oxygen Saturation: 98%          → 0 points
Supplemental Oxygen: No         → 0 points
Systolic BP: 120 mmHg          → 0 points
Heart Rate: 70 bpm             → 0 points
Temperature: 37.0°C            → 0 points
Consciousness: Alert           → 0 points
Total Score: 0 (Normal)
```

### Example 2: High Risk Patient
```
Respiratory Rate: 26 bpm        → 3 points
Oxygen Saturation: 90%          → 3 points
Supplemental Oxygen: Yes        → 2 points
Systolic BP: 85 mmHg           → 3 points
Heart Rate: 135 bpm            → 3 points
Temperature: 35.0°C            → 3 points
Consciousness: Confused        → 3 points
Total Score: 20 (High Risk)
```

## Implementation Notes

### Validation Rules
- All fields are required for accurate calculation
- Numeric values must be within physiologically reasonable ranges
- Boolean fields default to false/normal state

### Error Handling
- Invalid or missing values trigger validation errors
- Clear error messages guide user input
- Calculation only proceeds when all validations pass

### User Interface
- Input fields are clearly labeled with units
- Boolean options use intuitive toggle controls
- Results display with color-coded risk levels
- Action recommendations are prominently shown

## Clinical Considerations

### Limitations
- NEWS2 is a screening tool, not a diagnostic tool
- Clinical judgment should always override scoring systems
- Some patient populations may require modified scoring
- Trending scores over time is more valuable than single measurements

### Special Populations
- Pregnant women may have different normal ranges
- Elderly patients may have baseline abnormalities
- Patients with chronic conditions may require adjusted thresholds
- Pediatric patients require different scoring systems

## References

1. Royal College of Physicians. National Early Warning Score (NEWS) 2: Standardising the assessment of acute-illness severity in the NHS. Updated report of a working party. London: RCP, 2017.

2. Smith GB, Prytherch DR, Meredith P, Schmidt PE, Featherstone PI. The ability of the National Early Warning Score (NEWS) to discriminate patients at risk of early cardiac arrest, unanticipated intensive care unit admission, and death. Resuscitation. 2013;84(4):465-470.

3. Silcock DJ, Corfield AR, Gowens PA, Rooney KD. Validation of the National Early Warning Score in the prehospital setting. Resuscitation. 2015;89:31-35.
