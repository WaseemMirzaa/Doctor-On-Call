import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:dr_on_call/config/AppText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/news2_core_controller.dart';

class News2Tiles extends StatelessWidget {
  final List<String> symptoms;
  final ValueChanged<List<String>> onSelectionChanged;
  final Function(String) onSymptomTap; // Callback for navigation
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const News2Tiles({
    Key? key,
    required this.symptoms,
    required this.onSelectionChanged,
    required this.onSymptomTap,
    this.padding,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<News2CoreController>();

    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...symptoms.map((symptom) {
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _buildSymptomField(symptom, controller),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSymptomField(String symptom, News2CoreController controller) {
    // Handle level of consciousness with checkbox and dropdown
    if (symptom == AppText.levelOfConsciousness) {
      return Obx(() => Column(
            children: [
              // Checkbox for Level of Consciousness
              GestureDetector(
                onTap: () {
                  controller.toggleLevelOfConsciousness();
                  onSymptomTap(symptom);
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEEC643),
                      width: 1,
                    ),
                    color: controller.isConfusedOrUnresponsive.value
                        ? const Color(0xFF0A1A3F)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          symptom,
                          style: AppTextStyles.medium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.txtWhiteColor,
                          ),
                        ),
                        Icon(
                          controller.isConfusedOrUnresponsive.value
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: AppColors.txtOrangeColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // AVPU Dropdown (shown when checkbox is checked)
              if (controller.isConfusedOrUnresponsive.value) ...[
                const SizedBox(height: 20),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEEC643),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedConsciousnessLevel.value,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF0A1A3F),
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.txtWhiteColor,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.txtOrangeColor,
                        ),
                        items: controller.consciousnessOptions.keys
                            .map((String level) {
                          final score = controller.consciousnessOptions[level]!;
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  level,
                                  style: AppTextStyles.medium.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.txtWhiteColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.setConsciousnessLevel(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ));
    }

    if (symptom == AppText.oxygenRequirement) {
      return Obx(() => GestureDetector(
            onTap: () {
              controller.toggleOxygenRequirement();
              onSymptomTap(symptom);
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEEC643),
                  width: 1,
                ),
                color: controller.onSupplementalOxygen.value
                    ? const Color(0xFF0A1A3F)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      symptom,
                      style: AppTextStyles.medium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.txtWhiteColor,
                      ),
                    ),
                    Icon(
                      controller.onSupplementalOxygen.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: AppColors.txtOrangeColor,
                    ),
                  ],
                ),
              ),
            ),
          ));
    }

    // Handle numeric input fields
    TextEditingController textController;
    switch (symptom) {
      case AppText.respiratoryRate:
        textController = controller.respiratoryRateController;
        break;
      case AppText.oxygenSaturation:
        textController = controller.oxygenSaturationController;
        break;
      case AppText.temperature:
        textController = controller.temperatureController;
        break;
      case AppText.systolicBloodPressure:
        textController = controller.systolicBPController;
        break;
      case AppText.heartRate:
        textController = controller.heartRateController;
        break;
      default:
        textController = TextEditingController();
    }

    // Create a focus node for the text field
    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onTap: () {
        onSymptomTap(symptom);
        // Focus the text field when the row is tapped
        focusNode.requestFocus();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFEEC643),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              // Symptom label on the left
              Expanded(
                flex: 2,
                child: Text(
                  symptom,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtWhiteColor,
                  ),
                ),
              ),
              // Input field on the right
              Expanded(
                flex: 1,
                child: TextFormField(
                  focusNode: focusNode,
                  keyboardType: symptom == AppText.temperature
                      ? TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  controller: textController,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtWhiteColor,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter value",
                    hintStyle: AppTextStyles.medium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.txtWhiteColor.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  onChanged: (value) {
                    onSelectionChanged([value]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
