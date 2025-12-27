import 'package:dr_on_call/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_snack_bar.dart';

class ForgotviewController extends GetxController {
  //TODO: Implement ForgotviewController

  final emailController = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendResetLink() async {
    final email = emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      CustomSnackBar.warning("Email is required");
      return;
    }

    isLoading.value = true;

    try {
      print("Sending password reset email to: $email");

      // Directly send password reset email without checking sign-in methods
      // as fetchSignInMethodsForEmail is deprecated for security reasons
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      CustomSnackBar.success("Reset email sent.");
      Get.toNamed(Routes.LOGIN);
      emailController.clear();
    } on FirebaseAuthException catch (e) {
      // ✅ Show user-friendly errors
      if (e.code == 'invalid-email') {
        CustomSnackBar.error("The email address is badly formatted.");
      } else {
        CustomSnackBar.error(e.message ?? "Failed to send reset email.");
      }
    } catch (e) {
      CustomSnackBar.error("Something went wrong.");
      print("Reset error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  final count = 0.obs;
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

  void increment() => count.value++;
}
