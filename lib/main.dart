import 'package:dr_on_call/config/AppImages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'app/services/revenuecat_service.dart';
import 'app/services/subscription_manager_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for Samsung devices
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize RevenueCat
    await RevenueCatService.initialize();

    // Initialize trial if needed
    await SubscriptionManagerService.initializeTrialIfNeeded();

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
        debugShowCheckedModeBanner: false,
        title: "Application",
        initialRoute: isLoggedIn ? Routes.HOME : AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  } catch (e, stackTrace) {
    print('Error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Fallback app in case of initialization failure
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('App initialization failed'),
                SizedBox(height: 8),
                Text('Please restart the app'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
