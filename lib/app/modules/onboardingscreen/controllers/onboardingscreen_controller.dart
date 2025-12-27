import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';

class OnboardingscreenController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void increment() => count.value++;

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Future.microtask(() => Get.offAllNamed(Routes.HOME));
    }
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Get.offAllNamed(Routes.HOME);
  }

  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('isLoggedIn');
  //   Get.offAllNamed(Routes.ONBOARDINGSCREEN);
  // }
}
