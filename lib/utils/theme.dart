// utils/theme.dart
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

  // tambahan: biar bisa set langsung pas startup
  void setInitialTheme(ThemeMode? mode) {
    if (mode != null) {
      _themeMode = mode;
    }
  }
}

// ===== LIGHT THEME (aksen biru soft) =====
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF90CAF9), // biru soft
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF90CAF9), // aksen biru soft di AppBar
    foregroundColor: Colors.white, // warna teks & icon AppBar
  ),
  useMaterial3: true,
);

// ===== DARK THEME (aksen pink soft) =====
final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFF48FB1), // pink soft
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF48FB1), // aksen pink soft di AppBar
    foregroundColor: Color.fromARGB(
      255,
      117,
      117,
      117,
    ), // teks/icon AppBar lebih kontras
  ),
  useMaterial3: true,
);
