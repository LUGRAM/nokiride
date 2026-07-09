import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/locale_service.dart';
import '../../../app/services/theme_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../../../core/storage/app_storage.dart';
import '../model/profile_stats_model.dart';

class ProfileController extends GetxController {
  ProfileController(this._authService);

  final AuthApiService _authService;
  final _box = GetStorage();
  late final RxString userName;
  late final RxString userPhone;
  late final RxString userEmail;
  final Rx<ProfileStatsModel> stats = ProfileStatsModel.empty().obs;
  final RxBool isSavingProfile = false.obs;
  final RxBool isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    userName = (_box.read<String>('user_name') ?? 'Utilisateur').obs;
    userPhone = (_box.read<String>('user_phone') ?? '+241 --').obs;
    userEmail = (_box.read<String>('user_email') ?? '').obs;
    syncProfile();
    loadStats();
  }

  int get totalTrips => stats.value.totalTrips;
  String get totalSpent => stats.value.formattedSpent;
  String get memberSince => stats.value.formattedMemberSince;

  bool get isDark => ThemeService.to.isDark;
  bool get isFrench => LocaleService.to.isFrench;

  void toggleTheme() => ThemeService.to.toggleTheme();
  void toggleLocale() => LocaleService.to.toggleLocale();

  Future<void> syncProfile() async {
    try {
      final data = await _authService.me();
      final user = Map<String, dynamic>.from(data['user'] as Map);
      await AppStorage.saveUser(user);
      userName.value = user['name']?.toString() ?? userName.value;
      userPhone.value = user['phone']?.toString() ?? userPhone.value;
      userEmail.value = user['email']?.toString() ?? userEmail.value;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        Get.offAllNamed(Routes.login);
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    final cleanEmail = email?.trim();

    if (cleanName.isEmpty) {
      Get.snackbar('Profil incomplet', 'Le nom est obligatoire.');
      return;
    }

    if (!RegExp(r'^\+241\d{8}$').hasMatch(cleanPhone)) {
      Get.snackbar('Téléphone invalide', 'Le format attendu est +24177xxxxxx.');
      return;
    }

    isSavingProfile.value = true;
    try {
      final data = await _authService.updateProfile(
        name: cleanName,
        phone: cleanPhone,
        email: cleanEmail == null || cleanEmail.isEmpty ? null : cleanEmail,
      );
      final user = Map<String, dynamic>.from(data['user'] as Map);
      await AppStorage.saveUser(user);
      userName.value = user['name']?.toString() ?? cleanName;
      userPhone.value = user['phone']?.toString() ?? cleanPhone;
      userEmail.value = user['email']?.toString() ?? '';
      Get.back();
      Get.snackbar(
          'Profil mis à jour', 'Vos informations ont été enregistrées.',
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (error) {
      Get.snackbar('Mise à jour impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> loadStats() async {
    isLoadingStats.value = true;
    try {
      final data = await _authService.stats();
      stats.value = ProfileStatsModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        Get.offAllNamed(Routes.login);
      }
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException {
      // La déconnexion locale reste prioritaire.
    }
    await AppStorage.clearAuth();
    Get.offAllNamed(Routes.login);
  }
}
