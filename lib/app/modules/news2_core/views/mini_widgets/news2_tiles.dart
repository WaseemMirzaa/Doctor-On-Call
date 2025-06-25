import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class News2Tiles extends StatefulWidget {
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
  _SymptomSelectionWidgetState createState() => _SymptomSelectionWidgetState();
}

class _SymptomSelectionWidgetState extends State<News2Tiles> {
  String? _selectedSymptom;
  // Map to store text input for each symptom
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize a TextEditingController for each symptom
    for (var symptom in widget.symptoms) {
      _controllers[symptom] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.symptoms.map((symptom) {
            final isSelected = _selectedSymptom == symptom;
            return Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSymptom = symptom;
                    // Call the navigation callback with the selected symptom
                    widget.onSymptomTap(symptom);
                    // Notify selection change with current inputs
                    widget.onSelectionChanged(
                      _controllers.entries
                          .where((entry) => entry.value.text.isNotEmpty)
                          .map((entry) => entry.value.text)
                          .toList(),
                    );
                  });
                },
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFEEC643), // Yellow border
                          width: 1,
                        ),
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF0A1A2F).withOpacity(0.7),
                                  const Color(0xFF0A1A3F),
                                ],
                              )
                            : null,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _controllers[symptom],
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.txtWhiteColor,
                            ),
                            decoration: InputDecoration(
                              hintText: symptom,
                              hintStyle: AppTextStyles.medium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors
                                    .txtWhiteColor, // Slightly faded for hint
                              ),
                              border: InputBorder.none, // No additional border
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            onChanged: (value) {
                              // Notify selection change with updated inputs
                              widget.onSelectionChanged(
                                _controllers.entries
                                    .where(
                                        (entry) => entry.value.text.isNotEmpty)
                                    .map((entry) => entry.value.text)
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
