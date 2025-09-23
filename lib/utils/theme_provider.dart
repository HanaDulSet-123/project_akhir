import 'package:flutter/material.dart';
import 'package:tugas_ujk/shared_preferenced/shared_preferenced.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await PreferenceHandler.getThemeMode();
    if (savedTheme != null) {
      _themeMode = savedTheme;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    PreferenceHandler.saveThemeMode(mode);
    notifyListeners();
  }
}
