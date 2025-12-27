import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      snackPosition: position,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message) {
    show(title: "Success", message: message, backgroundColor: Colors.green);
  }

  static void error(String message) {
    show(title: "Error", message: message, backgroundColor: Colors.redAccent);
  }

  static void warning(String message) {
    show(title: "Warning", message: message, backgroundColor: Colors.orange);
  }
}
