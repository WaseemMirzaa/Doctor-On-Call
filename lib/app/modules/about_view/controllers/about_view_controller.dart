import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_snack_bar.dart';

class AboutViewController extends GetxController {
  final isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Logout user from Firebase and clear local storage
  Future<void> logout() async {
    try {
      isLoggingOut.value = true;

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.clear(); // Clear all stored data

      CustomSnackBar.success("Logged out successfully!");

      // Navigate to onboarding screen and clear navigation stack
      Get.offAllNamed(Routes.ONBOARDINGSCREEN);
    } catch (e) {
      CustomSnackBar.error("Failed to logout. Please try again.");
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Show logout confirmation dialog
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF00132B),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEEC643), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          Obx(() => TextButton(
                onPressed: isLoggingOut.value
                    ? null
                    : () {
                        Get.back(); // Close dialog
                        logout(); // Perform logout
                      },
                child: isLoggingOut.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
