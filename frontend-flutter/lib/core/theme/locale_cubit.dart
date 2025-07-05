import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit() : super(null);

  Future<void> loadLocale() async {
    final prefs = SharedPrefsService.instance;
    final lang = prefs.language ?? 'en';
    emit(Locale(lang));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = SharedPrefsService.instance;
    await prefs.setLanguage(locale.languageCode);
  }

  void clearLocale() => emit(null);
}
