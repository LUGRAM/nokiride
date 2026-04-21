import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/app_config.dart';

/// Couche de stockage unifiée.
/// - Tokens → SharedPreferences (prototype; en prod utiliser flutter_secure_storage)
/// - Prefs légères → Hive
///
class AppStorage {
  AppStorage._();
  static final AppStorage _i = AppStorage._();
  static AppStorage get instance => _i;

  late SharedPreferences _prefs;
  late Box _hive;

  // ── Init ─────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    _hive  = await Hive.openBox('prefs');
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Token ─────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _prefs.setString(AppConfig.kToken, token);

  String? getToken() => _prefs.getString(AppConfig.kToken);

  Future<void> saveRefreshToken(String token) =>
      _prefs.setString(AppConfig.kRefreshToken, token);

  String? getRefreshToken() => _prefs.getString(AppConfig.kRefreshToken);

  Future<void> clearTokens() async {
    await _prefs.remove(AppConfig.kToken);
    await _prefs.remove(AppConfig.kRefreshToken);
  }

  // ── Hive prefs ────────────────────────────────────────
  Future<void> put(String key, dynamic value) => _hive.put(key, value);

  T? get<T>(String key, {T? defaultValue}) =>
      _hive.get(key, defaultValue: defaultValue) as T?;

  Future<void> remove(String key) => _hive.delete(key);

  // ── Helpers ───────────────────────────────────────────
  bool get isOnboardingDone => get<bool>(AppConfig.kOnboarding) ?? false;
  Future<void> setOnboardingDone() => put(AppConfig.kOnboarding, true);

  Future<void> saveUserJson(String json) => put(AppConfig.kUser, json);
  String? get userJson => get<String>(AppConfig.kUser);

  // ── Clear all ─────────────────────────────────────────
  Future<void> clearAll() async {
    await clearTokens();
    await _hive.clear();
  }
}