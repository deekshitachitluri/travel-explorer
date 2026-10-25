import 'package:flutter/material.dart';

import '../data/local/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  late ThemeMode _themeMode;

  ThemeProvider(this._storage) {
    _themeMode = _storage.getThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _storage.saveThemeMode(_themeMode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(_themeMode);
    notifyListeners();
  }
}
