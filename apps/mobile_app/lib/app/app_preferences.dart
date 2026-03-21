import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesController extends ChangeNotifier {
  static const _themeKey = 'record.theme_mode';
  static const _languageKey = 'record.language_code';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ko');
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = _themeModeFromString(prefs.getString(_themeKey));
      _locale = Locale(prefs.getString(_languageKey) ?? 'ko');
      if (_themeMode != ThemeMode.system) {
        _themeMode = ThemeMode.system;
        await prefs.setString(_themeKey, ThemeMode.system.name);
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
      _locale = const Locale('ko');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _persistString(_themeKey, mode.name);
  }

  Future<void> toggleThemeMode() async {
    await setThemeMode(ThemeMode.system);
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    await _persistString(_languageKey, languageCode);
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _persistString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      // Ignore storage failures in preview mode and keep the in-memory setting.
    }
  }
}

final appPreferencesProvider = ChangeNotifierProvider<AppPreferencesController>(
  (ref) {
    final controller = AppPreferencesController();
    controller.load();
    return controller;
  },
);
