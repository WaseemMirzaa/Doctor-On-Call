import 'package:dr_on_call/config/AppColors.dart';
import 'package:flutter/material.dart';

import '../../config/AppTextStyle.dart';

class MedicalExpansionTile extends StatelessWidget {
  final String title;
  final String content;
  final bool isRedFlag;
  final bool isRedContent;
  final EdgeInsetsGeometry? contentPadding;

  const MedicalExpansionTile({
    Key? key,
    required this.title,
    required this.content,
    this.isRedFlag = false,
    this.isRedContent = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        title: Text(title,
            style: AppTextStyles.medium.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isRedFlag ? Colors.red : AppColors.txtOrangeColor,
            )),
        textColor: isRedFlag ? Colors.red : AppColors.txtOrangeColor,
        iconColor: isRedFlag ? Colors.grey : Colors.grey,
        collapsedIconColor: isRedFlag ? Colors.red : Colors.yellow,
        children: [
          Padding(
            padding: contentPadding ?? const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Check if content contains bullet points
    if (content.contains('•')) {
      // Split by bullet points and create separate Text widgets
      final parts = content.split('•').where((part) => part.trim().isNotEmpty);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((part) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '• ${part.trim()}',
              style: AppTextStyles.regular.copyWith(
                color: isRedContent ? Colors.black : AppColors.txtWhiteColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.left,
            ),
          );
        }).toList(),
      );
    } else {
      // Regular content without bullet points
      return Text(
        content,
        style: AppTextStyles.regular.copyWith(
          color: isRedContent ? Colors.black : AppColors.txtWhiteColor,
          fontSize: 13,
        ),
        textAlign: TextAlign.left,
      );
    }
  }
}
