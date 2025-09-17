import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/AppTextStyle.dart';
import 'back_icon_button.dart';

class CommonTitleSection extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onBackTap;
  final bool spacing;

  const CommonTitleSection({
    super.key,
    required this.title,
    this.description,
    this.onBackTap,
    this.spacing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BackIconButton(
          onTap: onBackTap ?? () => Get.back(),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bold.copyWith(fontSize: 25),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            textAlign: TextAlign.start,
            style: AppTextStyles.regular.copyWith(fontSize: 14),
          ),
          if (spacing) const SizedBox(height: 100),
        ],
      ],
    );
  }
}
