import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";
  static const String themeKey = "theme_mode";

  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(themeKey, mode.index); // 0 = system, 1 = light, 2 = dark
  }

  static Future<ThemeMode?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(themeKey);
    if (index != null) {
      return ThemeMode.values[index];
    }
    return null;
  }
}
