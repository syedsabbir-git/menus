import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _box = GetStorage();
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _isDark = _box.read<bool>(StorageKeys.isDarkMode) ?? false;
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _box.write(StorageKeys.isDarkMode, _isDark);
    Get.changeThemeMode(_isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
