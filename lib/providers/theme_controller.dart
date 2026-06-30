import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/intelligence_design_system.dart';

/// Owns the active light/dark mode. Swaps [AppColors] and persists the choice.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode_dark';
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Load the saved preference (call once at startup before runApp).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_key) ?? false;
    } catch (_) {
      _isDark = false;
    }
    AppColors.applyMode(_isDark);
  }

  Future<void> toggle() => setDark(!_isDark);

  Future<void> setDark(bool dark) async {
    if (_isDark == dark) return;
    _isDark = dark;
    AppColors.applyMode(dark);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, dark);
    } catch (_) {
      // Non-fatal: preference simply won't persist.
    }
  }
}
