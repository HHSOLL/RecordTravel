import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesController extends ChangeNotifier {
  static const _themeKey = 'record.theme_mode';
  static const _languageKey = 'record.language_code';
  static const enableThemePreview = false;

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ko');
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  ThemeMode get effectiveThemeMode =>
      enableThemePreview ? _themeMode : ThemeMode.dark;
  Locale get locale => _locale;
  bool get isLoaded => _loaded;
  bool get followsSystem => effectiveThemeMode == ThemeMode.system;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = _themeModeFromString(prefs.getString(_themeKey));
      _locale = Locale(prefs.getString(_languageKey) ?? 'ko');
    } catch (_) {
      _themeMode = ThemeMode.dark;
      _locale = const Locale('ko');
    }
    if (!enableThemePreview) {
      _themeMode = ThemeMode.dark;
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

  Future<void> toggleThemeMode(Brightness effectiveBrightness) async {
    final nextMode = effectiveBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> useSystemTheme() async {
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
