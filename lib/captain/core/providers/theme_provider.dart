import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(StorageService()),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storageService;

  ThemeModeNotifier(this._storageService) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final saved = await _storageService.getThemeMode();
    if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveThemeMode(isDark ? 'dark' : 'light');
  }
}
