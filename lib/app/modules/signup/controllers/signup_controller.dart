import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/revenuecat_service.dart';
import '../../../widgets/custom_snack_bar.dart';

class SignupController extends GetxController {
  //TODO: Implement SignupController

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  var isChecked = false.obs;

  void signUp() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      CustomSnackBar.warning("Email is required");
      return;
    }

    if (username.isEmpty) {
      CustomSnackBar.warning("Username is required");
      return;
    }

    if (phone.isEmpty) {
      CustomSnackBar.warning("Phone is required");
      return;
    }

    if (password.isEmpty) {
      CustomSnackBar.warning("Password is required");
      return;
    }

    isLoading.value = true;

    try {
      // ✅ Step 1: Create user in Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception("User UID is null.");
      }

      // ✅ Step 2: Save user to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Step 3: Link RevenueCat user ID (handles subscription sync)
      await RevenueCatService.setUserId(uid);

      // // ✅ Step 4: Sign out AFTER saving
      // await FirebaseAuth.instance.signOut();

      CustomSnackBar.success("Account created. Please log in.");
      Get.toNamed(Routes.LOGIN);

      emailController.clear();
      passwordController.clear();
      phoneController.clear();
      usernameController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is badly formatted.";
          break;
        case 'weak-password':
          errorMessage = "The password is too weak.";
          break;
        default:
          errorMessage = "Sign up failed. Please try again.";
      }

      CustomSnackBar.error(errorMessage);
    } catch (e) {
      CustomSnackBar.error("Something went wrong. Please try again.");
      // good for debugging
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
