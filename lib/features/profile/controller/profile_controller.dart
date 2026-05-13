import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/locale_service.dart';
import '../../../app/services/theme_service.dart';

class ProfileController extends GetxController {
  final _box = GetStorage();
  late final RxString userName;
  late final RxString userPhone;

  @override
  void onInit() {
    super.onInit();
    userName  = (_box.read<String>('user_name')  ?? 'Utilisateur').obs;
    userPhone = (_box.read<String>('user_phone') ?? '+241 --').obs;
  }

  // Mock stats — à remplacer par des données réelles
  final int totalTrips    = 12;
  final String totalSpent = '45 000 F';
  final String memberSince = 'Jan. 2025';

  bool get isDark => ThemeService.to.isDark;
  bool get isFrench => LocaleService.to.isFrench;

  void toggleTheme() => ThemeService.to.toggleTheme();
  void toggleLocale() => LocaleService.to.toggleLocale();

  void logout() {
    _box.remove('auth_token');
    Get.offAllNamed(Routes.login);
  }
}
