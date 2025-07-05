import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final prefs = SharedPrefsService.instance;
    final themeStr = prefs.theme ?? 'system';
    emit(_themeModeFromString(themeStr));
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = SharedPrefsService.instance;
    await prefs.setTheme(_themeModeToString(mode));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  void setLight() => setTheme(ThemeMode.light);
  void setDark() => setTheme(ThemeMode.dark);
  void setSystem() => setTheme(ThemeMode.system);
}
