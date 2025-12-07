import 'package:dr_on_call/app/widgets/filter_items.dart';
import 'package:dr_on_call/config/AppColors.dart';
import 'package:dr_on_call/config/AppIcons.dart';
import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:dr_on_call/app/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomSelectionWidget extends StatefulWidget {
  final List<String> symptoms;
  final ValueChanged<List<String>> onSelectionChanged;
  final Function(String) onSymptomTap;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final bool showHeartIcon;
  final bool showRecentIcon;
  final bool showSearch;
  final bool showFilter;
  final Map<String, bool>? favoriteStates; // External favorite states
  final Function(String)? onFavoriteToggle; // Callback for favorite toggle

  const SymptomSelectionWidget({
    Key? key,
    required this.symptoms,
    required this.onSelectionChanged,
    required this.onSymptomTap,
    this.padding,
    this.spacing = 8.0,
    this.showHeartIcon = false,
    this.showRecentIcon = false,
    this.showFilter = false,
    this.favoriteStates,
    this.onFavoriteToggle,
    this.showSearch = true,
  }) : super(key: key);

  @override
  _SymptomSelectionWidgetState createState() => _SymptomSelectionWidgetState();
}

class _SymptomSelectionWidgetState extends State<SymptomSelectionWidget> {
  String? _selectedSymptom;
  String _searchQuery = '';
  final Map<String, bool> _heartStates = {};

  @override
  void initState() {
    super.initState();
    // Initialize heart states for all symptoms
    for (var symptom in widget.symptoms) {
      _heartStates[symptom] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredSymptoms = widget.symptoms
        .where((symptom) =>
            symptom.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search field

          if (widget.showSearch)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.regular.copyWith(
                              fontSize: 14, color: AppColors.darkBlue),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.black),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showFilter)
                  SizedBox(
                    height: 50,
                    width: 60,
                    child: FilterItems(),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          if (filteredSymptoms.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No results found',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'IBMPlexSans'),
                ),
              ),
            )
          else
            // Symptom list
            ...filteredSymptoms.map((symptom) {
              final isSelected = _selectedSymptom == symptom;
              final isHeartActive = widget.favoriteStates?[symptom] ??
                  _heartStates[symptom] ??
                  false;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSymptom = symptom;
                          widget.onSymptomTap(symptom);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
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
                              padding: const EdgeInsets.only(
                                right: 10.0,
                                left: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      symptom.formatTitleCase,
                                      style: AppTextStyles.bold.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.txtWhiteColor),
                                    ),
                                  ),
                                  // Heart icon with separate tap handler
                                  if (widget.showHeartIcon)
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.onFavoriteToggle != null) {
                                          // Use external callback if provided
                                          widget.onFavoriteToggle!(symptom);
                                        } else {
                                          // Fallback to internal state management
                                          setState(() {
                                            _heartStates[symptom] =
                                                !(_heartStates[symptom] ??
                                                    false);
                                            // Notify parent of selection change
                                            widget.onSelectionChanged(
                                                _heartStates
                                                    .entries
                                                    .where(
                                                        (entry) => entry.value)
                                                    .map((entry) => entry.key)
                                                    .toList());
                                          });
                                        }
                                      },
                                      child: Image.asset(
                                        !isHeartActive
                                            ? AppIcons.like
                                            : AppIcons.heart,
                                        width: 25,
                                        height: 25,
                                        color: !isHeartActive
                                            ? Colors.grey
                                            : AppColors.txtRedColor,
                                      ),
                                    ),
                                  // Recent icon
                                  if (widget.showRecentIcon)
                                    Image.asset(
                                      AppIcons.recent,
                                      width: 25,
                                      height: 25,
                                      color: isSelected
                                          ? AppColors.txtOrangeColor
                                          : AppColors.txtWhiteColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              );
            }).toList()
        ],
      ),
    );
  }
}
