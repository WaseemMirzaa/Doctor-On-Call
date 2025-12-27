import 'package:dr_on_call/config/AppColors.dart';
import 'package:flutter/material.dart';
import '../../config/AppIcons.dart';

class BackIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const BackIconButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          height: 65,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 5),
            child: Image.asset(
              AppIcons.back,
              width: 15,
              color: AppColors.txtWhiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
