import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/locale_service.dart';
import 'app/services/theme_service.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetStorage().erase(); // Cela vide toute la mémoire locale


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Services globaux
  await Get.putAsync(() async => ThemeService());
  await Get.putAsync(() async => LocaleService());

  runApp(const NokiRideApp());
}

class NokiRideApp extends StatelessWidget {
  const NokiRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:                      'NokiRide',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      themeMode:                  ThemeService.to.mode,
      locale:                     LocaleService.to.locale,
      fallbackLocale:             const Locale('fr', 'FR'),
      translations:               AppTranslations(),
      initialRoute:               Routes.splash,
      getPages:                   AppPages.routes,
      defaultTransition:          Transition.cupertino,
    );
  }
}
