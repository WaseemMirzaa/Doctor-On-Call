import 'package:dr_on_call/config/AppImages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Precache the background image before launching the app
  final bindingContext = WidgetsBinding.instance;
  bindingContext.addPostFrameCallback((_) {
    final context = bindingContext.renderViewElement;
    if (context != null) {
      precacheImage(const AssetImage(AppImages.bg2Copy), context);
    }
  });

  print("App starting...");
  print('FIREBASE APP: ${Firebase.app().options.projectId}');

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'IBMPlexSans',
      ),
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
