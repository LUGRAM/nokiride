import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/theme_service.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Enregistre ThemeService AVANT runApp
  await Get.putAsync(() async => ThemeService());

  runApp(const NokiRideApp());
}

class NokiRideApp extends StatelessWidget {
  const NokiRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:                      'NokiRide',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.light,   // Light-Green
      darkTheme:                  AppTheme.dark,    // Blue-Dark
      themeMode:                  ThemeService.to.mode, // ← persisté
      initialRoute:               Routes.splash,
      getPages:                   AppPages.pages,
    );
  }
}