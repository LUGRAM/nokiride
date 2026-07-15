import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/locale_service.dart';
import 'app/services/theme_service.dart';
import 'app/theme/app_theme.dart';
import 'core/location/background_location_service.dart';
import 'features/driver/trip_mgt/service/driver_socket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await GetStorage.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Services globaux
  await Get.putAsync(() async => ThemeService());
  await Get.putAsync(() async => LocaleService());
  final locationService = Get.put(BackgroundLocationService(), permanent: true);
  await locationService.initService();
  Get.put(DriverSocketService(), permanent: true);

  runApp(const NokiRideApp());
}

class NokiRideApp extends StatelessWidget {
  const NokiRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NokiRide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.to.mode,
      locale: LocaleService.to.locale,
      fallbackLocale: const Locale('fr', 'FR'),
      translations: AppTranslations(),
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
