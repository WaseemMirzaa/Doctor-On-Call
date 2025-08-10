import 'package:dr_on_call/config/AppImages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: Precache image if needed later
  final bindingContext = WidgetsBinding.instance;
  bindingContext.addPostFrameCallback((_) {
    final context = bindingContext.rootElement;
    if (context != null) {
      precacheImage(const AssetImage(AppImages.bg2Copy), context);
    }
  });

  print("App starting...");
  print('FIREBASE APP: ${Firebase.app().options.projectId}');
  print('User isLoggedIn: $isLoggedIn');

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'IBMPlexSans',
      ),
      title: "Application",
      initialRoute: isLoggedIn ? Routes.HOME : AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
