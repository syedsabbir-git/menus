import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _box = GetStorage();

  final _isDark = false.obs;
  bool get isDark => _isDark.value;

  ThemeMode get themeMode => _isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _isDark.value = _box.read<bool>(StorageKeys.isDarkMode) ?? false;
  }

  void toggleTheme() {
    _isDark.value = !_isDark.value;
    _box.write(StorageKeys.isDarkMode, _isDark.value);
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setDark() {
    if (_isDark.value) return;
    toggleTheme();
  }

  void setLight() {
    if (!_isDark.value) return;
    toggleTheme();
  }
}
