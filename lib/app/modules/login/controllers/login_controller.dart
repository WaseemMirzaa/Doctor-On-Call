import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/custom_snack_bar.dart';
import '../../../services/revenuecat_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      CustomSnackBar.warning("Email and Password is required");
      return;
    }
    if (email.isEmpty) {
      CustomSnackBar.warning("Email is required");
      return;
    }
    if (password.isEmpty) {
      CustomSnackBar.warning("Password is required");
      return;
    }

    isLoading.value = true;

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Set isLoggedIn flag in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // ✅ Link RevenueCat user ID with Firebase UID
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await RevenueCatService.setUserId(uid);
      }

      CustomSnackBar.success("Logged in successfully!");
      emailController.clear();
      passwordController.clear();
      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is badly formatted.";
          break;
        case 'user-disabled':
          errorMessage = "This user has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many login attempts. Please try again later.";
          break;
        default:
          errorMessage = "Login failed. Please check your credentials.";
      }

      CustomSnackBar.error(errorMessage);
    } catch (e) {
      CustomSnackBar.error("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
}
