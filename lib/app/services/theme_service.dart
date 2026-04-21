import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service global de gestion du thème.
/// Persisté dans GetStorage — survit aux redémarrages.
///
/// Usage :
///   ThemeService.to.toggleTheme();
///   ThemeService.to.setDark();
///   ThemeService.to.setLight();
///   ThemeService.to.isDark   → bool
class ThemeService extends GetxService {

  static ThemeService get to => Get.find();

  static const _key = 'theme_mode';
  final _box = GetStorage();

  // Valeur réactive
  final _mode = ThemeMode.dark.obs;
  ThemeMode get mode  => _mode.value;
  bool      get isDark => _mode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final saved = _box.read<String>(_key);
    _mode.value = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    _apply();
  }

  void _apply() => Get.changeThemeMode(_mode.value);

  void setDark() {
    _mode.value = ThemeMode.dark;
    _box.write(_key, 'dark');
    _apply();
  }

  void setLight() {
    _mode.value = ThemeMode.light;
    _box.write(_key, 'light');
    _apply();
  }

  void toggleTheme() => isDark ? setLight() : setDark();
}