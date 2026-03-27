import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('ko'),
    this.isLoaded = false,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoaded;

  ThemeMode get effectiveThemeMode =>
      AppPreferencesController.enableThemePreview ? themeMode : ThemeMode.dark;
  bool get followsSystem => effectiveThemeMode == ThemeMode.system;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoaded,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class AppPreferencesController extends Notifier<AppPreferencesState> {
  static const _themeKey = 'record.theme_mode';
  static const _languageKey = 'record.language_code';
  static const enableThemePreview = false;

  bool _isLoading = false;

  @override
  AppPreferencesState build() {
    Future<void>.microtask(_load);
    return const AppPreferencesState();
  }

  Future<void> _load() async {
    if (state.isLoaded || _isLoading) {
      return;
    }
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = _themeModeFromString(prefs.getString(_themeKey));
      final locale = Locale(prefs.getString(_languageKey) ?? 'ko');
      if (!ref.mounted) {
        return;
      }
      state = AppPreferencesState(
        themeMode: enableThemePreview ? themeMode : ThemeMode.dark,
        locale: locale,
        isLoaded: true,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = const AppPreferencesState(isLoaded: true);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) {
      return;
    }
    state = state.copyWith(themeMode: mode);
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
    if (state.locale.languageCode == languageCode) {
      return;
    }
    state = state.copyWith(locale: Locale(languageCode));
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

final appPreferencesProvider =
    NotifierProvider<AppPreferencesController, AppPreferencesState>(
      AppPreferencesController.new,
    );
