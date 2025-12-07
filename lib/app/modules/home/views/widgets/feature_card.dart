import 'package:dr_on_call/config/AppTextStyle.dart';
import 'package:flutter/material.dart';
import '../../../../../config/AppColors.dart';

class FeatureCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
        width: 35,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.txtOrangeColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                iconPath,
                width: 40,
                height: 40,
                // color: AppColors.txtOrangeColor,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold
                      .copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
